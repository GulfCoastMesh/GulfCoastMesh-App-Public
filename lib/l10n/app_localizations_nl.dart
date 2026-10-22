// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

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
  String get nav_contacts => 'Contacten';

  @override
  String get nav_channels => 'Kanalen';

  @override
  String get nav_map => 'Kaart';

  @override
  String get nav_chats => 'Chats';

  @override
  String get nav_nodes => 'Knooppunten';

  @override
  String get nav_settings => 'Instellingen';

  @override
  String get common_cancel => 'Annuleren';

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
  String get common_unknownDevice => 'Onbekend apparaat';

  @override
  String get common_save => 'Opslaan';

  @override
  String get common_delete => 'Verwijderen';

  @override
  String get common_close => 'Sluiten';

  @override
  String get common_edit => 'Bewerken';

  @override
  String get common_add => 'Toevoegen';

  @override
  String get common_settings => 'Instellingen';

  @override
  String get common_disconnect => 'Verbinding verbreken';

  @override
  String get common_connected => 'Verbonden';

  @override
  String get common_disconnected => 'Verbinding verbroken';

  @override
  String get common_reconnecting => 'Reconnecting';

  @override
  String get common_create => 'Maak';

  @override
  String get common_continue => 'Doorgaan';

  @override
  String get common_share => 'Delen';

  @override
  String get common_copy => 'Kopiëren';

  @override
  String get common_retry => 'Nogmaals proberen';

  @override
  String get common_hide => 'Verbergen';

  @override
  String get common_remove => 'Verwijderen';

  @override
  String get common_enable => 'Activeren';

  @override
  String get common_disable => 'Uitschakelen';

  @override
  String get common_reboot => 'Herstarten';

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
  String get scanner_scanning => 'Scannen naar apparaten...';

  @override
  String get scanner_connecting => 'Verbinden...';

  @override
  String get scanner_disconnecting => 'Verbinding verbreken...';

  @override
  String get scanner_notConnected => 'Niet verbonden';

  @override
  String scanner_connectedTo(String deviceName) {
    return 'Verbonden met $deviceName';
  }

  @override
  String get scanner_searchingDevices => 'Zoeken naar MeshCore apparaten...';

  @override
  String get scanner_tapToScan => 'Tik Scan om MeshCore apparaten te vinden';

  @override
  String scanner_connectionFailed(String error) {
    return 'Verbinding mislukt: $error';
  }

  @override
  String get scanner_backgroundBleMayDrop =>
      'Background BLE may drop without notification permission.';

  @override
  String get scanner_stop => 'Stoppen';

  @override
  String get scanner_scan => 'Scan';

  @override
  String get scanner_bluetoothOff => 'Bluetooth is uitgeschakeld';

  @override
  String get scanner_bluetoothOffMessage =>
      'Zorg ervoor dat Bluetooth is ingeschakeld om naar apparaten te zoeken.';

  @override
  String get scanner_enableBluetooth => 'Activeer Bluetooth';

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
  String get device_quickSwitch => 'Snelle overschakeling';

  @override
  String get device_meshcore => 'MeshCore';

  @override
  String get settings_title => 'Instellingen';

  @override
  String get settings_deviceInfo => 'Apparateninformatie';

  @override
  String get settings_appSettings => 'App Instellingen';

  @override
  String get settings_appSettingsSubtitle =>
      'Notificaties, berichten en kaartinstellingen';

  @override
  String get settings_nodeSettings => 'Node Instellingen';

  @override
  String get settings_nodeName => 'Node Naam';

  @override
  String get settings_nodeNameNotSet => 'Niet ingesteld';

  @override
  String get settings_nodeNameHint => 'Voer nodenaam in';

  @override
  String get settings_nodeNameUpdated => 'Naam bijgewerkt';

  @override
  String get settings_radioSettings => 'Radio Instellingen';

  @override
  String get settings_radioSettingsSubtitle =>
      'Frequentie, vermogen, spredfactor';

  @override
  String get settings_radioSettingsUpdated => 'Radio instellingen bijgewerkt';

  @override
  String get settings_location => 'Locatie';

  @override
  String get settings_locationSubtitle => 'GPS coördinaten';

  @override
  String get settings_locationUpdated => 'Locatie bijgewerkt';

  @override
  String get settings_locationBothRequired =>
      'Voer zowel breedte- als lengtegraad in.';

  @override
  String get settings_locationInvalid =>
      'Ongeldige breedtegraad of lengtegraad.';

  @override
  String get settings_locationGPSEnable => 'GPS inschakelen';

  @override
  String get settings_locationGPSEnableSubtitle =>
      'Activeer automatisch locatieupdates via GPS.';

  @override
  String get settings_locationIntervalSec => 'Interval voor GPS (Seconden)';

  @override
  String get settings_usePhoneGps => 'Use phone GPS';

  @override
  String get settings_locationIntervalInvalid =>
      'De intervallen moeten minstens 60 seconden zijn en minder dan 86400 seconden.';

  @override
  String get settings_latitude => 'Breedtegraad';

  @override
  String get settings_longitude => 'Lengtegraad';

  @override
  String get settings_privacyMode => 'Privacy Mode';

  @override
  String get settings_privacyModeSubtitle =>
      'Naam/locatie verbergen in advertenties';

  @override
  String get settings_privacyModeToggle =>
      'Schakel privacy modus in om je naam en locatie in advertenties te verbergen.';

  @override
  String get settings_privacyModeEnabled => 'Privacy modus is ingeschakeld';

  @override
  String get settings_privacyModeDisabled => 'Privacy modus is uitgeschakeld';

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
  String get settings_actions => 'Acties';

  @override
  String get settings_sendAdvertisement => 'Verzend Advertentie';

  @override
  String get settings_sendAdvertisementSubtitle => 'Nu aanwezigheid uitzenden';

  @override
  String get settings_advertisementSent => 'Advertentie verzonden';

  @override
  String get settings_syncTime => 'Synchronisatie Tijd';

  @override
  String get settings_syncTimeSubtitle =>
      'Stel de apparaatklok in op de tijd van de telefoon.';

  @override
  String get settings_timeSynchronized => 'Tijdsynchronisatie';

  @override
  String get settings_refreshContacts => 'Contacten vernieuwen';

  @override
  String get settings_refreshContactsSubtitle =>
      'Contactlijst opnieuw laden van het apparaat';

  @override
  String get settings_rebootDevice => 'Apparaat opnieuw opstarten';

  @override
  String get settings_rebootDeviceSubtitle => 'Herstart het MeshCore apparaat';

  @override
  String get settings_rebootDeviceConfirm =>
      'Ben je er zeker van dat je het apparaat opnieuw wilt opstarten? Je wordt losgekoppeld.';

  @override
  String get settings_debug => 'Debug';

  @override
  String get settings_bleDebugLog => 'BLE Debug Log';

  @override
  String get settings_bleDebugLogSubtitle =>
      'BLE commando\'s, antwoorden en ruwe data';

  @override
  String get settings_appDebugLog => 'App Debug Log';

  @override
  String get settings_appDebugLogSubtitle => 'Toepassingsdebugberichten';

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
  String get settings_about => 'Over';

  @override
  String settings_aboutVersion(String version) {
    return 'Gulf Coast Mesh App v$version';
  }

  @override
  String get settings_aboutLegalese => 'Gulf Coast Mesh App 2024';

  @override
  String get settings_aboutDescription =>
      'Een open-source Flutter client voor MeshCore LoRa mesh netwerkapparaten.';

  @override
  String get settings_aboutOpenMeteoAttribution =>
      'LOS-hoogtegegevens: Open-Meteo (CC BY 4.0)';

  @override
  String get settings_infoName => 'Naam';

  @override
  String get settings_infoId => 'ID';

  @override
  String get settings_infoStatus => 'Status';

  @override
  String get settings_infoBattery => 'Batterij';

  @override
  String get settings_infoPublicKey => 'Openbare Sleutel';

  @override
  String get settings_infoContactsCount => 'Aantal Contacten';

  @override
  String get settings_infoChannelCount => 'Aantal Kanalen';

  @override
  String get settings_presets => 'Presets';

  @override
  String get settings_frequency => 'Frequentie (MHz)';

  @override
  String get settings_frequencyHelper => '300,0 - 2500,0';

  @override
  String get settings_frequencyInvalid => 'Ongeldige frequentie (300-2500 MHz)';

  @override
  String get settings_bandwidth => 'Bandbreedte';

  @override
  String get settings_spreadingFactor => 'Spreadsnelheid';

  @override
  String get settings_codingRate => 'Codeertarief';

  @override
  String get settings_txPower => 'TX Vermogen (dBm)';

  @override
  String get settings_txPowerHelper => '0 - 22';

  @override
  String get settings_txPowerInvalid => 'Ongeldige TX-vermogen (0-22 dBm)';

  @override
  String get settings_clientRepeat => 'Herhalen: Afgekoppeld';

  @override
  String get settings_clientRepeatSubtitle =>
      'Laat dit apparaat de mesh-pakketten opnieuw verzenden voor andere apparaten.';

  @override
  String get settings_clientRepeatFreqWarning =>
      'Om een signaal buiten het netwerk te versturen, zijn frequenties van 433, 869 of 918 MHz vereist.';

  @override
  String settings_error(String message) {
    return 'Fout: $message';
  }

  @override
  String get appSettings_title => 'App Instellingen';

  @override
  String get appSettings_appearance => 'Uiterlijk';

  @override
  String get appSettings_theme => 'Thema';

  @override
  String get appSettings_themeSystem => 'Standaardinstelling';

  @override
  String get appSettings_themeLight => 'Licht';

  @override
  String get appSettings_themeDark => 'Donker';

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
  String get appSettings_language => 'Taal';

  @override
  String get appSettings_languageSystem => 'Standaardinstelling';

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
  String get appSettings_languageUk => 'Oekraïens';

  @override
  String get appSettings_enableMessageTracing => 'Berichttracking inschakelen';

  @override
  String get appSettings_enableMessageTracingSubtitle =>
      'Gedetailleerde routerings- en timing-metadata voor berichten weergeven';

  @override
  String get appSettings_notifications => 'Notificaties';

  @override
  String get appSettings_enableNotifications => 'Notificaties inschakelen';

  @override
  String get appSettings_enableNotificationsSubtitle =>
      'Ontvang meldingen voor berichten en advertenties';

  @override
  String get appSettings_notificationPermissionDenied =>
      'Toestemming tot notificaties geweigerd';

  @override
  String get appSettings_notificationsEnabled =>
      'Notificaties zijn ingeschakeld';

  @override
  String get appSettings_notificationsDisabled =>
      'Notificaties zijn uitgeschakeld';

  @override
  String get appSettings_messageNotifications => 'Berichtnotificaties';

  @override
  String get appSettings_messageNotificationsSubtitle =>
      'Toon notificatie bij het ontvangen van nieuwe berichten';

  @override
  String get appSettings_channelMessageNotifications =>
      'Kanaal Bericht Meldingen';

  @override
  String get appSettings_channelMessageNotificationsSubtitle =>
      'Toon notificatie bij het ontvangen van kanaalberichten';

  @override
  String get appSettings_advertisementNotifications => 'Advertentie-meldingen';

  @override
  String get appSettings_advertisementNotificationsSubtitle =>
      'Toon notificatie wanneer nieuwe nodes worden ontdekt';

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
  String get appSettings_messaging => 'Berichten';

  @override
  String get appSettings_clearPathOnMaxRetry => 'Wis Pad op Max Retry';

  @override
  String get appSettings_clearPathOnMaxRetrySubtitle =>
      'Reset contactpad na 5 mislukte verzendpogingen';

  @override
  String get appSettings_pathsWillBeCleared =>
      'De paden worden na 5 mislukte pogingen leeggehaald.';

  @override
  String get appSettings_pathsWillNotBeCleared =>
      'Padoms worden niet automatisch verwijderd';

  @override
  String get appSettings_autoRouteRotation => 'Route Automatisch Roteren';

  @override
  String get appSettings_autoRouteRotationSubtitle =>
      'Verwissel tussen beste pad en floodmodus.';

  @override
  String get appSettings_autoRouteRotationEnabled =>
      'Automatische route rotatie ingeschakeld';

  @override
  String get appSettings_autoRouteRotationDisabled =>
      'Automatische route rotatie is uitgeschakeld';

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
  String get appSettings_battery => 'Batterij';

  @override
  String get appSettings_batteryChemistry => 'Batterijchemie';

  @override
  String appSettings_batteryChemistryPerDevice(String deviceName) {
    return 'Instellen per apparaat ($deviceName)';
  }

  @override
  String get appSettings_batteryChemistryConnectFirst =>
      'Verbind met een apparaat om te selecteren';

  @override
  String get appSettings_batteryNmc => '18650 NMC (3,0-4,2V)';

  @override
  String get appSettings_batteryLifepo4 => 'LiFePO4 (2,6-3,65V)';

  @override
  String get appSettings_batteryLipo => 'LiPo (3,0-4,2V)';

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
  String get appSettings_mapDisplay => 'Kaartweergave';

  @override
  String get appSettings_showRepeaters => 'Toon Repeaters';

  @override
  String get appSettings_showRepeatersSubtitle =>
      'Toon repeaternodes op de kaart';

  @override
  String get appSettings_showChatNodes => 'Chat Nodes tonen';

  @override
  String get appSettings_showChatNodesSubtitle =>
      'Chatnodes weergeven op de kaart';

  @override
  String get appSettings_showOtherNodes => 'Toon Andere Nodes';

  @override
  String get appSettings_showOtherNodesSubtitle =>
      'Toon andere nodetypes op de kaart';

  @override
  String get appSettings_timeFilter => 'Filter op tijd';

  @override
  String get appSettings_timeFilterShowAll => 'Alle nodes tonen';

  @override
  String appSettings_timeFilterShowLast(int hours) {
    return 'Toon nodes van de laatste $hours uur';
  }

  @override
  String get appSettings_mapTimeFilter => 'Filter tijd op kaart';

  @override
  String get appSettings_showNodesDiscoveredWithin =>
      'Toon nodes ontdekt binnen:';

  @override
  String get appSettings_allTime => 'Altijd';

  @override
  String get appSettings_lastHour => 'Laat uur';

  @override
  String get appSettings_last6Hours => 'laatste 6 uur';

  @override
  String get appSettings_last24Hours => 'De laatste 24 uur';

  @override
  String get appSettings_lastWeek => 'Laatste week';

  @override
  String get appSettings_offlineMapCache => 'Offline Kaarten Cache';

  @override
  String get appSettings_unitsTitle => 'Eenheden';

  @override
  String get appSettings_unitsMetric => 'Metrisch (m / km)';

  @override
  String get appSettings_unitsImperial => 'Imperiaal (ft / mi)';

  @override
  String get appSettings_noAreaSelected => 'Geen gebied geselecteerd';

  @override
  String appSettings_areaSelectedZoom(int minZoom, int maxZoom) {
    return 'Geselecteerd gebied (zoom $minZoom-$maxZoom)';
  }

  @override
  String get appSettings_debugCard => 'Debug';

  @override
  String get appSettings_appDebugLogging => 'App Debuggen Loggen';

  @override
  String get appSettings_appDebugLoggingSubtitle =>
      'Log app debugberichten voor probleemoplossing';

  @override
  String get appSettings_appDebugLoggingEnabled =>
      'App debug logging is ingeschakeld';

  @override
  String get appSettings_appDebugLoggingDisabled =>
      'App debug logging is uitgeschakeld';

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
  String get contacts_title => 'Contacten';

  @override
  String get contacts_noContacts => 'Nog geen contacten.';

  @override
  String get contacts_contactsWillAppear =>
      'Contacten verschijnen wanneer apparaten zich aanbieden.';

  @override
  String get contacts_searchContacts => 'Zoek contacten...';

  @override
  String get contacts_noUnreadContacts => 'Geen ongelezen contacten';

  @override
  String get contacts_noContactsFound => 'Geen contacten of groepen gevonden.';

  @override
  String get contacts_deleteContact => 'Verwijder Contact';

  @override
  String contacts_removeConfirm(String contactName) {
    return 'Verwijder $contactName uit de contacten?';
  }

  @override
  String get contacts_manageRepeater => 'Beheer Repeater';

  @override
  String get contacts_manageRoom => 'Beheer Ruimte Server';

  @override
  String get contacts_roomLogin => 'Ruimte Inloggen';

  @override
  String get contacts_openChat => 'Open Chat';

  @override
  String get contacts_editGroup => 'Groep bewerken';

  @override
  String get contacts_deleteGroup => 'Groep verwijderen';

  @override
  String contacts_deleteGroupConfirm(String groupName) {
    return 'Verwijder $groupName?';
  }

  @override
  String get contacts_newGroup => 'Nieuwe Groep';

  @override
  String get contacts_groupName => 'Groepnaam';

  @override
  String get contacts_groupNameRequired => 'De groepnaam is verplicht.';

  @override
  String contacts_groupAlreadyExists(String name) {
    return 'De groep \"$name\" bestaat al.';
  }

  @override
  String get contacts_filterContacts => 'Filters contacten...';

  @override
  String get contacts_noContactsMatchFilter =>
      'Geen contacten matchen met uw filter';

  @override
  String get contacts_noMembers => 'Geen leden';

  @override
  String get contacts_lastSeenNow => 'Laatste keer gezien nu';

  @override
  String contacts_lastSeenMinsAgo(int minutes) {
    return 'Laatst gezien $minutes minuten geleden';
  }

  @override
  String get contacts_lastSeenHourAgo => 'Laast gezien 1 uur geleden';

  @override
  String contacts_lastSeenHoursAgo(int hours) {
    return 'Laast gezien $hours uur geleden';
  }

  @override
  String get contacts_lastSeenDayAgo => 'Laatste bekeken 1 dag geleden';

  @override
  String contacts_lastSeenDaysAgo(int days) {
    return 'Laast gezien $days dagen geleden';
  }

  @override
  String get channels_title => 'Kanaal';

  @override
  String get channels_noChannelsConfigured => 'Geen kanalen geconfigureerd';

  @override
  String get channels_addPublicChannel => 'Maak Open Kanaal';

  @override
  String get channels_searchChannels => 'Zoek kanalen...';

  @override
  String get channels_noChannelsFound => 'Geen kanalen gevonden';

  @override
  String get channels_channelSlotsFull =>
      'All device channel slots are in use. Delete a channel before adding another.';

  @override
  String channels_channelAddFailed(String error) {
    return 'Could not add channel: $error';
  }

  @override
  String channels_channelIndex(int index) {
    return 'Kanaal $index';
  }

  @override
  String get channels_hashtagChannel => 'Hashtag kanaal';

  @override
  String get channels_public => 'Openbaar';

  @override
  String get channels_private => 'Privé';

  @override
  String get channels_publicChannel => 'Open kanaal';

  @override
  String get channels_privateChannel => 'Private kanaal';

  @override
  String get channels_editChannel => 'Kanaal bewerken';

  @override
  String get channels_deleteChannel => 'Kanaal verwijderen';

  @override
  String channels_deleteChannelConfirm(String name) {
    return 'Verwijderen \"$name\"? Dit kan niet worden teruggedraaid.';
  }

  @override
  String get channels_deleteChannelRequiresConnection =>
      'Connect to a device to delete a channel';

  @override
  String channels_channelDeleted(String name) {
    return 'Kanaal \"$name\" verwijderd';
  }

  @override
  String get channels_addChannel => 'Kanaal toevoegen';

  @override
  String get channels_channelIndexLabel => 'Kanaalindex';

  @override
  String get channels_channelName => 'Kanaalnaam';

  @override
  String get channels_usePublicChannel => 'Gebruik Open Kanaal';

  @override
  String get channels_standardPublicPsk => 'Standaard open PSK';

  @override
  String get channels_pskHex => 'PSK (Hex)';

  @override
  String get channels_generateRandomPsk => 'Willekeurige PSK genereren';

  @override
  String get channels_enterChannelName => 'Voer een kanaalnaam in';

  @override
  String get channels_pskMustBe32Hex =>
      'De PSK moet 32 hexadecimale tekens zijn.';

  @override
  String channels_channelAdded(String name) {
    return 'Kanaal \"$name\" toegevoegd';
  }

  @override
  String channels_editChannelTitle(int index) {
    return 'Bewerk Kanaal $index';
  }

  @override
  String get channels_smazCompression => 'SMAZ compressie';

  @override
  String channels_channelUpdated(String name) {
    return 'Kanaal \"$name\" is bijgewerkt';
  }

  @override
  String get channels_publicChannelAdded => 'Open kanaal toegevoegd';

  @override
  String get channels_sortBy => 'Sorteren door';

  @override
  String get channels_sortManual => 'Handmatig';

  @override
  String get channels_sortAZ => 'A-Z';

  @override
  String get channels_sortLatestMessages => 'Recent berichten';

  @override
  String get channels_sortUnread => 'Ongelezen';

  @override
  String get channels_createPrivateChannel => 'Maak een Privé Kanaal';

  @override
  String get channels_createPrivateChannelDesc =>
      'Beveiligd met een geheime sleutel.';

  @override
  String get channels_joinPrivateChannel => 'Sluit een Privé Kanaal aan';

  @override
  String get channels_joinPrivateChannelDesc =>
      'Handmatig een geheime sleutel invoeren.';

  @override
  String get channels_joinPublicChannel => 'Sluit het Open Kanaal';

  @override
  String get channels_joinPublicChannelDesc =>
      'Iedereen kan dit kanaal aanmelden.';

  @override
  String get channels_joinHashtagChannel => 'Sluit een Hashtag Kanaal';

  @override
  String get channels_joinHashtagChannelDesc =>
      'Iedereen kan lid worden van hashtag-kanalen.';

  @override
  String get channels_scanQrCode => 'Scan een QR-code';

  @override
  String get channels_scanQrCodeDesc =>
      'Import a channel invite with name, key, and optional region.';

  @override
  String get channels_scanQrCodeComingSoon => 'Komt later';

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
  String get channels_enterHashtag => 'Voer hashtag in';

  @override
  String get channels_hashtagHint => 'bijv. #team';

  @override
  String get chat_noMessages => 'Nog geen berichten.';

  @override
  String get chat_sendMessageToStart => 'Een bericht sturen om te beginnen';

  @override
  String get chat_originalMessageNotFound => 'Originele bericht niet gevonden';

  @override
  String chat_replyingTo(String name) {
    return 'Reageren op $name';
  }

  @override
  String chat_replyTo(String name) {
    return 'Reageer op $name';
  }

  @override
  String get chat_location => 'Locatie';

  @override
  String chat_sendMessageTo(String contactName) {
    return 'Verstuur een bericht naar $contactName';
  }

  @override
  String get chat_typeMessage => 'Type een bericht...';

  @override
  String chat_messageTooLong(int maxBytes) {
    return 'Bericht is te lang (max $maxBytes bytes).';
  }

  @override
  String get chat_messageCopied => 'Bericht gekopieerd';

  @override
  String get chat_messageDeleted => 'Bericht verwijderd';

  @override
  String get chat_retryingMessage => 'Poging opnieuw.';

  @override
  String chat_retryCount(int current, int max) {
    return 'Poging opnieuw $current/$max';
  }

  @override
  String get chat_sendGif => 'GIF verzenden';

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
  String get chat_reply => 'Reageren';

  @override
  String get chat_addReaction => 'Reactie toevoegen';

  @override
  String get chat_editMessage => 'Edit message';

  @override
  String get chat_editedLabel => '(edited)';

  @override
  String get chat_messageEdited => 'Message edited';

  @override
  String get chat_me => 'Mijn';

  @override
  String get emojiCategorySmileys => 'Emoji\'s';

  @override
  String get emojiCategoryGestures => 'Bewegingen';

  @override
  String get emojiCategoryHearts => 'Hartens';

  @override
  String get emojiCategoryObjects => 'Objecten';

  @override
  String get gifPicker_title => 'Kies een GIF';

  @override
  String get gifPicker_searchHint => 'Zoek GIFs...';

  @override
  String get gifPicker_poweredBy => 'Aangedreven door GIPHY';

  @override
  String get gifPicker_noGifsFound => 'Geen GIFs gevonden';

  @override
  String get gifPicker_failedLoad => 'GIF\'s konden niet worden geladen';

  @override
  String get gifPicker_failedSearch => 'Zoeken mislukt';

  @override
  String get gifPicker_noInternet => 'Geen internetverbinding';

  @override
  String get debugLog_appTitle => 'App Debug Log';

  @override
  String get debugLog_bleTitle => 'BLE Debug Log';

  @override
  String get debugLog_copyLog => 'Kopieer log';

  @override
  String get debugLog_clearLog => 'Log wissen';

  @override
  String get debugLog_copied => 'Debuglog gekopieerd';

  @override
  String get debugLog_bleCopied => 'BLE log gekopieerd';

  @override
  String get debugLog_noEntries => 'Nog geen debug logs beschikbaar.';

  @override
  String get debugLog_enableInSettings =>
      'Schakel app debug logging in de instellingen';

  @override
  String get debugLog_frames => 'Ramen';

  @override
  String get debugLog_rawLogRx => 'Raw Log-RX';

  @override
  String get debugLog_noBleActivity => 'Geen BLE-activiteit nog.';

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
    return 'Frame Lengte: $count bytes';
  }

  @override
  String debugFrame_command(String value) {
    return 'Boodschap: 0x$value';
  }

  @override
  String get debugFrame_textMessageHeader => 'Bericht Frame:';

  @override
  String debugFrame_destinationPubKey(String pubKey) {
    return '- Bestemming PubKey: $pubKey';
  }

  @override
  String debugFrame_timestamp(int timestamp) {
    return '- Tijdstempel: $timestamp';
  }

  @override
  String debugFrame_flags(String value) {
    return '- Vlaggen: 0x$value';
  }

  @override
  String debugFrame_textType(int type, String label) {
    return '- Tekstdocumenttype: $type ($label)';
  }

  @override
  String get debugFrame_textTypeCli => 'CLI';

  @override
  String get debugFrame_textTypePlain => 'Eenvoudig';

  @override
  String debugFrame_text(String text) {
    return '- Tekst: \"$text\"';
  }

  @override
  String get debugFrame_hexDump => 'Hex Dump:';

  @override
  String get chat_pathManagement => 'Beheer van Paden';

  @override
  String get chat_ShowAllPaths => 'Toon alle paden';

  @override
  String get chat_routingMode => 'Routeerwijze';

  @override
  String get chat_autoUseSavedPath => 'Automatisch (gebruik opgeslagen pad)';

  @override
  String get chat_forceFloodMode => 'Dwing Floodsmodus';

  @override
  String get chat_recentAckPaths => 'Recente ACK Paden (tik om te gebruiken):';

  @override
  String get chat_pathHistoryFull =>
      'De voorgeschiedenis is vol. Verwijder vermeldingen om er nieuwe aan toe te voegen.';

  @override
  String get chat_hopSingular => 'Hop';

  @override
  String get chat_hopPlural => 'hoppen';

  @override
  String chat_hopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return '$count $_temp0';
  }

  @override
  String get chat_successes => 'Succesvol';

  @override
  String get chat_removePath => 'Pad verwijderen';

  @override
  String get chat_noPathHistoryYet =>
      'Geen geschiedenis van paden nog beschikbaar.\nVerzend een bericht om paden te ontdekken.';

  @override
  String get chat_pathActions => 'Padacties:';

  @override
  String get chat_setCustomPath => 'Stel aangepaste pad in';

  @override
  String get chat_setCustomPathSubtitle => 'Handmatig routepad specificeren';

  @override
  String get chat_clearPath => 'Duidelijke Pad';

  @override
  String get chat_clearPathSubtitle =>
      'Dwing herontdekking bij volgende verzending';

  @override
  String get chat_pathCleared =>
      'Pad is vrijgegeven. Volgende bericht herontdekt route.';

  @override
  String get chat_floodModeSubtitle =>
      'Gebruik de route-schakelaar in de app-balk';

  @override
  String get chat_floodModeEnabled =>
      'Floodmodus is ingeschakeld. Schakel dit uit via het route-icoon in de app-balk.';

  @override
  String get chat_fullPath => 'Volledige Pad';

  @override
  String get chat_pathDetailsNotAvailable =>
      'De paddetails zijn nog niet beschikbaar. Probeer een bericht te sturen om te vernieuwen.';

  @override
  String chat_pathSetHops(int hopCount, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      hopCount,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Pad ingesteld: $hopCount $_temp0 - $status';
  }

  @override
  String get chat_pathSavedLocally =>
      'Opgeslagen lokaal. Verbinden om te synchroniseren.';

  @override
  String get chat_pathDeviceConfirmed => 'Apparaat bevestigd.';

  @override
  String get chat_pathDeviceNotConfirmed => 'Apparaat nog niet bevestigd.';

  @override
  String get chat_type => 'Typen';

  @override
  String get chat_path => 'Pad';

  @override
  String get chat_publicKey => 'Openbare Sleutel';

  @override
  String get chat_compressOutgoingMessages =>
      'Verzenden van uitgaande berichten comprimeren';

  @override
  String get chat_floodForced => 'Flood (afgedwongen)';

  @override
  String get chat_directForced => 'Direct (afgedwongen)';

  @override
  String chat_hopsForced(int count) {
    return '$count hops (afgedwongen)';
  }

  @override
  String get chat_floodAuto => 'Flood (auto)';

  @override
  String get chat_direct => 'Direct';

  @override
  String get chat_poiShared => 'Gedeelde POI';

  @override
  String chat_unread(int count) {
    return 'Nieuw: $count';
  }

  @override
  String get chat_openLink => 'Link openen?';

  @override
  String get chat_openLinkConfirmation =>
      'Wilt u deze link in uw browser openen?';

  @override
  String get chat_open => 'Openen';

  @override
  String chat_couldNotOpenLink(String url) {
    return 'Kan link niet openen: $url';
  }

  @override
  String get chat_invalidLink => 'Ongeldig linkformaat';

  @override
  String get map_title => 'Node Map';

  @override
  String get map_lineOfSight => 'Zichtlijn';

  @override
  String get map_losScreenTitle => 'Zichtlijn';

  @override
  String get map_noNodesWithLocation => 'Geen nodes met locatiegegevens';

  @override
  String get map_nodesNeedGps =>
      'Nodes moeten hun GPS-coördinaten delen\nom op de kaart te verschijnen';

  @override
  String map_nodesCount(int count) {
    return 'Nodes: $count';
  }

  @override
  String map_pinsCount(int count) {
    return 'Spelden: $count';
  }

  @override
  String get map_chat => 'Chat';

  @override
  String get map_repeater => 'Repeater';

  @override
  String get map_room => 'Ruimte';

  @override
  String get map_sensor => 'Sensor';

  @override
  String get map_pinDm => 'Verzenden als bericht (DM)';

  @override
  String get map_pinPrivate => 'Beveiligd (Privé)';

  @override
  String get map_pinPublic => 'Openbaar spikken';

  @override
  String get map_lastSeen => 'Laaste keer gezien';

  @override
  String get map_disconnectConfirm =>
      'Ben je er zeker van dat je verbinding met dit apparaat wilt verbreken?';

  @override
  String get map_from => 'Van';

  @override
  String get map_source => 'Bron';

  @override
  String get map_flags => 'Vlaggen';

  @override
  String get map_pinLabel => 'Label vastzetten';

  @override
  String get map_label => 'Label';

  @override
  String get map_publicLocationShare => 'Openbare locatie delen';

  @override
  String map_publicLocationShareConfirm(String channelLabel) {
    return 'U gaat een locatie delen in $channelLabel. Deze kanaal is openbaar en iedereen met de PSK kan het zien.';
  }

  @override
  String get map_connectToShareMarkers =>
      'Verbind met een apparaat om markers te delen';

  @override
  String get map_filterNodes => 'Filter Nodes';

  @override
  String get map_nodeTypes => 'Nodetypes';

  @override
  String get map_chatNodes => 'Chatnodes';

  @override
  String get map_repeaters => 'Repeaters';

  @override
  String get map_otherNodes => 'Andere Nodes';

  @override
  String get map_keyPrefix => 'Prefix sleutel';

  @override
  String get map_filterByKeyPrefix => 'Filteren op sleutelvoorgemeld';

  @override
  String get map_publicKeyPrefix => 'Openbare sleutelvoorgemeld';

  @override
  String get map_markers => 'Markeringen';

  @override
  String get map_showSharedMarkers => 'Toon gedeelde markeringen';

  @override
  String get map_lastSeenTime => 'Laatste Bekeken Tijd';

  @override
  String get map_joinRoom => 'Sluit Kamer';

  @override
  String get map_manageRepeater => 'Beheer Repeater';

  @override
  String get map_tapToAdd =>
      'Tik op knooppunten om ze toe te voegen aan het pad';

  @override
  String get map_runTrace => 'Padeshulp traceren';

  @override
  String get map_removeLast => 'Verwijder Laatste';

  @override
  String get map_pathTraceCancelled => 'Pad traceren geannuleerd';

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
  String get mapCache_title => 'Offline Kaarten Cache';

  @override
  String get mapCache_selectAreaFirst =>
      'Select een gebied om eerst in de cache op te slaan';

  @override
  String get mapCache_noTilesToDownload =>
      'Geen tiles te downloaden voor dit gebied.';

  @override
  String get mapCache_downloadTilesTitle => 'Tiles downloaden';

  @override
  String mapCache_downloadTilesPrompt(int count) {
    return 'Download $count tegels voor offline gebruik?';
  }

  @override
  String get mapCache_downloadAction => 'Download';

  @override
  String mapCache_cachedTiles(int count) {
    return 'Opgeslagen $count tegels';
  }

  @override
  String mapCache_cachedTilesWithFailed(int downloaded, int failed) {
    return 'Opgeslagen $downloaded tegels ($failed mislukt)';
  }

  @override
  String get mapCache_clearOfflineCacheTitle => 'Cache offline opschonen';

  @override
  String get mapCache_clearOfflineCachePrompt =>
      'Alle gecachte kaarttiles verwijderen?';

  @override
  String get mapCache_offlineCacheCleared => 'Offline cache is leeggezet';

  @override
  String get mapCache_noAreaSelected => 'Geen gebied geselecteerd';

  @override
  String get mapCache_cacheArea => 'Cache-gebied';

  @override
  String get mapCache_useCurrentView => 'Gebruik Huidige Weergave';

  @override
  String get mapCache_zoomRange => 'Zoom Bereik';

  @override
  String mapCache_estimatedTiles(int count) {
    return 'Geschatte tegels: $count';
  }

  @override
  String mapCache_downloadedTiles(int completed, int total) {
    return 'Gedownload $completed / $total';
  }

  @override
  String get mapCache_downloadTilesButton => 'Tiles downloaden';

  @override
  String get mapCache_clearCacheButton => 'Cache legen';

  @override
  String mapCache_failedDownloads(int count) {
    return 'Mislukte downloads: $count';
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
  String get time_justNow => 'Net nu';

  @override
  String time_minutesAgo(int minutes) {
    return '$minutes minuten geleden';
  }

  @override
  String time_hoursAgo(int hours) {
    return '$hours uur geleden';
  }

  @override
  String time_daysAgo(int days) {
    return '$days dagen geleden';
  }

  @override
  String get time_hour => 'uur';

  @override
  String get time_hours => 'uren';

  @override
  String get time_day => 'dag';

  @override
  String get time_days => 'dagen';

  @override
  String get time_week => 'week';

  @override
  String get time_weeks => 'weken';

  @override
  String get time_month => 'maand';

  @override
  String get time_months => 'maanden';

  @override
  String get time_minutes => 'minuten';

  @override
  String get time_allTime => 'Alle tijd';

  @override
  String get dialog_disconnect => 'Verbinden verbreken';

  @override
  String get dialog_disconnectConfirm =>
      'Ben je er zeker van dat je verbinding met dit apparaat wilt verbreken?';

  @override
  String get login_repeaterLogin => 'Inloggen Repeater';

  @override
  String get login_roomLogin => 'Ruimte Inloggen';

  @override
  String get login_password => 'Wachtwoord';

  @override
  String get login_enterPassword => 'Wachtwoord invoeren';

  @override
  String get login_savePassword => 'Wachtwoord opslaan';

  @override
  String get login_savePasswordSubtitle =>
      'Het wachtwoord wordt veilig op dit apparaat opgeslagen.';

  @override
  String get login_repeaterDescription =>
      'Voer het wachtwoord van de repeater in om instellingen en status te openen.';

  @override
  String get login_roomDescription =>
      'Voer het wachtwoord van de kamer in om toegang te krijgen tot instellingen en status.';

  @override
  String get login_routing => 'Routing';

  @override
  String get login_routingMode => 'Routeerwijze';

  @override
  String get login_autoUseSavedPath => 'Automatisch (gebruik opgeslagen pad)';

  @override
  String get login_forceFloodMode => 'Dwing Floodmodus Af';

  @override
  String get login_managePaths => 'Padbeheer';

  @override
  String get login_login => 'Inloggen';

  @override
  String login_attempt(int current, int max) {
    return 'Poging $current/$max';
  }

  @override
  String login_failed(String error) {
    return 'Inloggen mislukt: $error';
  }

  @override
  String get login_failedMessage =>
      'Inloggen mislukt. Het wachtwoord is onjuist of de repeater is niet bereikbaar.';

  @override
  String get common_reload => 'Opnieuw laden';

  @override
  String get common_clear => 'Schoonmaken';

  @override
  String path_currentPath(String path) {
    return 'Huidige pad: $path';
  }

  @override
  String path_usingHopsPath(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Gebruik $count $_temp0 pad';
  }

  @override
  String get path_enterCustomPath => 'Voer aangepaste pad in';

  @override
  String get path_currentPathLabel => 'Huidige pad';

  @override
  String get path_hexPrefixInstructions =>
      'Voer 2-letter hex-voorgiffen voor elke hop in, gescheiden door komma\'s.';

  @override
  String get path_hexPrefixExample =>
      'Voorbeeld: A1,F2,3C (elke node gebruikt het eerste byte van zijn openbare sleutel)';

  @override
  String get path_labelHexPrefixes => 'Pad (hex-voorkeursletters)';

  @override
  String get path_helperMaxHops =>
      'Maximaal 64 sprongen. Elke prefix is 2 hexadecimale tekens (1 byte)';

  @override
  String get path_selectFromContacts => 'Of select contacten:';

  @override
  String get path_noRepeatersFound => 'Geen repeaters of roomservers gevonden.';

  @override
  String get path_customPathsRequire =>
      'Aangepaste paden vereisen tussentse overstappen die berichten kunnen doorgeven.';

  @override
  String path_invalidHexPrefixes(String prefixes) {
    return 'Ongeldige hex-voorkeursletters: $prefixes';
  }

  @override
  String get path_tooLong =>
      'Pad is te lang. Maximaal 64 sprongen zijn toegestaan.';

  @override
  String get path_setPath => 'Stel Pad in';

  @override
  String get repeater_management => 'Beheer Repeaters';

  @override
  String get room_management => 'Beheer Server Kamer';

  @override
  String get repeater_managementTools => 'Beheerinstrumenten';

  @override
  String get repeater_status => 'Status';

  @override
  String get repeater_statusSubtitle =>
      'Status, statistieken en buren bekijken';

  @override
  String get repeater_sendAdvert => 'Send Advert';

  @override
  String get repeater_sendAdvertSubtitle =>
      'Broadcast an advertisement packet now';

  @override
  String get repeater_telemetry => 'Telemetry';

  @override
  String get repeater_telemetrySubtitle =>
      'Bekijk telemetrie van sensoren en systeemgegevens';

  @override
  String get repeater_cli => 'CLI';

  @override
  String get repeater_cliSubtitle => 'Verzend commando\'s naar de repeater';

  @override
  String get repeater_neighbors => 'Buren';

  @override
  String get repeater_neighborsSubtitle => 'Bekijk nul hops buren.';

  @override
  String get repeater_settings => 'Instellingen';

  @override
  String get repeater_settingsSubtitle => 'Configureer repeaterparameters';

  @override
  String get repeater_statusTitle => 'Status repeater';

  @override
  String get repeater_routingMode => 'Routeerwijze';

  @override
  String get repeater_autoUseSavedPath =>
      'Automatisch (gebruik opgeslagen pad)';

  @override
  String get repeater_forceFloodMode => 'Dwing Floodmodus Af';

  @override
  String get repeater_pathManagement => 'Beheer van paden';

  @override
  String get repeater_refresh => 'Vernieuwen';

  @override
  String get repeater_statusRequestTimeout => 'Statusverzoek is uitgevallen.';

  @override
  String repeater_errorLoadingStatus(String error) {
    return 'Fout bij het laden van de status: $error';
  }

  @override
  String get repeater_systemInformation => 'Systeeminformatie';

  @override
  String get repeater_firmwareVersion => 'Firmware';

  @override
  String get repeater_battery => 'Batterij';

  @override
  String get repeater_clockAtLogin => 'Tijd (bij aanmelden)';

  @override
  String get repeater_uptime => 'Beschikbaarheid';

  @override
  String get repeater_queueLength => 'Wachttijd';

  @override
  String get repeater_debugFlags => 'Debugvlaggen';

  @override
  String get repeater_radioStatistics => 'Radiostatistieken';

  @override
  String get repeater_lastRssi => 'Laatste RSSI';

  @override
  String get repeater_lastSnr => 'Laatste SNR';

  @override
  String get repeater_noiseFloor => 'Ruisvloer';

  @override
  String get repeater_txAirtime => 'TX Airtime';

  @override
  String get repeater_rxAirtime => 'RX Airtime';

  @override
  String get repeater_packetStatistics => 'Pakketstatistieken';

  @override
  String get repeater_sent => 'Verzonden';

  @override
  String get repeater_received => 'Ontvangen';

  @override
  String get repeater_duplicates => 'Duplicaat';

  @override
  String repeater_daysHoursMinsSecs(
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return '$days dagen $hours uur $minutes minuten $seconds seconden';
  }

  @override
  String repeater_packetTxTotal(int total, String flood, String direct) {
    return 'Totaal: $total, Flood: $flood, Direct: $direct';
  }

  @override
  String repeater_packetRxTotal(int total, String flood, String direct) {
    return 'Totaal: $total, Flood: $flood, Direct: $direct';
  }

  @override
  String repeater_duplicatesFloodDirect(String flood, String direct) {
    return 'Flood: $flood, Direct: $direct';
  }

  @override
  String repeater_duplicatesTotal(int total) {
    return 'Totaal: $total';
  }

  @override
  String get repeater_settingsTitle => 'Repeater Instellingen';

  @override
  String get repeater_basicSettings => 'Basisinstellingen';

  @override
  String get repeater_repeaterName => 'Repeaternaam';

  @override
  String get repeater_repeaterNameHelper => 'Weergave naam voor deze repeater';

  @override
  String get repeater_adminPassword => 'Admin wachtwoord';

  @override
  String get repeater_adminPasswordHelper => 'Volledige toegangspaswoord';

  @override
  String get repeater_guestPassword => 'Wachtwoord Gast';

  @override
  String get repeater_guestPasswordHelper => 'Leesbeheer wachtwoord';

  @override
  String get repeater_radioSettings => 'Radio Instellingen';

  @override
  String get repeater_frequencyMhz => 'Frequentie (MHz)';

  @override
  String get repeater_frequencyHelper => '300-2500 MHz';

  @override
  String get repeater_txPower => 'TX Power';

  @override
  String get repeater_txPowerHelper => '1-30 dBm';

  @override
  String get repeater_bandwidth => 'Bandbreedte';

  @override
  String get repeater_spreadingFactor => 'Spreidingsfactor';

  @override
  String get repeater_codingRate => 'Codeertarief';

  @override
  String get repeater_locationSettings => 'Locatie Instellingen';

  @override
  String get repeater_latitude => 'Breedtegraad';

  @override
  String get repeater_latitudeHelper => 'Graadseconden (bijv. 37.7749)';

  @override
  String get repeater_longitude => 'Lengtegraad';

  @override
  String get repeater_longitudeHelper => 'Graadseconden (bijv. -122.4194)';

  @override
  String get repeater_features => 'Kenmerken';

  @override
  String get repeater_packetForwarding => 'Pakketdoorvoering';

  @override
  String get repeater_packetForwardingSubtitle =>
      'Repeater instellen om pakketten door te sturen';

  @override
  String get repeater_guestAccess => 'Toegang voor Gasten';

  @override
  String get repeater_guestAccessSubtitle =>
      'Toegestane leesbeheer toegang voor gasten.';

  @override
  String get repeater_privacyMode => 'Privacy Modus';

  @override
  String get repeater_privacyModeSubtitle =>
      'Naam/locatie verbergen in advertenties';

  @override
  String get repeater_advertisementSettings => 'Advertentie Instellingen';

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
  String get repeater_localAdvertInterval => 'Lokale Advertentie Interval';

  @override
  String repeater_localAdvertIntervalMinutes(int minutes) {
    return '$minutes minuten';
  }

  @override
  String get repeater_floodAdvertInterval => 'Flood Advertentie Interval';

  @override
  String repeater_floodAdvertIntervalHours(int hours) {
    return '$hours uur';
  }

  @override
  String get repeater_encryptedAdvertInterval =>
      'Versleutelde Advertentie Interval';

  @override
  String get repeater_dangerZone => 'Gevaarzone';

  @override
  String get repeater_rebootRepeater => 'Herstart Repeater';

  @override
  String get repeater_rebootRepeaterSubtitle => 'Herstart het Repeaterapparaat';

  @override
  String get repeater_rebootRepeaterConfirm =>
      'Ben je er zeker van dat je deze repeater opnieuw wilt opstarten?';

  @override
  String get repeater_regenerateIdentityKeySubtitle =>
      'Nieuwe publieke/private sleutelpaar genereren';

  @override
  String get repeater_regenerateIdentityKeyConfirm =>
      'Dit genereert een nieuwe identiteit voor de repeater. Doorgaan?';

  @override
  String get repeater_eraseFileSystem => 'Verwijder Besturingssysteem';

  @override
  String get repeater_eraseFileSystemSubtitle =>
      'Formateer het bestandsysteem van de repeater';

  @override
  String get repeater_eraseFileSystemConfirm =>
      'WAARSCHUWING: Dit zal alle gegevens op de repeater wissen. Dit kan niet worden teruggedraaid!';

  @override
  String get repeater_eraseSerialOnly =>
      'Verwijderen is alleen beschikbaar via de seriële console.';

  @override
  String repeater_commandSent(String command) {
    return 'Commando verzonden: $command';
  }

  @override
  String repeater_errorSendingCommand(String error) {
    return 'Fout bij het verzenden van de opdracht: $error';
  }

  @override
  String get repeater_confirm => 'Bevestigen';

  @override
  String get repeater_settingsSaved => 'Instellingen succesvol opgeslagen';

  @override
  String repeater_errorSavingSettings(String error) {
    return 'Fout bij het opslaan van de instellingen: $error';
  }

  @override
  String get repeater_refreshBasicSettings => 'Basisinstellingen vernieuwen';

  @override
  String get repeater_refreshRadioSettings =>
      'Radiozender Instellingen Verversen';

  @override
  String get repeater_refreshTxPower => 'Nieuw laden TX-vermogen';

  @override
  String get repeater_refreshLocationSettings =>
      'Instellingen Locatie Vernieuwen';

  @override
  String get repeater_refreshPacketForwarding =>
      'Vernieuwen Pakket Doorversturing';

  @override
  String get repeater_refreshGuestAccess => 'Toegang Gast Vernieuwen';

  @override
  String get repeater_refreshPrivacyMode => 'Privacy Mode vernieuwen';

  @override
  String get repeater_refreshAdvertisementSettings =>
      'Instellingen Advertentie Bijwerken';

  @override
  String repeater_refreshed(String label) {
    return '$label is vernieuwd';
  }

  @override
  String repeater_errorRefreshing(String label) {
    return 'Fout bij het vernieuwen van $label';
  }

  @override
  String get repeater_cliTitle => 'Repeater CLI';

  @override
  String get repeater_debugNextCommand => 'Debug Volgende Commando';

  @override
  String get repeater_commandHelp => 'Help';

  @override
  String get repeater_clearHistory => 'Verwijder Geschiedenis';

  @override
  String get repeater_noCommandsSent => 'Geen commando\'s verzonden nog.';

  @override
  String get repeater_typeCommandOrUseQuick =>
      'Typ een opdracht hieronder of gebruik snelle commando\'s';

  @override
  String get repeater_enterCommandHint => 'Voer bevel in...';

  @override
  String get repeater_previousCommand => 'Vorige opdracht';

  @override
  String get repeater_nextCommand => 'Volgende opdracht';

  @override
  String get repeater_enterCommandFirst => 'Voer eerst een commando in';

  @override
  String get repeater_cliCommandFrameTitle => 'CLI Commando Frame';

  @override
  String repeater_cliCommandError(String error) {
    return 'Fout: $error';
  }

  @override
  String get repeater_cliQuickGetName => 'Haal Naam op';

  @override
  String get repeater_cliQuickGetRadio => 'Radio ontvangen';

  @override
  String get repeater_cliQuickGetTx => 'Krijg TX';

  @override
  String get repeater_cliQuickNeighbors => 'Buren';

  @override
  String get repeater_cliQuickVersion => 'Versie';

  @override
  String get repeater_cliQuickAdvertise => 'Advertenties';

  @override
  String get repeater_cliQuickClock => 'Tijd';

  @override
  String get repeater_cliHelpAdvert => 'Verstuurt een advertentiepakket';

  @override
  String get repeater_cliHelpReboot =>
      'Herstart het apparaat. (let op, je krijgt mogelijk een \'Timeout\', wat normaal is)';

  @override
  String get repeater_cliHelpClock =>
      'Toont de huidige tijd per apparaat\'s klok.';

  @override
  String get repeater_cliHelpPassword =>
      'Stelt een nieuw beheerderswachtwoord in voor het apparaat.';

  @override
  String get repeater_cliHelpVersion =>
      'Toont de apparaatversie en firmware-bouwdatum.';

  @override
  String get repeater_cliHelpClearStats =>
      'Reset verschillende statistiek-tellers naar nul.';

  @override
  String get repeater_cliHelpSetAf => 'Stelt de luchtvaartfactor in.';

  @override
  String get repeater_cliHelpSetTx =>
      'Stelt LoRa zendvermogen in dBm. (om te wijzigen)';

  @override
  String get repeater_cliHelpSetRepeat =>
      'Activeert of deactiveert de repeater rol van deze node.';

  @override
  String get repeater_cliHelpSetAllowReadOnly =>
      '(Kamervisie) Als \'aan\', dan wordt inloggen met een blanco wachtwoord toegestaan, maar kan niet naar de kamervisie Posten. (alleen lezen mogelijk).';

  @override
  String get repeater_cliHelpSetFloodMax =>
      'Stelt het maximale aantal hops van een inkomend floodpakket in (indien >= max, wordt het pakket niet doorgestuurd)';

  @override
  String get repeater_cliHelpSetIntThresh =>
      'Stelt de Interferentiewaarde (in dB) in. Standaardwaarde is 14. Stel in op 0 om het detecteren van kanaalinterferentie uit te schakelen.';

  @override
  String get repeater_cliHelpSetAgcResetInterval =>
      'Stelt het interval in om de Auto Gain Controller te resetten. Stel in op 0 om dit uit te schakelen.';

  @override
  String get repeater_cliHelpSetMultiAcks =>
      'Activeert of deactiveert de functie \'duplicate ACKs\'.';

  @override
  String get repeater_cliHelpSetAdvertInterval =>
      'Stelt het timerinterval in minuten in om een lokale (zero-hop) advertentiepakket te versturen. Stel in op 0 om uit te schakelen.';

  @override
  String get repeater_cliHelpSetFloodAdvertInterval =>
      'Stelt het timerinterval in uren in om een floodadvertentiepakket te versturen. Stel in op 0 om dit uit te schakelen.';

  @override
  String get repeater_cliHelpGetPathHashMode =>
      'Returns advert path hash mode (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetPathHashMode =>
      'Sets advert path hash mode for this repeater (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetGuestPassword =>
      'Stelt/past de gastenwacht aan of wijzigt deze. (voor herstelcontacten kunnen gastelogins de \"Get Stats\" verzoek verzenden)';

  @override
  String get repeater_cliHelpSetName => 'Stelt de advertentietitel in.';

  @override
  String get repeater_cliHelpSetLat =>
      'Stelt de breedtegraad van de advertentiekaart in. (graadrijssysteem)';

  @override
  String get repeater_cliHelpSetLon =>
      'Stelt de lengtegraad van de advertentiekaart in. (graadrijtjes)';

  @override
  String get repeater_cliHelpSetRadio =>
      'Stelt volledig nieuwe radio parameters in en slaat deze op in de instellingen. Vereist een \"reboot\" commando om toe te passen.';

  @override
  String get repeater_cliHelpSetRxDelay =>
      'Sets (experimenteel) basis (moet > 1 zijn voor effect) om een lichte vertraging toe te passen op ontvangen pakketten, gebaseerd op signaalsterkte/score. Stel op 0 om uit te schakelen.';

  @override
  String get repeater_cliHelpSetTxDelay =>
      'Stelt een factor in werking die wordt vermenigvuldigd met de tijd op lucht voor een flood-mode pakket en met een willekeurig slot systeem, om de verzending ervan te vertragen (om de kans op botsingen te verminderen).';

  @override
  String get repeater_cliHelpSetDirectTxDelay =>
      'Vergelijkbaar met txdelay, maar voor het toepassen van een willekeurige vertraging bij het doorsturen van pakketten in directe modus.';

  @override
  String get repeater_cliHelpSetBridgeEnabled =>
      'Poort inschakelen/uitschakelen.';

  @override
  String get repeater_cliHelpSetBridgeDelay =>
      'Verzend vertraging instellen voor pakketten.';

  @override
  String get repeater_cliHelpSetBridgeSource =>
      'Kies of de brug ontvangen pakketten of verzonden pakketten opnieuw moet versturen.';

  @override
  String get repeater_cliHelpSetBridgeBaud =>
      'Stel de seriële link baudrate in voor rs232 bruggen.';

  @override
  String get repeater_cliHelpSetBridgeSecret =>
      'Stel bridge-geheim in voor espnow bridges.';

  @override
  String get repeater_cliHelpSetAdcMultiplier =>
      'Stelt een aangepaste factor in om de gerapporteerde batterijspanning aan te passen (alleen ondersteund op selecte borden).';

  @override
  String get repeater_cliHelpTempRadio =>
      'Stelt tijdelijke radio parameters in voor het opgegeven aantal minuten, en keert daarna terug naar de originele radio parameters. (wordt niet opgeslagen in de voorkeuren).';

  @override
  String get repeater_cliHelpSetPerm =>
      'Wijzigt de ACL. Verwijder de overeenkomstige entry (door pubkey prefix) als \"permissions\" 0 is. Voeg een nieuwe entry toe als pubkey-hex volledig is en niet momenteel in de ACL staat. Update de entry door matching pubkey prefix. Toestemming bits variëren per firmware rol, maar de onderste 2 bits zijn: 0 (Gast), 1 (Alleen lezen), 2 (Lezen/schrijven), 3 (Admin)';

  @override
  String get repeater_cliHelpGetBridgeType =>
      'Ontvang brugtype: geen, rs232, espnow';

  @override
  String get repeater_cliHelpLogStart =>
      'Start pakketlogging naar het bestandssysteem.';

  @override
  String get repeater_cliHelpLogStop =>
      'Stoppen met het loggen van pakketten naar het bestandssysteem.';

  @override
  String get repeater_cliHelpLogErase =>
      'Verwijdert de pakketlogs uit het bestandssysteem.';

  @override
  String get repeater_cliHelpNeighbors =>
      'Toont een lijst met andere repeater nodes die via nul-hop advertenties zijn gehoord. Elke regel is id-prefix-hex:timestamp:snr-times-4';

  @override
  String get repeater_cliHelpNeighborRemove =>
      'Verwijdert de eerste overeenkomende vermelding (via pubkey prefix (hex)) uit de lijst van buren.';

  @override
  String get repeater_cliHelpRegion =>
      '(Alleen Serieel) Lijst alle gedefinieerde regio\'s en huidige floodrechten.';

  @override
  String get repeater_cliHelpRegionLoad =>
      'LET OP: dit is een speciale multi-command aanroep. Elke volgende opdracht is een regiortaak (uitgelijnd met spaties om de ouderhiërarchie aan te duiden, met minimaal één spatie). Beëindigd door een lege regel/opdracht te sturen.';

  @override
  String get repeater_cliHelpRegionGet =>
      'Zoekt naar regio met gegeven naam voorvoegsel (of \"\" voor de globale scope). Antwoordt met \"-> regio-naam (ouder-naam) \'F\'\"';

  @override
  String get repeater_cliHelpRegionPut =>
      'Voegt of wijzigt een regio-definitie met de gegeven naam.';

  @override
  String get repeater_cliHelpRegionRemove =>
      'Verwijdert een regio-definitie met de gegeven naam. (moet exact overeenkomen en geen kindregio\'s hebben)';

  @override
  String get repeater_cliHelpRegionAllowf =>
      'Stelt de \'F\'lood-toestemming in voor de opgegeven regio. (\'\' voor de globale/oude scope)';

  @override
  String get repeater_cliHelpRegionDenyf =>
      'Verwijdert de \'F\'lood-toestemming voor de gegeven regio. (LET OP: op dit moment niet aanbevolen om dit op de globale/oude scope te gebruiken!!)';

  @override
  String get repeater_cliHelpRegionHome =>
      'Antwoorden met de huidige \'thuis\'-regio. (Op dit moment nergens toegepast, gereserveerd voor toekomstig gebruik)';

  @override
  String get repeater_cliHelpRegionHomeSet => 'Stelt de \'thuis\'-regio in.';

  @override
  String get repeater_cliHelpRegionSave =>
      'Bewaar de lijst/kaart van de regio\'s naar de opslag.';

  @override
  String get repeater_cliHelpGps =>
      'Geeft de status van de GPS. Wanneer de GPS uit staat, antwoordt het alleen met \"uit\", als het aan staat, antwoordt het met \"aan\", status, fix, sat count.';

  @override
  String get repeater_cliHelpGpsOnOff => 'Schakel de GPS-standby aan/uit.';

  @override
  String get repeater_cliHelpGpsSync => 'Synchroniseer node met GPS-klok.';

  @override
  String get repeater_cliHelpGpsSetLoc =>
      'Stel de positie van de node vast als GPS-coördinaten en sla de voorkeuren op.';

  @override
  String get repeater_cliHelpGpsAdvert =>
      'Geeft de locatie advertentieconfiguratie van de node:\n- none: locatie niet in advertenties opnemen\n- share: gps locatie delen (van SensorManager)\n- prefs: locatie adverteren die in de voorkeuren is opgeslagen';

  @override
  String get repeater_cliHelpGpsAdvertSet =>
      'Stelt advertentie locatie configuratie in.';

  @override
  String get repeater_commandsListTitle => 'Commandenlijst';

  @override
  String get repeater_commandsListNote =>
      'LET OP: voor de verschillende \"set ...\" commando\'s is er ook een \"get ...\" commando.';

  @override
  String get repeater_general => 'Algemeen';

  @override
  String get repeater_settingsCategory => 'Instellingen';

  @override
  String get repeater_bridge => 'Bruggen';

  @override
  String get repeater_logging => 'Logging';

  @override
  String get repeater_neighborsRepeaterOnly => 'Buren (Alleen repeaters)';

  @override
  String get repeater_regionManagementRepeaterOnly =>
      'Regiobeheer (Alleen Repeater)';

  @override
  String get repeater_regionNote =>
      'Regio-commando\'s zijn geïntroduceerd om regio-definities en permissies te beheren.';

  @override
  String get repeater_gpsManagement => 'Beheer GPS';

  @override
  String get repeater_gpsNote =>
      'De GPS-commando is geïntroduceerd om locatiegerelateerde onderwerpen te beheren.';

  @override
  String get telemetry_receivedData => 'Ontvangen Telemetriedata';

  @override
  String get telemetry_requestTimeout => 'Telemetryverzoek is uitgevallen.';

  @override
  String telemetry_errorLoading(String error) {
    return 'Fout bij het laden van de telemetrie: $error';
  }

  @override
  String get telemetry_noData => 'Geen telemetriedata beschikbaar.';

  @override
  String telemetry_channelTitle(int channel) {
    return 'Kanaal $channel';
  }

  @override
  String get telemetry_batteryLabel => 'Batterij';

  @override
  String get telemetry_voltageLabel => 'Spanning';

  @override
  String get telemetry_mcuTemperatureLabel => 'MCU Temperatuur';

  @override
  String get telemetry_temperatureLabel => 'Temperatuur';

  @override
  String get telemetry_currentLabel => 'Huidig';

  @override
  String telemetry_batteryValue(int percent, String volts) {
    return '$percent% / ${volts}V';
  }

  @override
  String telemetry_voltageValue(String volts) {
    return '${volts}V';
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
  String get neighbors_receivedData => 'Ontvangen Buurdata';

  @override
  String get neighbors_requestTimedOut =>
      'Buren vragen om tijdelijk uitgeschakeld.';

  @override
  String neighbors_errorLoading(String error) {
    return 'Fout bij het laden van buren: $error';
  }

  @override
  String get neighbors_repeatersNeighbors => 'Herhalingen Buren';

  @override
  String get neighbors_noData => 'Geen gegevens van buren beschikbaar.';

  @override
  String neighbors_unknownContact(String pubkey) {
    return 'Onbekende $pubkey';
  }

  @override
  String neighbors_heardAgo(String time) {
    return 'Horen: $time geleden';
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
  String get channelPath_title => 'Pakketpad';

  @override
  String get channelPath_viewMap => 'Kaart bekijken';

  @override
  String get channelPath_otherObservedPaths => 'Overige Waargenomen Paden';

  @override
  String get channelPath_repeaterHops => 'Repeater Hops';

  @override
  String get channelPath_noHopDetails =>
      'De details van de pakket zijn niet verstrekt.';

  @override
  String get channelPath_messageDetails => 'Details Bericht';

  @override
  String get channelPath_senderLabel => 'Afzender';

  @override
  String get channelPath_timeLabel => 'Tijd';

  @override
  String get channelPath_repeatsLabel => 'Repeats';

  @override
  String channelPath_pathLabel(int index) {
    return 'Pad $index';
  }

  @override
  String get channelPath_observedLabel => 'Waargenomen';

  @override
  String channelPath_observedPathTitle(int index, String hops) {
    return 'Waargenomen pad $index • $hops';
  }

  @override
  String get channelPath_noLocationData => 'Geen locatiegegevens';

  @override
  String channelPath_timeWithDate(int day, int month, String time) {
    return '$day/$month $time';
  }

  @override
  String channelPath_timeOnly(String time) {
    return '$time';
  }

  @override
  String get channelPath_unknownPath => 'Onbekend';

  @override
  String get channelPath_floodPath => 'Flood';

  @override
  String get channelPath_directPath => 'Direct';

  @override
  String channelPath_observedZeroOf(int total) {
    return '0 van $total sprongen';
  }

  @override
  String channelPath_observedSomeOf(int observed, int total) {
    return '$observed van $total sprongen';
  }

  @override
  String get channelPath_mapTitle => 'Padkaart';

  @override
  String get channelPath_noRepeaterLocations =>
      'Geen repeaters beschikbaar voor deze route.';

  @override
  String channelPath_primaryPath(int index) {
    return 'Pad $index (Hoofdtype)';
  }

  @override
  String get channelPath_pathLabelTitle => 'Pad';

  @override
  String get channelPath_observedPathHeader => 'Waargenomen Pad';

  @override
  String channelPath_selectedPathLabel(String label, String prefixes) {
    return '$label • $prefixes';
  }

  @override
  String get channelPath_noHopDetailsAvailable =>
      'Geen details beschikbaar voor dit pakket.';

  @override
  String get channelPath_unknownRepeater => 'Onbekend Repeater';

  @override
  String get community_title => 'Gemeenschap';

  @override
  String get community_create => 'Maak Gemeenschap';

  @override
  String get community_createDesc =>
      'Maak een nieuwe community en deel deze via QR-code.';

  @override
  String get community_join => 'Sluit aan';

  @override
  String get community_joinTitle => 'Worden lid van de community';

  @override
  String community_joinConfirmation(String name) {
    return 'Wil je je aansluiten bij de community \"$name\"?';
  }

  @override
  String get community_scanQr => 'Scan Gemeenschap QR';

  @override
  String get community_scanInstructions =>
      'Richt de camera op een gemeenschappelijke QR-code';

  @override
  String get community_showQr => 'Toon QR-code';

  @override
  String get community_publicChannel => 'Gemeenschap Openbaar';

  @override
  String get community_hashtagChannel => 'Gemeenschappelijk Hashtag';

  @override
  String get community_name => 'Gemeenschapnaam';

  @override
  String get community_enterName => 'Voer de gemeenschapsnaam in';

  @override
  String community_created(String name) {
    return 'Gemeenschap \"$name\" is aangemaakt';
  }

  @override
  String community_joined(String name) {
    return 'Gevonden in de community \"$name\"';
  }

  @override
  String get community_qrTitle => 'Deel Gemeenschap';

  @override
  String community_qrInstructions(String name) {
    return 'Scan deze QR-code om je aan te sluiten bij $name';
  }

  @override
  String get community_hashtagPrivacyHint =>
      'Community hashtag-kanalen zijn alleen toegankelijk voor leden van de community';

  @override
  String get community_invalidQrCode => 'Ongeldige community QR-code';

  @override
  String get community_alreadyMember => 'Alleen al lid';

  @override
  String community_alreadyMemberMessage(String name) {
    return 'U bent al lid van \"$name\".';
  }

  @override
  String get community_addPublicChannel =>
      'Voeg een Openbaar Gemeenschapskanaal toe';

  @override
  String get community_addPublicChannelHint =>
      'Automatisch de publieke kanaal toevoegen voor deze community';

  @override
  String get community_noCommunities =>
      'Nog geen gemeenschappen zijn bijgesloten.';

  @override
  String get community_scanOrCreate =>
      'Scan een QR-code of een community aanmaken om te beginnen';

  @override
  String get community_manageCommunities => 'Beheer Gemeenschappen';

  @override
  String get community_delete => 'Laat Gemeenschap';

  @override
  String community_deleteConfirm(String name) {
    return '\"$name\" verlaten?';
  }

  @override
  String community_deleteChannelsWarning(int count) {
    return 'Dit verwijdert ook $count kanaal/kanalen en hun berichten.';
  }

  @override
  String community_deleted(String name) {
    return 'Community \"$name\" verlaten';
  }

  @override
  String get community_regenerateSecret => 'Regeneer Geheimwoord';

  @override
  String community_regenerateSecretConfirm(String name) {
    return 'Regeneere de geheime sleutel voor \"$name\"? Alle leden moeten de nieuwe QR-code scannen om verder te communiceren.';
  }

  @override
  String get community_regenerate => 'Regeneer';

  @override
  String community_secretRegenerated(String name) {
    return 'Geheim hersteld voor \"$name\"';
  }

  @override
  String get community_updateSecret => 'Bijwerken Geheime';

  @override
  String community_secretUpdated(String name) {
    return 'Geheim gewijzigd voor \"$name\"';
  }

  @override
  String community_scanToUpdateSecret(String name) {
    return 'Scan de nieuwe QR-code om het geheim voor \"$name\" bij te werken';
  }

  @override
  String get community_addHashtagChannel => 'Voeg Community Hashtag toe';

  @override
  String get community_addHashtagChannelDesc =>
      'Voeg een hashtag-kanaal toe aan deze community';

  @override
  String get community_selectCommunity => 'Selecteer Gemeenschap';

  @override
  String get community_regularHashtag => 'Gewone Hashtag';

  @override
  String get community_regularHashtagDesc =>
      'Open hashtag (iedereen kan deelnemen)';

  @override
  String get community_communityHashtag => 'Gemeenschappelijk Hashtag';

  @override
  String get community_communityHashtagDesc =>
      'Alleen zichtbaar voor leden van de community';

  @override
  String community_forCommunity(String name) {
    return 'Voor $name';
  }

  @override
  String get listFilter_tooltip => 'Filteren en sorteren';

  @override
  String get listFilter_sortBy => 'Sorteren door';

  @override
  String get listFilter_latestMessages => 'Recente berichten';

  @override
  String get listFilter_heardRecently => 'Hoor je onlangs';

  @override
  String get listFilter_az => 'A-Z';

  @override
  String get listFilter_filters => 'Filters';

  @override
  String get listFilter_all => 'Alles';

  @override
  String get listFilter_users => 'Gebruikers';

  @override
  String get listFilter_repeaters => 'Repeaters';

  @override
  String get listFilter_roomServers => 'Roomservers';

  @override
  String get listFilter_unreadOnly => 'Alleen ongelezen';

  @override
  String get listFilter_newGroup => 'Nieuwe groep';

  @override
  String get pathTrace_you => 'Jij';

  @override
  String get pathTrace_failed => 'Padtrace mislukt.';

  @override
  String get pathTrace_notAvailable => 'Padtrace niet beschikbaar.';

  @override
  String get pathTrace_refreshTooltip => 'Path Trace vernieuwen.';

  @override
  String get pathTrace_someHopsNoLocation =>
      'Een of meer van de hops ontbreken een locatie!';

  @override
  String get pathTrace_clearTooltip => 'Weg wissen';

  @override
  String get losSelectStartEnd =>
      'Selecteer begin- en eindknooppunten voor LOS.';

  @override
  String losRunFailed(String error) {
    return 'Zichtlijncontrole mislukt: $error';
  }

  @override
  String get losClearAllPoints => 'Wis alle punten';

  @override
  String get losRunToViewElevationProfile =>
      'Voer LOS uit om het hoogteprofiel te bekijken';

  @override
  String get losMenuTitle => 'LOS-menu';

  @override
  String get losMenuSubtitle =>
      'Tik op knooppunten of druk lang op de kaart voor aangepaste punten';

  @override
  String get losShowDisplayNodes => 'Toon weergaveknooppunten';

  @override
  String get losCustomPoints => 'Aangepaste punten';

  @override
  String losCustomPointLabel(int index) {
    return 'Aangepast $index';
  }

  @override
  String get losPointA => 'Punt A';

  @override
  String get losPointB => 'Punt B';

  @override
  String losAntennaA(String value, String unit) {
    return 'Antenne A: $value $unit';
  }

  @override
  String losAntennaB(String value, String unit) {
    return 'Antenne B: $value $unit';
  }

  @override
  String get losRun => 'Voer LOS uit';

  @override
  String get losNoElevationData => 'Geen hoogtegegevens';

  @override
  String losProfileClear(
    String distance,
    String distanceUnit,
    String clearance,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, vrije LOS, min. vrije ruimte $clearance $heightUnit';
  }

  @override
  String losProfileBlocked(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, geblokkeerd door $obstruction $heightUnit';
  }

  @override
  String get losStatusChecking => 'LOS: controleren...';

  @override
  String get losStatusNoData => 'LOS: geen gegevens';

  @override
  String losStatusSummary(int clear, int total, int blocked, int unknown) {
    return 'LOS: $clear/$total gewist, $blocked geblokkeerd, $unknown onbekend';
  }

  @override
  String get losErrorElevationUnavailable =>
      'Hoogtegegevens niet beschikbaar voor een of meer monsters.';

  @override
  String get losErrorInvalidInput =>
      'Ongeldige punten/hoogtegegevens voor LOS-berekening.';

  @override
  String get losRenameCustomPoint => 'Hernoem aangepast punt';

  @override
  String get losPointName => 'Puntnaam';

  @override
  String get losShowPanelTooltip => 'Toon LOS-paneel';

  @override
  String get losHidePanelTooltip => 'LOS-paneel verbergen';

  @override
  String get losElevationAttribution =>
      'Hoogtegegevens: Open-Meteo (CC BY 4.0)';

  @override
  String get contacts_pathTrace => 'Pad Traceren';

  @override
  String get contacts_ping => 'Pingen';

  @override
  String get contacts_repeaterPathTrace => 'Pad traceren naar repeater';

  @override
  String get contacts_repeaterPing => 'Ping repeater';

  @override
  String get contacts_roomPathTrace => 'Padtrace naar room server';

  @override
  String get contacts_roomPing => 'Ping kamer server';

  @override
  String get contacts_chatTraceRoute => 'Route traceren';

  @override
  String contacts_pathTraceTo(String name) {
    return 'Trace route to $name';
  }

  @override
  String get contacts_clipboardEmpty => 'Knipbord is leeg.';

  @override
  String get contacts_invalidAdvertFormat => 'Ongeldige contactgegevens';

  @override
  String get contacts_contactImported => 'Contact is geïmporteerd.';

  @override
  String get contacts_contactImportFailed =>
      'Contact kon niet geïmporteerd worden.';

  @override
  String get contacts_zeroHopAdvert => 'Zero Hop Reclame';

  @override
  String get contacts_floodAdvert => 'Overstromingsadvertentie';

  @override
  String get contacts_copyAdvertToClipboard => 'Advert naar klembord kopiëren';

  @override
  String get contacts_addContactFromClipboard =>
      'Contact uit klembord toevoegen';

  @override
  String get contacts_ShareContact => 'Kontakt naar Klembord kopiëren';

  @override
  String get contacts_ShareContactZeroHop => 'Contact delen via advertentie';

  @override
  String get contacts_zeroHopContactAdvertSent =>
      'Contact verzonden via advertentie';

  @override
  String get contacts_zeroHopContactAdvertFailed =>
      'Mislukt om contact te verzenden';

  @override
  String get contacts_contactAdvertCopied =>
      'Reclame gekopieerd naar Klembord.';

  @override
  String get contacts_contactAdvertCopyFailed =>
      'Kopiëren van advertentie naar Clipboard is mislukt.';

  @override
  String get notification_activityTitle => 'MeshCore Activiteit';

  @override
  String notification_messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'berichten',
      one: 'bericht',
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
      other: 'kanaalberichten',
      one: 'kanaalbericht',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nieuwe knooppunten',
      one: 'nieuw knooppunt',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newTypeDiscovered(String contactType) {
    return 'Nieuw $contactType ontdekt';
  }

  @override
  String get notification_receivedNewMessage => 'Nieuw bericht ontvangen';

  @override
  String get settings_gpxExportRepeaters =>
      'Exporteer repeaters / roomserver naar GPX';

  @override
  String get settings_gpxExportRepeatersSubtitle =>
      'Exporteert repeaters / roomserver met een locatie naar GPX-bestand.';

  @override
  String get settings_gpxExportContacts => 'Companions exporteren naar GPX';

  @override
  String get settings_gpxExportContactsSubtitle =>
      'Exporteert metgezellen met een locatie naar een GPX-bestand.';

  @override
  String get settings_gpxExportAll => 'Alle contacten exporteren naar GPX';

  @override
  String get settings_gpxExportAllSubtitle =>
      'Exporteert alle contacten met een locatie naar een GPX-bestand.';

  @override
  String get settings_gpxExportSuccess => 'Succesvol GPX-bestand geëxporteerd.';

  @override
  String get settings_gpxExportNoContacts => 'Geen contacten om te exporteren.';

  @override
  String get settings_gpxExportNotAvailable =>
      'Niet ondersteund op uw apparaat/besturingssysteem';

  @override
  String get settings_gpxExportError => 'Er was een fout bij het exporteren.';

  @override
  String get settings_gpxExportRepeatersRoom =>
      'Repeater- en kamer servers locaties';

  @override
  String get settings_gpxExportChat => 'Locaties van metgezellen';

  @override
  String get settings_gpxExportAllContacts => 'Alle contactlocaties';

  @override
  String get settings_gpxExportShareText =>
      'Kaartgegevens geëxporteerd uit Gulf Coast Mesh App';

  @override
  String get settings_gpxExportShareSubject =>
      'Gulf Coast Mesh App GPX kaartgegevens exporteren';

  @override
  String get snrIndicator_nearByRepeaters => 'Nabije herhalingseenheden';

  @override
  String get snrIndicator_lastSeen => 'Laatst gezien';

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
      'Identiteit sleutel opnieuw genereren';

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
  String get appSettings_nodeBlocking => 'Nodes blokkeren';

  @override
  String get appSettings_nodeBlockingSubtitle =>
      'Verberg gekozen nodes op je kaart, in contacten en chats, en demp hun meldingen. Alleen in de app: er wordt niets van je radio verwijderd.';

  @override
  String get appSettings_blockedNodes => 'Geblokkeerde nodes';

  @override
  String appSettings_blockedNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nodes geblokkeerd',
      one: '1 node geblokkeerd',
      zero: 'Nog geen geblokkeerd',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_title => 'Geblokkeerde nodes';

  @override
  String get blockedNodes_howItWorks => 'Hoe blokkeren werkt';

  @override
  String get blockedNodes_infoHidden =>
      'Verborgen op je kaart, in contacten en chats';

  @override
  String get blockedNodes_infoMuted =>
      'Geen meldingen voor nieuwe nodes en geen berichtmeldingen van hen';

  @override
  String get blockedNodes_infoKept =>
      'Niets wordt verwijderd. Ze blijven op je companion-radio en hun berichten worden bewaard';

  @override
  String get blockedNodes_infoRelay =>
      'Geblokkeerde repeaters kunnen je berichten nog steeds via het mesh doorgeven';

  @override
  String get blockedNodes_infoChannels =>
      'Hun berichten in kanalen worden nog steeds getoond';

  @override
  String get blockedNodes_emptyTitle => 'Geen geblokkeerde nodes';

  @override
  String get blockedNodes_emptyHint =>
      'Houd een node in Contacten of op de Kaart ingedrukt en kies Node blokkeren.';

  @override
  String get blockedNodes_unblock => 'Deblokkeren';

  @override
  String get blockedNodes_unblockAll => 'Alles deblokkeren';

  @override
  String blockedNodes_unblockAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Alle $count nodes deblokkeren? Ze worden weer getoond op je kaart en in je contacten.',
      one:
          '1 node deblokkeren? Hij wordt weer getoond op je kaart en in je contacten.',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_unknownNode => 'Onbekende node';

  @override
  String blockedNodes_blockedOn(String date) {
    return 'Geblokkeerd op $date';
  }

  @override
  String get blockedNodes_blockAction => 'Node blokkeren';

  @override
  String blockedNodes_blockConfirmTitle(String name) {
    return '$name blokkeren?';
  }

  @override
  String get blockedNodes_blockConfirmBody =>
      'Hij wordt verborgen op je kaart, in contacten en chats, en je krijgt geen meldingen of berichtmeldingen van hem. Er wordt niets van je radio verwijderd. Je kunt hem altijd deblokkeren via App Instellingen > Experimenteel > Geblokkeerde nodes.';

  @override
  String get blockedNodes_blockConfirmButton => 'Blokkeren';

  @override
  String blockedNodes_blocked(String name) {
    return '$name geblokkeerd';
  }

  @override
  String blockedNodes_unblocked(String name) {
    return '$name gedeblokkeerd';
  }

  @override
  String get blockedNodes_undo => 'Ongedaan maken';
}
