import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/ota_reply_parser.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../services/esp32_ota_uploader.dart';
import '../services/firmware_release_service.dart';
import '../services/nrf_dfu_service.dart';
import '../services/repeater_command_service.dart';
import '../theme/app_colors.dart';
import '../utils/dialog_utils.dart';

enum _OtaStep { detect, firmware, download, flash, verify }

enum _StepStatus { pending, active, done, failed }

class RepeaterOtaWizardScreen extends StatefulWidget {
  final Contact repeater;
  final String password;

  const RepeaterOtaWizardScreen({
    super.key,
    required this.repeater,
    required this.password,
  });

  @override
  State<RepeaterOtaWizardScreen> createState() =>
      _RepeaterOtaWizardScreenState();
}

class _RepeaterOtaWizardScreenState extends State<RepeaterOtaWizardScreen> {
  late MeshCoreConnector _connector;
  late RepeaterCommandService _commandService;
  StreamSubscription<Uint8List>? _frameSubscription;

  final _releaseService = FirmwareReleaseService();
  final _esp32Uploader = Esp32OtaUploader();
  final _nrfDfu = NrfDfuService();

  bool _started = false;
  bool _pipelineRunning = false;
  bool _awaitingBoardSelection = false;
  bool _localFirmwareRequested = false;
  bool _pickingFirmware = false;
  final Map<_OtaStep, _StepStatus> _stepStatus = {
    for (final step in _OtaStep.values) step: _StepStatus.pending,
  };
  String? _errorMessage;
  final List<String> _debugLog = [];

  // Detect results
  OtaVersionInfo? _currentVersion;
  String? _boardReply;
  String? _bootloaderReply;
  List<FirmwareRelease> _releases = [];
  bool _loadingReleases = true;
  FirmwareRelease? _release;
  FirmwareAsset? _selectedAsset;
  bool _boardAutoDetected = false;

  // Download results
  File? _firmwareFile;
  String? _firmwareMd5;
  double _downloadProgress = 0;
  bool _usingLocalFirmware = false;

  // Flash state
  StartOtaResult? _startOtaResult;
  bool _otaModeEntered = false;
  bool _wifiJoined = false;
  double _flashProgress = 0;
  bool _flashBusy = false;
  bool _flashDone = false;
  bool _rebootingAfterUpload = false;

  // Verify state
  bool _verifyBusy = false;
  String? _verifiedVersion;
  bool _clockSynced = false;

  bool _isCancelled = false;
  bool get _isAlive => mounted && !_isCancelled;

  @override
  void initState() {
    super.initState();
    _connector = Provider.of<MeshCoreConnector>(context, listen: false);
    _commandService = RepeaterCommandService(_connector);
    _frameSubscription = _connector.receivedFrames.listen(_onFrame);
    _prefetchReleases();
  }

  Future<void> _prefetchReleases() async {
    try {
      final releases = await _releaseService.fetchReleases(
        roomServer: _isRoomServer,
      );
      if (!mounted) return;
      setState(() {
        _releases = releases;
        _release = releases.isNotEmpty ? releases.first : null;
        _loadingReleases = false;
      });
    } catch (e) {
      _log('Could not prefetch releases: $e');
      if (mounted) setState(() => _loadingReleases = false);
    }
  }

  @override
  void dispose() {
    _isCancelled = true;
    unawaited(WakelockPlus.disable());
    _frameSubscription?.cancel();
    _commandService.dispose();
    super.dispose();
  }

  Future<void> _setKeepScreenOn(bool enabled) async {
    if (enabled) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }

  void _onFrame(Uint8List frame) {
    if (frame.isEmpty) return;
    if (frame[0] == respCodeContactMsgRecv ||
        frame[0] == respCodeContactMsgRecvV3) {
      final parsed = parseContactMessageText(frame);
      if (parsed == null) return;
      if (!_matchesRepeaterPrefix(parsed.senderPrefix)) return;
      _commandService.handleResponse(widget.repeater, parsed.text);
    }
  }

  bool _matchesRepeaterPrefix(Uint8List prefix) {
    final target = widget.repeater.publicKey;
    if (target.length < 6 || prefix.length < 6) return false;
    for (int i = 0; i < 6; i++) {
      if (prefix[i] != target[i]) return false;
    }
    return true;
  }

  Contact get _repeater {
    return _connector.contacts.firstWhere(
      (c) => c.publicKeyHex == widget.repeater.publicKeyHex,
      orElse: () => widget.repeater,
    );
  }

  void _log(String message) {
    final now = DateTime.now();
    final stamp =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    debugPrint('[OTA] $message');
    if (!mounted) return;
    setState(() => _debugLog.add('$stamp $message'));
  }

  void _setStep(_OtaStep step, _StepStatus status) {
    if (!mounted) return;
    setState(() {
      _stepStatus[step] = status;
      if (status != _StepStatus.failed) _errorMessage = null;
    });
  }

  void _fail(_OtaStep step, Object error) {
    _log('ERROR: $error');
    unawaited(_setKeepScreenOn(false));
    if (!mounted) return;
    setState(() {
      _stepStatus[step] = _StepStatus.failed;
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    });
  }

  Future<String> _sendCommand(String command, {int retries = 3}) async {
    _log('CLI > $command');
    final response = await _commandService.sendCommand(
      _repeater,
      command,
      retries: retries,
    );
    _log('CLI < $response');
    return response;
  }

  bool get _isRoomServer => widget.repeater.type == advTypeRoom;

  // ---------------------------------------------------------------- detect

  Future<void> _runDetect() async {
    setState(() => _started = true);
    await _setKeepScreenOn(true);
    _setStep(_OtaStep.detect, _StepStatus.active);
    try {
      if (_releases.isEmpty && !_localFirmwareRequested) {
        _log('Fetching firmware releases from GitHub');
        _releases = await _releaseService.fetchReleases(
          roomServer: _isRoomServer,
        );
        _release ??= _releases.isNotEmpty ? _releases.first : null;
      }
      final release = _release;
      if (release == null && !_localFirmwareRequested) {
        throw Exception('No firmware releases found');
      }
      if (release != null) {
        _log(
          'Target release: ${release.tag} (${release.assets.length} '
          'OTA-capable boards)',
        );
      }

      final verReply = await _sendCommand('ver');
      _currentVersion = parseVerReply(verReply);
      if (_currentVersion == null) {
        _log('Could not parse version from reply');
      }

      final boardReply = await _sendCommand('board');
      _boardReply = boardReply.trim();
      if (_localFirmwareRequested || release == null) {
        _log('Custom firmware file requested - skipping release asset match');
      } else {
        final matched = FirmwareReleaseService.matchBoardName(
          _boardReply!,
          release.assets,
        );
        _boardAutoDetected = matched != null;
        if (matched != null) {
          _selectedAsset = release.assets.firstWhere(
            (a) => a.boardId == matched,
          );
          _log('Matched board "$_boardReply" -> ${_selectedAsset!.fileName}');
        } else {
          _log(
            'No confident board match for "$_boardReply" - '
            'manual selection required',
          );
        }
      }

      if (_selectedAsset?.chip == OtaChipFamily.nrf52) {
        await _checkBootloader();
      }

      _setStep(_OtaStep.detect, _StepStatus.done);
      _setStep(_OtaStep.firmware, _StepStatus.active);
      await _continueAfterFirmwareSelection();
    } catch (e) {
      _fail(_OtaStep.detect, e);
    }
  }

  Future<void> _continueAfterFirmwareSelection() async {
    if (_selectedAsset == null) {
      setState(() => _awaitingBoardSelection = true);
      _log('Waiting for board selection');
      return;
    }
    setState(() => _awaitingBoardSelection = false);
    if (_pipelineRunning) return;
    _pipelineRunning = true;
    try {
      await _runDownload();
      if (_stepStatus[_OtaStep.download] == _StepStatus.done) {
        await _runFlashPipeline();
      }
    } finally {
      _pipelineRunning = false;
    }
  }

  Future<void> _pickLocalFirmware(OtaChipFamily chip) async {
    // Guard against a second tap re-entering this method (and clobbering
    // _firmwareFile/_firmwareMd5) while an earlier pick is still awaiting
    // the confirmation dialog, bootloader check, or pipeline kickoff below.
    if (_pickingFirmware || _pipelineRunning) return;
    _pickingFirmware = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [chip == OtaChipFamily.esp32 ? 'bin' : 'zip'],
      );
      final picked = result?.files.firstOrNull;
      final path = picked?.path;
      if (picked == null || path == null || !mounted) return;

      final confirmed = await showLocalFirmwareWarningDialog(context);
      if (!confirmed || !mounted) return;

      setState(() {
        _localFirmwareRequested = true;
        _usingLocalFirmware = true;
        _boardAutoDetected = true;
        _awaitingBoardSelection = false;
        _selectedAsset = FirmwareAsset(
          boardId: picked.name,
          chip: chip,
          fileName: picked.name,
          downloadUrl: '',
          sizeBytes: picked.size,
        );
        _firmwareFile = File(path);
      });
      if (chip == OtaChipFamily.nrf52 && _bootloaderReply == null) {
        await _checkBootloader();
      }
      if (!mounted) return;
      await _continueAfterFirmwareSelection();
    } finally {
      _pickingFirmware = false;
    }
  }

  Future<void> _checkBootloader() async {
    try {
      _bootloaderReply = await _sendCommand('get bootloader.ver', retries: 1);
    } catch (e) {
      _log('Bootloader version check failed (older firmware?): $e');
      _bootloaderReply = null;
    }
  }

  bool get _missingOtaFix {
    if (_selectedAsset?.chip != OtaChipFamily.nrf52) return false;
    final reply = _bootloaderReply;
    if (reply == null) return true; // unknown - warn anyway
    return !bootloaderHasOtaFix(reply);
  }

  bool get _alreadyUpToDate {
    final current = _currentVersion?.version;
    final target = _release?.version;
    if (current == null || target == null) return false;
    return compareVersions(current, target) >= 0;
  }

  bool get _isDowngrade {
    final current = _currentVersion?.version;
    final target = _release?.version;
    if (current == null || target == null) return false;
    return compareVersions(target, current) < 0;
  }

  // -------------------------------------------------------------- download

  Future<void> _runDownload() async {
    final asset = _selectedAsset;
    if (asset == null) return;
    _setStep(_OtaStep.firmware, _StepStatus.done);
    _setStep(_OtaStep.download, _StepStatus.active);
    if (_usingLocalFirmware && _firmwareFile != null) {
      final file = _firmwareFile!;
      try {
        setState(() => _downloadProgress = 1);
        _log('Using local firmware file: ${file.path}');
        _firmwareMd5 = await FirmwareReleaseService.md5OfFile(file);
        if (!_isAlive) return;
        _setStep(_OtaStep.download, _StepStatus.done);
        _setStep(_OtaStep.flash, _StepStatus.active);
      } catch (e) {
        if (!_isAlive) return;
        _fail(_OtaStep.download, e);
      }
      return;
    }
    setState(() => _downloadProgress = 0);
    try {
      _log('Downloading ${asset.fileName} (${asset.sizeBytes} bytes)');
      final file = await _releaseService.downloadAsset(
        asset,
        onProgress: (received, total) {
          if (total <= 0) return;
          final progress = received / total;
          if ((progress - _downloadProgress).abs() > 0.01 || progress >= 1) {
            if (_isAlive) setState(() => _downloadProgress = progress);
          }
        },
      );
      if (!_isAlive) return;
      _firmwareFile = file;
      _firmwareMd5 = await FirmwareReleaseService.md5OfFile(file);
      if (!_isAlive) return;
      _log('Downloaded to ${file.path}, MD5 $_firmwareMd5');
      _setStep(_OtaStep.download, _StepStatus.done);
      _setStep(_OtaStep.flash, _StepStatus.active);
    } catch (e) {
      if (!_isAlive) return;
      _fail(_OtaStep.download, e);
    }
  }

  // ----------------------------------------------------------------- flash

  Future<void> _runFlashPipeline() async {
    if (!_isAlive || _firmwareFile == null) return;
    setState(() => _flashBusy = true);
    try {
      await _enterOtaMode();
      if (!_isAlive) return;
      if (_selectedAsset!.chip == OtaChipFamily.esp32) {
        await _joinOtaWifi();
        if (!_isAlive) return;
        await _uploadEsp32Firmware();
      } else {
        await _transferNrfFirmware();
      }
      if (!_isAlive) return;
      _finishFlash();
    } catch (e) {
      if (!_isAlive) return;
      _fail(_OtaStep.flash, e);
      return;
    } finally {
      if (_isAlive) setState(() => _flashBusy = false);
    }
    if (!_isAlive) return;
    await _runVerify();
  }

  Future<void> _enterOtaMode() async {
    final reply = await _sendCommand('start ota', retries: 1);
    if (!_isAlive) return;
    final result = parseStartOtaReply(reply);
    if (result == null) {
      throw Exception('Unexpected start ota reply: $reply');
    }
    final expectEsp = _selectedAsset!.chip == OtaChipFamily.esp32;
    if (result.isEsp32 != expectEsp) {
      throw Exception(
        'Device entered ${result.isEsp32 ? 'WiFi' : 'BLE DFU'} OTA mode but '
        '${expectEsp ? 'an ESP32 .bin' : 'an nRF52 .zip'} was selected. '
        'Wrong board selected?',
      );
    }
    _startOtaResult = result;
    setState(() => _otaModeEntered = true);
  }

  Future<void> _joinOtaWifi() async {
    _log('Requesting WiFi join: ${Esp32OtaUploader.otaSsid}');
    final joined = await _esp32Uploader.joinOtaWifi();
    if (!_isAlive) return;
    _log(joined ? 'WiFi joined' : 'WiFi join failed or was declined');
    final url = _startOtaResult!.updateUrl!;
    final reachable = await _esp32Uploader.probe(url, onLog: _log);
    if (!_isAlive) return;
    setState(() => _wifiJoined = reachable);
    if (!reachable) {
      throw Exception(
        'OTA web server not reachable. Join the "MeshCore-OTA" network in '
        'your phone\'s WiFi settings, then retry.',
      );
    }
  }

  Future<void> _uploadEsp32Firmware() async {
    setState(() {
      _flashProgress = 0;
      _rebootingAfterUpload = false;
    });
    try {
      await _esp32Uploader.upload(
        updateUrl: _startOtaResult!.updateUrl!,
        firmware: _firmwareFile!,
        md5Hex: _firmwareMd5!,
        onProgress: (sent, total) {
          final progress = sent / total;
          if ((progress - _flashProgress).abs() > 0.01 || progress >= 1) {
            if (!_isAlive) return;
            setState(() {
              _flashProgress = progress;
              if (progress >= 1) _rebootingAfterUpload = true;
            });
          }
        },
        onLog: _log,
      );
    } catch (e) {
      if (_flashProgress < 0.99) rethrow;
      _log('Upload reached 100%; treating disconnect as reboot: $e');
      if (_isAlive) setState(() => _rebootingAfterUpload = true);
    }
    try {
      await _esp32Uploader.leaveOtaWifi();
    } on Exception catch (e) {
      _log('Leave WiFi skipped (expected after reboot): $e');
    }
  }

  Future<void> _transferNrfFirmware() async {
    setState(() => _flashProgress = 0);
    final String target;
    try {
      final resolved = await _nrfDfu.resolveTarget(
        macFromReply: _startOtaResult?.dfuMac,
        onLog: _log,
      );
      if (resolved == null) {
        throw Exception(
          'No DFU device found nearby. Move closer to the repeater and retry.',
        );
      }
      target = resolved;
    } on AmbiguousDfuTargetException catch (e) {
      throw Exception(
        'Multiple DFU devices found nearby (${e.candidates.map((c) => c.name).join(', ')}). '
        'Turn off other OTA/DFU devices and retry.',
      );
    }
    await _nrfDfu.startDfu(
      address: target,
      zipPath: _firmwareFile!.path,
      onProgress: (percent) {
        if (_isAlive) setState(() => _flashProgress = percent / 100);
      },
      onLog: _log,
    );
  }

  void _finishFlash() {
    setState(() => _flashDone = true);
    _setStep(_OtaStep.flash, _StepStatus.done);
    _setStep(_OtaStep.verify, _StepStatus.active);
    _log('Firmware transfer complete, device is rebooting');
  }

  // ---------------------------------------------------------------- verify

  bool _verifyVersionSuccess(OtaVersionInfo version) {
    if (_usingLocalFirmware) {
      // A custom local file has no known target version to compare
      // against, so the best available signal is that the device is
      // reachable again and its version differs from before the flash.
      final before = _currentVersion?.version;
      if (before == null) {
        _log(
          'Could not compare against the pre-flash version; treating a '
          'reachable, parseable post-flash reply as success',
        );
        return true;
      }
      final changed = compareVersions(version.version, before) != 0;
      if (!changed) {
        _log(
          'Device still reports pre-flash version ($before) - update may '
          'not have applied yet',
        );
      }
      return changed;
    }
    // compareVersions() already parses out the vX.Y.Z numeric triple, so
    // it tolerates build-hash/whitespace differences on its own - there is
    // no safe looser fallback here: any other reply means the device isn't
    // running the intended release yet.
    final target = _release?.version;
    return target != null && compareVersions(version.version, target) == 0;
  }

  Future<void> _runVerify() async {
    setState(() => _verifyBusy = true);
    try {
      const initialWaitSec = 15;
      const retryWaitSec = 10;
      const maxAttempts = 8;

      _log(
        'Upload complete — device is rebooting. '
        'Waiting ${initialWaitSec}s before checking version over LoRa',
      );
      await Future<void>.delayed(const Duration(seconds: initialWaitSec));
      if (!_isAlive) return;

      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        if (!_isAlive) return;
        if (attempt > 0) {
          _log(
            'Still waiting for device — retry in ${retryWaitSec}s '
            '(attempt ${attempt + 1}/$maxAttempts)',
          );
          await Future<void>.delayed(const Duration(seconds: retryWaitSec));
          if (!_isAlive) return;
        }

        _log('Logging back in over LoRa');
        if (!await _relogin()) {
          _log('Login attempt ${attempt + 1} timed out');
          continue;
        }
        if (!_isAlive) return;

        try {
          final verReply = await _sendCommand('ver', retries: 1);
          if (!_isAlive) return;
          final version = parseVerReply(verReply);
          if (version == null) {
            _log('Could not parse version: $verReply');
            continue;
          }
          if (!_verifyVersionSuccess(version)) {
            _log(
              'Device reports ${version.raw}; '
              'expected ${_release?.version ?? "update"} — retrying',
            );
            continue;
          }
          if (!_isAlive) return;
          setState(() => _verifiedVersion = version.raw);
          _setStep(_OtaStep.verify, _StepStatus.done);
          _log('Update verified over LoRa: ${version.raw}');
          await _syncClock();
          await _setKeepScreenOn(false);
          return;
        } catch (e) {
          _log('Verify attempt ${attempt + 1} failed: $e');
        }
      }
      throw Exception(
        'Could not verify the update over the mesh yet. The device may still '
        'be rebooting — wait a minute and tap Retry.',
      );
    } catch (e) {
      if (!_isAlive) return;
      _fail(_OtaStep.verify, e);
    } finally {
      if (_isAlive) setState(() => _verifyBusy = false);
    }
  }

  Future<bool> _relogin() async {
    final repeater = _repeater;
    final selection = await _connector.preparePathForContactSend(repeater);
    final frame = buildSendLoginFrame(repeater.publicKey, widget.password);
    final pathLengthValue = selection.useFlood ? -1 : selection.hopCount;
    final timeoutMs = _connector.calculateTimeout(
      pathLength: pathLengthValue,
      messageBytes: maxFrameSize,
    );
    for (var attempt = 0; attempt < 2; attempt++) {
      await _connector.sendFrame(frame);
      final result = await _awaitLoginResponse(
        Duration(milliseconds: timeoutMs),
      );
      if (result == true) return true;
      if (result == false) return false;
    }
    return false;
  }

  Future<bool?> _awaitLoginResponse(Duration timeout) async {
    final completer = Completer<bool?>();
    final targetPrefix = widget.repeater.publicKey.sublist(0, 6);
    StreamSubscription<Uint8List>? subscription;
    subscription = _connector.receivedFrames.listen((frame) {
      if (frame.isEmpty) return;
      final code = frame[0];
      if (code != pushCodeLoginSuccess && code != pushCodeLoginFail) return;
      if (frame.length < 8) return;
      if (!listEquals(frame.sublist(2, 8), targetPrefix)) return;
      if (!completer.isCompleted) {
        completer.complete(code == pushCodeLoginSuccess);
      }
    });
    final result = await completer.future.timeout(
      timeout,
      onTimeout: () => null,
    );
    await subscription.cancel();
    return result;
  }

  Future<void> _syncClock() async {
    try {
      await _sendCommand('clock sync');
      if (!_isAlive) return;
      setState(() => _clockSynced = true);
    } catch (e) {
      _log('Clock sync failed: $e');
    }
  }

  Future<void> _sendReboot() async {
    try {
      await _sendCommand('reboot', retries: 1);
    } catch (e) {
      // Reboot rarely replies; that is expected.
      _log('No reboot reply (device likely rebooting): $e');
    }
  }

  void _retryCurrentStep() {
    final failed = _stepStatus.entries
        .where((e) => e.value == _StepStatus.failed)
        .map((e) => e.key)
        .toList();
    if (failed.isEmpty) return;
    final step = failed.first;
    _setStep(step, _StepStatus.active);
    switch (step) {
      case _OtaStep.detect:
        _runDetect();
      case _OtaStep.firmware:
        _continueAfterFirmwareSelection();
      case _OtaStep.download:
        _continueAfterFirmwareSelection();
      case _OtaStep.flash:
        _runFlashPipeline();
      case _OtaStep.verify:
        _runVerify();
    }
  }

  // ------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.ota_title),
            Text(
              widget.repeater.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!_started) _buildIntroCard(l10n) else ..._buildSteps(l10n),
            if (_errorMessage != null) _buildErrorCard(l10n),
            const SizedBox(height: 16),
            _buildDebugLog(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.system_update, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.ota_introTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.ota_introBody),
            const SizedBox(height: 12),
            _infoRow(Icons.wifi, l10n.ota_introInternet),
            _infoRow(Icons.near_me, l10n.ota_introProximity),
            _infoRow(Icons.power, l10n.ota_introPower),
            const SizedBox(height: 16),
            if (_loadingReleases) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                l10n.ota_loadingVersions,
                style: const TextStyle(fontSize: 13),
              ),
            ] else if (_releases.isNotEmpty) ...[
              DropdownButtonFormField<FirmwareRelease>(
                initialValue: _release,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.ota_targetVersion,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  for (var i = 0; i < _releases.length; i++)
                    DropdownMenuItem(
                      value: _releases[i],
                      child: Text(
                        i == 0
                            ? '${_releases[i].version} (${l10n.ota_latestLabel})'
                            : _releases[i].version,
                      ),
                    ),
                ],
                onChanged: (release) => setState(() => _release = release),
              ),
              const SizedBox(height: 8),
            ],
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              value: _localFirmwareRequested,
              onChanged: (value) =>
                  setState(() => _localFirmwareRequested = value ?? false),
              title: Text(
                l10n.ota_useLocalFirmwareToggle,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    _loadingReleases ||
                        (_release == null && !_localFirmwareRequested)
                    ? null
                    : _runDetect,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.ota_start),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  List<Widget> _buildSteps(AppLocalizations l10n) {
    return [
      _buildStepCard(
        l10n,
        step: _OtaStep.detect,
        title: l10n.ota_stepDetect,
        body: _buildDetectBody(l10n),
      ),
      _buildStepCard(
        l10n,
        step: _OtaStep.firmware,
        title: l10n.ota_stepFirmware,
        body: _buildFirmwareBody(l10n),
      ),
      _buildStepCard(
        l10n,
        step: _OtaStep.download,
        title: l10n.ota_stepDownload,
        body: _buildDownloadBody(l10n),
      ),
      _buildStepCard(
        l10n,
        step: _OtaStep.flash,
        title: l10n.ota_stepFlash,
        body: _buildFlashBody(l10n),
      ),
      _buildStepCard(
        l10n,
        step: _OtaStep.verify,
        title: l10n.ota_stepVerify,
        body: _buildVerifyBody(l10n),
      ),
    ];
  }

  Widget _buildStepCard(
    AppLocalizations l10n, {
    required _OtaStep step,
    required String title,
    required Widget? body,
  }) {
    final status = _stepStatus[step]!;
    final theme = Theme.of(context);
    final Widget leading;
    switch (status) {
      case _StepStatus.pending:
        leading = Icon(Icons.circle_outlined, color: theme.colorScheme.outline);
      case _StepStatus.active:
        leading = const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        );
      case _StepStatus.done:
        leading = Icon(Icons.check_circle, color: context.appColors.connected);
      case _StepStatus.failed:
        leading = Icon(Icons.error, color: theme.colorScheme.error);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (status != _StepStatus.pending && body != null) ...[
              const SizedBox(height: 12),
              body,
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildDetectBody(AppLocalizations l10n) {
    if (_currentVersion == null && _boardReply == null) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentVersion != null)
          Text(l10n.ota_currentVersion(_currentVersion!.raw)),
        if (_boardReply != null) Text(l10n.ota_detectedBoard(_boardReply!)),
      ],
    );
  }

  Widget? _buildFirmwareBody(AppLocalizations l10n) {
    final release = _release;
    if (release == null && !_localFirmwareRequested) return null;
    final firmwareSelected = _selectedAsset != null;
    final downloadDone = _stepStatus[_OtaStep.firmware] == _StepStatus.done;
    final showLocalOption =
        !downloadDone &&
        !_usingLocalFirmware &&
        (_localFirmwareRequested || _awaitingBoardSelection);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (release != null && !_localFirmwareRequested) ...[
          Text(l10n.ota_targetVersionLabel(release.version)),
          const SizedBox(height: 8),
          if (_isDowngrade) ...[
            Text(
              l10n.ota_downgradeWarning,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
          ] else if (_alreadyUpToDate) ...[
            Text(
              l10n.ota_upToDate,
              style: TextStyle(color: context.appColors.connected),
            ),
            const SizedBox(height: 8),
          ],
          if (!_boardAutoDetected) ...[
            Text(
              l10n.ota_boardUnknown,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
          ],
          DropdownButtonFormField<FirmwareAsset>(
            initialValue: _selectedAsset,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.ota_firmwareFile,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              for (final asset in release.assets)
                DropdownMenuItem(
                  value: asset,
                  child: Text(
                    '${asset.boardId} '
                    '(${asset.chip == OtaChipFamily.esp32 ? 'ESP32' : 'nRF52'})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: downloadDone
                ? null
                : (asset) async {
                    setState(() => _selectedAsset = asset);
                    if (asset?.chip == OtaChipFamily.nrf52 &&
                        _bootloaderReply == null) {
                      await _checkBootloader();
                    }
                    if (mounted) setState(() {});
                    if (asset != null && _awaitingBoardSelection) {
                      await _continueAfterFirmwareSelection();
                    }
                  },
          ),
        ],
        if (_missingOtaFix && firmwareSelected) ...[
          const SizedBox(height: 8),
          Text(
            l10n.ota_otafixWarning,
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 13,
            ),
          ),
        ],
        if (showLocalOption) ...[
          const SizedBox(height: 12),
          if (!_localFirmwareRequested) const Divider(),
          Text(l10n.ota_orLoadLocalLabel, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickLocalFirmware(OtaChipFamily.esp32),
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.ota_pickLocalEsp32),
              ),
              OutlinedButton.icon(
                onPressed: () => _pickLocalFirmware(OtaChipFamily.nrf52),
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.ota_pickLocalNrf52),
              ),
            ],
          ),
        ],
        if (_usingLocalFirmware) ...[
          const SizedBox(height: 8),
          Text(
            l10n.ota_usingLocalFile(_selectedAsset?.fileName ?? ''),
            style: const TextStyle(fontSize: 13),
          ),
        ],
        if (!_localFirmwareRequested && _awaitingBoardSelection) ...[
          const SizedBox(height: 8),
          Text(
            l10n.ota_selectBoardToContinue,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget? _buildDownloadBody(AppLocalizations l10n) {
    if (_stepStatus[_OtaStep.download] == _StepStatus.pending) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: _downloadProgress),
        const SizedBox(height: 8),
        Text(
          _usingLocalFirmware
              ? l10n.ota_usingLocalFile(_selectedAsset?.fileName ?? '')
              : _firmwareFile != null
              ? l10n.ota_downloadComplete(_selectedAsset?.fileName ?? '')
              : l10n.ota_downloading(
                  (_downloadProgress * 100).toStringAsFixed(0),
                ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget? _buildFlashBody(AppLocalizations l10n) {
    final asset = _selectedAsset;
    if (asset == null) return null;
    final isEsp = asset.chip == OtaChipFamily.esp32;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_otaModeEntered && _flashBusy) ...[
          Text(
            isEsp ? l10n.ota_flashIntroEsp32 : l10n.ota_flashIntroNrf,
            style: const TextStyle(fontSize: 13),
          ),
        ] else if (isEsp && !_flashDone && _otaModeEntered) ...[
          if (!_wifiJoined)
            Text(
              l10n.ota_joinWifiHint(Esp32OtaUploader.otaSsid),
              style: const TextStyle(fontSize: 13),
            )
          else ...[
            LinearProgressIndicator(value: _flashProgress),
            const SizedBox(height: 8),
            Text(
              l10n.ota_uploading((_flashProgress * 100).toStringAsFixed(0)),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ] else if (!isEsp && !_flashDone && _otaModeEntered) ...[
          LinearProgressIndicator(value: _flashProgress),
          const SizedBox(height: 8),
          Text(
            l10n.ota_dfuProgress((_flashProgress * 100).toStringAsFixed(0)),
            style: const TextStyle(fontSize: 13),
          ),
        ] else if (_rebootingAfterUpload || _flashDone) ...[
          Text(l10n.ota_deviceRebooting, style: const TextStyle(fontSize: 13)),
        ],
      ],
    );
  }

  Widget? _buildVerifyBody(AppLocalizations l10n) {
    if (_stepStatus[_OtaStep.verify] == _StepStatus.pending) return null;
    final verified = _stepStatus[_OtaStep.verify] == _StepStatus.done;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!verified && _verifyBusy) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Text(
            l10n.ota_verifyingOverMesh,
            style: const TextStyle(fontSize: 13),
          ),
        ],
        if (verified) ...[
          Text(
            l10n.ota_verified(_verifiedVersion ?? ''),
            style: TextStyle(
              color: context.appColors.connected,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_clockSynced) ...[
            const SizedBox(height: 4),
            Text(l10n.ota_clockSynced, style: const TextStyle(fontSize: 13)),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ota_done),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorCard(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _retryCurrentStep,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.ota_retry),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sendReboot,
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: Text(l10n.ota_sendReboot),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.ota_stallHint,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugLog(AppLocalizations l10n) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.bug_report),
        title: Text(l10n.ota_debugLog),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 20),
          tooltip: l10n.ota_copyLog,
          onPressed: _debugLog.isEmpty
              ? null
              : () {
                  Clipboard.setData(ClipboardData(text: _debugLog.join('\n')));
                },
        ),
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 240),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _debugLog.isEmpty
                ? Text(
                    l10n.ota_logEmpty,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  )
                : SingleChildScrollView(
                    child: SelectableText(
                      _debugLog.join('\n'),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
