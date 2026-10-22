import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/notification_pref.dart';
import '../services/app_settings_service.dart';
import '../storage/notification_prefs_store.dart';
import '../widgets/adaptive_app_bar_title.dart';

class NotificationPrefScreen extends StatefulWidget {
  final int? channelIndex;
  final String? contactKeyHex;
  final String itemName;

  const NotificationPrefScreen({
    super.key,
    this.channelIndex,
    this.contactKeyHex,
    required this.itemName,
  }) : assert(
         (channelIndex == null) != (contactKeyHex == null),
         'exactly one of channelIndex or contactKeyHex must be set',
       );

  @override
  State<NotificationPrefScreen> createState() => _NotificationPrefScreenState();
}

class _NotificationPrefScreenState extends State<NotificationPrefScreen> {
  final _store = NotificationPrefsStore();
  late NotificationPref _pref;

  @override
  void initState() {
    super.initState();
    final fallbackLevel = context
        .read<AppSettingsService>()
        .settings
        .notificationDefaultLevel;
    _pref = widget.channelIndex != null
        ? _store.loadChannelPref(widget.channelIndex!, fallbackLevel)
        : _store.loadContactPref(widget.contactKeyHex!, fallbackLevel);
  }

  void _update(NotificationPref pref) {
    setState(() => _pref = pref);
    if (widget.channelIndex != null) {
      _store.saveChannelPref(widget.channelIndex!, pref);
    } else {
      _store.saveContactPref(widget.contactKeyHex!, pref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: AdaptiveAppBarTitle(
          '${l10n.notificationPref_title} · ${widget.itemName}',
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          children: [
            RadioGroup<NotificationLevel>(
              groupValue: _pref.level,
              onChanged: (value) {
                if (value == null) return;
                _update(
                  NotificationPref(
                    level: value,
                    soundEnabled: _pref.soundEnabled,
                    vibrationEnabled: _pref.vibrationEnabled,
                    bannerEnabled: _pref.bannerEnabled,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<NotificationLevel>(
                    title: Text(l10n.notificationPref_none),
                    value: NotificationLevel.none,
                  ),
                  RadioListTile<NotificationLevel>(
                    title: Text(l10n.notificationPref_all),
                    value: NotificationLevel.all,
                  ),
                  RadioListTile<NotificationLevel>(
                    title: Text(l10n.notificationPref_mentions),
                    value: NotificationLevel.mentions,
                  ),
                  RadioListTile<NotificationLevel>(
                    title: Text(l10n.notificationPref_custom),
                    value: NotificationLevel.custom,
                  ),
                ],
              ),
            ),
            if (_pref.level == NotificationLevel.custom) ...[
              const Divider(height: 1),
              SwitchListTile(
                title: Text(l10n.notificationPref_sound),
                value: _pref.soundEnabled,
                onChanged: (value) => _update(
                  NotificationPref(
                    level: _pref.level,
                    soundEnabled: value,
                    vibrationEnabled: _pref.vibrationEnabled,
                    bannerEnabled: _pref.bannerEnabled,
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.notificationPref_vibration),
                value: _pref.vibrationEnabled,
                onChanged: (value) => _update(
                  NotificationPref(
                    level: _pref.level,
                    soundEnabled: _pref.soundEnabled,
                    vibrationEnabled: value,
                    bannerEnabled: _pref.bannerEnabled,
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.notificationPref_banner),
                value: _pref.bannerEnabled,
                onChanged: (value) => _update(
                  NotificationPref(
                    level: _pref.level,
                    soundEnabled: _pref.soundEnabled,
                    vibrationEnabled: _pref.vibrationEnabled,
                    bannerEnabled: value,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
