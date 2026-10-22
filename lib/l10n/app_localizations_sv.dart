// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

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
  String get nav_contacts => 'Kontakter';

  @override
  String get nav_channels => 'Kanaler';

  @override
  String get nav_map => 'Karta';

  @override
  String get nav_chats => 'Chattar';

  @override
  String get nav_nodes => 'Noder';

  @override
  String get nav_settings => 'Inställningar';

  @override
  String get common_cancel => 'Avbryt';

  @override
  String get common_ok => 'Okej';

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
  String get common_connect => 'Anslut';

  @override
  String get common_unknownDevice => 'Okänd enhet';

  @override
  String get common_save => 'Spara';

  @override
  String get common_delete => 'Radera';

  @override
  String get common_close => 'Stänga';

  @override
  String get common_edit => 'Redigera';

  @override
  String get common_add => 'Lägg till';

  @override
  String get common_settings => 'Inställningar';

  @override
  String get common_disconnect => 'Koppla från';

  @override
  String get common_connected => 'Ansluten';

  @override
  String get common_disconnected => 'Ansluten';

  @override
  String get common_reconnecting => 'Reconnecting';

  @override
  String get common_create => 'Skapa';

  @override
  String get common_continue => 'Fortsätt';

  @override
  String get common_share => 'Dela';

  @override
  String get common_copy => 'Kopiera';

  @override
  String get common_retry => 'Försök igen';

  @override
  String get common_hide => 'Dölj';

  @override
  String get common_remove => 'Ta bort';

  @override
  String get common_enable => 'Aktivera';

  @override
  String get common_disable => 'Inaktivera';

  @override
  String get common_reboot => 'Start om';

  @override
  String get common_loading => 'Laddar...';

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
  String get scanner_scanning => 'Söker efter enheter...';

  @override
  String get scanner_connecting => 'Anslutning...';

  @override
  String get scanner_disconnecting => 'Anslutning bryts...';

  @override
  String get scanner_notConnected => 'Inte ansluten';

  @override
  String scanner_connectedTo(String deviceName) {
    return 'Ansluten till $deviceName';
  }

  @override
  String get scanner_searchingDevices => 'Söker efter MeshCore-enheter...';

  @override
  String get scanner_tapToScan => 'Tryck Skanna för att hitta MeshCore-enheter';

  @override
  String scanner_connectionFailed(String error) {
    return 'Anslutning misslyckades: $error';
  }

  @override
  String get scanner_backgroundBleMayDrop =>
      'Background BLE may drop without notification permission.';

  @override
  String get scanner_stop => 'Stoppa';

  @override
  String get scanner_scan => 'Skanna';

  @override
  String get scanner_bluetoothOff => 'Bluetooth är avstängt';

  @override
  String get scanner_bluetoothOffMessage =>
      'Vänligen aktivera Bluetooth för att söka efter enheter.';

  @override
  String get scanner_enableBluetooth => 'Aktivera Bluetooth';

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
  String get device_quickSwitch => 'Snabb växling';

  @override
  String get device_meshcore => 'MeshCore';

  @override
  String get settings_title => 'Inställningar';

  @override
  String get settings_deviceInfo => 'Enhetens information';

  @override
  String get settings_appSettings => 'Appinställningar';

  @override
  String get settings_appSettingsSubtitle =>
      'Meddelanden, notiser och kartinställningar';

  @override
  String get settings_nodeSettings => 'Nodinställningar';

  @override
  String get settings_nodeName => 'Nodnamn';

  @override
  String get settings_nodeNameNotSet => 'Inte angivet';

  @override
  String get settings_nodeNameHint => 'Ange nodnamn';

  @override
  String get settings_nodeNameUpdated => 'Namn uppdaterat';

  @override
  String get settings_radioSettings => 'Radioinställningar';

  @override
  String get settings_radioSettingsSubtitle =>
      'Frekvens, effekt, spridningsfaktor';

  @override
  String get settings_radioSettingsUpdated =>
      'Radioinställningarna har uppdaterats';

  @override
  String get settings_location => 'Plats';

  @override
  String get settings_locationSubtitle => 'GPS koordinater';

  @override
  String get settings_locationUpdated => 'Plats uppdaterad';

  @override
  String get settings_locationBothRequired => 'Ange både latitud och longitud.';

  @override
  String get settings_locationInvalid => 'Ogiltig latitud eller longitud.';

  @override
  String get settings_locationGPSEnable => 'Aktivera GPS';

  @override
  String get settings_locationGPSEnableSubtitle =>
      'Aktivera automatiska uppdateringar av platsen med hjälp av GPS.';

  @override
  String get settings_locationIntervalSec => 'Interval för GPS (Sekunder)';

  @override
  String get settings_usePhoneGps => 'Use phone GPS';

  @override
  String get settings_locationIntervalInvalid =>
      'Intervalet måste vara minst 60 sekunder och mindre än 86400 sekunder.';

  @override
  String get settings_latitude => 'Latitud';

  @override
  String get settings_longitude => 'Längdgrad';

  @override
  String get settings_privacyMode => 'Privatläge';

  @override
  String get settings_privacyModeSubtitle => 'Dölj namn/plats i annonser';

  @override
  String get settings_privacyModeToggle =>
      'Aktivera privatläge för att dölja ditt namn och din plats i annonser.';

  @override
  String get settings_privacyModeEnabled => 'Privatläget är aktiverat';

  @override
  String get settings_privacyModeDisabled => 'Privatläge är avstängt';

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
  String get settings_actions => 'Åtgärder';

  @override
  String get settings_sendAdvertisement => 'Skicka Annons';

  @override
  String get settings_sendAdvertisementSubtitle => 'Sändning finns nu';

  @override
  String get settings_advertisementSent => 'Annons skickad';

  @override
  String get settings_syncTime => 'Synkroniseringstid';

  @override
  String get settings_syncTimeSubtitle => 'Ställ enheten till telefonens tid';

  @override
  String get settings_timeSynchronized => 'Tidssynkroniserat';

  @override
  String get settings_refreshContacts => 'Uppdatera Kontakter';

  @override
  String get settings_refreshContactsSubtitle =>
      'Ladda om kontaktlistan från enheten';

  @override
  String get settings_rebootDevice => 'Starta om enheten';

  @override
  String get settings_rebootDeviceSubtitle => 'Starta MeshCore-enheten';

  @override
  String get settings_rebootDeviceConfirm =>
      'Är du säker på att du vill starta om enheten? Du kommer att bli avkopplad.';

  @override
  String get settings_debug => 'Felsök';

  @override
  String get settings_bleDebugLog => 'BLE-felsökning';

  @override
  String get settings_bleDebugLogSubtitle => 'BLE-kommandon, svar och rådata';

  @override
  String get settings_appDebugLog => 'Appfelsökning';

  @override
  String get settings_appDebugLogSubtitle =>
      'Applikations felsökningsmeddelanden';

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
  String get settings_about => 'Om';

  @override
  String settings_aboutVersion(String version) {
    return 'Gulf Coast Mesh App v$version';
  }

  @override
  String get settings_aboutLegalese => 'Gulf Coast Mesh App 2024';

  @override
  String get settings_aboutDescription =>
      'En öppen källkods Flutter-klient för MeshCore LoRa meshnätverksenheter.';

  @override
  String get settings_aboutOpenMeteoAttribution =>
      'LOS-höjddata: Open-Meteo (CC BY 4.0)';

  @override
  String get settings_infoName => 'Namn';

  @override
  String get settings_infoId => 'ID';

  @override
  String get settings_infoStatus => 'Status';

  @override
  String get settings_infoBattery => 'Batteri';

  @override
  String get settings_infoPublicKey => 'Allmänt nyckel';

  @override
  String get settings_infoContactsCount => 'Kontakterantal';

  @override
  String get settings_infoChannelCount => 'Kanalantal';

  @override
  String get settings_presets => 'Fördefinierade inställningar';

  @override
  String get settings_frequency => 'Frekvens (MHz)';

  @override
  String get settings_frequencyHelper => '300,0 - 2500,0';

  @override
  String get settings_frequencyInvalid => 'Ogiltig frekvens (300-2500 MHz)';

  @override
  String get settings_bandwidth => 'Bandbredd';

  @override
  String get settings_spreadingFactor => 'Spreadingfaktor';

  @override
  String get settings_codingRate => 'Kodningsgrad';

  @override
  String get settings_txPower => 'TX-effekt (dBm)';

  @override
  String get settings_txPowerHelper => '0 - 22';

  @override
  String get settings_txPowerInvalid => 'Ogiltig TX-effekt (0-22 dBm)';

  @override
  String get settings_clientRepeat => 'Upprepa utan elnät';

  @override
  String get settings_clientRepeatSubtitle =>
      'Låt enheten repetera nätpaket för andra användare.';

  @override
  String get settings_clientRepeatFreqWarning =>
      'För att kunna kommunicera utanför elnätet krävs frekvenserna 433, 869 eller 918 MHz.';

  @override
  String settings_error(String message) {
    return 'Fel: $message';
  }

  @override
  String get appSettings_title => 'Appinställningar';

  @override
  String get appSettings_appearance => 'Utseende';

  @override
  String get appSettings_theme => 'Tema';

  @override
  String get appSettings_themeSystem => 'Systemstandard';

  @override
  String get appSettings_themeLight => 'Ljus';

  @override
  String get appSettings_themeDark => 'Mörk';

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
  String get appSettings_language => 'Språk';

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
  String get appSettings_languageRu => 'Ryska';

  @override
  String get appSettings_languageUk => 'Ukrainska';

  @override
  String get appSettings_enableMessageTracing => 'Aktivera meddelandespårning';

  @override
  String get appSettings_enableMessageTracingSubtitle =>
      'Visa detaljerade metadata om dirigering och tidsinställningar för meddelanden';

  @override
  String get appSettings_notifications => 'Meddelanden';

  @override
  String get appSettings_enableNotifications => 'Aktivera Notifikationer';

  @override
  String get appSettings_enableNotificationsSubtitle =>
      'Ta emot notiser för meddelanden och reklam';

  @override
  String get appSettings_notificationPermissionDenied =>
      'Tillåtelse för notifikationer nekad';

  @override
  String get appSettings_notificationsEnabled => 'Notifikationer aktiverade';

  @override
  String get appSettings_notificationsDisabled => 'Meddelanden är avstängda';

  @override
  String get appSettings_messageNotifications => 'Meddelandekrav';

  @override
  String get appSettings_messageNotificationsSubtitle =>
      'Visa notis när nya meddelanden tas emot';

  @override
  String get appSettings_channelMessageNotifications => 'Kanalmeddelandena';

  @override
  String get appSettings_channelMessageNotificationsSubtitle =>
      'Visa notis när meddelanden i kanal mottas';

  @override
  String get appSettings_advertisementNotifications => 'Annonsmeddelanden';

  @override
  String get appSettings_advertisementNotificationsSubtitle =>
      'Visa notis när nya noder upptäcks';

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
  String get appSettings_messaging => 'Meddelanden';

  @override
  String get appSettings_clearPathOnMaxRetry => 'Rensa Vägen på Max Försök';

  @override
  String get appSettings_clearPathOnMaxRetrySubtitle =>
      'Återställ kontaktväg efter 5 misslyckade försök att skicka';

  @override
  String get appSettings_pathsWillBeCleared =>
      'Sökvägar kommer att tömmas efter 5 misslyckade försök.';

  @override
  String get appSettings_pathsWillNotBeCleared =>
      'Sökvägar kommer inte att rensas automatiskt.';

  @override
  String get appSettings_autoRouteRotation => 'Automatisk Rutväxling';

  @override
  String get appSettings_autoRouteRotationSubtitle =>
      'Blixtra mellan bästa vägar och flödesläge';

  @override
  String get appSettings_autoRouteRotationEnabled =>
      'Automatisk ruttrotation är aktiverad';

  @override
  String get appSettings_autoRouteRotationDisabled =>
      'Automatisk ruttrotation är avstängd';

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
  String get appSettings_battery => 'Batteri';

  @override
  String get appSettings_batteryChemistry => 'Batterikemi';

  @override
  String appSettings_batteryChemistryPerDevice(String deviceName) {
    return 'Ställ in per enhet ($deviceName)';
  }

  @override
  String get appSettings_batteryChemistryConnectFirst =>
      'Anslut till en enhet för att välja';

  @override
  String get appSettings_batteryNmc => '18650 NMC (3.0-4.2V)';

  @override
  String get appSettings_batteryLifepo4 => 'LiFePO4 (2,6–3,65V)';

  @override
  String get appSettings_batteryLipo => 'LiPo (3.0-4.2V)';

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
  String get appSettings_mapDisplay => 'Kartvisning';

  @override
  String get appSettings_showRepeaters => 'Visa återuppslag';

  @override
  String get appSettings_showRepeatersSubtitle =>
      'Visa återspelsnoder på kartan';

  @override
  String get appSettings_showChatNodes => 'Visa Chattnoder';

  @override
  String get appSettings_showChatNodesSubtitle => 'Visa chattnoder på kartan';

  @override
  String get appSettings_showOtherNodes => 'Visa andra noder';

  @override
  String get appSettings_showOtherNodesSubtitle =>
      'Visa andra nodtyper på kartan';

  @override
  String get appSettings_timeFilter => 'Tidsfilter';

  @override
  String get appSettings_timeFilterShowAll => 'Visa alla noder';

  @override
  String appSettings_timeFilterShowLast(int hours) {
    return 'Visa noder från de senaste $hours timmarna';
  }

  @override
  String get appSettings_mapTimeFilter => 'Karttid Filter';

  @override
  String get appSettings_showNodesDiscoveredWithin =>
      'Visa noder som upptäckts inom:';

  @override
  String get appSettings_allTime => 'Totalen';

  @override
  String get appSettings_lastHour => 'Sista timmen';

  @override
  String get appSettings_last6Hours => 'De senaste 6 timmarna';

  @override
  String get appSettings_last24Hours => 'De senaste 24 timmarna';

  @override
  String get appSettings_lastWeek => 'Förra veckan';

  @override
  String get appSettings_offlineMapCache => 'Offline Kartcache';

  @override
  String get appSettings_unitsTitle => 'Enheter';

  @override
  String get appSettings_unitsMetric => 'Metriskt (m/km)';

  @override
  String get appSettings_unitsImperial => 'Imperialt (ft / mi)';

  @override
  String get appSettings_noAreaSelected => 'Ingen area markerad';

  @override
  String appSettings_areaSelectedZoom(int minZoom, int maxZoom) {
    return 'Område markerat (zoom $minZoom-$maxZoom)';
  }

  @override
  String get appSettings_debugCard => 'Felsök';

  @override
  String get appSettings_appDebugLogging => 'App-felsökning och loggning';

  @override
  String get appSettings_appDebugLoggingSubtitle =>
      'Logga appens felsökningsmeddelanden för felsökning';

  @override
  String get appSettings_appDebugLoggingEnabled =>
      'App felsökning loggning aktiverad';

  @override
  String get appSettings_appDebugLoggingDisabled =>
      'App felsökning är avstängd';

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
  String get contacts_title => 'Kontakter';

  @override
  String get contacts_noContacts => 'Inga kontakter ännu';

  @override
  String get contacts_contactsWillAppear =>
      'Kontakter kommer att visas när enheter annonserar.';

  @override
  String get contacts_searchContacts => 'Sök kontakter...';

  @override
  String get contacts_noUnreadContacts => 'Inga oinlästa kontakter';

  @override
  String get contacts_noContactsFound =>
      'Inga kontakter eller grupper hittades.';

  @override
  String get contacts_deleteContact => 'Ta bort Kontakt';

  @override
  String contacts_removeConfirm(String contactName) {
    return 'Ta bort $contactName från kontakter?';
  }

  @override
  String get contacts_manageRepeater => 'Hantera Upprepare';

  @override
  String get contacts_manageRoom => 'Hantera Rumserver';

  @override
  String get contacts_roomLogin => 'Rum Inloggning';

  @override
  String get contacts_openChat => 'Öppna Chatt';

  @override
  String get contacts_editGroup => 'Redigera Grupp';

  @override
  String get contacts_deleteGroup => 'Ta bort Grupp';

  @override
  String contacts_deleteGroupConfirm(String groupName) {
    return 'Ta bort $groupName?';
  }

  @override
  String get contacts_newGroup => 'Ny grupp';

  @override
  String get contacts_groupName => 'Gruppnamn';

  @override
  String get contacts_groupNameRequired => 'Gruppnamnet är obligatoriskt';

  @override
  String contacts_groupAlreadyExists(String name) {
    return 'Gruppen \"$name\" finns redan.';
  }

  @override
  String get contacts_filterContacts => 'Filtrera kontakter...';

  @override
  String get contacts_noContactsMatchFilter =>
      'Inga kontakter matchar ditt filter';

  @override
  String get contacts_noMembers => 'Inga medlemmar';

  @override
  String get contacts_lastSeenNow => 'Senast synlig nu';

  @override
  String contacts_lastSeenMinsAgo(int minutes) {
    return 'Senast sedd $minutes min sedan';
  }

  @override
  String get contacts_lastSeenHourAgo => 'Senast sedd för 1 timme sedan';

  @override
  String contacts_lastSeenHoursAgo(int hours) {
    return 'Senast sedd $hours timmar sedan';
  }

  @override
  String get contacts_lastSeenDayAgo => 'Senast sedd för 1 dag sedan';

  @override
  String contacts_lastSeenDaysAgo(int days) {
    return 'Senast synlig $days dagar sedan';
  }

  @override
  String get channels_title => 'Kanaler';

  @override
  String get channels_noChannelsConfigured => 'Inga kanaler konfigurerade';

  @override
  String get channels_addPublicChannel => 'Lägg till publik kanal';

  @override
  String get channels_searchChannels => 'Sök kanaler...';

  @override
  String get channels_noChannelsFound => 'Inga kanaler hittades';

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
  String get channels_hashtagChannel => 'Hashtagkanal';

  @override
  String get channels_public => 'Offentligt';

  @override
  String get channels_private => 'Privat';

  @override
  String get channels_publicChannel => 'Allmänt kanal';

  @override
  String get channels_privateChannel => 'Privat kanal';

  @override
  String get channels_editChannel => 'Redigera kanal';

  @override
  String get channels_deleteChannel => 'Ta bort kanal';

  @override
  String channels_deleteChannelConfirm(String name) {
    return 'Radera \"$name\"? Detta kan inte ångras.';
  }

  @override
  String get channels_deleteChannelRequiresConnection =>
      'Connect to a device to delete a channel';

  @override
  String channels_channelDeleted(String name) {
    return 'Kanalen \"$name\" raderad';
  }

  @override
  String get channels_addChannel => 'Lägg till kanal';

  @override
  String get channels_channelIndexLabel => 'Kanalindex';

  @override
  String get channels_channelName => 'Kanalnamn';

  @override
  String get channels_usePublicChannel => 'Använd Publikkanal';

  @override
  String get channels_standardPublicPsk => 'Standard allmän PSK';

  @override
  String get channels_pskHex => 'PSK (Hex)';

  @override
  String get channels_generateRandomPsk => 'Generera slumpmässig PSK';

  @override
  String get channels_enterChannelName => 'Ange en kanalnamn';

  @override
  String get channels_pskMustBe32Hex => 'PSK måste vara 32 hexadecimala tecken';

  @override
  String channels_channelAdded(String name) {
    return 'Kanalen \"$name\" har lagts till';
  }

  @override
  String channels_editChannelTitle(int index) {
    return 'Redigera Kanal $index';
  }

  @override
  String get channels_smazCompression => 'SMAZ-komprimering';

  @override
  String channels_channelUpdated(String name) {
    return 'Kanalen \"$name\" har uppdaterats';
  }

  @override
  String get channels_publicChannelAdded => 'Allmänt kanal tillagd';

  @override
  String get channels_sortBy => 'Sortera efter';

  @override
  String get channels_sortManual => 'Manuell';

  @override
  String get channels_sortAZ => 'A-Z';

  @override
  String get channels_sortLatestMessages => 'Senaste meddelanden';

  @override
  String get channels_sortUnread => 'Oläst';

  @override
  String get channels_createPrivateChannel => 'Skapa en privat kanal';

  @override
  String get channels_createPrivateChannelDesc =>
      'Skyddat med en hemlig nyckel.';

  @override
  String get channels_joinPrivateChannel => 'Gå med i en Privat Kanal';

  @override
  String get channels_joinPrivateChannelDesc =>
      'Ange en hemlig nyckel manuellt.';

  @override
  String get channels_joinPublicChannel => 'Gå med i den Offentliga Kanalen';

  @override
  String get channels_joinPublicChannelDesc =>
      'Vem som helst kan gå med i denna kanal.';

  @override
  String get channels_joinHashtagChannel => 'Gå med i en Hashtagkanal';

  @override
  String get channels_joinHashtagChannelDesc =>
      'Väldigt enkelt att gå med i hashtag-kanaler.';

  @override
  String get channels_scanQrCode => 'Skanna en QR-kod';

  @override
  String get channels_scanQrCodeDesc =>
      'Import a channel invite with name, key, and optional region.';

  @override
  String get channels_scanQrCodeComingSoon => 'Kommer snart';

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
  String get channels_enterHashtag => 'Ange hashtag';

  @override
  String get channels_hashtagHint => 't.ex. #team';

  @override
  String get chat_noMessages => 'Inga meddelanden ännu';

  @override
  String get chat_sendMessageToStart =>
      'Skicka ett meddelande för att komma igång';

  @override
  String get chat_originalMessageNotFound =>
      'Originalt meddelande hittades inte';

  @override
  String chat_replyingTo(String name) {
    return 'Svara till $name';
  }

  @override
  String chat_replyTo(String name) {
    return 'Svara till $name';
  }

  @override
  String get chat_location => 'Plats';

  @override
  String chat_sendMessageTo(String contactName) {
    return 'Skicka ett meddelande till $contactName';
  }

  @override
  String get chat_typeMessage => 'Skriv ett meddelande...';

  @override
  String chat_messageTooLong(int maxBytes) {
    return 'Meddelandet är för långt (max $maxBytes byte).';
  }

  @override
  String get chat_messageCopied => 'Meddelandet kopierades';

  @override
  String get chat_messageDeleted => 'Meddelandet raderat';

  @override
  String get chat_retryingMessage => 'Försöker igen';

  @override
  String chat_retryCount(int current, int max) {
    return 'Försök igen $current/$max';
  }

  @override
  String get chat_sendGif => 'Skicka GIF';

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
  String get chat_reply => 'Svara';

  @override
  String get chat_addReaction => 'Lägg till reaktion';

  @override
  String get chat_editMessage => 'Edit message';

  @override
  String get chat_editedLabel => '(edited)';

  @override
  String get chat_messageEdited => 'Message edited';

  @override
  String get chat_me => 'Mig';

  @override
  String get emojiCategorySmileys => 'Emojis';

  @override
  String get emojiCategoryGestures => 'Gestikuleringar';

  @override
  String get emojiCategoryHearts => 'Hjärtan';

  @override
  String get emojiCategoryObjects => 'Objekt';

  @override
  String get gifPicker_title => 'Välj en GIF';

  @override
  String get gifPicker_searchHint => 'Sök GIF:ar...';

  @override
  String get gifPicker_poweredBy => 'Drivet av GIPHY';

  @override
  String get gifPicker_noGifsFound => 'Inga GIF-filer hittades';

  @override
  String get gifPicker_failedLoad => 'Kunde inte ladda GIF-filer';

  @override
  String get gifPicker_failedSearch => 'Sökningen misslyckades.';

  @override
  String get gifPicker_noInternet => 'Ingen internetanslutning';

  @override
  String get debugLog_appTitle => 'Appfelsökning';

  @override
  String get debugLog_bleTitle => 'BLE-felsökning';

  @override
  String get debugLog_copyLog => 'Kopiera logg';

  @override
  String get debugLog_clearLog => 'Rensa logg';

  @override
  String get debugLog_copied => 'Felsökningslogg kopierad';

  @override
  String get debugLog_bleCopied => 'BLE-logg kopierad';

  @override
  String get debugLog_noEntries => 'Inga felsökningsloggar ännu';

  @override
  String get debugLog_enableInSettings =>
      'Aktivera appens felsökningsloggning i inställningarna';

  @override
  String get debugLog_frames => 'Rammar';

  @override
  String get debugLog_rawLogRx => 'Rå Log-RX';

  @override
  String get debugLog_noBleActivity => 'Ingen BLE-aktivitet ännu';

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
    return 'Ramstorlek: $count byte';
  }

  @override
  String debugFrame_command(String value) {
    return 'Kommando: 0x$value';
  }

  @override
  String get debugFrame_textMessageHeader => 'Textmeddelandefält:';

  @override
  String debugFrame_destinationPubKey(String pubKey) {
    return '– Destination PubKey: $pubKey';
  }

  @override
  String debugFrame_timestamp(int timestamp) {
    return '- Tidsstämpel: $timestamp';
  }

  @override
  String debugFrame_flags(String value) {
    return '- Flaggor: 0x$value';
  }

  @override
  String debugFrame_textType(int type, String label) {
    return '- Texttyp: $type ($label)';
  }

  @override
  String get debugFrame_textTypeCli => 'CLI';

  @override
  String get debugFrame_textTypePlain => 'Enkel';

  @override
  String debugFrame_text(String text) {
    return '- Text: \"$text\"';
  }

  @override
  String get debugFrame_hexDump => 'Hexdump:';

  @override
  String get chat_pathManagement => 'Stigarhantering';

  @override
  String get chat_ShowAllPaths => 'Visa alla vägar';

  @override
  String get chat_routingMode => 'Ruttläge';

  @override
  String get chat_autoUseSavedPath => 'Automatisk (använd sparad sökväg)';

  @override
  String get chat_forceFloodMode => 'Tvinga Översvämningsläge';

  @override
  String get chat_recentAckPaths =>
      'Nyligen Ack-vägar (tryck för att använda):';

  @override
  String get chat_pathHistoryFull =>
      'Historisk sökväg är full. Ta bort poster för att lägga till nya.';

  @override
  String get chat_hopSingular => 'hoppa';

  @override
  String get chat_hopPlural => 'hoppar';

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
  String get chat_successes => 'framgångar';

  @override
  String get chat_removePath => 'Ta bort sökväg';

  @override
  String get chat_noPathHistoryYet =>
      'Ingen historik ännu.\nSkicka ett meddelande för att upptäcka spår.';

  @override
  String get chat_pathActions => 'Stigar:';

  @override
  String get chat_setCustomPath => 'Ange anpassad sökväg';

  @override
  String get chat_setCustomPathSubtitle => 'Ange ruttväg manuellt';

  @override
  String get chat_clearPath => 'Rensa Vägen';

  @override
  String get chat_clearPathSubtitle => 'Tvinga fram omstart vid nästa sändning';

  @override
  String get chat_pathCleared =>
      'Routen är nu fri. Nästa meddelande kommer att upptäcka rutten igen.';

  @override
  String get chat_floodModeSubtitle => 'Använd routningsomkopplaren i appraden';

  @override
  String get chat_floodModeEnabled =>
      'Översvämningsläge aktiverat. Stäng av via ruttikonen i appraden.';

  @override
  String get chat_fullPath => 'Fullständig sökväg';

  @override
  String get chat_pathDetailsNotAvailable =>
      'Stigaruppgifterna är ännu inte tillgängliga. Försök att skicka ett meddelande för att uppdatera.';

  @override
  String chat_pathSetHops(int hopCount, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      hopCount,
      locale: localeName,
      other: 'hoppar',
      one: 'hopp',
    );
    return 'Sökväg inställd: $hopCount $_temp0 - $status';
  }

  @override
  String get chat_pathSavedLocally =>
      'Sparat lokalt. Anslut för att synkronisera.';

  @override
  String get chat_pathDeviceConfirmed => 'Enheten bekräftad.';

  @override
  String get chat_pathDeviceNotConfirmed => 'Enheten har inte bekräftats ännu.';

  @override
  String get chat_type => 'Skriv';

  @override
  String get chat_path => 'Sökväg';

  @override
  String get chat_publicKey => 'Allmänt nyckel';

  @override
  String get chat_compressOutgoingMessages => 'Kryptera utgående meddelanden';

  @override
  String get chat_floodForced => 'Översvämning (tvingad)';

  @override
  String get chat_directForced => 'Direkt (tvingad)';

  @override
  String chat_hopsForced(int count) {
    return '$count hopp (tvingat)';
  }

  @override
  String get chat_floodAuto => 'Översvämning (auto)';

  @override
  String get chat_direct => 'Direkt';

  @override
  String get chat_poiShared => 'Delad POI';

  @override
  String chat_unread(int count) {
    return 'Olästa: $count';
  }

  @override
  String get chat_openLink => 'Öppna länk?';

  @override
  String get chat_openLinkConfirmation =>
      'Vill du öppna den här länken i din webbläsare?';

  @override
  String get chat_open => 'Öppna';

  @override
  String chat_couldNotOpenLink(String url) {
    return 'Kunde inte öppna länken: $url';
  }

  @override
  String get chat_invalidLink => 'Ogiltigt länkformat';

  @override
  String get map_title => 'Nodkarta';

  @override
  String get map_lineOfSight => 'Synlinje';

  @override
  String get map_losScreenTitle => 'Synlinje';

  @override
  String get map_noNodesWithLocation => 'Inga noder med platsinformation';

  @override
  String get map_nodesNeedGps =>
      'Noder måste dela sina GPS-koordinater\nför att visas på kartan';

  @override
  String map_nodesCount(int count) {
    return 'Noder: $count';
  }

  @override
  String map_pinsCount(int count) {
    return 'Pinnar: $count';
  }

  @override
  String get map_chat => 'Chat';

  @override
  String get map_repeater => 'Återuppspelare';

  @override
  String get map_room => 'Rum';

  @override
  String get map_sensor => 'Sensor';

  @override
  String get map_pinDm => 'Lås (DM)';

  @override
  String get map_pinPrivate => 'Lås (Privat)';

  @override
  String get map_pinPublic => 'Anslå (Offentligt)';

  @override
  String get map_lastSeen => 'Senast sedd';

  @override
  String get map_disconnectConfirm =>
      'Är du säker på att du vill koppla från enheten?';

  @override
  String get map_from => 'Från';

  @override
  String get map_source => 'Källa';

  @override
  String get map_flags => 'Flaggor';

  @override
  String get map_pinLabel => 'Fästetikett';

  @override
  String get map_label => 'Etikett';

  @override
  String get map_publicLocationShare => 'Dela offentlig plats';

  @override
  String map_publicLocationShareConfirm(String channelLabel) {
    return 'Du håller på att dela en plats i $channelLabel. Denna kanal är offentlig och alla med PSK kan se den.';
  }

  @override
  String get map_connectToShareMarkers =>
      'Anslut till en enhet för att dela markörer';

  @override
  String get map_filterNodes => 'Filtrera noder';

  @override
  String get map_nodeTypes => 'Nodtyper';

  @override
  String get map_chatNodes => 'Chatnoder';

  @override
  String get map_repeaters => 'Upprepare';

  @override
  String get map_otherNodes => 'Andra noder';

  @override
  String get map_keyPrefix => 'Nyckelprefix';

  @override
  String get map_filterByKeyPrefix => 'Filtrera efter nyckelprefix';

  @override
  String get map_publicKeyPrefix => 'Allmänt nyckelprästegenskap';

  @override
  String get map_markers => 'Markörer';

  @override
  String get map_showSharedMarkers => 'Visa delade markörer';

  @override
  String get map_lastSeenTime => 'Senaste Visats Tid';

  @override
  String get map_joinRoom => 'Gå med i rum';

  @override
  String get map_manageRepeater => 'Hantera Upprepare';

  @override
  String get map_tapToAdd => 'Tryck på noder för att lägga till dem i banan.';

  @override
  String get map_runTrace => 'Kör spårsökning';

  @override
  String get map_removeLast => 'Ta bort sista';

  @override
  String get map_pathTraceCancelled => 'Sökvägsspårning avbruten.';

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
  String get mapCache_title => 'Offline Kartcache';

  @override
  String get mapCache_selectAreaFirst => 'Välj ett område att cachera först';

  @override
  String get mapCache_noTilesToDownload =>
      'Inga kuber att ladda ner för detta område';

  @override
  String get mapCache_downloadTilesTitle => 'Ladda ner klick';

  @override
  String mapCache_downloadTilesPrompt(int count) {
    return 'Ladda ner $count kuber för offlineanvändning?';
  }

  @override
  String get mapCache_downloadAction => 'Ladda ner';

  @override
  String mapCache_cachedTiles(int count) {
    return 'Cache $count kuber';
  }

  @override
  String mapCache_cachedTilesWithFailed(int downloaded, int failed) {
    return 'Cachelagda $downloaded klickark ($failed misslyckades)';
  }

  @override
  String get mapCache_clearOfflineCacheTitle => 'Rensa offline-cache';

  @override
  String get mapCache_clearOfflineCachePrompt => 'Ta bort alla cachemapplaner?';

  @override
  String get mapCache_offlineCacheCleared => 'Offline-cache rensad';

  @override
  String get mapCache_noAreaSelected => 'Ingen area markerad';

  @override
  String get mapCache_cacheArea => 'Cacheområde';

  @override
  String get mapCache_useCurrentView => 'Använd Aktuell Visning';

  @override
  String get mapCache_zoomRange => 'Zoombegränsning';

  @override
  String mapCache_estimatedTiles(int count) {
    return 'Uppskattat antal klick: $count';
  }

  @override
  String mapCache_downloadedTiles(int completed, int total) {
    return 'Ladda ner $completed / $total';
  }

  @override
  String get mapCache_downloadTilesButton => 'Ladda ner klick';

  @override
  String get mapCache_clearCacheButton => 'Rensa Cache';

  @override
  String mapCache_failedDownloads(int count) {
    return 'Misslyckade nedladdningar: $count';
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
  String get time_justNow => 'Precis nu';

  @override
  String time_minutesAgo(int minutes) {
    return '$minutes min sedan';
  }

  @override
  String time_hoursAgo(int hours) {
    return '$hours timmar sedan';
  }

  @override
  String time_daysAgo(int days) {
    return '$days dagar sedan';
  }

  @override
  String get time_hour => 'timme';

  @override
  String get time_hours => 'timmar';

  @override
  String get time_day => 'dag';

  @override
  String get time_days => 'dagar';

  @override
  String get time_week => 'vecka';

  @override
  String get time_weeks => 'veckor';

  @override
  String get time_month => 'månad';

  @override
  String get time_months => 'månader';

  @override
  String get time_minutes => 'minuter';

  @override
  String get time_allTime => 'Alla tider';

  @override
  String get dialog_disconnect => 'Koppla från';

  @override
  String get dialog_disconnectConfirm =>
      'Är du säker på att du vill koppla från enheten?';

  @override
  String get login_repeaterLogin => 'Återuppta Inloggning';

  @override
  String get login_roomLogin => 'Rum Inloggning';

  @override
  String get login_password => 'Lösenord';

  @override
  String get login_enterPassword => 'Ange lösenord';

  @override
  String get login_savePassword => 'Spara lösenord';

  @override
  String get login_savePasswordSubtitle =>
      'Lösenord kommer att lagras säkert på enheten.';

  @override
  String get login_repeaterDescription =>
      'Ange återuppspelarens lösenord för att komma åt inställningar och status.';

  @override
  String get login_roomDescription =>
      'Ange rummets lösenord för att komma åt inställningar och status.';

  @override
  String get login_routing => 'Ruttning';

  @override
  String get login_routingMode => 'Ruttläge';

  @override
  String get login_autoUseSavedPath => 'Automatisk (använd sparad sökväg)';

  @override
  String get login_forceFloodMode => 'Tvinga Översvämningsläge';

  @override
  String get login_managePaths => 'Hantera Sökvägar';

  @override
  String get login_login => 'Logga in';

  @override
  String login_attempt(int current, int max) {
    return 'Försök $current/$max';
  }

  @override
  String login_failed(String error) {
    return 'Inloggning misslyckades: $error';
  }

  @override
  String get login_failedMessage =>
      'Inloggning misslyckades. Antingen är lösenordet fel eller så går det inte att nå repeatern.';

  @override
  String get common_reload => 'Ladda om';

  @override
  String get common_clear => 'Rensa';

  @override
  String path_currentPath(String path) {
    return 'Nuvarande sökväg: $path';
  }

  @override
  String path_usingHopsPath(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Använda $count $_temp0 sökväg';
  }

  @override
  String get path_enterCustomPath => 'Ange anpassad sökväg';

  @override
  String get path_currentPathLabel => 'Nuvarande sökväg';

  @override
  String get path_hexPrefixInstructions =>
      'Ange 2-tecknets hex-prefett för varje hopp, åtskilda med komma.';

  @override
  String get path_hexPrefixExample =>
      'Exempel: A1,F2,3C (varje nod använder det första bytet av sitt publika nyckel)';

  @override
  String get path_labelHexPrefixes => 'Hexprefixer';

  @override
  String get path_helperMaxHops =>
      'Max 64 hopp. Varje prefix är 2 hex-tecken (1 byte)';

  @override
  String get path_selectFromContacts => 'Välj istället från kontakter:';

  @override
  String get path_noRepeatersFound =>
      'Inga återuppspelare eller rumsservrar hittades.';

  @override
  String get path_customPathsRequire =>
      'Anpassade sökvägar kräver mellansteg som kan vidarebefordra meddelanden.';

  @override
  String path_invalidHexPrefixes(String prefixes) {
    return 'Ogiltiga hex-prefikser: $prefixes';
  }

  @override
  String get path_tooLong => 'Sökvägen är för lång. Max 64 hopp tillåtna.';

  @override
  String get path_setPath => 'Ange Sökväg';

  @override
  String get repeater_management => 'Återuppspelarens Hantering';

  @override
  String get room_management => 'Rumserverhantering';

  @override
  String get repeater_managementTools => 'Administrationsverktyg';

  @override
  String get repeater_status => 'Status';

  @override
  String get repeater_statusSubtitle =>
      'Visa återspolningsstatus, statistik och grannar';

  @override
  String get repeater_sendAdvert => 'Send Advert';

  @override
  String get repeater_sendAdvertSubtitle =>
      'Broadcast an advertisement packet now';

  @override
  String get repeater_telemetry => 'Telemetry';

  @override
  String get repeater_telemetrySubtitle =>
      'Visa telemetri för sensorer och systemstatistik';

  @override
  String get repeater_cli => 'CLI';

  @override
  String get repeater_cliSubtitle => 'Skicka kommandon till repetitorn';

  @override
  String get repeater_neighbors => 'Grannar';

  @override
  String get repeater_neighborsSubtitle => 'Visa noll hoppgrannar.';

  @override
  String get repeater_settings => 'Inställningar';

  @override
  String get repeater_settingsSubtitle => 'Konfigurera återspolarparametrar';

  @override
  String get repeater_statusTitle => 'Återspelsstatus';

  @override
  String get repeater_routingMode => 'Ruttläge';

  @override
  String get repeater_autoUseSavedPath => 'Automatisk (använd sparad sökväg)';

  @override
  String get repeater_forceFloodMode => 'Tvinga Översvämningsläge';

  @override
  String get repeater_pathManagement => 'Stigarhantering';

  @override
  String get repeater_refresh => 'Uppdatera';

  @override
  String get repeater_statusRequestTimeout =>
      'Statusförfrågan gick inte att hämta.';

  @override
  String repeater_errorLoadingStatus(String error) {
    return 'Fel vid inläsning av status: $error';
  }

  @override
  String get repeater_systemInformation => 'Systeminformation';

  @override
  String get repeater_firmwareVersion => 'Firmware';

  @override
  String get repeater_battery => 'Batteri';

  @override
  String get repeater_clockAtLogin => 'Klocka (vid inloggning)';

  @override
  String get repeater_uptime => 'Tillgänglighet';

  @override
  String get repeater_queueLength => 'Köans längd';

  @override
  String get repeater_debugFlags => 'Felsökningsflaggor';

  @override
  String get repeater_radioStatistics => 'Radiostatistik';

  @override
  String get repeater_lastRssi => 'Senaste RSSI';

  @override
  String get repeater_lastSnr => 'Sista SNR';

  @override
  String get repeater_noiseFloor => 'Ljudnivå';

  @override
  String get repeater_txAirtime => 'TX Airtime';

  @override
  String get repeater_rxAirtime => 'RX Airtime';

  @override
  String get repeater_packetStatistics => 'Paketstatistik';

  @override
  String get repeater_sent => 'Skickat';

  @override
  String get repeater_received => 'Mottaget';

  @override
  String get repeater_duplicates => 'Dubbletter';

  @override
  String repeater_daysHoursMinsSecs(
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return '$days dagar $hours timmar $minutes minuter $seconds sekunder';
  }

  @override
  String repeater_packetTxTotal(int total, String flood, String direct) {
    return 'Totalt: $total, Översvämning: $flood, Direkt: $direct';
  }

  @override
  String repeater_packetRxTotal(int total, String flood, String direct) {
    return 'Totalt: $total, Översvämning: $flood, Direkt: $direct';
  }

  @override
  String repeater_duplicatesFloodDirect(String flood, String direct) {
    return 'Översvämning: $flood, Direkt: $direct';
  }

  @override
  String repeater_duplicatesTotal(int total) {
    return 'Totalt: $total';
  }

  @override
  String get repeater_settingsTitle => 'Återuppspelarens Inställningar';

  @override
  String get repeater_basicSettings => 'Grundinställningar';

  @override
  String get repeater_repeaterName => 'Upprepare Namn';

  @override
  String get repeater_repeaterNameHelper => 'Visa namn för denna återupprepare';

  @override
  String get repeater_adminPassword => 'Adminlösenord';

  @override
  String get repeater_adminPasswordHelper => 'Fullständig åtkomstlösenord';

  @override
  String get repeater_guestPassword => 'Gästlösenhet';

  @override
  String get repeater_guestPasswordHelper => 'Läs-skyddspassord';

  @override
  String get repeater_radioSettings => 'Radioinställningar';

  @override
  String get repeater_frequencyMhz => 'Frekvens (MHz)';

  @override
  String get repeater_frequencyHelper => '300-2500 MHz';

  @override
  String get repeater_txPower => 'TX Effekt';

  @override
  String get repeater_txPowerHelper => '1-30 dBm';

  @override
  String get repeater_bandwidth => 'Bandbredd';

  @override
  String get repeater_spreadingFactor => 'Spreadingfaktor';

  @override
  String get repeater_codingRate => 'Kodningsgrad';

  @override
  String get repeater_locationSettings => 'Platsinställningar';

  @override
  String get repeater_latitude => 'Latitud';

  @override
  String get repeater_latitudeHelper => 'Decimalgrader (t.ex. 37.7749)';

  @override
  String get repeater_longitude => 'Längdgrad';

  @override
  String get repeater_longitudeHelper => 'Decimalgrader (t.ex. -122.4194)';

  @override
  String get repeater_features => 'Funktioner';

  @override
  String get repeater_packetForwarding => 'Paketväxling';

  @override
  String get repeater_packetForwardingSubtitle =>
      'Aktivera återuppspelaren för att vidarebefordra paket';

  @override
  String get repeater_guestAccess => 'Gäståtkomst';

  @override
  String get repeater_guestAccessSubtitle =>
      'Tillåt läsbehörigheter för gäster.';

  @override
  String get repeater_privacyMode => 'Privatläge';

  @override
  String get repeater_privacyModeSubtitle => 'Dölj namn/plats i annonser';

  @override
  String get repeater_advertisementSettings => 'Annonsinställningar';

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
  String get repeater_localAdvertInterval => 'Lokalt Annonsintervall';

  @override
  String repeater_localAdvertIntervalMinutes(int minutes) {
    return '$minutes minuter';
  }

  @override
  String get repeater_floodAdvertInterval =>
      'Översvämnadsannonsens tidsintervall';

  @override
  String repeater_floodAdvertIntervalHours(int hours) {
    return '$hours timmar';
  }

  @override
  String get repeater_encryptedAdvertInterval => 'Krypterad Annonsintervall';

  @override
  String get repeater_dangerZone => 'Faraområde';

  @override
  String get repeater_rebootRepeater => 'Starta Återuppspelaren';

  @override
  String get repeater_rebootRepeaterSubtitle => 'Starta om repeternheten';

  @override
  String get repeater_rebootRepeaterConfirm =>
      'Är du säker på att du vill starta om denna repeater?';

  @override
  String get repeater_regenerateIdentityKeySubtitle =>
      'Generera ny publik/privat nyckelpar';

  @override
  String get repeater_regenerateIdentityKeyConfirm =>
      'Detta kommer att generera en ny identitet för återspelaren. Fortsätta?';

  @override
  String get repeater_eraseFileSystem => 'Radera Filsystem';

  @override
  String get repeater_eraseFileSystemSubtitle =>
      'Formatera återspelsfilsystemet';

  @override
  String get repeater_eraseFileSystemConfirm =>
      'VARNING: Detta kommer att radera all data på repeatern. Detta kan inte ångras!';

  @override
  String get repeater_eraseSerialOnly =>
      'Rensa är endast tillgängligt via seriell konsol.';

  @override
  String repeater_commandSent(String command) {
    return 'Kommandot skickades: $command';
  }

  @override
  String repeater_errorSendingCommand(String error) {
    return 'Fel vid skickande av kommando: $error';
  }

  @override
  String get repeater_confirm => 'Bekräfta';

  @override
  String get repeater_settingsSaved =>
      'Inställningarna sparades framgångsrikt.';

  @override
  String repeater_errorSavingSettings(String error) {
    return 'Fel vid sparande av inställningar: $error';
  }

  @override
  String get repeater_refreshBasicSettings =>
      'Återställ Grundläggande Inställningar';

  @override
  String get repeater_refreshRadioSettings => 'Återställ Radiosinställningar';

  @override
  String get repeater_refreshTxPower => 'Återställ TX-effekt';

  @override
  String get repeater_refreshLocationSettings =>
      'Uppdatera Lokationsinställningar';

  @override
  String get repeater_refreshPacketForwarding => 'Återställ Paketväxling';

  @override
  String get repeater_refreshGuestAccess => 'Återställ Gäståtkomst';

  @override
  String get repeater_refreshPrivacyMode => 'Återställ Sekretessläge';

  @override
  String get repeater_refreshAdvertisementSettings =>
      'Återställ Annonsinställningar';

  @override
  String repeater_refreshed(String label) {
    return '$label har uppdaterats';
  }

  @override
  String repeater_errorRefreshing(String label) {
    return 'Fel vid uppdatering av $label';
  }

  @override
  String get repeater_cliTitle => 'Återuppspelaren CLI';

  @override
  String get repeater_debugNextCommand => 'Felsök Nästa Kommando';

  @override
  String get repeater_commandHelp => 'Hjälp';

  @override
  String get repeater_clearHistory => 'Rensa Historik';

  @override
  String get repeater_noCommandsSent => 'Inga kommandon skickats ännu';

  @override
  String get repeater_typeCommandOrUseQuick =>
      'Skriv en kommando nedan eller använd snabba kommandon';

  @override
  String get repeater_enterCommandHint => 'Ange kommando...';

  @override
  String get repeater_previousCommand => 'Tidigare kommando';

  @override
  String get repeater_nextCommand => 'Nästa kommando';

  @override
  String get repeater_enterCommandFirst => 'Ange en kommando först';

  @override
  String get repeater_cliCommandFrameTitle => 'Kommandofönster';

  @override
  String repeater_cliCommandError(String error) {
    return 'Fel: $error';
  }

  @override
  String get repeater_cliQuickGetName => 'Hämta namn';

  @override
  String get repeater_cliQuickGetRadio => 'Få Radio';

  @override
  String get repeater_cliQuickGetTx => 'Hämta TX';

  @override
  String get repeater_cliQuickNeighbors => 'Grannar';

  @override
  String get repeater_cliQuickVersion => 'Version';

  @override
  String get repeater_cliQuickAdvertise => 'Annonsera';

  @override
  String get repeater_cliQuickClock => 'Klocka';

  @override
  String get repeater_cliHelpAdvert => 'Skickar ett annonspaket';

  @override
  String get repeater_cliHelpReboot =>
      'Startar om enheten. (notera, du får kanske \'Timeout\' vilket är normalt)';

  @override
  String get repeater_cliHelpClock => 'Visar aktuell tid per enhetens klocka.';

  @override
  String get repeater_cliHelpPassword =>
      'Ställer in ett nytt administratörslösenord för enheten.';

  @override
  String get repeater_cliHelpVersion =>
      'Visar enhetsversion och firmwarebyggnadsdatum.';

  @override
  String get repeater_cliHelpClearStats =>
      'Återställer olika statistikräknare till noll.';

  @override
  String get repeater_cliHelpSetAf => 'Ställer in lufttidsfaktor.';

  @override
  String get repeater_cliHelpSetTx =>
      'Ställer LoRa-sändningseffekten i dBm. (starta om för att tillämpa)';

  @override
  String get repeater_cliHelpSetRepeat =>
      'Aktiverar eller inaktiverar återuppspelarens roll för denna nod.';

  @override
  String get repeater_cliHelpSetAllowReadOnly =>
      '(Rumserver) Om \'på\', så tillåts login med tomt lösenord, men kan inte Posta till rummet. (bara läsa).';

  @override
  String get repeater_cliHelpSetFloodMax =>
      'Ställer in det maximala antalet hopp för inkommande översvämning (om >= max, skickas inte paketet).';

  @override
  String get repeater_cliHelpSetIntThresh =>
      'Ställer Interferensgränsen (i dB). Standardvärdet är 14. Ställ in den på 0 för att inaktivera detektion av kanalinterferens.';

  @override
  String get repeater_cliHelpSetAgcResetInterval =>
      'Ställer in intervallet för att återställa Auto Gain-kontrollen. Ställ in till 0 för att inaktivera.';

  @override
  String get repeater_cliHelpSetMultiAcks =>
      'Aktiverar eller inaktiverar funktionen \'dubbla ACKs\'.';

  @override
  String get repeater_cliHelpSetAdvertInterval =>
      'Ställer in tidsintervallen i minuter för att skicka ett lokalt (utan-hopp) annonseringspaket. Ställs till 0 för att inaktivera.';

  @override
  String get repeater_cliHelpSetFloodAdvertInterval =>
      'Ställer in tidsintervallen i timmar för att skicka ett flödesannonspaket. Ställ in på 0 för att inaktivera.';

  @override
  String get repeater_cliHelpGetPathHashMode =>
      'Returns advert path hash mode (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetPathHashMode =>
      'Sets advert path hash mode for this repeater (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetGuestPassword =>
      'Ställer in/uppdaterar gästlösenordet. (för återvändare kan gästloggar skicka \"Get Stats\"-förfrågan)';

  @override
  String get repeater_cliHelpSetName => 'Ställer in annonstexterna namn.';

  @override
  String get repeater_cliHelpSetLat =>
      'Ställer in annonskartans latitud. (decimalgrader)';

  @override
  String get repeater_cliHelpSetLon =>
      'Ställer in annonskartans longitud (decimalgrader).';

  @override
  String get repeater_cliHelpSetRadio =>
      'Ställer helt nya radioparametrar och sparar dem i inställningar. Kräver en \"omstart\" för att tillämpa.';

  @override
  String get repeater_cliHelpSetRxDelay =>
      'Ställer (experimentell) basvärde (måste vara > 1 för effekt) för att applicera en liten fördröjning på mottagna paket, baserat på signalstyrka/poäng. Ställ in på 0 för att inaktivera.';

  @override
  String get repeater_cliHelpSetTxDelay =>
      'Ställer in en faktor som multipliceras med tid på luft för en översvämningsläge-paket och med ett slumpmässigt slot-system för att fördröja dess vidarebefordran (för att minska risken för kollisioner).';

  @override
  String get repeater_cliHelpSetDirectTxDelay =>
      'Samma som txdelay, men för att applicera en slumpmässig fördröjning vid vidarebefordran av direktlägespaket.';

  @override
  String get repeater_cliHelpSetBridgeEnabled => 'Aktivera/Inaktivera brygga.';

  @override
  String get repeater_cliHelpSetBridgeDelay =>
      'Ställ in fördröjning innan paket åter sänder.';

  @override
  String get repeater_cliHelpSetBridgeSource =>
      'Välj om bron ska återända mottagna paket eller sända paket.';

  @override
  String get repeater_cliHelpSetBridgeBaud =>
      'Ställ baudgränsen för rs232-bryggarna.';

  @override
  String get repeater_cliHelpSetBridgeSecret =>
      'Ställ bro-hemlighet för espnow-broar.';

  @override
  String get repeater_cliHelpSetAdcMultiplier =>
      'Ställer in anpassad faktor för att justera rapporterad batterispänning (endast stödd på utvalda kort).';

  @override
  String get repeater_cliHelpTempRadio =>
      'Ställer temporära radioparametrar för det angivna antalet minuter, vilket återgår till de ursprungliga radioparametrarna efteråt. (sparar inte i inställningar).';

  @override
  String get repeater_cliHelpSetPerm =>
      'Modifierar ACL. Tar bort matchande post (genom pubkey-prefiks) om \"permissions\" är noll. Lägger till ny post om pubkey-hex är full längd och inte redan finns i ACL. Uppdaterar posten genom matchande pubkey-prefiks. Tillståndsbiten varierar per firmware-roll, men de låga 2 bitarna är: 0 (Gäst), 1 (endast läsa), 2 (läs- och skrivskydd), 3 (administratör).';

  @override
  String get repeater_cliHelpGetBridgeType =>
      'Får brotyperna ingen, rs232, espnow';

  @override
  String get repeater_cliHelpLogStart => 'Starta paketloggning till filsystem.';

  @override
  String get repeater_cliHelpLogStop => 'Stoppar paketloggning till filsystem.';

  @override
  String get repeater_cliHelpLogErase =>
      'Raderar pakets loggar från filsystemet.';

  @override
  String get repeater_cliHelpNeighbors =>
      'Visar en lista över andra repeaternoder som hörts via noll-hop-annonser. Varje rad är id-prefix-hex:tidsstämpel:snr-g撮-4';

  @override
  String get repeater_cliHelpNeighborRemove =>
      'Tar bort det första matchande inlägget (genom pubkey-prefiks (hex)) från grannlistan.';

  @override
  String get repeater_cliHelpRegion =>
      '(Serien endast) Listar alla definierade regioner och aktuella översvämningsbehörigheter.';

  @override
  String get repeater_cliHelpRegionLoad =>
      'MEDDELANDE: detta är ett specialkommando med flera kommandon. Varje efterföljande kommando är ett regionsnamn (indenterat med blanksteg för att indikera en hierarkisk relation, med minst ett blanksteg). Avslutas genom att skicka en tom rad/kommando.';

  @override
  String get repeater_cliHelpRegionGet =>
      'Söker efter region med given namnprefiks (eller \"\" för det globala scopet). Svarar med \"-> regionnamn (föräldernamn) \'F\'\"';

  @override
  String get repeater_cliHelpRegionPut =>
      'Lägger till eller uppdaterar en regionsdefinition med det angivna namnet.';

  @override
  String get repeater_cliHelpRegionRemove =>
      'Tar bort en regionsdefinition med det angivna namnet. (måste matcha exakt och inte ha några barnregioner)';

  @override
  String get repeater_cliHelpRegionAllowf =>
      'Ställer \'Flöde\'-behörighet för det angivna området. (\'\' för det globala/gamla scopet)';

  @override
  String get repeater_cliHelpRegionDenyf =>
      'Tar bort \'F\'lood-behörigheten för det angivna området. (OBS: rekommenderas inte att använda detta i detta skede på den globala/gamla omfattningen!!).';

  @override
  String get repeater_cliHelpRegionHome =>
      'Svarar med den aktuella \'hem\'-regionen. (Notera att detta ännu inte har tillämpats, reserverat för framtida användning).';

  @override
  String get repeater_cliHelpRegionHomeSet => 'Ställer in \'hemregionen\'.';

  @override
  String get repeater_cliHelpRegionSave =>
      'Sparar regionlistan/kartan till lagring.';

  @override
  String get repeater_cliHelpGps =>
      'Visar GPS-status. Om GPS är avstängd svarar den endast med \"av\", annars svarar den med \"på\", status, fix, antal satelliter.';

  @override
  String get repeater_cliHelpGpsOnOff =>
      'Aktiverar/inaktiverar GPS-strömsättningen.';

  @override
  String get repeater_cliHelpGpsSync =>
      'Synkroniserar nätverks tid med GPS-klockan.';

  @override
  String get repeater_cliHelpGpsSetLoc =>
      'Ställer nodens position till GPS-koordinater och sparar inställningar.';

  @override
  String get repeater_cliHelpGpsAdvert =>
      'Ger platsannonskonfigurationen för noden:\n- ingen: inkludera inte plats i annonser\n- dela: dela gps-plats (från SensorManager)\n- inställningar: annonsera platsen som sparats i inställningar';

  @override
  String get repeater_cliHelpGpsAdvertSet =>
      'Ställer in annonsplatskonfiguration.';

  @override
  String get repeater_commandsListTitle => 'Inställningslista';

  @override
  String get repeater_commandsListNote =>
      'OBS: för de olika \"set ...\" -kommandon finns det även ett \"get ...\" -kommando.';

  @override
  String get repeater_general => 'Allmänt';

  @override
  String get repeater_settingsCategory => 'Inställningar';

  @override
  String get repeater_bridge => 'Bro';

  @override
  String get repeater_logging => 'Logga';

  @override
  String get repeater_neighborsRepeaterOnly => 'Grannar (Endast återspelare)';

  @override
  String get repeater_regionManagementRepeaterOnly =>
      'Regionhantering (endast återuppspelare)';

  @override
  String get repeater_regionNote =>
      'Regionkommandon har införts för att hantera regiondefinitioner och behörigheter.';

  @override
  String get repeater_gpsManagement => 'GPS Hantering';

  @override
  String get repeater_gpsNote =>
      'GPS-kommando har introducerats för att hantera platsrelaterade ämnen.';

  @override
  String get telemetry_receivedData => 'Mottagen Telemetridata';

  @override
  String get telemetry_requestTimeout => 'Telemetryförfrågan gick ut.';

  @override
  String telemetry_errorLoading(String error) {
    return 'Fel vid laddning av telemetri: $error';
  }

  @override
  String get telemetry_noData => 'Inga telemetridata tillgängliga.';

  @override
  String telemetry_channelTitle(int channel) {
    return 'Kanal $channel';
  }

  @override
  String get telemetry_batteryLabel => 'Batteri';

  @override
  String get telemetry_voltageLabel => 'Spänning';

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
  String get neighbors_receivedData => 'Mottagna grannars data';

  @override
  String get neighbors_requestTimedOut => 'Grannar begär tidsinställd utskick.';

  @override
  String neighbors_errorLoading(String error) {
    return 'Fel vid inläsning av grannar: $error';
  }

  @override
  String get neighbors_repeatersNeighbors => 'Upprepar grannar';

  @override
  String get neighbors_noData => 'Inga grannuppgifter finns tillgängliga.';

  @override
  String neighbors_unknownContact(String pubkey) {
    return 'Okänd $pubkey';
  }

  @override
  String neighbors_heardAgo(String time) {
    return 'Hördes: $time sedan';
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
  String get channelPath_title => 'Paketväg';

  @override
  String get channelPath_viewMap => 'Visa karta';

  @override
  String get channelPath_otherObservedPaths => 'Övriga observerade stigar';

  @override
  String get channelPath_repeaterHops => 'Återupptagningssteg';

  @override
  String get channelPath_noHopDetails =>
      'Detaljer för denna paket är inte angivna.';

  @override
  String get channelPath_messageDetails => 'Meddelandets detaljer';

  @override
  String get channelPath_senderLabel => 'Avsändare';

  @override
  String get channelPath_timeLabel => 'Tid';

  @override
  String get channelPath_repeatsLabel => 'Upprepa';

  @override
  String channelPath_pathLabel(int index) {
    return 'Sökväg $index';
  }

  @override
  String get channelPath_observedLabel => 'Observerat';

  @override
  String channelPath_observedPathTitle(int index, String hops) {
    return 'Observerad bana $index • $hops';
  }

  @override
  String get channelPath_noLocationData => 'Ingen platsdata';

  @override
  String channelPath_timeWithDate(int day, int month, String time) {
    return '$day/$month kl. $time';
  }

  @override
  String channelPath_timeOnly(String time) {
    return '$time';
  }

  @override
  String get channelPath_unknownPath => 'Okänt';

  @override
  String get channelPath_floodPath => 'Översvämning';

  @override
  String get channelPath_directPath => 'Direkt';

  @override
  String channelPath_observedZeroOf(int total) {
    return '0 av $total hopp';
  }

  @override
  String channelPath_observedSomeOf(int observed, int total) {
    return '$observed av $total hopp';
  }

  @override
  String get channelPath_mapTitle => 'Sökvägskarta';

  @override
  String get channelPath_noRepeaterLocations =>
      'Inga återupprepningsplatser finns tillgängliga för denna väg.';

  @override
  String channelPath_primaryPath(int index) {
    return 'Sökväg $index (Primär)';
  }

  @override
  String get channelPath_pathLabelTitle => 'Sökväg';

  @override
  String get channelPath_observedPathHeader => 'Observerad Sökväg';

  @override
  String channelPath_selectedPathLabel(String label, String prefixes) {
    return '$label • $prefixes';
  }

  @override
  String get channelPath_noHopDetailsAvailable =>
      'Inga hoppdetaljer finns tillgängliga för detta paket.';

  @override
  String get channelPath_unknownRepeater => 'Okänt Upprepare';

  @override
  String get community_title => 'Gemenskap';

  @override
  String get community_create => 'Skapa Gemenskap';

  @override
  String get community_createDesc =>
      'Skapa en ny gemenskap och dela via QR-kod.';

  @override
  String get community_join => 'Gå med';

  @override
  String get community_joinTitle => 'Gå med i gemenskapen';

  @override
  String community_joinConfirmation(String name) {
    return 'Vill du gå med i communityn \"$name\"?';
  }

  @override
  String get community_scanQr => 'Skanna Gemenskapens QR';

  @override
  String get community_scanInstructions =>
      'Rikta kameran mot en QR-kod i communityn';

  @override
  String get community_showQr => 'Visa QR-kod';

  @override
  String get community_publicChannel => 'Föreningens Offentliga';

  @override
  String get community_hashtagChannel => 'Community Hashtag';

  @override
  String get community_name => 'Gemenskapens namn';

  @override
  String get community_enterName => 'Ange communities namn';

  @override
  String community_created(String name) {
    return 'Community \"$name\" har skapats';
  }

  @override
  String community_joined(String name) {
    return 'Medlem i communityn \"$name\"';
  }

  @override
  String get community_qrTitle => 'Dela Gemenskap';

  @override
  String community_qrInstructions(String name) {
    return 'Skanna denna QR-kod för att gå med i \"$name\"';
  }

  @override
  String get community_hashtagPrivacyHint =>
      'Community-hashtagkanaler kan endast nås av medlemmar i communityn';

  @override
  String get community_invalidQrCode => 'Ogiltig community QR-kod';

  @override
  String get community_alreadyMember => 'Är redan medlem';

  @override
  String community_alreadyMemberMessage(String name) {
    return 'Du är redan medlem av \"$name\".';
  }

  @override
  String get community_addPublicChannel =>
      'Lägg till Gemenskapskanal (Offentlig)';

  @override
  String get community_addPublicChannelHint =>
      'Lägg automatiskt till den offentliga kanalen för denna community';

  @override
  String get community_noCommunities => 'Inga gemenskaper har anslutats ännu';

  @override
  String get community_scanOrCreate =>
      'Skanna en QR-kod eller skapa en community för att komma igång';

  @override
  String get community_manageCommunities => 'Hantera Gemenskaper';

  @override
  String get community_delete => 'Lämna Gemenskap';

  @override
  String community_deleteConfirm(String name) {
    return 'Lämna \"$name\"?';
  }

  @override
  String community_deleteChannelsWarning(int count) {
    return 'Detta kommer också att radera $count kanal/kanaler och deras meddelanden.';
  }

  @override
  String community_deleted(String name) {
    return 'Lämnade community \"$name\"';
  }

  @override
  String get community_regenerateSecret => 'Regenerera hemlig kod';

  @override
  String community_regenerateSecretConfirm(String name) {
    return 'Regenerera den hemliga nyckeln för \"$name\"? Alla medlemmar måste scanna den nya QR-koden för att fortsätta kommunicera.';
  }

  @override
  String get community_regenerate => 'Regenerera';

  @override
  String community_secretRegenerated(String name) {
    return 'Lösenord återskapad för \"$name\"';
  }

  @override
  String get community_updateSecret => 'Uppdatera hemlighet';

  @override
  String community_secretUpdated(String name) {
    return 'Hemlighet uppdaterad för \"$name\"';
  }

  @override
  String community_scanToUpdateSecret(String name) {
    return 'Skanna den nya QR-koden för att uppdatera hemligheten för \"$name\"';
  }

  @override
  String get community_addHashtagChannel => 'Lägg till Gemenskapens Hashtag';

  @override
  String get community_addHashtagChannelDesc =>
      'Lägg till en hashtag-kanal för denna community';

  @override
  String get community_selectCommunity => 'Välj Gemenskap';

  @override
  String get community_regularHashtag => 'Vanlig Hash Tag';

  @override
  String get community_regularHashtagDesc =>
      'Offentlig hashtag (alla kan gå med)';

  @override
  String get community_communityHashtag => 'Community Hashtag';

  @override
  String get community_communityHashtagDesc => 'Endast för medlemmar';

  @override
  String community_forCommunity(String name) {
    return 'För $name';
  }

  @override
  String get listFilter_tooltip => 'Filtrera och sortera';

  @override
  String get listFilter_sortBy => 'Sortera efter';

  @override
  String get listFilter_latestMessages => 'Senaste meddelanden';

  @override
  String get listFilter_heardRecently => 'Hörts nyligen';

  @override
  String get listFilter_az => 'A-Z';

  @override
  String get listFilter_filters => 'Filteralternativ';

  @override
  String get listFilter_all => 'Alla';

  @override
  String get listFilter_users => 'Användare';

  @override
  String get listFilter_repeaters => 'Upprepare';

  @override
  String get listFilter_roomServers => 'Rumservrar';

  @override
  String get listFilter_unreadOnly => 'Endast oinlästa';

  @override
  String get listFilter_newGroup => 'Ny grupp';

  @override
  String get pathTrace_you => 'Du';

  @override
  String get pathTrace_failed => 'Sökvägsföljning misslyckades.';

  @override
  String get pathTrace_notAvailable => 'Path trace ej tillgänglig.';

  @override
  String get pathTrace_refreshTooltip => 'Uppdatera Path Trace';

  @override
  String get pathTrace_someHopsNoLocation =>
      'En eller flera av humlen saknar en plats!';

  @override
  String get pathTrace_clearTooltip => 'Rensa väg';

  @override
  String get losSelectStartEnd => 'Välj start- och slutnoder för LOS.';

  @override
  String losRunFailed(String error) {
    return 'Synlinjekontroll misslyckades: $error';
  }

  @override
  String get losClearAllPoints => 'Rensa alla punkter';

  @override
  String get losRunToViewElevationProfile => 'Kör LOS för att se höjdprofil';

  @override
  String get losMenuTitle => 'LOS-menyn';

  @override
  String get losMenuSubtitle =>
      'Tryck på noder eller tryck länge på kartan för anpassade punkter';

  @override
  String get losShowDisplayNodes => 'Visa displaynoder';

  @override
  String get losCustomPoints => 'Anpassade poäng';

  @override
  String losCustomPointLabel(int index) {
    return 'Anpassad $index';
  }

  @override
  String get losPointA => 'Punkt A';

  @override
  String get losPointB => 'Punkt B';

  @override
  String losAntennaA(String value, String unit) {
    return 'Antenn A: $value $unit';
  }

  @override
  String losAntennaB(String value, String unit) {
    return 'Antenn B: $value $unit';
  }

  @override
  String get losRun => 'Kör LOS';

  @override
  String get losNoElevationData => 'Inga höjddata';

  @override
  String losProfileClear(
    String distance,
    String distanceUnit,
    String clearance,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, rensa LOS, min clearance $clearance $heightUnit';
  }

  @override
  String losProfileBlocked(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, blockerad av $obstruction $heightUnit';
  }

  @override
  String get losStatusChecking => 'LOS: kollar...';

  @override
  String get losStatusNoData => 'LOS: inga data';

  @override
  String losStatusSummary(int clear, int total, int blocked, int unknown) {
    return 'LOS: $clear/$total rensa, $blocked blockerad, $unknown okänd';
  }

  @override
  String get losErrorElevationUnavailable =>
      'Höjddata är inte tillgänglig för ett eller flera prover.';

  @override
  String get losErrorInvalidInput =>
      'Ogiltiga poäng/höjddata för LOS-beräkning.';

  @override
  String get losRenameCustomPoint => 'Byt namn på anpassad punkt';

  @override
  String get losPointName => 'Punktnamn';

  @override
  String get losShowPanelTooltip => 'Visa LOS-panelen';

  @override
  String get losHidePanelTooltip => 'Dölj LOS-panelen';

  @override
  String get losElevationAttribution => 'Höjddata: Open-Meteo (CC BY 4.0)';

  @override
  String get contacts_pathTrace => 'Path Trace';

  @override
  String get contacts_ping => 'Ping';

  @override
  String get contacts_repeaterPathTrace => 'Vägspårning till repeater';

  @override
  String get contacts_repeaterPing => 'Ping-repeater';

  @override
  String get contacts_roomPathTrace => 'Vägspårning till rumserver';

  @override
  String get contacts_roomPing => 'Ping rumsserver';

  @override
  String get contacts_chatTraceRoute => 'Spåra rutt';

  @override
  String contacts_pathTraceTo(String name) {
    return 'Spåra rutt till $name';
  }

  @override
  String get contacts_clipboardEmpty => 'Urklipp är tomt.';

  @override
  String get contacts_invalidAdvertFormat => 'Ogiltiga kontaktuppgifter';

  @override
  String get contacts_contactImported => 'Kontakt har importerats.';

  @override
  String get contacts_contactImportFailed => 'Kontakt kunde inte importeras.';

  @override
  String get contacts_zeroHopAdvert => 'Reklam med nollhopp';

  @override
  String get contacts_floodAdvert => 'Översvämningsannons';

  @override
  String get contacts_copyAdvertToClipboard => 'Kopiera annons till urklipp';

  @override
  String get contacts_addContactFromClipboard =>
      'Lägg till kontakt från urklipp';

  @override
  String get contacts_ShareContact => 'Kopiera kontakt till Urklipp';

  @override
  String get contacts_ShareContactZeroHop => 'Dela kontakt via annons';

  @override
  String get contacts_zeroHopContactAdvertSent => 'Skickat kontakt via annons.';

  @override
  String get contacts_zeroHopContactAdvertFailed =>
      'Misslyckades med att skicka kontakt.';

  @override
  String get contacts_contactAdvertCopied => 'Annons kopierad till Urklipp.';

  @override
  String get contacts_contactAdvertCopyFailed =>
      'Kopiering av annons till Urklipp misslyckades.';

  @override
  String get notification_activityTitle => 'MeshCore Aktivitet';

  @override
  String notification_messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'meddelanden',
      one: 'meddelande',
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
      other: 'kanalmeddelanden',
      one: 'kanalmeddelande',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nya noder',
      one: 'ny nod',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newTypeDiscovered(String contactType) {
    return 'Ny $contactType upptäckt';
  }

  @override
  String get notification_receivedNewMessage => 'Nytt meddelande mottaget';

  @override
  String get settings_gpxExportRepeaters =>
      'Exportera repeater / rumsservrar till GPX';

  @override
  String get settings_gpxExportRepeatersSubtitle =>
      'Exporterar repeater / roomserver med plats till GPX-fil.';

  @override
  String get settings_gpxExportContacts => 'Exportera följeslagare till GPX';

  @override
  String get settings_gpxExportContactsSubtitle =>
      'Exporterar följeslagare med en plats till GPX-fil.';

  @override
  String get settings_gpxExportAll => 'Exportera alla kontakter till GPX';

  @override
  String get settings_gpxExportAllSubtitle =>
      'Exporterar alla kontakter med en plats till GPX-fil.';

  @override
  String get settings_gpxExportSuccess => 'Har exporterat GPX-fil med framgång';

  @override
  String get settings_gpxExportNoContacts => 'Inga kontakter att exportera.';

  @override
  String get settings_gpxExportNotAvailable =>
      'Stöds inte på din enhet/operativsystem';

  @override
  String get settings_gpxExportError =>
      'Det uppstod ett fel när data exporterades.';

  @override
  String get settings_gpxExportRepeatersRoom =>
      'Repeater- och rumsserverplatser';

  @override
  String get settings_gpxExportChat => 'Medhjälparplatser';

  @override
  String get settings_gpxExportAllContacts => 'Alla kontakters platser';

  @override
  String get settings_gpxExportShareText =>
      'Kartdata exporterad från Gulf Coast Mesh App';

  @override
  String get settings_gpxExportShareSubject =>
      'Gulf Coast Mesh App export av GPX-kartdata';

  @override
  String get snrIndicator_nearByRepeaters => 'Närliggande uppreparstationer';

  @override
  String get snrIndicator_lastSeen => 'Senast sedd';

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
  String get repeater_regenerateIdentityKey => 'Generera Identitetsknyckel';

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
  String get appSettings_nodeBlocking => 'Blockera noder';

  @override
  String get appSettings_nodeBlockingSubtitle =>
      'Dölj valda noder på kartan, i kontakter och chattar och tysta deras aviseringar. Endast i appen: inget tas bort från din radio.';

  @override
  String get appSettings_blockedNodes => 'Blockerade noder';

  @override
  String appSettings_blockedNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blockerade noder',
      one: '1 blockerad nod',
      zero: 'Inga blockerade ännu',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_title => 'Blockerade noder';

  @override
  String get blockedNodes_howItWorks => 'Så fungerar blockering';

  @override
  String get blockedNodes_infoHidden =>
      'Dolda på kartan, i kontakter och chattar';

  @override
  String get blockedNodes_infoMuted =>
      'Inga aviseringar om nya noder och inga meddelandeaviseringar från dem';

  @override
  String get blockedNodes_infoKept =>
      'Inget raderas. De finns kvar på din companion-radio och deras meddelanden sparas';

  @override
  String get blockedNodes_infoRelay =>
      'Blockerade repeaters kan fortfarande vidarebefordra dina meddelanden över nätet';

  @override
  String get blockedNodes_infoChannels =>
      'Deras meddelanden i kanaler visas fortfarande';

  @override
  String get blockedNodes_emptyTitle => 'Inga blockerade noder';

  @override
  String get blockedNodes_emptyHint =>
      'Tryck länge på en nod i Kontakter eller på Kartan och välj Blockera nod.';

  @override
  String get blockedNodes_unblock => 'Avblockera';

  @override
  String get blockedNodes_unblockAll => 'Avblockera alla';

  @override
  String blockedNodes_unblockAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Avblockera alla $count noder? De visas igen på kartan och i kontakterna.',
      one: 'Avblockera 1 nod? Den visas igen på kartan och i kontakterna.',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_unknownNode => 'Okänd nod';

  @override
  String blockedNodes_blockedOn(String date) {
    return 'Blockerad $date';
  }

  @override
  String get blockedNodes_blockAction => 'Blockera nod';

  @override
  String blockedNodes_blockConfirmTitle(String name) {
    return 'Blockera $name?';
  }

  @override
  String get blockedNodes_blockConfirmBody =>
      'Noden döljs på kartan, i kontakter och chattar, och du får inga aviseringar eller meddelandeaviseringar från den. Inget tas bort från din radio. Du kan avblockera den när som helst under Appinställningar > Experimentellt > Blockerade noder.';

  @override
  String get blockedNodes_blockConfirmButton => 'Blockera';

  @override
  String blockedNodes_blocked(String name) {
    return '$name blockerades';
  }

  @override
  String blockedNodes_unblocked(String name) {
    return '$name avblockerades';
  }

  @override
  String get blockedNodes_undo => 'Ångra';
}
