import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../screens/app_settings_screen.dart';
import '../services/app_debug_log_service.dart';
import '../services/app_settings_service.dart';
import '../services/frame_debug_log_service.dart';
import '../services/crash_log_service.dart';
import '../storage/debug_report_store.dart';

/// Support inbox shown as the fallback recipient if the automatic upload
/// can't be reached and we fall back to the share sheet.
const String debugLogSupportEmail = 'support@gulfcoastmesh.org';

/// Nextcloud "Files Drop" share that user-submitted debug reports upload to.
/// Upload-only: nothing already dropped there can be listed, read, or
/// deleted through this link, so shipping the token in the APK only risks
/// spam uploads, not exposing anyone's report to other users.
const String _debugDropShareToken = 'p2gLZdmTRW5aEWb';
const String _debugDropUploadBase =
    'https://cloud.gproconnect.com/public.php/dav/files/$_debugDropShareToken';

/// Prompts for an optional description, sends the report, then shows the
/// generated reference code. This is the entry point every "report a
/// problem" button in the app should call — it owns the whole flow so the
/// debug-log screen and general Settings entry points stay in sync.
Future<void> showDebugReportDialog(BuildContext context) async {
  if (!await _maybePromptToEnableDebugLog(context)) return;
  if (!context.mounted) return;

  final controller = TextEditingController();
  final l10n = context.l10n;
  final send = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.debugLog_reportDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.debugLog_reportDialogBody),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.debugLog_reportDescriptionLabel,
              hintText: l10n.debugLog_reportDescriptionHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.debugLog_reportSendButton),
        ),
      ],
    ),
  );
  if (send != true || !context.mounted) return;

  final code = await sendDebugReport(
    context,
    frameLogService: context.read<FrameDebugLogService>(),
    appLogService: context.read<AppDebugLogService>(),
    crashLogService: context.read<CrashLogService>(),
    connector: context.read<MeshCoreConnector>(),
    description: controller.text.trim().isEmpty ? null : controller.text.trim(),
  );
  if (code == null || !context.mounted) return;

  await DebugReportStore().addRecent(code);
  if (!context.mounted) return;
  await _showReportCodeDialog(context, code);
}

/// If app debug logging is off and the user hasn't been asked before,
/// offers a shortcut into Settings to turn it on before they file a
/// report — the extra detail makes reports much easier to diagnose. Shown
/// at most once ever; returns false if the caller should stop because the
/// user went to Settings instead of continuing with the report.
Future<bool> _maybePromptToEnableDebugLog(BuildContext context) async {
  final settingsService = context.read<AppSettingsService>();
  final settings = settingsService.settings;
  if (settings.appDebugLogEnabled || settings.debugLogPromptShown) return true;

  final l10n = context.l10n;
  final openSettings = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.debugLog_enablePromptTitle),
      content: Text(l10n.debugLog_enablePromptBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.debugLog_enablePromptNotNow),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.debugLog_enablePromptOpenSettings),
        ),
      ],
    ),
  );

  await settingsService.setDebugLogPromptShown(true);
  if (openSettings != true) return true;
  if (!context.mounted) return false;

  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
  );
  return false;
}

Future<void> _showReportCodeDialog(BuildContext context, String code) async {
  final l10n = context.l10n;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.debugLog_reportCodeDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.debugLog_reportCodeDialogBody),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.common_copy,
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(l10n.debugLog_reportCodeCopied)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.common_close),
        ),
      ],
    ),
  );
}

/// Zips the frame log, raw log-RX capture, and app debug log into one
/// archive tagged with a short reference code, and silently uploads it to
/// the support team's debug drop. Falls back to the share sheet (with the
/// support email copied to the clipboard) if the upload can't get through,
/// so the user always has a way to send it. Returns the generated reference
/// code, or null if the archive itself couldn't be built.
Future<String?> sendDebugReport(
  BuildContext context, {
  required FrameDebugLogService frameLogService,
  required AppDebugLogService appLogService,
  required CrashLogService crashLogService,
  required MeshCoreConnector connector,
  String? description,
}) async {
  try {
    final now = DateTime.now();
    final code = _generateReportCode();
    final zipBytes = await _buildLogArchive(
      now,
      code,
      frameLogService,
      appLogService,
      crashLogService,
      connector,
      description,
    );
    final stamp = now.toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final filename = 'gulfmesh-debug-logs-$code-$stamp.zip';

    final uploaded = await _tryUpload(zipBytes, filename);
    if (!context.mounted) return code;

    if (uploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.debugLog_sendLogsSuccess)),
      );
      return code;
    }

    await _shareInstead(context, zipBytes, filename);
    return code;
  } catch (e) {
    if (!context.mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.debugLog_sendLogsFailed)),
    );
    return null;
  }
}

/// An 8-character Crockford Base32 code from 5 random bytes, displayed as
/// two hyphenated groups of 4 for easier reading/typing over chat or phone.
/// Mirrors the encoder in reaction_helper.dart, but fed random bytes rather
/// than a content hash since a report code has no need to be deterministic.
String _generateReportCode() {
  const alphabet = '0123456789abcdefghjkmnpqrstvwxyz';
  final random = Random.secure();
  final bytes = List<int>.generate(5, (_) => random.nextInt(256));
  var value = 0;
  for (final byte in bytes) {
    value = (value << 8) | byte;
  }
  final out = StringBuffer();
  for (var shift = 35; shift >= 0; shift -= 5) {
    out.write(alphabet[(value >> shift) & 0x1f]);
  }
  final flat = out.toString().toUpperCase();
  return '${flat.substring(0, 4)}-${flat.substring(4, 8)}';
}

Future<bool> _tryUpload(Uint8List zipBytes, String filename) async {
  try {
    final response = await http
        .put(
          Uri.parse('$_debugDropUploadBase/$filename'),
          headers: {
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$_debugDropShareToken:'))}',
            'Content-Type': 'application/zip',
          },
          body: zipBytes,
        )
        .timeout(const Duration(seconds: 20));
    return response.statusCode == 201 || response.statusCode == 204;
  } catch (_) {
    return false;
  }
}

Future<void> _shareInstead(
  BuildContext context,
  Uint8List zipBytes,
  String filename,
) async {
  final dir = await getTemporaryDirectory();
  final zipFile = File('${dir.path}/$filename');
  await zipFile.writeAsBytes(zipBytes);

  await Clipboard.setData(const ClipboardData(text: debugLogSupportEmail));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(context.l10n.debugLog_sendLogsEmailCopied)),
  );

  await SharePlus.instance.share(
    ShareParams(
      subject: 'Gulf Coast Mesh App debug logs',
      text:
          'Automatic upload failed. Please send this to $debugLogSupportEmail '
          '(address copied to your clipboard).',
      files: [XFile(zipFile.path)],
    ),
  );

  unawaited(zipFile.delete());
}

Future<Uint8List> _buildLogArchive(
  DateTime now,
  String code,
  FrameDebugLogService frameLogService,
  AppDebugLogService appLogService,
  CrashLogService crashLogService,
  MeshCoreConnector connector,
  String? description,
) async {
  final archive = Archive();

  void addText(String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  addText(
    'info.txt',
    await _buildInfoText(now, code, appLogService.enabled, connector),
  );
  if (description != null) addText('report.txt', description);
  addText('frames.txt', _formatFrames(frameLogService));
  addText('raw_log_rx.txt', _formatRawLogRx(frameLogService));
  addText('app_log.txt', _formatAppLog(appLogService));
  addText('crash_log.txt', _formatCrashLog(crashLogService));

  return ZipEncoder().encodeBytes(archive);
}

Future<String> _buildInfoText(
  DateTime now,
  String code,
  bool appLogEnabled,
  MeshCoreConnector connector,
) async {
  final pkg = await PackageInfo.fromPlatform();
  return [
    'Gulf Coast Mesh App debug log export',
    'Report code: $code',
    'Generated: ${now.toIso8601String()}',
    'App version: ${pkg.version}+${pkg.buildNumber}',
    'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    'App debug logging enabled: $appLogEnabled',
    'Connected: ${connector.isConnected}',
    'Device: ${connector.deviceDisplayName} (${connector.deviceIdLabel})',
    'Contacts: ${connector.contacts.length}',
    'Channels: ${connector.channels.length}',
    'Radio: freq=${connector.currentFreqHz} bw=${connector.currentBwHz} '
        'sf=${connector.currentSf} cr=${connector.currentCr}',
  ].join('\n');
}

String _formatFrames(FrameDebugLogService service) {
  if (service.entries.isEmpty) return 'No frames captured.';
  return service.entries
      .map(
        (e) =>
            '${e.timestamp.toIso8601String()} '
            '${e.outgoing ? 'TX' : 'RX'} ${e.description}\n${e.hexFull}',
      )
      .join('\n\n');
}

String _formatRawLogRx(FrameDebugLogService service) {
  if (service.rawLogRxEntries.isEmpty) return 'No raw log-RX packets captured.';
  return service.rawLogRxEntries
      .map((e) => '${e.timestamp.toIso8601String()}\n${e.hexFull}')
      .join('\n\n');
}

String _formatCrashLog(CrashLogService service) {
  if (service.entries.isEmpty) return 'No crashes recorded.';
  return service.entries
      .map(
        (e) =>
            '${e.timestamp.toIso8601String()} ${e.error}'
            '${e.stackTrace != null ? '\n${e.stackTrace}' : ''}',
      )
      .join('\n\n');
}

String _formatAppLog(AppDebugLogService service) {
  if (service.entries.isEmpty) {
    return service.enabled
        ? 'No app log entries captured.'
        : 'App debug logging was off, so no app log was captured. Enable '
              '"App Debug Log" in Settings before reproducing the issue for '
              'more detail next time.';
  }
  return service.entries
      .map(
        (e) => '${e.formattedTime} [${e.levelLabel}] [${e.tag}] ${e.message}',
      )
      .join('\n');
}
