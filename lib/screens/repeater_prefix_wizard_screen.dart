import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/prefix_key_generator.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../services/meshbuddy_api_service.dart';
import '../services/repeater_command_service.dart';
import '../theme/app_colors.dart';

enum _WizardStep { choosePath, lookup, reserve, confirm, work, done }

class RepeaterPrefixWizardScreen extends StatefulWidget {
  final Contact repeater;
  final String password;

  const RepeaterPrefixWizardScreen({
    super.key,
    required this.repeater,
    required this.password,
  });

  @override
  State<RepeaterPrefixWizardScreen> createState() =>
      _RepeaterPrefixWizardScreenState();
}

class _RepeaterPrefixWizardScreenState
    extends State<RepeaterPrefixWizardScreen> {
  late final MeshCoreConnector _connector;
  late final RepeaterCommandService _commandService;
  late final MeshBuddyApiService _api;
  StreamSubscription<Uint8List>? _frameSubscription;

  _WizardStep _step = _WizardStep.choosePath;
  int _prefixLength = 4;
  bool _busy = false;
  String? _error;

  final _emailController = TextEditingController();
  final _prefixController = TextEditingController();
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _altitudeController = TextEditingController(text: '0');

  List<MeshBuddyReservation> _reservations = [];
  MeshBuddyReservation? _selected;
  String? _availabilityMessage;
  bool? _prefixAvailable;

  bool _generateCancelled = false;
  int _generateAttempts = 0;
  PrefixKeyPair? _generatedKey;
  String? _appliedPublicKey;
  bool _rebooting = false;

  @override
  void initState() {
    super.initState();
    _connector = Provider.of<MeshCoreConnector>(context, listen: false);
    _commandService = RepeaterCommandService(_connector);
    _api = MeshBuddyApiService();
    _frameSubscription = _connector.receivedFrames.listen(_onFrame);
    _nameController.text = widget.repeater.name;
    _latController.text = widget.repeater.latitude?.toStringAsFixed(6) ?? '';
    _lonController.text = widget.repeater.longitude?.toStringAsFixed(6) ?? '';
    _loadStatus();
  }

  @override
  void dispose() {
    _generateCancelled = true;
    _frameSubscription?.cancel();
    _commandService.dispose();
    _api.close();
    _emailController.dispose();
    _prefixController.dispose();
    _nameController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _altitudeController.dispose();
    super.dispose();
  }

  Contact get _repeater {
    return _connector.contacts.firstWhere(
      (c) => c.publicKeyHex == widget.repeater.publicKeyHex,
      orElse: () => widget.repeater,
    );
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
    for (var i = 0; i < 6; i++) {
      if (prefix[i] != target[i]) return false;
    }
    return true;
  }

  Future<void> _loadStatus() async {
    try {
      final status = await _api.getStatus();
      if (!mounted) return;
      setState(() => _prefixLength = status.prefixLength);
    } catch (_) {
      // Keep default prefix length; reservation calls will surface errors.
    }
  }

  void _goTo(_WizardStep step) {
    setState(() {
      _step = step;
      _error = null;
      _busy = false;
    });
  }

  Future<void> _lookupReservations() async {
    final l10n = context.l10n;
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      setState(() => _error = l10n.repeater_prefixInvalidEmail);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _reservations = [];
      _selected = null;
    });
    try {
      final list = await _api.myReservations(email);
      if (!mounted) return;
      setState(() {
        _reservations = list;
        _busy = false;
        if (list.isEmpty) {
          _error = l10n.repeater_prefixNoReservations;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = formatMeshBuddyException(e);
      });
    }
  }

  Future<void> _checkAvailability() async {
    final l10n = context.l10n;
    final prefix = _prefixController.text.trim().toUpperCase();
    if (!isValidKeyPrefix(prefix, expectedLength: _prefixLength)) {
      setState(() {
        _prefixAvailable = false;
        _availabilityMessage = l10n.repeater_prefixInvalidPrefix(_prefixLength);
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _availabilityMessage = null;
      _prefixAvailable = null;
    });
    try {
      final result = await _api.checkPrefix(prefix);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _prefixAvailable = result.available;
        if (result.available) {
          _availabilityMessage = l10n.repeater_prefixAvailable(result.prefix);
        } else {
          _availabilityMessage = l10n.repeater_prefixUnavailable(
            result.prefix,
            result.reason ?? 'unavailable',
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _prefixAvailable = false;
        _availabilityMessage = formatMeshBuddyException(e);
      });
    }
  }

  Future<void> _reservePrefix() async {
    final l10n = context.l10n;
    final prefix = _prefixController.text.trim().toUpperCase();
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final lat = double.tryParse(_latController.text.trim());
    final lon = double.tryParse(_lonController.text.trim());
    final altitude = double.tryParse(_altitudeController.text.trim()) ?? 0;

    if (!isValidKeyPrefix(prefix, expectedLength: _prefixLength)) {
      setState(() => _error = l10n.repeater_prefixInvalidPrefix(_prefixLength));
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _error = l10n.repeater_prefixInvalidEmail);
      return;
    }
    if (name.isEmpty || lat == null || lon == null) {
      setState(() => _error = l10n.repeater_prefixInvalidLocation);
      return;
    }
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      setState(() => _error = l10n.repeater_prefixInvalidLocation);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final reservation = await _api.reserve(
        prefix: prefix,
        name: name,
        lat: lat,
        lon: lon,
        altitude: altitude,
        email: email,
      );
      if (!mounted) return;
      setState(() {
        _selected = reservation;
        _busy = false;
        _step = _WizardStep.confirm;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = formatMeshBuddyException(e);
      });
    }
  }

  Future<void> _confirmAndApply() async {
    final selected = _selected;
    if (selected == null) return;
    setState(() {
      _step = _WizardStep.work;
      _busy = true;
      _error = null;
      _generateCancelled = false;
      _generateAttempts = 0;
      _generatedKey = null;
      _appliedPublicKey = null;
    });

    try {
      final key = await _generateKeyForPrefix(selected.prefix);
      if (!mounted) return;
      if (key == null) {
        setState(() {
          _busy = false;
          _error = context.l10n.repeater_prefixCancelled;
          _step = _WizardStep.confirm;
        });
        return;
      }
      setState(() => _generatedKey = key);

      final loggedIn = await _ensureLoggedIn();
      if (!mounted) return;
      if (!loggedIn) {
        setState(() {
          _busy = false;
          _error = context.l10n.repeater_prefixLoginFailed;
          _step = _WizardStep.confirm;
        });
        return;
      }

      final command = buildSetPrivateKeyCommand(key.privateKeyHex);
      final reply = await _commandService.sendCommand(_repeater, command);
      if (!mounted) return;

      // Require the device to echo the new pubkey. Falling back to the locally
      // generated key previously reported false success when firmware replied
      // with "Error, bad key" or a truncated/unexpected OK.
      final reported = parseSuccessfulSetPrvKeyReply(reply);
      if (reported == null) {
        final detail = reply.trim().isEmpty
            ? context.l10n.repeater_prefixNoDevicePubkey
            : reply.trim();
        setState(() {
          _busy = false;
          _error = context.l10n.repeater_prefixApplyFailed(detail);
          _step = _WizardStep.confirm;
        });
        return;
      }
      if (!reported.startsWith(selected.prefix.toLowerCase())) {
        setState(() {
          _busy = false;
          _error = context.l10n.repeater_prefixPubkeyMismatch;
          _step = _WizardStep.confirm;
        });
        return;
      }

      setState(() {
        _appliedPublicKey = reported;
        _busy = false;
        _step = _WizardStep.done;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = context.l10n.repeater_prefixApplyFailed(
          formatMeshBuddyException(e),
        );
        _step = _WizardStep.confirm;
      });
    }
  }

  Future<bool> _ensureLoggedIn() async {
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
    late final StreamSubscription<Uint8List> subscription;
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

  Future<void> _reboot() async {
    setState(() => _rebooting = true);
    try {
      await _commandService.sendCommand(_repeater, 'reboot', retries: 1);
    } catch (_) {
      // Reboot rarely replies.
    }
    if (!mounted) return;
    setState(() => _rebooting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.repeater_commandSent('reboot'))),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  /// Prefer MeshBuddy `POST /api/keygen` (server Rust/Python keygen). Fall back
  /// to on-device search only when the generator is unavailable/unreachable.
  Future<PrefixKeyPair?> _generateKeyForPrefix(String prefix) async {
    final email = _emailController.text.trim().isNotEmpty
        ? _emailController.text.trim()
        : (_selected?.email ?? '').trim();

    if (_isValidEmail(email)) {
      try {
        final remote = await _api.keygen(prefix: prefix, email: email);
        if (_generateCancelled || !mounted) return null;
        return PrefixKeyPair(
          privateKeyHex: remote.privateKey.toLowerCase(),
          publicKeyHex: remote.publicKey.toLowerCase(),
          attempts: remote.attempts,
        );
      } on MeshBuddyApiException catch (e) {
        if (!shouldFallbackToLocalKeygen(e)) rethrow;
        // Server keygen down / timed out / unreachable — continue locally.
      }
    }

    return findPrefixKey(
      prefix,
      onProgress: (attempts) {
        if (!mounted || _generateCancelled) return;
        setState(() => _generateAttempts = attempts);
      },
      isCancelled: () => _generateCancelled || !mounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.repeater_prefixTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _busy && _step == _WizardStep.work
              ? null
              : () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNodeHeader(),
            const SizedBox(height: 16),
            if (_error != null) ...[
              _ErrorBanner(message: _error!),
              const SizedBox(height: 12),
            ],
            switch (_step) {
              _WizardStep.choosePath => _buildChoosePath(l10n),
              _WizardStep.lookup => _buildLookup(l10n),
              _WizardStep.reserve => _buildReserve(l10n),
              _WizardStep.confirm => _buildConfirm(l10n),
              _WizardStep.work => _buildWork(l10n),
              _WizardStep.done => _buildDone(l10n),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildNodeHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
          child: Icon(Icons.tag, color: colorScheme.primary),
        ),
        title: Text(widget.repeater.name),
        subtitle: Text(widget.repeater.shortPubKeyHex),
      ),
    );
  }

  Widget _buildChoosePath(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.repeater_prefixChoosePath,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _PathCard(
          icon: Icons.mail_outline,
          title: l10n.repeater_prefixLookupOption,
          subtitle: l10n.repeater_prefixLookupOptionSubtitle,
          onTap: () => _goTo(_WizardStep.lookup),
        ),
        const SizedBox(height: 12),
        _PathCard(
          icon: Icons.add_circle_outline,
          title: l10n.repeater_prefixNewOption,
          subtitle: l10n.repeater_prefixNewOptionSubtitle,
          onTap: () => _goTo(_WizardStep.reserve),
        ),
      ],
    );
  }

  Widget _buildLookup(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: l10n.repeater_prefixEmailLabel,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _lookupReservations(),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _busy ? null : _lookupReservations,
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search),
          label: Text(l10n.repeater_prefixLookupButton),
        ),
        if (_reservations.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            l10n.repeater_prefixSelectReservation,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: _selected?.prefix,
            onChanged: _busy
                ? (_) {}
                : (value) {
                    if (value == null) return;
                    final match = _reservations
                        .where((r) => r.prefix == value)
                        .firstOrNull;
                    if (match != null) setState(() => _selected = match);
                  },
            child: Column(
              children: [
                for (final reservation in _reservations)
                  Card(
                    child: RadioListTile<String>(
                      value: reservation.prefix,
                      title: Text(
                        reservation.prefix,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      subtitle: Text(
                        '${reservation.name}\n'
                        '${reservation.isDeployed ? l10n.repeater_prefixStatusDeployed : l10n.repeater_prefixStatusReserved}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _selected == null || _busy
                ? null
                : () => _goTo(_WizardStep.confirm),
            child: Text(l10n.common_continue),
          ),
        ],
        const SizedBox(height: 12),
        TextButton(
          onPressed: _busy ? null : () => _goTo(_WizardStep.choosePath),
          child: Text(l10n.analyzer_back),
        ),
      ],
    );
  }

  Widget _buildReserve(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _prefixController,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
            LengthLimitingTextInputFormatter(_prefixLength),
            _UpperCaseTextFormatter(),
          ],
          decoration: InputDecoration(
            labelText: l10n.repeater_prefixFieldLabel,
            helperText: l10n.repeater_prefixInvalidPrefix(_prefixLength),
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {
            _prefixAvailable = null;
            _availabilityMessage = null;
          }),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _busy ? null : _checkAvailability,
          child: Text(l10n.repeater_prefixCheckAvailability),
        ),
        if (_availabilityMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _availabilityMessage!,
            style: TextStyle(
              color: _prefixAvailable == true
                  ? context.appColors.connected
                  : Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.repeater_prefixNameLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: l10n.repeater_prefixEmailLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _latController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.repeater_prefixLatLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _lonController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.repeater_prefixLonLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _altitudeController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: InputDecoration(
            labelText: l10n.repeater_prefixAltitudeLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy ? null : _reservePrefix,
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.bookmark_add_outlined),
          label: Text(l10n.repeater_prefixReserveButton),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : () => _goTo(_WizardStep.choosePath),
          child: Text(l10n.analyzer_back),
        ),
      ],
    );
  }

  Widget _buildConfirm(AppLocalizations l10n) {
    final selected = _selected;
    if (selected == null) {
      return TextButton(
        onPressed: () => _goTo(_WizardStep.choosePath),
        child: Text(l10n.analyzer_back),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Theme.of(
            context,
          ).colorScheme.errorContainer.withValues(alpha: 0.35),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.repeater_prefixConfirmTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.repeater_prefixConfirmBody(
                    selected.prefix,
                    widget.repeater.name,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  selected.prefix,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy ? null : _confirmAndApply,
          icon: const Icon(Icons.key),
          label: Text(l10n.repeater_prefixConfirmYes),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : () => _goTo(_WizardStep.choosePath),
          child: Text(l10n.common_cancel),
        ),
      ],
    );
  }

  Widget _buildWork(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = _selected;
    final generating = _generatedKey == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 20),
                Text(
                  generating
                      ? l10n.repeater_prefixGenerating(selected?.prefix ?? '')
                      : l10n.repeater_prefixApplying,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (generating) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.repeater_prefixGenerateMayTakeTime,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  if (_generateAttempts > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.repeater_prefixGenerateProgress(_generateAttempts),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => setState(() => _generateCancelled = true),
                    child: Text(l10n.repeater_prefixGenerateCancel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDone(AppLocalizations l10n) {
    final pub = _appliedPublicKey ?? _generatedKey?.publicKeyHex ?? '';
    final connectedColor = context.appColors.connected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: connectedColor.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: connectedColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.repeater_prefixApplySuccess,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  pub,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: pub.isEmpty
                        ? null
                        : () async {
                            await Clipboard.setData(ClipboardData(text: pub));
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.common_copy)),
                            );
                          },
                    icon: const Icon(Icons.copy, size: 18),
                    label: Text(l10n.common_copy),
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.repeater_prefixRebootNeeded),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _rebooting ? null : _reboot,
          icon: _rebooting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.restart_alt),
          label: Text(l10n.repeater_prefixRebootNow),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.repeater_prefixDone),
        ),
      ],
    );
  }
}

class _PathCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PathCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: scheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
