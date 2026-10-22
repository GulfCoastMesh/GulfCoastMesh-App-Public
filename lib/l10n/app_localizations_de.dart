// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get analyzer_fullScreen => 'Full screen';

  @override
  String get analyzer_exitFullScreen => 'Exit full screen';

  @override
  String get analyzer_zoomIn => 'Zoom in';

  @override
  String get analyzer_zoomOut => 'Zoom out';

  @override
  String get analyzer_fitMap => 'Fit nodes and paths';

  @override
  String get analyzer_followTraffic => 'Follow packet paths';

  @override
  String get analyzer_showLabels => 'Show node names';

  @override
  String get analyzer_hideLabels => 'Hide node names';

  @override
  String get appTitle => 'Gulf Coast Mesh App';

  @override
  String get nav_contacts => 'Kontakte';

  @override
  String get nav_channels => 'Kanäle';

  @override
  String get nav_map => 'Karte';

  @override
  String get nav_chats => 'Chats';

  @override
  String get nav_nodes => 'Knoten';

  @override
  String get nav_settings => 'Einstellungen';

  @override
  String get common_cancel => 'Abbrechen';

  @override
  String get common_ok => 'OK';

  @override
  String get wardriving_disclosureTitle => 'Wardriving disclosure';

  @override
  String get wardriving_disclosureBody =>
      'Wardriving uploads your GPS coordinates and radio signal metadata to MeshMapper.net for public coverage mapping. Location is used while wardriving is active.';

  @override
  String get wardriving_disclosureAccept => 'I understand';

  @override
  String get wardriving_locationPermissionRequired =>
      'Location permission is required';

  @override
  String get common_connect => 'Verbinden';

  @override
  String get common_unknownDevice => 'Unbekanntes Gerät';

  @override
  String get common_save => 'Speichern';

  @override
  String get common_delete => 'Löschen';

  @override
  String get common_close => 'Schließen';

  @override
  String get common_edit => 'Bearbeiten';

  @override
  String get common_add => 'Hinzufügen';

  @override
  String get common_settings => 'Einstellungen';

  @override
  String get common_disconnect => 'Trennen';

  @override
  String get common_connected => 'Verbunden';

  @override
  String get common_disconnected => 'Getrennt';

  @override
  String get common_reconnecting => 'Reconnecting';

  @override
  String get common_create => 'Erstellen';

  @override
  String get common_continue => 'Fortfahren';

  @override
  String get common_share => 'Teilen';

  @override
  String get common_copy => 'Kopieren';

  @override
  String get common_retry => 'Versuchen';

  @override
  String get common_hide => 'Ausblenden';

  @override
  String get common_remove => 'Löschen';

  @override
  String get common_enable => 'Aktivieren';

  @override
  String get common_disable => 'Deaktivieren';

  @override
  String get common_reboot => 'Neustart';

  @override
  String get common_loading => 'Laden...';

  @override
  String get common_notAvailable => '—';

  @override
  String common_voltageValue(String volts) {
    return '$volts V';
  }

  @override
  String common_percentValue(int percent) {
    return '$percent%';
  }

  @override
  String chat_sendFailed(String error) {
    return 'Message could not be sent: $error';
  }

  @override
  String get chat_historyLoadFailed => 'Could not load older messages.';

  @override
  String get supportPrompt_title => 'Enjoying the app?';

  @override
  String get supportPrompt_message =>
      'We hope you\'re enjoying Gulf Coast Mesh App! This app is built by the community, for the community. If you\'d like to support its development, consider buying us a coffee on Ko-fi.';

  @override
  String get supportPrompt_kofiButton => 'Support on Ko-fi';

  @override
  String get supportPrompt_dismiss => 'Maybe later';

  @override
  String get scanner_title => 'Gulf Coast Mesh App';

  @override
  String get scanner_scanning => 'Scannen nach Geräten...';

  @override
  String get scanner_connecting => 'Verbunden...';

  @override
  String get scanner_disconnecting => 'Trenne...';

  @override
  String get scanner_notConnected => 'Nicht verbunden';

  @override
  String scanner_connectedTo(String deviceName) {
    return 'Verbunden mit $deviceName';
  }

  @override
  String get scanner_searchingDevices => 'Suche nach MeshCore-Geräten...';

  @override
  String get scanner_tapToScan =>
      'Tippen Sie auf Scan, um MeshCore-Geräte zu finden.';

  @override
  String scanner_connectionFailed(String error) {
    return 'Verbindungsfehler: $error';
  }

  @override
  String get scanner_backgroundBleMayDrop =>
      'Background BLE may drop without notification permission.';

  @override
  String get scanner_stop => 'Stopp';

  @override
  String get scanner_scan => 'Scannen';

  @override
  String get scanner_bluetoothOff => 'Bluetooth ist deaktiviert.';

  @override
  String get scanner_bluetoothOffMessage =>
      'Bitte aktivieren Sie Bluetooth, um nach Geräten zu suchen.';

  @override
  String get scanner_enableBluetooth => 'Bluetooth aktivieren';

  @override
  String get scanner_transportBluetooth => 'Bluetooth';

  @override
  String get telemetryMonitor_title => 'Telemetry';

  @override
  String get telemetryMonitor_localNode => 'This device';

  @override
  String get telemetryMonitor_noHistory => 'No telemetry recorded yet';

  @override
  String get telemetryMonitor_disabled => 'Telemetry monitoring is off';

  @override
  String get telemetryMonitor_enableHint =>
      'Turn it on in Settings to record history';

  @override
  String get telemetryMonitor_sampleNow => 'Sample now';

  @override
  String get telemetryMonitor_pollRemoteNow => 'Poll repeaters now';

  @override
  String telemetryMonitor_lastSample(String time) {
    return 'Last sample $time';
  }

  @override
  String get telemetryMonitor_clearHistory => 'Clear history';

  @override
  String get telemetryMonitor_clearHistoryConfirm =>
      'Delete all recorded telemetry for this node?';

  @override
  String get telemetryMonitor_battery => 'Battery';

  @override
  String get telemetryMonitor_noiseFloor => 'Noise floor';

  @override
  String get telemetryMonitor_rssi => 'Last RSSI';

  @override
  String get telemetryMonitor_snr => 'Last SNR';

  @override
  String get telemetryMonitor_txAirtime => 'TX airtime';

  @override
  String get telemetryMonitor_rxAirtime => 'RX airtime';

  @override
  String get telemetryMonitor_uptime => 'Uptime';

  @override
  String get telemetryMonitor_sensors => 'Sensors';

  @override
  String telemetryMonitor_samples(int count) {
    return '$count samples';
  }

  @override
  String get telemetrySettings_title => 'Telemetry monitoring';

  @override
  String get telemetrySettings_enable => 'Record telemetry history';

  @override
  String get telemetrySettings_enableSubtitle =>
      'Sample this device\'s battery and radio stats on a schedule';

  @override
  String get telemetrySettings_interval => 'Sample interval';

  @override
  String get telemetrySettings_remoteEnable => 'Poll saved repeaters';

  @override
  String get telemetrySettings_remoteSubtitle =>
      'Only repeaters logged into within the last 30 days can be polled. Costs airtime on every request and reply. Off by default.';

  @override
  String get telemetrySettings_remoteInterval => 'Repeater poll interval';

  @override
  String get telemetrySettings_remoteNodes => 'Recently logged-in repeaters';

  @override
  String get telemetrySettings_remoteNodesNone =>
      'No repeaters logged into within the last 30 days';

  @override
  String get telemetrySettings_alerts => 'Threshold alerts';

  @override
  String get telemetrySettings_alertsSubtitle =>
      'Notify on low battery or a rising noise floor';

  @override
  String get telemetrySettings_lowBattery => 'Low battery threshold';

  @override
  String get telemetrySettings_noiseFloor => 'Noise floor threshold';

  @override
  String telemetrySettings_airtimeEstimate(String count) {
    return 'About $count requests per hour';
  }

  @override
  String get scanner_transportUsb => 'USB';

  @override
  String get scanner_transportNetwork => 'Network';

  @override
  String get scanner_searchingUsbDevices => 'Searching for USB devices...';

  @override
  String get scanner_usbTapToRefresh => 'Tap Refresh to list USB devices';

  @override
  String get scanner_refresh => 'Refresh';

  @override
  String get scanner_savedConnections => 'Saved connections';

  @override
  String get scanner_networkNoDiscovery =>
      'Network devices are not discoverable. Add one by address.';

  @override
  String get scanner_addNetworkDevice => 'Add network device';

  @override
  String get scanner_editConnection => 'Edit connection';

  @override
  String get scanner_profileName => 'Name';

  @override
  String get scanner_networkAddress => 'Address';

  @override
  String get scanner_networkAddressHint => '192.168.1.50:5000';

  @override
  String get scanner_networkAddressInvalid =>
      'Enter a host or host:port address';

  @override
  String get scanner_profileNameRequired => 'Enter a name';

  @override
  String scanner_savedConnection(String name) {
    return 'Saved $name';
  }

  @override
  String get scanner_deleteConnection => 'Delete connection';

  @override
  String scanner_deleteConnectionConfirm(String name) {
    return 'Delete the saved connection \"$name\"?';
  }

  @override
  String get scanner_autoConnect => 'Auto-connect';

  @override
  String get scanner_autoConnectSubtitle =>
      'Connect automatically when this device is available';

  @override
  String get scanner_autoConnecting => 'Looking for saved devices...';

  @override
  String get device_quickSwitch => 'Schnelles Umschalten';

  @override
  String get device_meshcore => 'MeshCore';

  @override
  String get settings_title => 'Einstellungen';

  @override
  String get settings_deviceInfo => 'Geräteinformationen';

  @override
  String get settings_appSettings => 'App-Einstellungen';

  @override
  String get settings_appSettingsSubtitle =>
      'Benachrichtigungen, Messaging und Kartenwahrnehmung';

  @override
  String get settings_nodeSettings => 'Knoten-Einstellungen';

  @override
  String get settings_nodeName => 'Knotenname';

  @override
  String get settings_nodeNameNotSet => 'Nicht festgelegt';

  @override
  String get settings_nodeNameHint => 'Gebe den Knotenamen ein';

  @override
  String get settings_nodeNameUpdated => 'Name aktualisiert';

  @override
  String get settings_radioSettings => 'Funk Einstellungen';

  @override
  String get settings_radioSettingsSubtitle =>
      'Frequenz, Leistung, Verbreitungsfaktor';

  @override
  String get settings_radioSettingsUpdated => 'Funkparameter aktualisiert';

  @override
  String get settings_location => 'Ort';

  @override
  String get settings_locationSubtitle => 'GPS-Koordinaten';

  @override
  String get settings_locationUpdated => 'Ort aktualisiert';

  @override
  String get settings_locationBothRequired =>
      'Bitte geben Sie sowohl Breite als auch Längengrad ein.';

  @override
  String get settings_locationInvalid => 'Ungültige Breiten- oder Längengrade.';

  @override
  String get settings_locationGPSEnable => 'GPS aktivieren';

  @override
  String get settings_locationGPSEnableSubtitle =>
      'Aktiviert GPS zur automatischen Aktualisierung des Standorts.';

  @override
  String get settings_locationIntervalSec => 'Intervall für GPS (Sekunden)';

  @override
  String get settings_usePhoneGps => 'Use phone GPS';

  @override
  String get settings_locationIntervalInvalid =>
      'Das Intervall muss mindestens 60 Sekunden und weniger als 86400 Sekunden betragen.';

  @override
  String get settings_latitude => 'Breitengrad';

  @override
  String get settings_longitude => 'Längengrad';

  @override
  String get settings_privacyMode => 'Privatsphäreeinstellung';

  @override
  String get settings_privacyModeSubtitle =>
      'Verstecken Sie Name/Ort in Ankündigungen';

  @override
  String get settings_privacyModeToggle =>
      'Aktivieren Sie die Privatsphäreeinstellung, um Ihren Namen und Ihre Standortdaten in Ankündigungen zu verbergen.';

  @override
  String get settings_privacyModeEnabled => 'Datenschutzmodus aktiviert';

  @override
  String get settings_privacyModeDisabled => 'Datenschutzmodus deaktiviert';

  @override
  String get settings_defaultFloodScope => 'Default Flood Scope';

  @override
  String get settings_defaultFloodScopeSubtitle =>
      'Limit flood sends to a MeshCore region';

  @override
  String get settings_defaultFloodScopeFooter =>
      'When set, the device applies this scope to flood sends. Saved on the device and survives reboots.';

  @override
  String get settings_defaultFloodScopeDisabled => 'None';

  @override
  String get settings_defaultFloodScopeUpdated => 'Default flood scope updated';

  @override
  String get settings_defaultFloodScopeCleared => 'Default flood scope cleared';

  @override
  String get settings_defaultFloodScopeUnsupported =>
      'This firmware does not support default flood scope';

  @override
  String get settings_defaultFloodScopeCustom => 'Custom region';

  @override
  String get settings_defaultFloodScopeCustomHint => 'e.g. us-la-msy';

  @override
  String get settings_defaultFloodScopeInvalid =>
      'Region names must be ASCII letters, digits, or hyphens (max 30 bytes)';

  @override
  String get settings_defaultFloodScopeAddKnown => 'Remember this region';

  @override
  String get settings_actions => 'Aktionen';

  @override
  String get settings_sendAdvertisement => 'Sende Ankündigung';

  @override
  String get settings_sendAdvertisementSubtitle => 'Sende eine Ankündigung';

  @override
  String get settings_advertisementSent => 'Ankündigung gesendet';

  @override
  String get settings_syncTime => 'Zeitsynchronisierung';

  @override
  String get settings_syncTimeSubtitle =>
      'Stelle die Gerätezeit auf die Uhrzeit des Telefons ein';

  @override
  String get settings_timeSynchronized => 'Zeit synchronisiert';

  @override
  String get settings_refreshContacts => 'Kontakte aktualisieren';

  @override
  String get settings_refreshContactsSubtitle =>
      'Kontakt-Liste vom Gerät neu laden';

  @override
  String get settings_rebootDevice => 'Gerät neu starten';

  @override
  String get settings_rebootDeviceSubtitle => 'MeshCore-Gerät neu starten';

  @override
  String get settings_rebootDeviceConfirm =>
      'Sind Sie sicher, dass Sie das Gerät neu starten möchten? Sie werden getrennt.';

  @override
  String get settings_debug => 'Fehlerbehebung';

  @override
  String get settings_bleDebugLog => 'BLE-Debug-Protokoll';

  @override
  String get settings_bleDebugLogSubtitle =>
      'BLE-Befehle, Antworten und Rohdaten';

  @override
  String get settings_appDebugLog => 'App-Debug-Protokoll';

  @override
  String get settings_appDebugLogSubtitle => 'Anwendung Debug-Nachrichten';

  @override
  String get settings_backgroundReliability => 'Background reliability';

  @override
  String get settings_backgroundReliabilityStatus => 'Battery optimization';

  @override
  String get settings_backgroundReliabilityExempt =>
      'Unrestricted (recommended)';

  @override
  String get settings_backgroundReliabilityRestricted => 'Restricted';

  @override
  String get settings_backgroundReliabilityExplainer =>
      'Unrestricted background use keeps the mesh connection alive and notifications arriving while the app is closed. Some phone manufacturers (Samsung, Xiaomi, Huawei, OnePlus, and others) apply additional battery restrictions beyond this setting that this app cannot override — check your phone\'s battery settings for this app if messages stop arriving in the background.';

  @override
  String get settings_backgroundReliabilityRequestButton =>
      'Allow unrestricted background use';

  @override
  String get settings_backgroundReliabilityOpenSettingsButton =>
      'Open battery settings';

  @override
  String get settings_reportProblem => 'Report a Problem';

  @override
  String get settings_reportProblemSubtitle =>
      'Send app logs to Gulf Coast Mesh support';

  @override
  String get settings_about => 'Über';

  @override
  String settings_aboutVersion(String version) {
    return 'Gulf Coast Mesh App v$version';
  }

  @override
  String get settings_aboutLegalese => 'Gulf Coast Mesh App 2026';

  @override
  String get settings_aboutDescription =>
      'Ein Open-Source-Flutter-Client für MeshCore LoRa-Meshnetzwerkgeräte.';

  @override
  String get settings_aboutOpenMeteoAttribution =>
      'LOS-Höhendaten: Open-Meteo (CC BY 4.0)';

  @override
  String get settings_infoName => 'Name';

  @override
  String get settings_infoId => 'ID';

  @override
  String get settings_infoStatus => 'Status';

  @override
  String get settings_infoBattery => 'Akku';

  @override
  String get settings_infoPublicKey => 'Öffentlicher Schlüssel';

  @override
  String get settings_infoContactsCount => 'Anzahl Kontakte';

  @override
  String get settings_infoChannelCount => 'Anzahl Kanäle';

  @override
  String get settings_presets => 'Voreinstellungen';

  @override
  String get settings_frequency => 'Frequenz (MHz)';

  @override
  String get settings_frequencyHelper => '300,00 - 2.500,00';

  @override
  String get settings_frequencyInvalid => 'Ungültige Frequenz (300-2500 MHz)';

  @override
  String get settings_bandwidth => 'Bandbreite';

  @override
  String get settings_spreadingFactor => 'Verteilungsfaktor';

  @override
  String get settings_codingRate => 'Kodierungsrate';

  @override
  String get settings_txPower => 'TX-Leistung (dBm)';

  @override
  String get settings_txPowerHelper => '0 - 22';

  @override
  String get settings_txPowerInvalid => 'Ungültige TX-Leistung (0-22 dBm)';

  @override
  String get settings_clientRepeat => 'Wiederholung, ohne Stromanschluss';

  @override
  String get settings_clientRepeatSubtitle =>
      'Ermöglichen Sie diesem Gerät, Mesh-Pakete für andere zu wiederholen.';

  @override
  String get settings_clientRepeatFreqWarning =>
      'Die Kommunikation ohne Stromversorgung erfordert Frequenzen von 433, 869 oder 918 MHz.';

  @override
  String settings_error(String message) {
    return 'Fehler: $message';
  }

  @override
  String get appSettings_title => 'App-Einstellungen';

  @override
  String get appSettings_appearance => 'Aussehen';

  @override
  String get appSettings_theme => 'Theme';

  @override
  String get appSettings_themeSystem => 'Systemstandard';

  @override
  String get appSettings_themeLight => 'Hell';

  @override
  String get appSettings_themeDark => 'Dunkel';

  @override
  String get appSettings_layoutMode => 'Layout';

  @override
  String get appSettings_layoutModeAuto => 'Automatic';

  @override
  String get appSettings_layoutModeAutoSubtitle =>
      'Tablet layout on wide screens, mobile on narrow';

  @override
  String get appSettings_layoutModeMobile => 'Mobile';

  @override
  String get appSettings_layoutModeMobileSubtitle =>
      'Bottom navigation and full-screen lists';

  @override
  String get appSettings_layoutModeTablet => 'Tablet/Desktop';

  @override
  String get appSettings_layoutModeTabletSubtitle =>
      'Side rail and split master-detail panes';

  @override
  String get appSettings_language => 'Sprache';

  @override
  String get appSettings_languageSystem => 'Systemstandard';

  @override
  String get appSettings_languageEn => 'English';

  @override
  String get appSettings_languageFr => 'Français';

  @override
  String get appSettings_languageEs => 'Español';

  @override
  String get appSettings_languageDe => 'Deutsch';

  @override
  String get appSettings_languagePl => 'Polski';

  @override
  String get appSettings_languageSl => 'Slovenščina';

  @override
  String get appSettings_languagePt => 'Português';

  @override
  String get appSettings_languageIt => 'Italiano';

  @override
  String get appSettings_languageZh => '中文';

  @override
  String get appSettings_languageSv => 'Svenska';

  @override
  String get appSettings_languageNl => 'Nederlands';

  @override
  String get appSettings_languageSk => 'Slovenčina';

  @override
  String get appSettings_languageBg => 'Български';

  @override
  String get appSettings_languageRu => 'Russisch';

  @override
  String get appSettings_languageUk => 'Ukrainisch';

  @override
  String get appSettings_enableMessageTracing =>
      'Nachrichtenverfolgung aktivieren';

  @override
  String get appSettings_enableMessageTracingSubtitle =>
      'Detaillierte Routing- und Timing-Metadaten für Nachrichten anzeigen';

  @override
  String get appSettings_notifications => 'Benachrichtigungen';

  @override
  String get appSettings_enableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get appSettings_enableNotificationsSubtitle =>
      'Erhalte Benachrichtigungen für Nachrichten und Ankündigungen';

  @override
  String get appSettings_notificationPermissionDenied =>
      'Erlaubnis zur Benachrichtigung verweigert';

  @override
  String get appSettings_notificationsEnabled => 'Benachrichtigungen aktiviert';

  @override
  String get appSettings_notificationsDisabled =>
      'Benachrichtigungen deaktiviert';

  @override
  String get appSettings_messageNotifications =>
      'Direktnachrichten Benachrichtigungen';

  @override
  String get appSettings_messageNotificationsSubtitle =>
      'Zeige Benachrichtigung beim Empfang neuer Direktnachrichten';

  @override
  String get appSettings_channelMessageNotifications =>
      'Kanalnachrichten Benachrichtigungen';

  @override
  String get appSettings_channelMessageNotificationsSubtitle =>
      'Zeige Benachrichtigung beim Empfangen von Kanalnachrichten';

  @override
  String get appSettings_advertisementNotifications =>
      'Ankündigungsbenachrichtigungen';

  @override
  String get appSettings_advertisementNotificationsSubtitle =>
      'Zeige Benachrichtigung, wenn neue Knoten entdeckt werden.';

  @override
  String get appSettings_notificationDefaultLevel =>
      'Default Notification Level';

  @override
  String get notificationPref_title => 'Notifications';

  @override
  String get notificationPref_none => 'None';

  @override
  String get notificationPref_all => 'All';

  @override
  String get notificationPref_mentions => 'Mentions only';

  @override
  String get notificationPref_custom => 'Custom';

  @override
  String get notificationPref_sound => 'Sound';

  @override
  String get notificationPref_vibration => 'Vibration';

  @override
  String get notificationPref_banner => 'Banner';

  @override
  String get appSettings_messaging => 'Nachrichten';

  @override
  String get appSettings_clearPathOnMaxRetry =>
      'Lösche Pfade bei Max Wiederholungsversuchen';

  @override
  String get appSettings_clearPathOnMaxRetrySubtitle =>
      'Zurücksetzen der Kontaktpfade nach 5 fehlgeschlagenen Sendeabbrüchen';

  @override
  String get appSettings_pathsWillBeCleared =>
      'Die Pfade werden nach 5 fehlgeschlagenen Versuchen gelöscht.';

  @override
  String get appSettings_pathsWillNotBeCleared =>
      'Die Pfade werden nicht automatisch gelöscht.';

  @override
  String get appSettings_autoRouteRotation => 'Automatische Routenrotation';

  @override
  String get appSettings_autoRouteRotationSubtitle =>
      'Wechseln zwischen den besten Pfaden und dem Fluten';

  @override
  String get appSettings_autoRouteRotationEnabled =>
      'Automatische Routenrotation aktiviert';

  @override
  String get appSettings_autoRouteRotationDisabled =>
      'Automatische Routenrotation deaktiviert';

  @override
  String get appSettings_companionPathHashMode => 'Companion path hash size';

  @override
  String get appSettings_companionPathHashModeSubtitle =>
      'Hash size for flood packets and adverts from your companion radio';

  @override
  String get appSettings_companionPathHashMode1Byte =>
      '1-byte (legacy, up to 64 hops)';

  @override
  String get appSettings_companionPathHashMode2Byte =>
      '2-byte (default, up to 32 hops)';

  @override
  String get appSettings_companionPathHashMode3Byte => '3-byte (up to 21 hops)';

  @override
  String get appSettings_companionPathHashModeUnsupported =>
      'Requires companion firmware v1.14+';

  @override
  String get appSettings_companionPathHashModeWarning =>
      '2- and 3-byte paths require repeaters on firmware v1.14+. Older repeaters silently drop multibyte packets.';

  @override
  String get appSettings_companionPathHashModeApplied =>
      'Companion path hash size updated';

  @override
  String get appSettings_battery => 'Akku';

  @override
  String get appSettings_batteryChemistry => 'Batteriechemie';

  @override
  String appSettings_batteryChemistryPerDevice(String deviceName) {
    return 'Konfiguriert pro Gerät ($deviceName)';
  }

  @override
  String get appSettings_batteryChemistryConnectFirst =>
      'Verbinde ein Gerät, um zu wählen';

  @override
  String get appSettings_batteryNmc => '18650 NMC (3,0–4,2 V)';

  @override
  String get appSettings_batteryLifepo4 => 'LiFePO4 (2,6–3,65 V)';

  @override
  String get appSettings_batteryLipo => 'LiPo (3,0–4,2V)';

  @override
  String get appSettings_batteryCellCount => 'Cell Count';

  @override
  String get appSettings_batteryCellCount1S => '1S (single cell)';

  @override
  String get appSettings_batteryCellCount2S => '2S';

  @override
  String get appSettings_batteryCellCount3S => '3S';

  @override
  String get appSettings_batteryCellCount4S => '4S';

  @override
  String get appSettings_mapDisplay => 'Kartendarstellung';

  @override
  String get appSettings_showRepeaters => 'Zeige Repeater';

  @override
  String get appSettings_showRepeatersSubtitle =>
      'Zeige Repeater-Knoten auf der Karte an';

  @override
  String get appSettings_showChatNodes => 'Zeige Chat-Knoten';

  @override
  String get appSettings_showChatNodesSubtitle =>
      'Chat-Knoten auf der Karte anzeigen';

  @override
  String get appSettings_showOtherNodes => 'Zeige andere Knoten';

  @override
  String get appSettings_showOtherNodesSubtitle =>
      'Andere Knotentypen auf der Karte anzeigen';

  @override
  String get appSettings_timeFilter => 'Zeitfilter';

  @override
  String get appSettings_timeFilterShowAll => 'Alle Knoten anzeigen';

  @override
  String appSettings_timeFilterShowLast(int hours) {
    return 'Zeige Knoten der letzten $hours Stunden an';
  }

  @override
  String get appSettings_mapTimeFilter => 'Karten Zeitfilter';

  @override
  String get appSettings_showNodesDiscoveredWithin =>
      'Zeige Knoten, die innerhalb von:';

  @override
  String get appSettings_allTime => 'Ganzer Zeitverlauf';

  @override
  String get appSettings_lastHour => 'Letzte Stunde';

  @override
  String get appSettings_last6Hours => 'Letzte 6 Stunden';

  @override
  String get appSettings_last24Hours => 'Letzte 24 Stunden';

  @override
  String get appSettings_lastWeek => 'Letzte Woche';

  @override
  String get appSettings_offlineMapCache => 'Offline-Karten-Cache';

  @override
  String get appSettings_unitsTitle => 'Einheiten';

  @override
  String get appSettings_unitsMetric => 'Metrisch (m/km)';

  @override
  String get appSettings_unitsImperial => 'Imperial (ft/mi)';

  @override
  String get appSettings_noAreaSelected => 'Kein Bereich ausgewählt';

  @override
  String appSettings_areaSelectedZoom(int minZoom, int maxZoom) {
    return 'Ausgewählte Fläche (Zoom $minZoom-$maxZoom)';
  }

  @override
  String get appSettings_debugCard => 'Fehlerbehebung';

  @override
  String get appSettings_appDebugLogging => 'App-Debug-Protokollierung';

  @override
  String get appSettings_appDebugLoggingSubtitle =>
      'Protokolliere App-Debug-Nachrichten zur Fehlerbehebung';

  @override
  String get appSettings_appDebugLoggingEnabled =>
      'App-Debug-Protokollierung aktiviert';

  @override
  String get appSettings_appDebugLoggingDisabled =>
      'App-Debug-Protokollierung deaktiviert';

  @override
  String get contacts_addContactByScanQr => 'Add contact by QR code';

  @override
  String get contacts_scanQrCode => 'Scan a QR Code';

  @override
  String get contacts_scanQrCodeDesc =>
      'Scan a contact\'s QR code to add them.';

  @override
  String get contacts_invalidContactQr => 'Invalid contact QR code';

  @override
  String get contacts_showMyQrCode => 'Show my QR code';

  @override
  String get contacts_myQrCodeTitle => 'My QR Code';

  @override
  String get contacts_myQrCodeInstructions =>
      'Scan this code from another device to add this contact.';

  @override
  String get contacts_myQrCodeFailed => 'Could not load your contact QR code.';

  @override
  String get contacts_title => 'Kontakte';

  @override
  String get contacts_noContacts => 'Noch keine Kontakte vorhanden.';

  @override
  String get contacts_contactsWillAppear =>
      'Kontakte werden angezeigt, wenn Geräte eine Ankündigung machen.';

  @override
  String get contacts_searchContacts => 'Suche Kontakte...';

  @override
  String get contacts_noUnreadContacts => 'Keine ungesehene Kontakte';

  @override
  String get contacts_noContactsFound =>
      'Keine Kontakte oder Gruppen gefunden.';

  @override
  String get contacts_deleteContact => 'Lösche den Kontakt';

  @override
  String contacts_removeConfirm(String contactName) {
    return '$contactName aus den Kontakten entfernen?';
  }

  @override
  String get contacts_manageRepeater => 'Repeater verwalten';

  @override
  String get contacts_manageRoom => 'Raum-Server verwalten';

  @override
  String get contacts_roomLogin => 'Raum-Login';

  @override
  String get contacts_openChat => 'Öffne Chat';

  @override
  String get contacts_editGroup => 'Gruppe bearbeiten';

  @override
  String get contacts_deleteGroup => 'Löschen Gruppe';

  @override
  String contacts_deleteGroupConfirm(String groupName) {
    return 'Löschen von \"$groupName\"?';
  }

  @override
  String get contacts_newGroup => 'Neue Gruppe';

  @override
  String get contacts_groupName => 'Gruppenname';

  @override
  String get contacts_groupNameRequired => 'Der Gruppennamen ist erforderlich.';

  @override
  String contacts_groupAlreadyExists(String name) {
    return 'Die Gruppe \"$name\" existiert bereits.';
  }

  @override
  String get contacts_filterContacts => 'Filtert Kontakte...';

  @override
  String get contacts_noContactsMatchFilter =>
      'Keine Kontakte passen zu Ihrem Filter';

  @override
  String get contacts_noMembers => 'Keine Mitglieder';

  @override
  String get contacts_lastSeenNow => 'gerade gesehen';

  @override
  String contacts_lastSeenMinsAgo(int minutes) {
    return 'Letzte Sichtung vor $minutes Minuten.';
  }

  @override
  String get contacts_lastSeenHourAgo => 'Letzte Sichtung vor 1 Stunde.';

  @override
  String contacts_lastSeenHoursAgo(int hours) {
    return 'Letzte Sichtung vor $hours Stunden.';
  }

  @override
  String get contacts_lastSeenDayAgo => 'Letzte Sichtung vor 1 Tag';

  @override
  String contacts_lastSeenDaysAgo(int days) {
    return 'Letzte Sichtung $days Tage zuvor';
  }

  @override
  String get channels_title => 'Kanäle';

  @override
  String get channels_noChannelsConfigured => 'Keine Kanäle konfiguriert';

  @override
  String get channels_addPublicChannel => 'Öffentlichen Kanal hinzufügen';

  @override
  String get channels_searchChannels => 'Suche Kanäle...';

  @override
  String get channels_noChannelsFound => 'Keine Kanäle gefunden';

  @override
  String get channels_channelSlotsFull =>
      'All device channel slots are in use. Delete a channel before adding another.';

  @override
  String channels_channelAddFailed(String error) {
    return 'Could not add channel: $error';
  }

  @override
  String channels_channelIndex(int index) {
    return 'Kanal $index';
  }

  @override
  String get channels_hashtagChannel => 'Hashtag-Kanal';

  @override
  String get channels_public => 'Öffentlich';

  @override
  String get channels_private => 'Privat';

  @override
  String get channels_publicChannel => 'Öffentlicher Kanal';

  @override
  String get channels_privateChannel => 'Privater Kanal';

  @override
  String get channels_editChannel => 'Kanal bearbeiten';

  @override
  String get channels_deleteChannel => 'Lösche den Kanal';

  @override
  String channels_deleteChannelConfirm(String name) {
    return 'Löschen von \"$name\"? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get channels_deleteChannelRequiresConnection =>
      'Connect to a device to delete a channel';

  @override
  String channels_channelDeleted(String name) {
    return 'Kanal \"$name\" gelöscht';
  }

  @override
  String get channels_addChannel => 'Kanal hinzufügen';

  @override
  String get channels_channelIndexLabel => 'Kanalindex';

  @override
  String get channels_channelName => 'Kanalname';

  @override
  String get channels_usePublicChannel => 'Verwende öffentlichen Kanal';

  @override
  String get channels_standardPublicPsk => 'Öffentliche Standard PSK';

  @override
  String get channels_pskHex => 'PSK (Hex)';

  @override
  String get channels_generateRandomPsk => 'Zufällige PSK generieren';

  @override
  String get channels_enterChannelName =>
      'Bitte geben Sie einen Kanalnamen ein.';

  @override
  String get channels_pskMustBe32Hex =>
      'Die PSK muss 32 hexadezimale Zeichen haben.';

  @override
  String channels_channelAdded(String name) {
    return 'Kanal \"$name\" hinzugefügt';
  }

  @override
  String channels_editChannelTitle(int index) {
    return 'Bearbeiteter Kanal $index';
  }

  @override
  String get channels_smazCompression => 'SMAZ-Komprimierung';

  @override
  String channels_channelUpdated(String name) {
    return 'Kanal \"$name\" aktualisiert';
  }

  @override
  String get channels_publicChannelAdded => 'Öffentlicher Kanal hinzugefügt';

  @override
  String get channels_sortBy => 'Sortiere nach';

  @override
  String get channels_sortManual => 'Manuell';

  @override
  String get channels_sortAZ => 'A bis Z';

  @override
  String get channels_sortLatestMessages => 'Letzte Nachrichten';

  @override
  String get channels_sortUnread => 'Ungelesen';

  @override
  String get channels_createPrivateChannel => 'Erstelle einen privaten Kanal';

  @override
  String get channels_createPrivateChannelDesc =>
      'Verschlüsselt mit einem geheimen Schlüssel.';

  @override
  String get channels_joinPrivateChannel =>
      'Treten Sie einem privaten Kanal bei';

  @override
  String get channels_joinPrivateChannelDesc =>
      'Manuelle Eingabe eines geheimen Schlüssels.';

  @override
  String get channels_joinPublicChannel => 'Tritt dem öffentlichen Kanal bei';

  @override
  String get channels_joinPublicChannelDesc =>
      'Jeder kann diesem Kanal beitreten.';

  @override
  String get channels_joinHashtagChannel =>
      'Treten Sie einem Hashtag-Kanal bei';

  @override
  String get channels_joinHashtagChannelDesc =>
      'Jeder kann sich bei Hashtag-Kanälen beteiligen.';

  @override
  String get channels_scanQrCode => 'Scannen Sie einen QR-Code';

  @override
  String get channels_scanQrCodeDesc =>
      'Import a channel invite with name, key, and optional region.';

  @override
  String get channels_scanQrCodeComingSoon => 'Bald verfügbar';

  @override
  String get channels_invalidInviteQr => 'Invalid channel invite QR code';

  @override
  String get channels_shareChannel => 'Share channel';

  @override
  String get channels_shareChannelTitle => 'Share Channel';

  @override
  String channels_shareChannelInstructions(String name) {
    return 'Scan to join \"$name\"';
  }

  @override
  String get channels_setScope => 'Set region scope';

  @override
  String get channels_scopeCleared => 'Region scope cleared';

  @override
  String channels_scopeUpdated(String code) {
    return 'Region scope set to $code';
  }

  @override
  String get channels_scopeUnscoped => 'Unscoped';

  @override
  String get channels_scopeUseArea => 'Use this area';

  @override
  String channels_scopeUseEntire(String name) {
    return 'Use entire $name';
  }

  @override
  String get channels_scopeSet => 'Set scope';

  @override
  String get channels_scopeCoverageHint =>
      'Messages flood only within this area';

  @override
  String get channels_scopeMorePrecise => 'More precise';

  @override
  String get channels_scopeClear => 'Clear scope';

  @override
  String get channels_scopeTitle => 'Region scope';

  @override
  String get channels_scopeBreadcrumb => 'Current level';

  @override
  String get channels_scopeGulfCoast => 'Gulf Coast';

  @override
  String get channels_scopeEnterManually => 'Enter region code';

  @override
  String get channels_scopeManualHint => 'Region code';

  @override
  String get channels_scopePromptSubtitle => 'Choose where messages can flood';

  @override
  String get channels_enterHashtag => 'Gib Hashtag ein';

  @override
  String get channels_hashtagHint => 'z.B. #team';

  @override
  String get chat_noMessages => 'Noch keine Nachrichten.';

  @override
  String get chat_sendMessageToStart => 'Eine Nachricht senden, um anzufangen.';

  @override
  String get chat_originalMessageNotFound => 'Originalmeldung nicht gefunden';

  @override
  String chat_replyingTo(String name) {
    return 'Antworten an $name';
  }

  @override
  String chat_replyTo(String name) {
    return 'Antwort an $name';
  }

  @override
  String get chat_location => 'Ort';

  @override
  String chat_sendMessageTo(String contactName) {
    return 'Sende eine Nachricht an $contactName';
  }

  @override
  String get chat_typeMessage => 'Eine Nachricht eingeben...';

  @override
  String chat_messageTooLong(int maxBytes) {
    return 'Nachricht ist zu lang (max $maxBytes Bytes).';
  }

  @override
  String get chat_messageCopied => 'Nachricht kopiert';

  @override
  String get chat_messageDeleted => 'Nachricht gelöscht';

  @override
  String get chat_retryingMessage => 'Versuche es erneut.';

  @override
  String chat_retryCount(int current, int max) {
    return 'Versuche $current/$max';
  }

  @override
  String get chat_sendGif => 'GIF senden';

  @override
  String get chat_sendWaypoint => 'Send waypoint';

  @override
  String get chat_waypointShared => 'Waypoint shared';

  @override
  String get chat_pickLocationHint => 'Tap the map to place a waypoint';

  @override
  String get chat_locationPermissionRequired =>
      'Location permission is required to use your current position';

  @override
  String get chat_reply => 'Beantworten';

  @override
  String get chat_addReaction => 'Reaktion hinzufügen';

  @override
  String get chat_editMessage => 'Edit message';

  @override
  String get chat_editedLabel => '(edited)';

  @override
  String get chat_messageEdited => 'Message edited';

  @override
  String get chat_me => 'Ich';

  @override
  String get emojiCategorySmileys => 'Emoticons';

  @override
  String get emojiCategoryGestures => 'Gesten';

  @override
  String get emojiCategoryHearts => 'Herz';

  @override
  String get emojiCategoryObjects => 'Objekte';

  @override
  String get gifPicker_title => 'Wähle ein GIF';

  @override
  String get gifPicker_searchHint => 'Suche nach GIFs...';

  @override
  String get gifPicker_poweredBy => 'Bereitgestellt von GIPHY';

  @override
  String get gifPicker_noGifsFound => 'Keine GIFs gefunden';

  @override
  String get gifPicker_failedLoad => 'GIF-Datei konnten nicht geladen werden.';

  @override
  String get gifPicker_failedSearch => 'Suche nach GIFs fehlgeschlagen';

  @override
  String get gifPicker_noInternet => 'Keine Internetverbindung';

  @override
  String get debugLog_appTitle => 'App-Debug-Protokoll';

  @override
  String get debugLog_bleTitle => 'BLE-Debug-Protokoll';

  @override
  String get debugLog_copyLog => 'Kopieren des Protokolls';

  @override
  String get debugLog_clearLog => 'Protokoll löschen';

  @override
  String get debugLog_copied => 'Debug-Protokoll kopiert';

  @override
  String get debugLog_bleCopied => 'BLE-Protokoll kopiert';

  @override
  String get debugLog_noEntries => 'No Debug-Protokolle noch verfügbar';

  @override
  String get debugLog_enableInSettings =>
      'Aktivieren Sie das App-Debug-Logging in den Einstellungen';

  @override
  String get debugLog_frames => 'Rahmen';

  @override
  String get debugLog_rawLogRx => 'Roh-Log-RX';

  @override
  String get debugLog_noBleActivity => 'Bisher keine BLE-Aktivität';

  @override
  String get debugLog_sendLogs => 'Send logs to support';

  @override
  String get debugLog_sendLogsSuccess => 'Debug report sent — thank you!';

  @override
  String get debugLog_sendLogsEmailCopied =>
      'support@gulfcoastmesh.org copied to your clipboard — paste it as the recipient';

  @override
  String get debugLog_sendLogsFailed => 'Couldn\'t prepare the log archive';

  @override
  String get debugLog_reportDialogTitle => 'Report a Problem';

  @override
  String get debugLog_reportDialogBody =>
      'This sends your recent app activity and connection logs to Gulf Coast Mesh support to help diagnose the issue.';

  @override
  String get debugLog_reportDescriptionLabel => 'What happened? (optional)';

  @override
  String get debugLog_reportDescriptionHint =>
      'e.g. Messages stopped syncing after I renamed my node';

  @override
  String get debugLog_reportSendButton => 'Send Report';

  @override
  String get debugLog_enablePromptTitle => 'Enable Debug Logging?';

  @override
  String get debugLog_enablePromptBody =>
      'App debug logging is currently off. Turning it on before you reproduce the issue captures details that make it much easier for us to diagnose your report.';

  @override
  String get debugLog_enablePromptNotNow => 'Not Now';

  @override
  String get debugLog_enablePromptOpenSettings => 'Open Settings';

  @override
  String get debugLog_reportCodeDialogTitle => 'Report Sent';

  @override
  String get debugLog_reportCodeDialogBody =>
      'Give this code to support if they ask for it:';

  @override
  String get debugLog_reportCodeCopied => 'Reference code copied';

  @override
  String get debugLog_recentCodesTitle => 'Recent Report Codes';

  @override
  String get debugLog_recentCodesSubtitle =>
      'View codes from reports you\'ve sent';

  @override
  String get debugLog_recentCodesEmpty => 'No reports sent yet';

  @override
  String debugFrame_length(int count) {
    return 'Rahmenlänge: $count Bytes';
  }

  @override
  String debugFrame_command(String value) {
    return 'Befehl: 0x$value';
  }

  @override
  String get debugFrame_textMessageHeader => 'Textnachrichten Frame:';

  @override
  String debugFrame_destinationPubKey(String pubKey) {
    return '- Ziel-Public-Schlüssel: $pubKey';
  }

  @override
  String debugFrame_timestamp(int timestamp) {
    return '- Zeitstempel: $timestamp';
  }

  @override
  String debugFrame_flags(String value) {
    return '- Flags: 0x$value';
  }

  @override
  String debugFrame_textType(int type, String label) {
    return '- Textart: $type ($label)';
  }

  @override
  String get debugFrame_textTypeCli => 'CLI';

  @override
  String get debugFrame_textTypePlain => 'Einfach';

  @override
  String debugFrame_text(String text) {
    return '- Text: \"$text\"';
  }

  @override
  String get debugFrame_hexDump => 'Hex-Dump:';

  @override
  String get chat_pathManagement => 'Pfadverwaltung';

  @override
  String get chat_ShowAllPaths => 'Alle Pfade anzeigen';

  @override
  String get chat_routingMode => 'Routenmodus';

  @override
  String get chat_autoUseSavedPath =>
      'Automatisch (gespeicherten Pfad verwenden)';

  @override
  String get chat_forceFloodMode => 'Flut-Modus erzwingen';

  @override
  String get chat_recentAckPaths =>
      'Aktuelle ACK-Pfade (antippen, um zu verwenden):';

  @override
  String get chat_pathHistoryFull =>
      'Die Pfadhistorie ist voll. Entferne Einträge, um neue hinzuzufügen.';

  @override
  String get chat_hopSingular => 'Sprung';

  @override
  String get chat_hopPlural => 'Sprünge';

  @override
  String chat_hopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sprünge',
      one: 'Sprung',
    );
    return '$count $_temp0';
  }

  @override
  String get chat_successes => 'Erfolgreich';

  @override
  String get chat_removePath => 'Pfad entfernen';

  @override
  String get chat_noPathHistoryYet =>
      'Keine Pfadhistorie vorhanden.\nSende eine Nachricht, um Pfade zu entdecken.';

  @override
  String get chat_pathActions => 'Pfadaktionen:';

  @override
  String get chat_setCustomPath => 'Lege benutzerdefinierten Pfad fest';

  @override
  String get chat_setCustomPathSubtitle => 'Manuellen Routenpfad festlegen';

  @override
  String get chat_clearPath => 'Pfad zurücksetzen';

  @override
  String get chat_clearPathSubtitle =>
      'Setze Pfad zurück, erkenne neuen Pfad bei nächster Sendung.';

  @override
  String get chat_pathCleared =>
      'Pfad zurückgesetzt. Nächste Nachricht wird Route neu entdecken.';

  @override
  String get chat_floodModeSubtitle =>
      'Verwende den Routingschalter in der App-Leiste';

  @override
  String get chat_floodModeEnabled => 'Flutmodus aktiviert.';

  @override
  String get chat_fullPath => 'Vollständiger Pfad';

  @override
  String get chat_pathDetailsNotAvailable =>
      'Die Pfaddetails sind noch nicht verfügbar. Versuchen Sie, eine Nachricht zu senden, um zu aktualisieren.';

  @override
  String chat_pathSetHops(int hopCount, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      hopCount,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Pfad gesetzt: $hopCount $_temp0 - $status';
  }

  @override
  String get chat_pathSavedLocally =>
      'Lokal Gespeichert. Bitte Verbinden zum Synchronisieren.';

  @override
  String get chat_pathDeviceConfirmed => 'Gerät bestätigt.';

  @override
  String get chat_pathDeviceNotConfirmed => 'Gerät noch nicht bestätigt.';

  @override
  String get chat_type => 'Gebe ein';

  @override
  String get chat_path => 'Pfad';

  @override
  String get chat_publicKey => 'Öffentlicher Schlüssel';

  @override
  String get chat_compressOutgoingMessages =>
      'Komprimieren ausgehender Nachrichten';

  @override
  String get chat_floodForced => 'Geflutet (erzwungen)';

  @override
  String get chat_directForced => 'Direkt (erzwungen)';

  @override
  String chat_hopsForced(int count) {
    return '$count Sprünge (erzwungen)';
  }

  @override
  String get chat_floodAuto => 'Geflutet (automatisch)';

  @override
  String get chat_direct => 'Direkt';

  @override
  String get chat_poiShared => 'Geteilter POI';

  @override
  String chat_unread(int count) {
    return 'Ungelesen: $count';
  }

  @override
  String get chat_openLink => 'Link öffnen?';

  @override
  String get chat_openLinkConfirmation =>
      'Möchten Sie diesen Link in Ihrem Browser öffnen?';

  @override
  String get chat_open => 'Öffnen';

  @override
  String chat_couldNotOpenLink(String url) {
    return 'Link konnte nicht geöffnet werden: $url';
  }

  @override
  String get chat_invalidLink => 'Ungültiges Link-Format';

  @override
  String get map_title => 'Karte';

  @override
  String get map_lineOfSight => 'Sichtlinie';

  @override
  String get map_losScreenTitle => 'Sichtlinie';

  @override
  String get map_noNodesWithLocation => 'Keine Knoten mit Standortdaten';

  @override
  String get map_nodesNeedGps =>
      'Knoten müssen ihre GPS-Koordinaten teilen,\num auf der Karte zu erscheinen.';

  @override
  String map_nodesCount(int count) {
    return 'Knoten: $count';
  }

  @override
  String map_pinsCount(int count) {
    return 'Pins: $count';
  }

  @override
  String get map_chat => 'Benutzer';

  @override
  String get map_repeater => 'Repeater';

  @override
  String get map_room => 'Raum';

  @override
  String get map_sensor => 'Sensor';

  @override
  String get map_pinDm => 'Pin (Kontakt)';

  @override
  String get map_pinPrivate => 'Pin (Channel)';

  @override
  String get map_pinPublic => 'Pin (Public)';

  @override
  String get map_lastSeen => 'Letzte Sichtung';

  @override
  String get map_disconnectConfirm =>
      'Sind Sie sicher, dass Sie sich von diesem Gerät trennen möchten?';

  @override
  String get map_from => 'Von';

  @override
  String get map_source => 'Quelle';

  @override
  String get map_flags => 'Flags';

  @override
  String get map_pinLabel => 'Pin Name';

  @override
  String get map_label => 'Label';

  @override
  String get map_publicLocationShare => 'Öffentliche Standortfreigabe';

  @override
  String map_publicLocationShareConfirm(String channelLabel) {
    return 'Sie werden kurz darauf einen Ort in $channelLabel teilen. Dieser Kanal ist öffentlich und jeder mit dem PSK kann ihn sehen.';
  }

  @override
  String get map_connectToShareMarkers =>
      'Verbinde ein Gerät, um Marker zu teilen';

  @override
  String get map_filterNodes => 'Knotenfilter';

  @override
  String get map_nodeTypes => 'Knotentypen';

  @override
  String get map_chatNodes => 'Chat-Knoten';

  @override
  String get map_repeaters => 'Repeater';

  @override
  String get map_otherNodes => 'Andere Knoten';

  @override
  String get map_keyPrefix => 'Schlüsselpräfix';

  @override
  String get map_filterByKeyPrefix => 'Filter nach Schlüsselpräfix';

  @override
  String get map_publicKeyPrefix => 'Schlüsselpräfix';

  @override
  String get map_markers => 'Marker';

  @override
  String get map_showSharedMarkers => 'Zeige gemeinsam genutzte Marker';

  @override
  String get map_lastSeenTime => 'Letzte Sichtung';

  @override
  String get map_joinRoom => 'Beitreten Sie dem Raum';

  @override
  String get map_manageRepeater => 'Repeater verwalten';

  @override
  String get map_tapToAdd =>
      'Tippen Sie auf Knoten, um sie zum Pfad hinzuzufügen.';

  @override
  String get map_runTrace => 'Pfadverlauf ausführen';

  @override
  String get map_removeLast => 'Letztes Entfernen';

  @override
  String get map_pathTraceCancelled => 'Pfadverfolgung abgebrochen.';

  @override
  String get map_atakTitle => 'ATAK Channel';

  @override
  String get map_atakNotJoined => 'Not joined';

  @override
  String get map_atakJoinChannel => 'Join #atak';

  @override
  String get map_atakSelectChannel => 'Select channel';

  @override
  String get map_atakClearSelection => 'Clear selection';

  @override
  String get map_atakBroadcastEnabled => 'Broadcast location';

  @override
  String get map_atakBroadcastEnabledSubtitle =>
      'Send your position to the selected channel';

  @override
  String get map_atakBroadcasting => 'Broadcasting';

  @override
  String get map_atakMovementMeters => 'Movement threshold (meters)';

  @override
  String get map_atakMinIntervalSec => 'Minimum send interval (seconds)';

  @override
  String get map_atakAdvancedSettings => 'Broadcast settings';

  @override
  String map_atakChannelJoined(String name) {
    return 'Joined $name';
  }

  @override
  String get map_atakConnectToJoin => 'Connect to a device to join channels';

  @override
  String get map_atakNoChannels => 'No channels configured';

  @override
  String get map_atakLocationPermissionDenied =>
      'Location permission is required to broadcast your position';

  @override
  String get map_atakSyncNodeAdvert => 'Sync radio advert location';

  @override
  String get map_atakSyncNodeAdvertSubtitle =>
      'Update the connected radio\'s advertised location whenever a position is broadcast';

  @override
  String map_atakParticipantsCount(int count) {
    return 'ATAK: $count';
  }

  @override
  String map_atakPoisCount(int count) {
    return 'POIs: $count';
  }

  @override
  String get map_atakParticipant => 'ATAK participant';

  @override
  String get map_atakPoi => 'ATAK POI';

  @override
  String get map_lastUpdate => 'Last update';

  @override
  String get map_markerType => 'Type';

  @override
  String get map_markOnMap => 'Mark on map';

  @override
  String get map_markerTypePoi => 'Point of interest';

  @override
  String get map_markerTypeWaypoint => 'Waypoint';

  @override
  String get map_markerTypeTarget => 'Target';

  @override
  String get map_markerTypeHazard => 'Hazard';

  @override
  String get map_atakCustomChannel => 'Custom channel';

  @override
  String get map_atakCustomChannelHint => 'Hashtag name (e.g. myteam)';

  @override
  String get map_atakUseCustomChannel => 'Use channel';

  @override
  String get map_atakEnterChannelName => 'Enter a channel name';

  @override
  String get map_atakChannelNotEligible =>
      'Public channel cannot be used for ATAK';

  @override
  String get map_atakSelectChannelToMark =>
      'Select an ATAK channel in the panel above';

  @override
  String map_atakMarkerSent(String channel) {
    return 'Marker sent to $channel';
  }

  @override
  String get mapCache_title => 'Offline-Karten-Cache';

  @override
  String get mapCache_selectAreaFirst =>
      'Wählen Sie zuerst einen Bereich zum Zwischenspeichern aus.';

  @override
  String get mapCache_noTilesToDownload =>
      'Keine Kacheln für diese Region zum Herunterladen verfügbar.';

  @override
  String get mapCache_downloadTilesTitle => 'Herunterladen von Kacheln';

  @override
  String mapCache_downloadTilesPrompt(int count) {
    return 'Laden $count Kacheln für den Offline-Bereich herunter?';
  }

  @override
  String get mapCache_downloadAction => 'Herunterladen';

  @override
  String mapCache_cachedTiles(int count) {
    return 'Zwischengespeicherte $count Kacheln';
  }

  @override
  String mapCache_cachedTilesWithFailed(int downloaded, int failed) {
    return 'Zwischengespeicherte $downloaded Kacheln ($failed fehlgeschlagen)';
  }

  @override
  String get mapCache_clearOfflineCacheTitle => 'Leere Offline-Cache';

  @override
  String get mapCache_clearOfflineCachePrompt =>
      'Alle zwischengespeicherten Kartenraster entfernen?';

  @override
  String get mapCache_offlineCacheCleared => 'Offline-Cache gelöscht';

  @override
  String get mapCache_noAreaSelected => 'Kein Bereich ausgewählt';

  @override
  String get mapCache_cacheArea => 'Zwischenspeicherbereich';

  @override
  String get mapCache_useCurrentView => 'Aktuelle Ansicht verwenden';

  @override
  String get mapCache_zoomRange => 'Zoom Bereich';

  @override
  String mapCache_estimatedTiles(int count) {
    return 'Geschätzte Kacheln: $count';
  }

  @override
  String mapCache_downloadedTiles(int completed, int total) {
    return 'Heruntergeladen $completed / $total';
  }

  @override
  String get mapCache_downloadTilesButton => 'Herunterladen von Kacheln';

  @override
  String get mapCache_clearCacheButton => 'Cache leeren';

  @override
  String mapCache_failedDownloads(int count) {
    return 'Fehlgeschlagene Downloads: $count';
  }

  @override
  String mapCache_boundsLabel(
    String north,
    String south,
    String east,
    String west,
  ) {
    return 'N $north, S $south, E $east, W $west';
  }

  @override
  String get mapCache_worldOverview => 'World overview';

  @override
  String get mapCache_worldOverviewHint =>
      'Low-zoom global map for context when zoomed out.';

  @override
  String get mapCache_worldZoomHighWarning =>
      'Zoom above 5 downloads many tiles. Prefer 2–5 for a light global layer.';

  @override
  String get mapCache_downloadWorldButton => 'Download world';

  @override
  String get mapCache_presetAreas => 'Regional presets';

  @override
  String get mapCache_presetGulfCoast => 'Gulf Coast';

  @override
  String get mapCache_customArea => 'Custom area';

  @override
  String get mapCache_wifiRequired => 'Connect to Wi‑Fi to download map tiles.';

  @override
  String get mapCache_downloadAllButton => 'Download all';

  @override
  String mapCache_downloadAllSummary(int count) {
    return 'Download all configured layers: about $count tiles.';
  }

  @override
  String appSettings_mapCacheSummaryWorld(int minZoom, int maxZoom) {
    return 'World z$minZoom–$maxZoom';
  }

  @override
  String appSettings_mapCacheSummaryCustom(int minZoom, int maxZoom) {
    return 'Custom z$minZoom–$maxZoom';
  }

  @override
  String get time_justNow => 'Gerade eben';

  @override
  String time_minutesAgo(int minutes) {
    return '$minutes Minuten her';
  }

  @override
  String time_hoursAgo(int hours) {
    return '$hours Stunden her';
  }

  @override
  String time_daysAgo(int days) {
    return '$days Tage/Tage zuvor';
  }

  @override
  String get time_hour => 'Stunde';

  @override
  String get time_hours => 'Stunden';

  @override
  String get time_day => 'Tag';

  @override
  String get time_days => 'Tage';

  @override
  String get time_week => 'Woche';

  @override
  String get time_weeks => 'Wochen';

  @override
  String get time_month => 'Monat';

  @override
  String get time_months => 'Monate';

  @override
  String get time_minutes => 'Minuten';

  @override
  String get time_allTime => 'Ganzer Zeitraum';

  @override
  String get dialog_disconnect => 'Trennen';

  @override
  String get dialog_disconnectConfirm =>
      'Sind Sie sicher, dass Sie sich von diesem Gerät trennen möchten?';

  @override
  String get login_repeaterLogin => 'Beim Repeater anmelden';

  @override
  String get login_roomLogin => 'Raum-Login';

  @override
  String get login_password => 'Passwort';

  @override
  String get login_enterPassword => 'Passwort eingeben';

  @override
  String get login_savePassword => 'Passwort speichern';

  @override
  String get login_savePasswordSubtitle =>
      'Das Passwort wird auf diesem Gerät sicher gespeichert.';

  @override
  String get login_repeaterDescription =>
      'Geben Sie das Repeater-Passwort ein, um auf Einstellungen und Status zuzugreifen.';

  @override
  String get login_roomDescription =>
      'Geben Sie das Raumkennwort ein, um auf die Einstellungen und den Status zuzugreifen.';

  @override
  String get login_routing => 'Routen';

  @override
  String get login_routingMode => 'Routenmodus';

  @override
  String get login_autoUseSavedPath =>
      'Automatisch (gespeicherten Pfad verwenden)';

  @override
  String get login_forceFloodMode => 'Flut-Modus erzwingen';

  @override
  String get login_managePaths => 'Pfadverwaltung';

  @override
  String get login_login => 'Anmelden';

  @override
  String login_attempt(int current, int max) {
    return 'Versuche $current/$max';
  }

  @override
  String login_failed(String error) {
    return 'Anmeldung fehlgeschlagen: $error';
  }

  @override
  String get login_failedMessage =>
      'Anmeldung fehlgeschlagen. Entweder ist das Passwort falsch oder der Repeater ist nicht erreichbar.';

  @override
  String get common_reload => 'Neu laden';

  @override
  String get common_clear => 'Löschen';

  @override
  String path_currentPath(String path) {
    return 'Aktiver Pfad: $path';
  }

  @override
  String path_usingHopsPath(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hops',
      one: 'Hop',
    );
    return 'Verwenden Sie $count $_temp0 Pfad';
  }

  @override
  String get path_enterCustomPath => 'Gebe Pfad ein';

  @override
  String get path_currentPathLabel => 'Aktueller Pfad';

  @override
  String get path_hexPrefixInstructions =>
      'Gebe für jeden Zwischen-Hop das 2-stellige Hex-Präfix ein, getrennt durch Kommas.';

  @override
  String get path_hexPrefixExample =>
      'Beispiel: A1,F2,3C (jeder Knoten verwendet den ersten Byte seines öffentlichen Schlüssels)';

  @override
  String get path_labelHexPrefixes => 'Pfad (Hex-Präfixe)';

  @override
  String get path_helperMaxHops =>
      'Max 64 Sprünge. Jede Präfixe ist 2 Hexadezimalzeichen (1 Byte)';

  @override
  String get path_selectFromContacts => 'Oder wähle aus Kontakten aus:';

  @override
  String get path_noRepeatersFound =>
      'Keine Repeater oder Raumserver gefunden.';

  @override
  String get path_customPathsRequire =>
      'Benutzerdefinierte Pfade erfordern Zwischen-Hops, die Nachrichten weiterleiten können.';

  @override
  String path_invalidHexPrefixes(String prefixes) {
    return 'Ungültige Hexadezimal-Präfixe: $prefixes';
  }

  @override
  String get path_tooLong => 'Pfad zu lang. Maximal 64 Hops erlaubt.';

  @override
  String get path_setPath => 'Pfad festlegen';

  @override
  String get repeater_management => 'Repeater-Verwaltung';

  @override
  String get room_management => 'Raum-Server-Verwaltung';

  @override
  String get repeater_managementTools => 'Verwaltungs-Tools';

  @override
  String get repeater_status => 'Status';

  @override
  String get repeater_statusSubtitle =>
      'Status, Statistiken und Nachbarn anzeigen';

  @override
  String get repeater_sendAdvert => 'Send Advert';

  @override
  String get repeater_sendAdvertSubtitle =>
      'Broadcast an advertisement packet now';

  @override
  String get repeater_telemetry => 'Telemetrie';

  @override
  String get repeater_telemetrySubtitle =>
      'Sensordaten und Systemwerte anzeigen';

  @override
  String get repeater_cli => 'CLI';

  @override
  String get repeater_cliSubtitle => 'Sende Befehle an den Repeater';

  @override
  String get repeater_neighbors => 'Nachbarn';

  @override
  String get repeater_neighborsSubtitle => 'Anzahl der Hop-Nachbarn anzeigen.';

  @override
  String get repeater_settings => 'Einstellungen';

  @override
  String get repeater_settingsSubtitle => 'Repeater-parameter konfigurieren';

  @override
  String get repeater_statusTitle => 'Repeaterstatus';

  @override
  String get repeater_routingMode => 'Routenmodus';

  @override
  String get repeater_autoUseSavedPath =>
      'Automatisch (gespeicherten Pfad verwenden)';

  @override
  String get repeater_forceFloodMode => 'Flut-Modus erzwingen';

  @override
  String get repeater_pathManagement => 'Pfadverwaltung';

  @override
  String get repeater_refresh => 'Aktualisieren';

  @override
  String get repeater_statusRequestTimeout =>
      'Statusanfrage durch Timeout fehlgeschlagen.';

  @override
  String repeater_errorLoadingStatus(String error) {
    return 'Fehler beim Laden des Status: $error';
  }

  @override
  String get repeater_systemInformation => 'Systeminformation';

  @override
  String get repeater_firmwareVersion => 'Firmware';

  @override
  String get repeater_battery => 'Akku';

  @override
  String get repeater_clockAtLogin => 'Uhr (bei Anmeldung)';

  @override
  String get repeater_uptime => 'Verfügbarkeit';

  @override
  String get repeater_queueLength => 'Warteschlangenlänge';

  @override
  String get repeater_debugFlags => 'Fehlerbehebungsoptionen';

  @override
  String get repeater_radioStatistics => 'Funk-Statistik';

  @override
  String get repeater_lastRssi => 'Letzter RSSI';

  @override
  String get repeater_lastSnr => 'Letzter SNR';

  @override
  String get repeater_noiseFloor => 'Rauschpegel';

  @override
  String get repeater_txAirtime => 'TX Airtime';

  @override
  String get repeater_rxAirtime => 'RX Airtime';

  @override
  String get repeater_packetStatistics => 'Paketstatistiken';

  @override
  String get repeater_sent => 'Gesendet';

  @override
  String get repeater_received => 'Empfangen';

  @override
  String get repeater_duplicates => 'Duplikate';

  @override
  String repeater_daysHoursMinsSecs(
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return '$days Tage ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  String repeater_packetTxTotal(int total, String flood, String direct) {
    return 'Gesamt: $total, Flut: $flood, Direkt: $direct';
  }

  @override
  String repeater_packetRxTotal(int total, String flood, String direct) {
    return 'Gesamt: $total, Flut: $flood, Direkt: $direct';
  }

  @override
  String repeater_duplicatesFloodDirect(String flood, String direct) {
    return 'Flut: $flood, Direkt: $direct';
  }

  @override
  String repeater_duplicatesTotal(int total) {
    return 'Gesamt: $total';
  }

  @override
  String get repeater_settingsTitle => 'Repeater Einstellungen';

  @override
  String get repeater_basicSettings => 'Grundlegende Einstellungen';

  @override
  String get repeater_repeaterName => 'Repeater Name';

  @override
  String get repeater_repeaterNameHelper => 'Anzeigename für diesen Repeater';

  @override
  String get repeater_adminPassword => 'Admin-Passwort';

  @override
  String get repeater_adminPasswordHelper => 'Vollzugriffspasswort';

  @override
  String get repeater_guestPassword => 'Gast-Passwort';

  @override
  String get repeater_guestPasswordHelper =>
      'Schreibgeschütztes Zugriffspasswort';

  @override
  String get repeater_radioSettings => 'Funk Einstellungen';

  @override
  String get repeater_frequencyMhz => 'Frequenz (MHz)';

  @override
  String get repeater_frequencyHelper => '300-2500 MHz';

  @override
  String get repeater_txPower => 'TX Power';

  @override
  String get repeater_txPowerHelper => '1-30 dBm';

  @override
  String get repeater_bandwidth => 'Bandbreite';

  @override
  String get repeater_spreadingFactor => 'Verteilungsfaktor';

  @override
  String get repeater_codingRate => 'Kodierungsrate';

  @override
  String get repeater_locationSettings => 'Standort Einstellungen';

  @override
  String get repeater_latitude => 'Breitengrad';

  @override
  String get repeater_latitudeHelper => 'Dezimalgrad (z.B. 37,7749)';

  @override
  String get repeater_longitude => 'Längengrad';

  @override
  String get repeater_longitudeHelper => 'Dezimalgrad (z.B. -122,4194)';

  @override
  String get repeater_features => 'Funktionen';

  @override
  String get repeater_packetForwarding => 'Paketweiterleitung';

  @override
  String get repeater_packetForwardingSubtitle =>
      'Aktivieren Sie den Repeater, um Pakete weiterzuleiten.';

  @override
  String get repeater_guestAccess => 'Gastzugriff';

  @override
  String get repeater_guestAccessSubtitle =>
      'Gast-Zugriff mit beschränkten Rechten zulassen';

  @override
  String get repeater_privacyMode => 'Privatsphäreeinstellung';

  @override
  String get repeater_privacyModeSubtitle =>
      'Verstecken Sie Name/Ort in Ankündigungen';

  @override
  String get repeater_advertisementSettings => 'Ankündigungseinstellungen';

  @override
  String get repeater_pathHashMode => 'Advert path hash size';

  @override
  String get repeater_pathHashModeSubtitle =>
      'Path hash bytes in this repeater\'s adverts (firmware 1.14+)';

  @override
  String get repeater_pathHashModeLoading => 'Loading…';

  @override
  String get repeater_pathHashModeLoadFailed =>
      'Could not read setting (requires firmware 1.14+)';

  @override
  String get repeater_localAdvertInterval =>
      'Intervall der lokalen Ankündigungen';

  @override
  String repeater_localAdvertIntervalMinutes(int minutes) {
    return '$minutes Minuten';
  }

  @override
  String get repeater_floodAdvertInterval =>
      'Intervall der gefluteten Ankündigungen';

  @override
  String repeater_floodAdvertIntervalHours(int hours) {
    return '$hours Stunden';
  }

  @override
  String get repeater_encryptedAdvertInterval =>
      'Intervall der verschlüsselten Ankündigung';

  @override
  String get repeater_dangerZone => 'Gefahrenzone';

  @override
  String get repeater_rebootRepeater => 'Neustart Repeater';

  @override
  String get repeater_rebootRepeaterSubtitle => 'Repeater-Gerät neu starten.';

  @override
  String get repeater_rebootRepeaterConfirm =>
      'Sind Sie sicher, dass Sie diesen Repeater neu starten möchten?';

  @override
  String get repeater_regenerateIdentityKeySubtitle =>
      'Neuen öffentlichen/privaten Schlüsselpaar generieren';

  @override
  String get repeater_regenerateIdentityKeyConfirm =>
      'Dies generiert eine neue Identität für den Repeater. Fortfahren?';

  @override
  String get repeater_eraseFileSystem => 'Dateisystem löschen';

  @override
  String get repeater_eraseFileSystemSubtitle =>
      'Formatiere die Repeater-Dateisystemdatei';

  @override
  String get repeater_eraseFileSystemConfirm =>
      'WARNUNG: Dies löscht alle Daten auf dem Repeater. Dies kann nicht rückgängig gemacht werden!';

  @override
  String get repeater_eraseSerialOnly =>
      'Löschen ist nur über die serielle Konsole möglich.';

  @override
  String repeater_commandSent(String command) {
    return 'Befehl gesendet: $command';
  }

  @override
  String repeater_errorSendingCommand(String error) {
    return 'Fehler beim Senden des Befehls: $error';
  }

  @override
  String get repeater_confirm => 'Bestätigen';

  @override
  String get repeater_settingsSaved => 'Einstellungen erfolgreich gespeichert';

  @override
  String repeater_errorSavingSettings(String error) {
    return 'Fehler beim Speichern der Einstellungen: $error';
  }

  @override
  String get repeater_refreshBasicSettings =>
      'Grundlegende Einstellungen aktualisieren';

  @override
  String get repeater_refreshRadioSettings =>
      'Radio-Einstellungen aktualisieren';

  @override
  String get repeater_refreshTxPower => 'Sendeleistung aktualisieren';

  @override
  String get repeater_refreshLocationSettings =>
      'Aktualisieren Sie die Standort Einstellungen';

  @override
  String get repeater_refreshPacketForwarding =>
      'Aktualisieren Paketweiterleitung';

  @override
  String get repeater_refreshGuestAccess => 'Aktualisieren Sie den Gastzugriff';

  @override
  String get repeater_refreshPrivacyMode =>
      'Wiederherstellen des Datenschutzzustands';

  @override
  String get repeater_refreshAdvertisementSettings =>
      'Aktualisieren Sie die Ankündigungseinstellungen';

  @override
  String repeater_refreshed(String label) {
    return '$label wurde aktualisiert';
  }

  @override
  String repeater_errorRefreshing(String label) {
    return 'Fehler beim Aktualisieren von $label';
  }

  @override
  String get repeater_cliTitle => 'Repeater CLI';

  @override
  String get repeater_debugNextCommand => 'Fehlersuche des nächsten Befehls';

  @override
  String get repeater_commandHelp => 'Hilfe';

  @override
  String get repeater_clearHistory => 'Löschen der Historie';

  @override
  String get repeater_noCommandsSent => 'Noch keine Befehle gesendet.';

  @override
  String get repeater_typeCommandOrUseQuick =>
      'Geben Sie unten einen Befehl ein oder verwenden Sie die Schnellbefehle';

  @override
  String get repeater_enterCommandHint => 'Geben Sie den Befehl ein...';

  @override
  String get repeater_previousCommand => 'Vorhergehende Aktion';

  @override
  String get repeater_nextCommand => 'Nächste Aktion';

  @override
  String get repeater_enterCommandFirst => 'Geben Sie zuerst einen Befehl ein';

  @override
  String get repeater_cliCommandFrameTitle => 'CLI-Befehlsfenster';

  @override
  String repeater_cliCommandError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get repeater_cliQuickGetName => 'Name erhalten';

  @override
  String get repeater_cliQuickGetRadio => 'Radio empfangen';

  @override
  String get repeater_cliQuickGetTx => 'Erhalte TX';

  @override
  String get repeater_cliQuickNeighbors => 'Nachbarn';

  @override
  String get repeater_cliQuickVersion => 'Version';

  @override
  String get repeater_cliQuickAdvertise => 'Ankündigungen';

  @override
  String get repeater_cliQuickClock => 'Uhr';

  @override
  String get repeater_cliHelpAdvert => 'Sendet eine Ankündigung';

  @override
  String get repeater_cliHelpReboot =>
      'Startet das Gerät neu. (Beachten Sie, dass es möglicherweise zu einer \'Timeout\'-Situation kommt, was normal ist.)';

  @override
  String get repeater_cliHelpClock =>
      'Zeigt die aktuelle Uhrzeit pro Gerät an.';

  @override
  String get repeater_cliHelpPassword =>
      'Legt ein neues Administrator-Passwort für das Gerät fest.';

  @override
  String get repeater_cliHelpVersion =>
      'Zeigt die Geräteversion und das Datum des Firmware-Builds an.';

  @override
  String get repeater_cliHelpClearStats =>
      'Setzt verschiedene Statistikberechnungen auf Null zurück.';

  @override
  String get repeater_cliHelpSetAf => 'Legt den Luftzeitfaktor fest.';

  @override
  String get repeater_cliHelpSetTx =>
      'Legt die LoRa-Übertragungspower in dBm (bezogen auf 1 Watt) fest. (Neustart erforderlich, um die Änderungen anzuwenden)';

  @override
  String get repeater_cliHelpSetRepeat =>
      'Aktiviert oder deaktiviert die Repeater-Rolle für diesen Knoten.';

  @override
  String get repeater_cliHelpSetAllowReadOnly =>
      '(Raumspeicher) Wenn \'an\', dann wird die Anmeldung mit einem leeren Passwort erlaubt sein, aber es kann nicht in den Raum gesendet werden. (nur lesen möglich).';

  @override
  String get repeater_cliHelpSetFloodMax =>
      'Legt die maximale Anzahl an Hops für Pakete der eingehenden Flut (wenn >= max, wird das Paket nicht weitergeleitet)';

  @override
  String get repeater_cliHelpSetIntThresh =>
      'Legt den Interferenzeniveau (in dB) fest. Der Standardwert ist 14. Auf 0 setzen, um die Erkennung von Kanalinterferenzen zu deaktivieren.';

  @override
  String get repeater_cliHelpSetAgcResetInterval =>
      'Legt das Intervall für das Zurücksetzen des Auto Gain Controllers fest. Auf 0 setzen, um die Funktion zu deaktivieren.';

  @override
  String get repeater_cliHelpSetMultiAcks =>
      'Aktiviert oder deaktiviert die Funktion \'Doppel-ACKs\'.';

  @override
  String get repeater_cliHelpSetAdvertInterval =>
      'Legt das Timer-Intervall in Minuten fest, um ein lokales (ohne-Weiterleitung) Ankündigungspaket zu senden. Auf 0 setzen, um die Funktion zu deaktivieren.';

  @override
  String get repeater_cliHelpSetFloodAdvertInterval =>
      'Legt das Timer-Intervall in Stunden für den Versand eines Flut-Ankündigungspacket fest. Auf 0 setzen, um es zu deaktivieren.';

  @override
  String get repeater_cliHelpGetPathHashMode =>
      'Returns advert path hash mode (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetPathHashMode =>
      'Sets advert path hash mode for this repeater (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetGuestPassword =>
      'Legt/aktualisiert das Gastpasswort fest. (für Repeater können Gast-Logins die \"Get Stats\"-Anfrage senden)';

  @override
  String get repeater_cliHelpSetName => 'Legt den Anzeigenamen fest.';

  @override
  String get repeater_cliHelpSetLat =>
      'Legt die Breitengrad der Ankündigung fest. (dezimale Grad)';

  @override
  String get repeater_cliHelpSetLon =>
      'Legt die Längengrade der Ankündigung fest. (dezimale Grad)';

  @override
  String get repeater_cliHelpSetRadio =>
      'Legt komplett neue Radio-Parameter fest und speichert diese als Präferenzen. Benötigt einen \"Reboot\"-Befehl, um sie anzuwenden.';

  @override
  String get repeater_cliHelpSetRxDelay =>
      'Fügt eine leichte Verzögerung bei empfangenen Paketen hinzu, basierend auf Signalstärke/Punktzahl. Auf 0 setzen, um die Funktion zu deaktivieren.';

  @override
  String get repeater_cliHelpSetTxDelay =>
      'Legt einen Faktor fest, der mit der Zeit bei voller Zuluft für ein Flood-Mode-Paket und mit einem zufälligen Slot-System multipliziert wird, um dessen Weiterleitung zu verzögern (um Kollisionen zu vermeiden).';

  @override
  String get repeater_cliHelpSetDirectTxDelay =>
      'Ähnlich wie txdelay, aber zum Anwenden einer zufälligen Verzögerung bei der Weiterleitung von Direktmodus-Paketen.';

  @override
  String get repeater_cliHelpSetBridgeEnabled =>
      'Brücke aktivieren/deaktivieren.';

  @override
  String get repeater_cliHelpSetBridgeDelay =>
      'Setze Verzögerung vor erneuter Übertragung von Paketen.';

  @override
  String get repeater_cliHelpSetBridgeSource =>
      'Wählen Sie, ob über die Brücke empfangene oder gesendete Pakete erneut übertragen soll.';

  @override
  String get repeater_cliHelpSetBridgeBaud =>
      'Setze die serielle Link-Baudrate für RS232-Brücken.';

  @override
  String get repeater_cliHelpSetBridgeSecret =>
      'Richte das Brückenpassword ein.';

  @override
  String get repeater_cliHelpSetAdcMultiplier =>
      'Legt einen benutzerdefinierten Faktor zur Anpassung der gemeldeten Batteriewirkspannung fest (nur auf ausgewählten Boards unterstützt).';

  @override
  String get repeater_cliHelpTempRadio =>
      'Legt vorübergehende Funkparameter für die angegebene Anzahl von Minuten fest und kehrt anschließend zu den ursprünglichen Funkparametern zurück (wird nicht in den Einstellungen gespeichert).';

  @override
  String get repeater_cliHelpSetPerm =>
      'Ändert die ACL. Entfernt das passende Eintragen (durch Pubkey-Präfix), wenn \"permissions\" auf 0 steht. Fügt ein neues Eintragen hinzu, wenn die Pubkey-Hex-Länge vollständig ist und nicht bereits in der ACL vorhanden ist. Aktualisiert das Eintragen anhand des übereinstimmenden Pubkey-Präfix. Berechtigungsbits variieren je nach Firmware-Rolle, aber die unteren 2 Bits sind: 0 (Gast), 1 (Nur Lesen), 2 (Lesen/Schreiben), 3 (Admin)';

  @override
  String get repeater_cliHelpGetBridgeType =>
      'Ruft Brückentyp: none, rs232, espnow ab.';

  @override
  String get repeater_cliHelpLogStart =>
      'Beginnt die Paketprotokollierung in das Dateisystem.';

  @override
  String get repeater_cliHelpLogStop =>
      'Stoppt das Paketprotokollieren in das Dateisystem.';

  @override
  String get repeater_cliHelpLogErase =>
      'Löscht die Paketprotokolle aus dem Dateisystem.';

  @override
  String get repeater_cliHelpNeighbors =>
      'Zeigt eine Liste anderer Repeater-Knoten an, die über Zero-Hop-Ankündigung gehört wurden. Jede Zeile ist id-prefix-hex:timestamp:snr-times-4';

  @override
  String get repeater_cliHelpNeighborRemove =>
      'Entfernt das erste übereinstimmende Element (über Pubkey-Präfix (hex)) aus der Liste der Nachbarn.';

  @override
  String get repeater_cliHelpRegion => 'Listet alle definierten Regionen auf.';

  @override
  String get repeater_cliHelpRegionLoad =>
      'Hinweis: Dies ist ein spezieller Mehrbefehl-Aufruf. Jeder nachfolgende Befehl ist ein Regionsname (eingerückt mit Leerzeichen zur Angabe der übergeordneten Hierarchie, mit mindestens einem Leerzeichen). Beendet durch das Senden einer Leerzeile.';

  @override
  String get repeater_cliHelpRegionGet =>
      'Sucht die Region mit dem gegebenen Namenspräfix (oder \"\\\" für den globalen Scope) und antwortet mit \"-> region-name (parent-name) \'F\'\".';

  @override
  String get repeater_cliHelpRegionPut =>
      'Fügt eine Region-Definition mit dem angegebenen Namen hinzu oder aktualisiert diese.';

  @override
  String get repeater_cliHelpRegionRemove =>
      'Löscht eine Regiondefinition mit dem angegebenen Namen. (muss genau übereinstimmen und keine Kindregionen haben)';

  @override
  String get repeater_cliHelpRegionAllowf =>
      'Legt die \'Flut\'-Berechtigung für die angegebene Region fest. (\'\' für den globalen/legacy-Bereich)';

  @override
  String get repeater_cliHelpRegionDenyf =>
      'Entfernt die \"F\"lood-Berechtigung für die angegebene Region. (ANMERKUNG: in dieser Phase wird nicht empfohlen, dies auf dem globalen/legacy-Bereich zu verwenden!!)';

  @override
  String get repeater_cliHelpRegionHome =>
      'Antwortet mit der aktuellen \'Home\'-Region. (Hinweis wurde bisher nirgendwo angewendet, für zukünftige Zwecke reserviert)';

  @override
  String get repeater_cliHelpRegionHomeSet => 'Legt die \'Home\'-Region fest.';

  @override
  String get repeater_cliHelpRegionSave =>
      'Speichert die Regionenliste/Karte in den Speicher.';

  @override
  String get repeater_cliHelpGps =>
      'Zeigt GPS-Status an. Wenn GPS deaktiviert ist, antwortet es nur mit \"aus\", wenn es eingeschaltet ist, antwortet es mit \"an\", \"Status\", \"Fix\" und Satellitenanzahl.';

  @override
  String get repeater_cliHelpGpsOnOff => 'Schaltet die GPS-Leistung ein/aus.';

  @override
  String get repeater_cliHelpGpsSync =>
      'Synchronisiert die Knotenzeit mit der GPS-Uhr.';

  @override
  String get repeater_cliHelpGpsSetLoc =>
      'Setze die Position des Knotens auf GPS-Koordinaten und speichere die Präferenzen.';

  @override
  String get repeater_cliHelpGpsAdvert =>
      'Gibt Konfiguration für die Standortanzeige des Knotens:\n- none: Standort nicht in Anzeigen einbeziehen\n- share: GPS-Standort teilen (von SensorManager)\n- prefs: Standort aus Einstellungen anzeigen';

  @override
  String get repeater_cliHelpGpsAdvertSet =>
      'Legt die Standort-Anzeigekonfiguration fest.';

  @override
  String get repeater_commandsListTitle => 'Befehlsliste';

  @override
  String get repeater_commandsListNote =>
      'ACHTUNG: Für die verschiedenen „set ...“-Befehle gibt es auch einen „get ...“-Befehl.';

  @override
  String get repeater_general => 'Allgemein';

  @override
  String get repeater_settingsCategory => 'Einstellungen';

  @override
  String get repeater_bridge => 'Brücke';

  @override
  String get repeater_logging => 'Protokollierung';

  @override
  String get repeater_neighborsRepeaterOnly => 'Nachbarn (nur Repeater)';

  @override
  String get repeater_regionManagementRepeaterOnly =>
      'Regionenverwaltung (nur Repeater)';

  @override
  String get repeater_regionNote =>
      'Region-Befehle wurden eingeführt, um Region-Definitionen und Berechtigungen zu verwalten.';

  @override
  String get repeater_gpsManagement => 'GPS-Verwaltung';

  @override
  String get repeater_gpsNote =>
      'Der GPS-Befehl wurde eingeführt, um Standortbezogene Themen zu verwalten.';

  @override
  String get telemetry_receivedData => 'Empfangene Telemetriedaten';

  @override
  String get telemetry_requestTimeout =>
      'Telemetry-Anfrage hat zu lange gedauert.';

  @override
  String telemetry_errorLoading(String error) {
    return 'Fehler beim Laden der Telemetrie: $error';
  }

  @override
  String get telemetry_noData => 'Keine Telemetriedaten verfügbar.';

  @override
  String telemetry_channelTitle(int channel) {
    return 'Kanal $channel';
  }

  @override
  String get telemetry_batteryLabel => 'Akku';

  @override
  String get telemetry_voltageLabel => 'Spannung';

  @override
  String get telemetry_mcuTemperatureLabel => 'MCU Temperatur';

  @override
  String get telemetry_temperatureLabel => 'Temperatur';

  @override
  String get telemetry_currentLabel => 'Aktuell';

  @override
  String telemetry_batteryValue(int percent, String volts) {
    return '$percent% / ${volts}V';
  }

  @override
  String telemetry_voltageValue(String volts) {
    return '$volts Volt';
  }

  @override
  String telemetry_currentValue(String amps) {
    return '${amps}A';
  }

  @override
  String telemetry_temperatureValue(String celsius, String fahrenheit) {
    return '$celsius°C / $fahrenheit°F';
  }

  @override
  String get neighbors_receivedData => 'Empfangene Nachbarsdaten';

  @override
  String get neighbors_requestTimedOut =>
      'Anfrage durch Timeout fehlgeschlagen.';

  @override
  String neighbors_errorLoading(String error) {
    return 'Fehler beim Laden der Nachbarn: $error';
  }

  @override
  String get neighbors_repeatersNeighbors => 'Nachbarn';

  @override
  String get neighbors_noData => 'Keine Nachbarsdaten verfügbar.';

  @override
  String neighbors_unknownContact(String pubkey) {
    return 'Unbekannt $pubkey';
  }

  @override
  String neighbors_heardAgo(String time) {
    return 'Gehört vor: $time';
  }

  @override
  String get discoverNodes_title => 'Discover Nearby Nodes';

  @override
  String get discoverNodes_subtitle =>
      'Actively scan for nearby repeaters and rooms';

  @override
  String get discoverNodes_description =>
      'Broadcasts a discovery request and listens for nearby repeaters and room servers to respond. Useful for finding good placement when setting up a new repeater.';

  @override
  String get discoverNodes_scan => 'Start Discovery';

  @override
  String get discoverNodes_scanning => 'Scanning…';

  @override
  String get discoverNodes_clearList => 'Clear List';

  @override
  String get discoverNodes_noResults =>
      'No nodes discovered yet. Tap Start Discovery to scan.';

  @override
  String discoverNodes_resultsCount(int count) {
    return '$count node(s) found';
  }

  @override
  String discoverNodes_unknownNode(String pubkey) {
    return 'Unknown Node $pubkey';
  }

  @override
  String discoverNodes_lastSeenAgo(String time) {
    return 'Last seen: $time ago';
  }

  @override
  String discoverNodes_remoteSnr(String snr) {
    return 'Their SNR: $snr dB';
  }

  @override
  String get channelPath_title => 'Paketpfad';

  @override
  String get channelPath_viewMap => 'Karte anzeigen';

  @override
  String get channelPath_otherObservedPaths => 'Sonstige beobachtete Pfade';

  @override
  String get channelPath_repeaterHops => 'Repeater-Sprünge';

  @override
  String get channelPath_noHopDetails =>
      'Die Detailangaben für dieses Paket sind nicht verfügbar.';

  @override
  String get channelPath_messageDetails => 'Nachrichtendetails';

  @override
  String get channelPath_senderLabel => 'Sender';

  @override
  String get channelPath_timeLabel => 'Zeit';

  @override
  String get channelPath_repeatsLabel => 'Wiederholungen';

  @override
  String channelPath_pathLabel(int index) {
    return 'Pfad $index';
  }

  @override
  String get channelPath_observedLabel => 'Beobachtet';

  @override
  String channelPath_observedPathTitle(int index, String hops) {
    return 'Beobachteter Pfad $index • $hops';
  }

  @override
  String get channelPath_noLocationData => 'Keine Standortdaten';

  @override
  String channelPath_timeWithDate(int day, int month, String time) {
    return '$day/$month $time';
  }

  @override
  String channelPath_timeOnly(String time) {
    return '$time';
  }

  @override
  String get channelPath_unknownPath => 'Unbekannt';

  @override
  String get channelPath_floodPath => 'Geflutet';

  @override
  String get channelPath_directPath => 'Direkt';

  @override
  String channelPath_observedZeroOf(int total) {
    return '0 von $total Sprüngen';
  }

  @override
  String channelPath_observedSomeOf(int observed, int total) {
    return '$observed von $total Sprüngen';
  }

  @override
  String get channelPath_mapTitle => 'Pfadkarte';

  @override
  String get channelPath_noRepeaterLocations =>
      'Für diesen Pfad stehen keine Repeater-Positionen zur Verfügung.';

  @override
  String channelPath_primaryPath(int index) {
    return 'Pfad $index (Primär)';
  }

  @override
  String get channelPath_pathLabelTitle => 'Pfad';

  @override
  String get channelPath_observedPathHeader => 'Beobachteter Pfad';

  @override
  String channelPath_selectedPathLabel(String label, String prefixes) {
    return '$label • $prefixes';
  }

  @override
  String get channelPath_noHopDetailsAvailable =>
      'Keine Informationen zu dieser Paketroute verfügbar.';

  @override
  String get channelPath_unknownRepeater => 'Unbekannter Repeater';

  @override
  String get community_title => 'Community';

  @override
  String get community_create => 'Erstelle Community';

  @override
  String get community_createDesc =>
      'Erstelle eine neue Community und teile sie über den QR-Code.';

  @override
  String get community_join => 'Beitreten';

  @override
  String get community_joinTitle => 'Tritt der Community bei';

  @override
  String community_joinConfirmation(String name) {
    return 'Möchten Sie sich der Community \"$name\" anschließen?';
  }

  @override
  String get community_scanQr => 'Scannen Sie die Community QR-Code';

  @override
  String get community_scanInstructions =>
      'Richten Sie die Kamera auf einen Community-QR-Code.';

  @override
  String get community_showQr => 'Zeige QR-Code';

  @override
  String get community_publicChannel => 'Community Öffentlich';

  @override
  String get community_hashtagChannel => 'Community Hashtag';

  @override
  String get community_name => 'Community Name';

  @override
  String get community_enterName => 'Bitte Community-Name eingeben';

  @override
  String community_created(String name) {
    return 'Community \"$name\" wurde erstellt';
  }

  @override
  String community_joined(String name) {
    return 'Community \"$name\" beigetreten';
  }

  @override
  String get community_qrTitle => 'Teile Community';

  @override
  String community_qrInstructions(String name) {
    return 'Scannen Sie diesen QR-Code, um sich \"$name\" anzuschließen.';
  }

  @override
  String get community_hashtagPrivacyHint =>
      'Community-Hashtag-Kanäle können nur von Mitgliedern der Community betreten werden';

  @override
  String get community_invalidQrCode => 'Ungültiger Community-QR-Code';

  @override
  String get community_alreadyMember => 'Bereits registriert';

  @override
  String community_alreadyMemberMessage(String name) {
    return 'Sie sind bereits Mitglied von \"$name\".';
  }

  @override
  String get community_addPublicChannel =>
      'Füge einen öffentlichen Community-Kanal hinzu';

  @override
  String get community_addPublicChannelHint =>
      'Automatisch den öffentlichen Kanal für diese Community hinzufügen';

  @override
  String get community_noCommunities => 'Noch keiner Community beigetreten';

  @override
  String get community_scanOrCreate =>
      'Scannen Sie einen QR-Code oder eine Community erstellen, um loszulegen.';

  @override
  String get community_manageCommunities => 'Verwalten von Communities';

  @override
  String get community_delete => 'Verlasse Community';

  @override
  String community_deleteConfirm(String name) {
    return '\"$name\" verlassen?';
  }

  @override
  String community_deleteChannelsWarning(int count) {
    return 'Dies löscht auch $count Kanal/Kanäle und deren Nachrichten.';
  }

  @override
  String community_deleted(String name) {
    return 'Community \"$name\" verlassen';
  }

  @override
  String get community_regenerateSecret => 'Neugenerierung des Schlüssels';

  @override
  String community_regenerateSecretConfirm(String name) {
    return 'Nehmen Sie den geheimen Schlüssel für \"$name\" neu auf? Alle Mitglieder müssen den neuen QR-Code scannen, um die Kommunikation fortzusetzen.';
  }

  @override
  String get community_regenerate => 'Neu generieren';

  @override
  String community_secretRegenerated(String name) {
    return 'Wiederherstellung des Schlüssels für \"$name\" erfolgreich';
  }

  @override
  String get community_updateSecret => 'Aktualisieren Sie den Schlüssel';

  @override
  String community_secretUpdated(String name) {
    return 'Schlüssel für \"$name\" aktualisiert';
  }

  @override
  String community_scanToUpdateSecret(String name) {
    return 'Scannen Sie den neuen QR-Code, um das Geheimnis für \"$name\" zu aktualisieren.';
  }

  @override
  String get community_addHashtagChannel =>
      'Füge einen Community-Hashtag hinzu';

  @override
  String get community_addHashtagChannelDesc =>
      'Füge einen Hashtag-Kanal für diese Community hinzu';

  @override
  String get community_selectCommunity => 'Wählen Sie eine Community';

  @override
  String get community_regularHashtag => 'Regulärer Hashtag';

  @override
  String get community_regularHashtagDesc =>
      'Öffentlicher Hashtag (jeder kann teilnehmen)';

  @override
  String get community_communityHashtag => 'Community Hashtag';

  @override
  String get community_communityHashtagDesc =>
      'Nur für Mitglieder der Community';

  @override
  String community_forCommunity(String name) {
    return 'Für $name';
  }

  @override
  String get listFilter_tooltip => 'Filteren und sortieren';

  @override
  String get listFilter_sortBy => 'Sortiere nach';

  @override
  String get listFilter_latestMessages => 'Letzte Nachrichten';

  @override
  String get listFilter_heardRecently => 'Kürzlich gehört';

  @override
  String get listFilter_az => 'A-Z';

  @override
  String get listFilter_filters => 'Filtere';

  @override
  String get listFilter_all => 'Alle';

  @override
  String get listFilter_users => 'Benutzer';

  @override
  String get listFilter_repeaters => 'Repeater';

  @override
  String get listFilter_roomServers => 'Raumserver';

  @override
  String get listFilter_unreadOnly => 'Nicht gelesen';

  @override
  String get listFilter_newGroup => 'Neue Gruppe';

  @override
  String get pathTrace_you => 'Du';

  @override
  String get pathTrace_failed => 'Pfadverfolgung fehlgeschlagen.';

  @override
  String get pathTrace_notAvailable => 'Pfadverfolgung nicht verfügbar.';

  @override
  String get pathTrace_refreshTooltip => 'Path Trace aktualisieren.';

  @override
  String get pathTrace_someHopsNoLocation =>
      'Bei einer oder mehreren Knoten fehlt der Standort!';

  @override
  String get pathTrace_clearTooltip => 'Pfad löschen';

  @override
  String get losSelectStartEnd =>
      'Wählen Sie Start- und Endknoten für LOS aus.';

  @override
  String losRunFailed(String error) {
    return 'Sichtlinienprüfung fehlgeschlagen: $error';
  }

  @override
  String get losClearAllPoints => 'Löschen Sie alle Punkte';

  @override
  String get losRunToViewElevationProfile =>
      'Führen Sie LOS aus, um das Höhenprofil anzuzeigen';

  @override
  String get losMenuTitle => 'LOS-Menü';

  @override
  String get losMenuSubtitle =>
      'Tippen Sie auf Knoten oder drücken Sie lange auf die Karte, um benutzerdefinierte Punkte anzuzeigen';

  @override
  String get losShowDisplayNodes => 'Anzeigeknoten anzeigen';

  @override
  String get losCustomPoints => 'Benutzerdefinierte Punkte';

  @override
  String losCustomPointLabel(int index) {
    return 'Benutzerdefiniert $index';
  }

  @override
  String get losPointA => 'Punkt A';

  @override
  String get losPointB => 'Punkt B';

  @override
  String losAntennaA(String value, String unit) {
    return 'Antenne A: $value $unit';
  }

  @override
  String losAntennaB(String value, String unit) {
    return 'Antenne B: $value $unit';
  }

  @override
  String get losRun => 'Führen Sie LOS aus';

  @override
  String get losNoElevationData => 'Keine Höhendaten';

  @override
  String losProfileClear(
    String distance,
    String distanceUnit,
    String clearance,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, freie Sichtlinie, Mindestabstand $clearance $heightUnit';
  }

  @override
  String losProfileBlocked(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, blockiert durch $obstruction $heightUnit';
  }

  @override
  String get losStatusChecking => 'LOS: Überprüfen...';

  @override
  String get losStatusNoData => 'LOS: keine Daten';

  @override
  String losStatusSummary(int clear, int total, int blocked, int unknown) {
    return 'Sichtlinie: $clear/$total frei, $blocked blockiert, $unknown unbekannt';
  }

  @override
  String get losErrorElevationUnavailable =>
      'Für eine oder mehrere Proben sind keine Höhendaten verfügbar.';

  @override
  String get losErrorInvalidInput =>
      'Ungültige Punkte/Höhendaten für die LOS-Berechnung.';

  @override
  String get losRenameCustomPoint =>
      'Benennen Sie den benutzerdefinierten Punkt um';

  @override
  String get losPointName => 'Punktname';

  @override
  String get losShowPanelTooltip => 'LOS-Panel anzeigen';

  @override
  String get losHidePanelTooltip => 'LOS-Panel ausblenden';

  @override
  String get losElevationAttribution => 'Höhendaten: Open-Meteo (CC BY 4.0)';

  @override
  String get contacts_pathTrace => 'Pfadverfolgung';

  @override
  String get contacts_ping => 'Pingen';

  @override
  String get contacts_repeaterPathTrace => 'Pfadverfolgung zum Repeater';

  @override
  String get contacts_repeaterPing => 'Repeater pingen';

  @override
  String get contacts_roomPathTrace => 'Pfadverfolgung zum Raumserver';

  @override
  String get contacts_roomPing => 'Raumserver anpingen';

  @override
  String get contacts_chatTraceRoute => 'Pfadverfolgungsroute';

  @override
  String contacts_pathTraceTo(String name) {
    return 'Route nach $name verfolgen';
  }

  @override
  String get contacts_clipboardEmpty => 'Die Zwischenablage ist leer.';

  @override
  String get contacts_invalidAdvertFormat => 'Ungültige Kontaktdaten';

  @override
  String get contacts_contactImported => 'Kontakt wurde importiert.';

  @override
  String get contacts_contactImportFailed =>
      'Kontakt konnte nicht importiert werden';

  @override
  String get contacts_zeroHopAdvert => 'Zero-Hop-Ankündigung';

  @override
  String get contacts_floodAdvert => 'Flut-Ankündigung';

  @override
  String get contacts_copyAdvertToClipboard =>
      'Ankündigung in die Zwischenablage kopieren';

  @override
  String get contacts_addContactFromClipboard =>
      'Kontakt aus Zwischenablage hinzufügen';

  @override
  String get contacts_ShareContact => 'Kontakt in die Zwischenablage kopieren';

  @override
  String get contacts_ShareContactZeroHop => 'Kontakt über Anzeige teilen';

  @override
  String get contacts_zeroHopContactAdvertSent =>
      'Kontakt über Anzeige gesendet';

  @override
  String get contacts_zeroHopContactAdvertFailed =>
      'Kontakt konnte nicht gesendet werden.';

  @override
  String get contacts_contactAdvertCopied =>
      'Anzeige in die Zwischenablage kopiert.';

  @override
  String get contacts_contactAdvertCopyFailed =>
      'Kopieren der Ankündigung in die Zwischenablage fehlgeschlagen.';

  @override
  String get notification_activityTitle => 'MeshCore Aktivität';

  @override
  String notification_messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nachrichten',
      one: 'Nachricht',
    );
    return '$count $_temp0';
  }

  @override
  String notification_channelPoiShared(String label) {
    return 'POI shared: $label';
  }

  @override
  String notification_channelMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kanalnachrichten',
      one: 'Kanalnachricht',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'neue Knoten',
      one: 'neuer Knoten',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newTypeDiscovered(String contactType) {
    return 'Neuer $contactType entdeckt';
  }

  @override
  String get notification_receivedNewMessage => 'Neue Nachricht empfangen';

  @override
  String get settings_gpxExportRepeaters =>
      'Repeater und Raumserver als GPX exportieren';

  @override
  String get settings_gpxExportRepeatersSubtitle =>
      'Exportiert Repeater und Raumserver mit einem Standort in eine GPX-Datei.';

  @override
  String get settings_gpxExportContacts => 'Kontakte als GPX exportieren';

  @override
  String get settings_gpxExportContactsSubtitle =>
      'Exportiert Kontakte mit einem Ort in eine GPX-Datei.';

  @override
  String get settings_gpxExportAll => 'Alle Knoten als GPX exportieren';

  @override
  String get settings_gpxExportAllSubtitle =>
      'Exportiert alle Knoten mit einem Standort in eine GPX-Datei.';

  @override
  String get settings_gpxExportSuccess => 'GPX-Datei erfolgreich exportiert.';

  @override
  String get settings_gpxExportNoContacts => 'Keine Kontakte zum Exportieren.';

  @override
  String get settings_gpxExportNotAvailable =>
      'Nicht auf Ihrem Gerät/Betriebssystem unterstützt';

  @override
  String get settings_gpxExportError =>
      'Beim Export ist ein Fehler aufgetreten.';

  @override
  String get settings_gpxExportRepeatersRoom =>
      'Repeater- und Raumserver-Standorte';

  @override
  String get settings_gpxExportChat => 'Kontaktstandorte';

  @override
  String get settings_gpxExportAllContacts => 'Alle Kontaktstandorte';

  @override
  String get settings_gpxExportShareText =>
      'GPX-Kartendaten aus Gulf Coast Mesh App exportiert';

  @override
  String get settings_gpxExportShareSubject =>
      'GPX-Kartendaten aus Gulf Coast Mesh App exportieren';

  @override
  String get snrIndicator_nearByRepeaters => 'In der Nähe befindliche Repeater';

  @override
  String get snrIndicator_lastSeen => 'Zuletzt gesehen';

  @override
  String get ota_title => 'OTA Update';

  @override
  String get ota_cardSubtitle => 'Update firmware over the air';

  @override
  String get ota_introTitle => 'Over-the-air firmware update';

  @override
  String get ota_introBody =>
      'This wizard updates the firmware of this device remotely. It detects the model and current version, downloads a MeshCore release (latest or an older version to downgrade), and transfers it via WiFi (ESP32) or Bluetooth (nRF52).';

  @override
  String get ota_targetVersion => 'Firmware version';

  @override
  String ota_targetVersionLabel(String version) {
    return 'Target version: $version';
  }

  @override
  String get ota_latestLabel => 'latest';

  @override
  String get ota_loadingVersions => 'Loading available versions...';

  @override
  String get ota_downgradeWarning =>
      'You are installing an older firmware version than the device currently runs. Downgrading can cause config or compatibility issues.';

  @override
  String get ota_deviceRebooting =>
      'Upload complete. The device is rebooting — checking the new firmware over the mesh shortly.';

  @override
  String get ota_verifyingOverMesh => 'Checking firmware version over LoRa...';

  @override
  String get ota_introInternet =>
      'An internet connection is required to download the firmware.';

  @override
  String get ota_introProximity =>
      'Your phone must be within WiFi/Bluetooth range of the device for the transfer.';

  @override
  String get ota_introPower =>
      'Make sure the device has reliable power. Do not power it off during the update.';

  @override
  String get ota_start => 'Start';

  @override
  String get ota_stepDetect => 'Detect device';

  @override
  String get ota_stepFirmware => 'Choose firmware';

  @override
  String get ota_stepDownload => 'Download firmware';

  @override
  String get ota_stepFlash => 'Transfer firmware';

  @override
  String get ota_stepVerify => 'Verify update';

  @override
  String ota_currentVersion(String version) {
    return 'Current version: $version';
  }

  @override
  String ota_detectedBoard(String board) {
    return 'Board: $board';
  }

  @override
  String ota_latestVersion(String version) {
    return 'Latest version: $version';
  }

  @override
  String get ota_upToDate => 'Already on the latest version.';

  @override
  String get ota_boardUnknown =>
      'Could not auto-detect the board. Select it manually below. Flashing the wrong firmware can make the device unreachable!';

  @override
  String get ota_selectBoardToContinue =>
      'Select the correct board above to continue the update.';

  @override
  String get ota_firmwareFile => 'Firmware file (board)';

  @override
  String get ota_useLocalFirmwareToggle =>
      'Use a custom firmware file from this device instead of the release above';

  @override
  String get ota_orLoadLocalLabel =>
      'Or load a specific firmware file from this device:';

  @override
  String get ota_pickLocalEsp32 => 'ESP32 (.bin)';

  @override
  String get ota_pickLocalNrf52 => 'nRF52 (.zip)';

  @override
  String ota_usingLocalFile(String fileName) {
    return 'Using local file: $fileName';
  }

  @override
  String get ota_localFirmwareWarningTitle => 'Use custom firmware?';

  @override
  String get ota_localFirmwareWarningBody =>
      'This file hasn\'t been verified against an official release. Flashing the wrong or corrupt firmware can make the device unreachable. Continue only if you trust this file.';

  @override
  String get ota_otafixWarning =>
      'This device may not have the OTAFIX bootloader. If the OTA update fails, the device can get stuck and require a USB reflash. Continue at your own risk.';

  @override
  String get ota_download => 'Download';

  @override
  String ota_downloading(String percent) {
    return 'Downloading... $percent%';
  }

  @override
  String ota_downloadComplete(String file) {
    return 'Downloaded $file';
  }

  @override
  String get ota_flashIntroEsp32 =>
      'The device will open a WiFi access point named MeshCore-OTA. Stay within range.';

  @override
  String get ota_flashIntroNrf =>
      'The device will switch to Bluetooth firmware-update mode. Stay within range.';

  @override
  String get ota_enterOtaMode => 'Put device into OTA mode';

  @override
  String ota_joinWifiHint(String ssid) {
    return 'Connect your phone to the \"$ssid\" WiFi network. If the prompt fails, join it manually in your phone\'s WiFi settings.';
  }

  @override
  String get ota_joinWifi => 'Join OTA WiFi';

  @override
  String get ota_upload => 'Upload firmware';

  @override
  String ota_uploading(String percent) {
    return 'Uploading... $percent%';
  }

  @override
  String ota_dfuProgress(String percent) {
    return 'Transferring via Bluetooth... $percent%';
  }

  @override
  String get ota_flashComplete => 'Transfer complete. The device is rebooting.';

  @override
  String get ota_verifyHint =>
      'Once the device has rebooted, log back in and confirm the new version.';

  @override
  String get ota_verify => 'Verify';

  @override
  String get ota_verifying => 'Waiting for reboot and logging back in...';

  @override
  String ota_verified(String version) {
    return 'Update verified - now running $version';
  }

  @override
  String get ota_syncClock => 'Sync clock';

  @override
  String get ota_clockSynced => 'Clock synced';

  @override
  String get ota_done => 'Done';

  @override
  String get ota_retry => 'Retry';

  @override
  String get ota_sendReboot => 'Send reboot';

  @override
  String get ota_stallHint =>
      'If the transfer stalled, send reboot to the device and retry the update.';

  @override
  String get ota_debugLog => 'Debug log';

  @override
  String get ota_copyLog => 'Copy log';

  @override
  String get ota_logEmpty => 'No log entries yet.';

  @override
  String get chats_searchConversations => 'Search conversations...';

  @override
  String get chats_noConversationsFound => 'No conversations found';

  @override
  String get chats_filterAll => 'All';

  @override
  String get chats_filterUnread => 'Unread';

  @override
  String get chats_filterDMs => 'DMs';

  @override
  String get chats_filterChannels => 'Channels';

  @override
  String get chats_filterRooms => 'Rooms';

  @override
  String get chats_sortMostRecent => 'Sort: Most recent';

  @override
  String get chats_sortAlphabetical => 'Sort: Alphabetical';

  @override
  String get chats_selectConversation => 'Select a conversation';

  @override
  String get nodes_filterFavorites => 'Favorites';

  @override
  String get nodes_filterContacts => 'Contacts';

  @override
  String get nodes_filterRepeaters => 'Repeaters';

  @override
  String get nodes_filterRooms => 'Rooms';

  @override
  String nodes_searchHintCount(int count) {
    return 'Search nodes ($count)';
  }

  @override
  String get nodes_selectNode => 'Select a node';

  @override
  String get contacts_newBadge => 'New';

  @override
  String get contacts_addToFavorites => 'Add to Favorites';

  @override
  String get contacts_removeFromFavorites => 'Remove from Favorites';

  @override
  String get contacts_sendMessage => 'Send Message';

  @override
  String get contacts_hasLocation => 'Has Location';

  @override
  String get contacts_infoSection => 'Info';

  @override
  String get contacts_nickname => 'Nickname';

  @override
  String get contacts_nameLabel => 'Name';

  @override
  String get contacts_lastAdvert => 'Last Advert';

  @override
  String get contacts_locationSection => 'Location';

  @override
  String get contacts_none => 'None';

  @override
  String get status_repeat => 'Repeat';

  @override
  String get messageStatus_failed => 'Failed';

  @override
  String get messageStatus_sending => 'Sending...';

  @override
  String messageStatus_retrying(int retryCount, int maxRetries) {
    return 'Retrying $retryCount/$maxRetries';
  }

  @override
  String get messageStatus_delivered => 'Delivered';

  @override
  String get messageStatus_deliveredTooltip =>
      'A mesh acknowledgment was received for this message. This confirms the ack made it back through the mesh — it is not a guarantee the recipient read it, and on rare occasions a stale or misrouted ack can trigger a false positive.';

  @override
  String get messageStatus_sent => 'Sent';

  @override
  String get map_removeMarker => 'Remove Marker';

  @override
  String map_removeMarkerConfirm(String markerName) {
    return 'Remove \"$markerName\" from the map?';
  }

  @override
  String get nav_analyzer => 'Analyzer';

  @override
  String get appSettings_meshAnalyzer => 'Show Mesh Analyzer tab';

  @override
  String get appSettings_meshAnalyzerSubtitle =>
      'Live packet visualization dashboard';

  @override
  String get appSettings_meshAnalyzerMobileWarningTitle =>
      'Not designed for mobile';

  @override
  String get appSettings_meshAnalyzerMobileWarningBody =>
      'The Mesh Analyzer can be used on mobile, but it is not recommended or designed for mobile use.';

  @override
  String get analyzer_title => 'Mesh Analyzer';

  @override
  String get analyzer_pause => 'Pause';

  @override
  String get analyzer_resume => 'Resume';

  @override
  String get analyzer_clear => 'Clear';

  @override
  String get analyzer_filterAll => 'All';

  @override
  String get analyzer_filterDM => 'DMs';

  @override
  String get analyzer_filterChannel => 'Channels';

  @override
  String get analyzer_filterAdvert => 'Adverts';

  @override
  String get analyzer_filterDiscovery => 'Discovery';

  @override
  String get analyzer_noPackets => 'No packets received yet';

  @override
  String get analyzer_noChats => 'No conversations';

  @override
  String get analyzer_packets => 'Packets';

  @override
  String get analyzer_chats => 'Chats';

  @override
  String get analyzer_back => 'Back';

  @override
  String get repeater_prefixTitle => 'Node Prefix';

  @override
  String get repeater_prefixCardSubtitle =>
      'Reserve or apply a MeshBuddy public-key prefix';

  @override
  String get repeater_prefixChoosePath => 'How do you want to choose a prefix?';

  @override
  String get repeater_prefixLookupOption => 'I already reserved a prefix';

  @override
  String get repeater_prefixLookupOptionSubtitle =>
      'Look up reservations by email';

  @override
  String get repeater_prefixNewOption => 'Reserve a new prefix';

  @override
  String get repeater_prefixNewOptionSubtitle =>
      'Pick an available prefix and register it';

  @override
  String get repeater_prefixEmailLabel => 'Email used for reservation';

  @override
  String get repeater_prefixLookupButton => 'Look up reservations';

  @override
  String get repeater_prefixNoReservations =>
      'No reservations found for that email';

  @override
  String get repeater_prefixSelectReservation => 'Select a reservation';

  @override
  String get repeater_prefixStatusReserved => 'Reserved';

  @override
  String get repeater_prefixStatusDeployed => 'Deployed';

  @override
  String get repeater_prefixFieldLabel => 'Prefix (hex)';

  @override
  String get repeater_prefixNameLabel => 'Node name';

  @override
  String get repeater_prefixLatLabel => 'Latitude';

  @override
  String get repeater_prefixLonLabel => 'Longitude';

  @override
  String get repeater_prefixAltitudeLabel => 'Altitude (m)';

  @override
  String get repeater_prefixCheckAvailability => 'Check availability';

  @override
  String repeater_prefixAvailable(String prefix) {
    return 'Prefix $prefix is available';
  }

  @override
  String repeater_prefixUnavailable(String prefix, String reason) {
    return 'Prefix $prefix is not available: $reason';
  }

  @override
  String get repeater_prefixReserveButton => 'Reserve prefix';

  @override
  String get repeater_prefixConfirmTitle => 'Apply this prefix?';

  @override
  String repeater_prefixConfirmBody(String prefix, String name) {
    return 'Use prefix $prefix on $name? This generates a new identity key so the public key starts with that prefix, then writes it to the device. After reboot the node will appear as a new contact.';
  }

  @override
  String get repeater_prefixConfirmYes => 'Yes, apply prefix';

  @override
  String repeater_prefixGenerating(String prefix) {
    return 'Generating keypair for prefix $prefix…';
  }

  @override
  String get repeater_prefixGenerateMayTakeTime =>
      'This may take a while — MeshBuddy generates the key on the server when available.';

  @override
  String repeater_prefixGenerateProgress(int attempts) {
    return 'Tried $attempts keys so far';
  }

  @override
  String get repeater_prefixGenerateCancel => 'Cancel generation';

  @override
  String get repeater_prefixApplying => 'Writing private key to device…';

  @override
  String get repeater_prefixApplySuccess => 'Prefix applied. New public key:';

  @override
  String get repeater_prefixRebootNeeded =>
      'The device must reboot before the new identity takes effect. After reboot, discover the node again — it will have a new public key.';

  @override
  String get repeater_prefixRebootNow => 'Reboot now';

  @override
  String get repeater_prefixDone => 'Done';

  @override
  String get repeater_prefixInvalidEmail => 'Enter a valid email address';

  @override
  String repeater_prefixInvalidPrefix(int length) {
    return 'Enter a valid $length-character hex prefix';
  }

  @override
  String get repeater_prefixInvalidLocation =>
      'Enter valid latitude and longitude';

  @override
  String get repeater_prefixLoginFailed =>
      'Admin login failed. Check the password and try again.';

  @override
  String repeater_prefixApplyFailed(String error) {
    return 'Failed to set private key: $error';
  }

  @override
  String get repeater_prefixNoDevicePubkey =>
      'Device did not confirm the new public key';

  @override
  String get repeater_prefixPubkeyMismatch =>
      'Device reported a public key that does not start with the selected prefix';

  @override
  String get repeater_prefixCancelled => 'Key generation cancelled';

  @override
  String repeater_prefixError(String error) {
    return 'Error: $error';
  }

  @override
  String get repeater_regions => 'Regions';

  @override
  String get repeater_regionsFooter =>
      'Allow or deny flood traffic per region.';

  @override
  String get repeater_regionsDiscardRefreshTitle => 'Discard unsaved changes?';

  @override
  String get repeater_regionsDiscardRefreshMessage =>
      'Refreshing will replace your local region edits with what is on the repeater.';

  @override
  String get repeater_regionsDiscardRefreshConfirm => 'Discard and refresh';

  @override
  String get repeater_regionsEmpty => 'No regions configured on this repeater';

  @override
  String get repeater_regionsHome => 'Home region';

  @override
  String get repeater_regionsAllTraffic => 'All traffic (*)';

  @override
  String get repeater_regionsRefresh => 'Refresh regions';

  @override
  String get repeater_regionsAdd => 'Add region';

  @override
  String get repeater_regionsAddTitle => 'Add region';

  @override
  String get repeater_regionsName => 'Region name';

  @override
  String get repeater_regionsSave => 'Save regions to device';

  @override
  String get repeater_regionsSaved => 'Regions saved';

  @override
  String get repeater_regionsUnsaved => 'Unsaved region changes';

  @override
  String get repeater_regionsLoadFailed => 'Failed to load regions';

  @override
  String get repeater_regionsAddFailed => 'Failed to add region';

  @override
  String get repeater_regionsRemoveFailed => 'Failed to remove region';

  @override
  String get repeater_regionsToggleFailed =>
      'Failed to update region flood setting';

  @override
  String get repeater_regionsHomeFailed => 'Failed to set home region';

  @override
  String get repeater_regionsSaveFailed => 'Failed to save regions';

  @override
  String get repeater_regionsPresets => 'Gulf Coast presets';

  @override
  String get repeater_regionsPresetIsolateTitle => 'Block all other regions?';

  @override
  String repeater_regionsPresetIsolateMessage(String label) {
    return 'Allow flood for $label and block flood for every other region on this repeater.';
  }

  @override
  String get repeater_regionsPresetIsolateConfirm => 'Yes';

  @override
  String get repeater_regionsPresetIsolateAddOnly => 'No';

  @override
  String get repeater_regionsFloodAllowed => 'Flood allowed — tap to block';

  @override
  String get repeater_regionsFloodDenied => 'Flood blocked — tap to allow';

  @override
  String get repeater_regionsNotEmpty =>
      'Region has children and cannot be removed';

  @override
  String get repeater_regionsUnknown =>
      'Unknown region or unsupported firmware';

  @override
  String get nav_weather => 'Weather';

  @override
  String get demo_bannerLabel => 'DEMO MODE · Simulated data';

  @override
  String get demo_exit => 'Exit demo';

  @override
  String get demo_exitTitle => 'Exit demo mode?';

  @override
  String get demo_exitMessage =>
      'The simulated session and any changes you made in it will be discarded. Your real mesh data is unchanged.';

  @override
  String get demo_exitStay => 'Stay in demo';

  @override
  String get demo_ended => 'Demo mode ended. Ready for a real device.';

  @override
  String get demo_explore => 'Explore demo mode';

  @override
  String get demo_startTitle => 'Start demo mode?';

  @override
  String get demo_startMessage =>
      'This opens a simulated mesh with example messages, weather, maps, and repeater tools. Demo changes are temporary and will not alter your real contacts or message history.';

  @override
  String get demo_start => 'Start demo';

  @override
  String get chat_voiceMessageTooltip => 'Voice message';

  @override
  String get chat_sendImageOrPdfTooltip => 'Send image or PDF';

  @override
  String get appSettings_mediaRichSection => 'Media & rich messages';

  @override
  String get appSettings_linkPreviews => 'Link previews';

  @override
  String get appSettings_linkPreviewsSubtitle =>
      'Show previews for links in messages';

  @override
  String get appSettings_imageSize => 'Image size';

  @override
  String get appSettings_imageCompression => 'Image compression';

  @override
  String get appSettings_grayscaleImages => 'Grayscale images';

  @override
  String get appSettings_grayscaleImagesSubtitle =>
      'Use grayscale for smaller image transfers';

  @override
  String get appSettings_voiceAndFileMedia => 'Voice and file media';

  @override
  String get appSettings_voiceAndFileMediaSubtitle =>
      'Show voice messages and image/PDF media sending and receiving';

  @override
  String get appSettings_weatherDisplay => 'Weather display';

  @override
  String get appSettings_weatherDisplaySubtitle =>
      'Show a Weather tab that requests forecasts from a #wx-bot-hidden weather bot';

  @override
  String get wardriving_operationInterval => 'Operation interval';

  @override
  String wardriving_intervalSummary(int seconds, int meters) {
    return '$seconds seconds · minimum $meters m';
  }

  @override
  String get wardriving_minDistanceLabel => 'Minimum distance (m)';

  @override
  String get wardriving_minDistanceHelper =>
      'The minimum movement before another sample';

  @override
  String get wardriving_externalAntenna => 'External antenna';

  @override
  String get wardriving_continueInBackground => 'Continue in background';

  @override
  String get wardriving_continueInBackgroundSubtitle =>
      'Requires Always location permission';

  @override
  String get wardriving_offlineSessionMode => 'Offline-session mode';

  @override
  String get wardriving_offlineSessionModeSubtitle =>
      'Save samples locally for later upload';

  @override
  String get wardriving_offlineSessionModeLocked =>
      'Stop wardriving before changing how samples are saved.';

  @override
  String get wardriving_privacyAndUpload => 'Privacy and upload';

  @override
  String get wardriving_broadcastCoordinates => 'Broadcast coordinates';

  @override
  String get wardriving_includeContactKeyPrefix => 'Include contact-key prefix';

  @override
  String get wardriving_advancedFiltering => 'Advanced filtering';

  @override
  String get wardriving_disableRssiFilter => 'Disable RSSI CARpeater filter';

  @override
  String get wardriving_allowDiscoveryDrops => 'Allow discovery drops';

  @override
  String get wardriving_allowDiscoveryDropsSubtitle =>
      'Keep discovery packets normally dropped by policy';

  @override
  String get wardriving_carpeaterPrefixLabel => 'CARpeater prefix (hex)';

  @override
  String get wardriving_coverageAppearance => 'Coverage appearance';

  @override
  String get wardriving_showCoverageOverlay => 'Show coverage overlay';

  @override
  String get chat_mediaRequestUnavailable => 'Unable to request media';

  @override
  String chat_voiceSendUnavailable(String error) {
    return 'Voice send unavailable: $error';
  }

  @override
  String chat_microphoneUnavailable(String error) {
    return 'Microphone unavailable: $error';
  }

  @override
  String chat_attachmentSendUnavailable(String error) {
    return 'Attachment send unavailable: $error';
  }

  @override
  String get chat_sendTextOnlyPdfTitle => 'Send text-only PDF?';

  @override
  String chat_pdfSourcePages(int count) {
    return '$count source pages';
  }

  @override
  String chat_pdfRebuiltBytes(int bytes) {
    return '$bytes rebuilt bytes';
  }

  @override
  String get chat_pdfTextPreview => 'Text preview:';

  @override
  String get chat_pdfTextOnlyNotice =>
      'Only extracted text will be sent. Images, audio, attachments, scripts, annotations, layout, and metadata are removed.';

  @override
  String get flasher_launchFailed => 'Could not launch flasher.meshcore.co.uk';

  @override
  String flasher_launchError(String error) {
    return 'Error launching flasher: $error';
  }

  @override
  String get flasher_title => 'Flash Device';

  @override
  String get flasher_heading => 'Flash MeshCore Firmware';

  @override
  String get flasher_description =>
      'To install or update the firmware on your node (such as a Heltec V3, V4, or Seeed T-1000E), we recommend using the official MeshCore Web Flasher.';

  @override
  String get flasher_openWebFlasher => 'Open Web Flasher';

  @override
  String get flasher_note =>
      'Note: If the flashing fails, you might need to try a different cable, put the device in BOOT mode, or use a desktop computer instead of a phone.';

  @override
  String get settings_flashFirmware => 'Flash Device Firmware';

  @override
  String get settings_flashFirmwareSubtitle =>
      'Open the web flasher to update your node via USB';

  @override
  String get repeater_regenerateIdentityKey =>
      'Schlüssel für die Identitätswiederherstellung';

  @override
  String get splash_tagline => 'Gulf Coast mesh community beta app';

  @override
  String get analyzer_chatNotFound => 'Chat not found';

  @override
  String analyzer_activePaths(int count) {
    return '$count active paths';
  }

  @override
  String get gif_tapToLoad => 'Tap to load GIF';

  @override
  String get media_unavailable => 'Media unavailable';

  @override
  String get media_pdfUnavailable => 'PDF unavailable';

  @override
  String get wardriving_refreshAvailability => 'Refresh availability';

  @override
  String get wardriving_targetRepeater => 'Target repeater';

  @override
  String get wardriving_recenterOnGps => 'Recenter on GPS';

  @override
  String get wardriving_offlineSessionsHistory => 'Offline sessions / history';

  @override
  String wardriving_savedSessions(int count) {
    return '$count saved session(s)';
  }

  @override
  String map_coverageSamples(int count) {
    return '$count coverage sample(s)';
  }

  @override
  String map_coverageStatusSuffix(int status) {
    return ' · status $status';
  }

  @override
  String map_repeatersList(String names) {
    return 'Repeaters: $names';
  }

  @override
  String get map_noDetailedServerData =>
      'No detailed server data for this selection.';

  @override
  String get map_controls => 'Map controls';

  @override
  String get map_closeControls => 'Close map controls';

  @override
  String get map_openControls => 'Open map controls';

  @override
  String get map_offlineWardriveSessions => 'Offline wardrive sessions';

  @override
  String get map_offlineWardriveSessionsSubtitle =>
      'Export, upload, or delete locally recorded samples.';

  @override
  String get map_noOfflineSessions => 'No offline sessions';

  @override
  String get map_sessionUploadedSuffix => ' · uploaded';

  @override
  String get map_sessionJsonCopied => 'Session JSON copied';

  @override
  String get map_deleteSessionTitle => 'Delete session?';

  @override
  String map_deleteSessionBody(int count) {
    return 'Delete $count locally saved sample(s)?';
  }

  @override
  String get map_copyJson => 'Copy JSON';

  @override
  String get map_uploadNow => 'Upload now';

  @override
  String get media_imageFallbackLabel => 'Image';

  @override
  String media_formatReady(String format) {
    return '$format ready';
  }

  @override
  String get media_cannotDecodeImage =>
      'This device cannot decode the image format';

  @override
  String get community_joinTrustWarning =>
      'Only join from a QR you trust. Whoever created it can read every message on this community\'s channels and post as any member.';

  @override
  String get appSettings_nodeBlocking => 'Knoten blockieren';

  @override
  String get appSettings_nodeBlockingSubtitle =>
      'Ausgewählte Knoten auf Karte, in Kontakten und Chats ausblenden und ihre Benachrichtigungen stummschalten. Nur in der App: Auf dem Funkgerät wird nichts entfernt.';

  @override
  String get appSettings_blockedNodes => 'Blockierte Knoten';

  @override
  String appSettings_blockedNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Knoten blockiert',
      one: '1 Knoten blockiert',
      zero: 'Noch keine blockiert',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_title => 'Blockierte Knoten';

  @override
  String get blockedNodes_howItWorks => 'So funktioniert Blockieren';

  @override
  String get blockedNodes_infoHidden =>
      'Ausgeblendet auf Karte, in Kontakten und Chats';

  @override
  String get blockedNodes_infoMuted =>
      'Keine Benachrichtigungen über neue Knoten und keine Nachrichtenbenachrichtigungen von ihnen';

  @override
  String get blockedNodes_infoKept =>
      'Nichts wird gelöscht. Sie bleiben auf dem Funkgerät und ihre Nachrichten werden gespeichert';

  @override
  String get blockedNodes_infoRelay =>
      'Blockierte Repeater können Nachrichten weiterhin über das Mesh weiterleiten';

  @override
  String get blockedNodes_infoChannels =>
      'Ihre Nachrichten in Kanälen werden weiterhin angezeigt';

  @override
  String get blockedNodes_emptyTitle => 'Keine blockierten Knoten';

  @override
  String get blockedNodes_emptyHint =>
      'Einen Knoten in Kontakte oder auf der Karte gedrückt halten und Knoten blockieren wählen.';

  @override
  String get blockedNodes_unblock => 'Entblocken';

  @override
  String get blockedNodes_unblockAll => 'Alle entblocken';

  @override
  String blockedNodes_unblockAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Alle $count Knoten entblocken? Sie werden danach wieder auf der Karte und in den Kontakten angezeigt.',
      one:
          '1 Knoten entblocken? Er wird danach wieder auf der Karte und in den Kontakten angezeigt.',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_unknownNode => 'Unbekannter Knoten';

  @override
  String blockedNodes_blockedOn(String date) {
    return 'Blockiert am $date';
  }

  @override
  String get blockedNodes_blockAction => 'Knoten blockieren';

  @override
  String blockedNodes_blockConfirmTitle(String name) {
    return '$name blockieren?';
  }

  @override
  String get blockedNodes_blockConfirmBody =>
      'Er wird auf der Karte, in Kontakten und Chats ausgeblendet, und es gibt keine Benachrichtigungen oder Nachrichtenbenachrichtigungen von ihm. Auf dem Funkgerät wird nichts gelöscht. Entblocken ist jederzeit unter App-Einstellungen > Experimentell > Blockierte Knoten möglich.';

  @override
  String get blockedNodes_blockConfirmButton => 'Blockieren';

  @override
  String blockedNodes_blocked(String name) {
    return '$name blockiert';
  }

  @override
  String blockedNodes_unblocked(String name) {
    return '$name entblockt';
  }

  @override
  String get blockedNodes_undo => 'Rückgängig';
}
