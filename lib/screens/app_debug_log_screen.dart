import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../services/app_debug_log_service.dart';
import '../widgets/adaptive_app_bar_title.dart';

class AppDebugLogScreen extends StatelessWidget {
  const AppDebugLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDebugLogService>(
      builder: (context, logService, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final entries = logService.entries.reversed.toList();
        final hasEntries = entries.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: AdaptiveAppBarTitle(context.l10n.debugLog_appTitle),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: context.l10n.debugLog_copyLog,
                icon: const Icon(Icons.copy),
                onPressed: hasEntries
                    ? () async {
                        final text = entries
                            .map(
                              (entry) =>
                                  '[${entry.formattedTime}] [${entry.levelLabel}] [${entry.tag}] ${entry.message}',
                            )
                            .join('\n');
                        await Clipboard.setData(ClipboardData(text: text));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.l10n.debugLog_copied)),
                        );
                      }
                    : null,
              ),
              IconButton(
                tooltip: context.l10n.debugLog_clearLog,
                icon: const Icon(Icons.delete_outline),
                onPressed: hasEntries
                    ? () {
                        logService.clear();
                      }
                    : null,
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: hasEntries
                ? ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return ListTile(
                        dense: true,
                        leading: _buildLevelIcon(colorScheme, entry.level),
                        title: Text(
                          '[${entry.tag}] ${entry.message}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        subtitle: Text(
                          entry.formattedTime,
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bug_report_outlined,
                          size: 64,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.debugLog_noEntries,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.debugLog_enableInSettings,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLevelIcon(ColorScheme colorScheme, AppDebugLogLevel level) {
    switch (level) {
      case AppDebugLogLevel.info:
        return Icon(Icons.info_outline, size: 18, color: colorScheme.primary);
      case AppDebugLogLevel.warning:
        return Icon(
          Icons.warning_amber_outlined,
          size: 18,
          color: colorScheme.tertiary,
        );
      case AppDebugLogLevel.error:
        return Icon(Icons.error_outline, size: 18, color: colorScheme.error);
    }
  }
}
