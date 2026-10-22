// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

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
  String get nav_contacts => 'Kontakty';

  @override
  String get nav_channels => 'Kanály';

  @override
  String get nav_map => 'Mapa';

  @override
  String get nav_chats => 'Chaty';

  @override
  String get nav_nodes => 'Uzly';

  @override
  String get nav_settings => 'Nastavenia';

  @override
  String get common_cancel => 'Zrušiť';

  @override
  String get common_ok => 'OK\nDobre';

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
  String get common_connect => 'Pripojiť';

  @override
  String get common_unknownDevice => 'Neznáme zariadenie';

  @override
  String get common_save => 'Uložiť';

  @override
  String get common_delete => 'Odstrániť';

  @override
  String get common_close => 'Zavrieť';

  @override
  String get common_edit => 'Upraviť';

  @override
  String get common_add => 'Pridať';

  @override
  String get common_settings => 'Nastavenia';

  @override
  String get common_disconnect => 'Odpojiť';

  @override
  String get common_connected => 'Pripojené';

  @override
  String get common_disconnected => 'Odpojené';

  @override
  String get common_reconnecting => 'Reconnecting';

  @override
  String get common_create => 'Vytvoriť';

  @override
  String get common_continue => 'Pokračovať';

  @override
  String get common_share => 'Zdieľať';

  @override
  String get common_copy => 'Kopírovať';

  @override
  String get common_retry => 'Pokusť znova';

  @override
  String get common_hide => 'Skryť';

  @override
  String get common_remove => 'Odstrániť';

  @override
  String get common_enable => 'Povolit';

  @override
  String get common_disable => 'Zakázať';

  @override
  String get common_reboot => 'Restartovať';

  @override
  String get common_loading => 'Načítavanie...';

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
  String get scanner_scanning => 'Skrívania zariadení...';

  @override
  String get scanner_connecting => 'Pripojujem sa...';

  @override
  String get scanner_disconnecting => 'Odpojuje sa...';

  @override
  String get scanner_notConnected => 'Nezriadené';

  @override
  String scanner_connectedTo(String deviceName) {
    return 'Pripojené k $deviceName';
  }

  @override
  String get scanner_searchingDevices => 'Hľadám zariadenia MeshCore...';

  @override
  String get scanner_tapToScan =>
      'Stlač skenovanie na nájdenie zariadení MeshCore.';

  @override
  String scanner_connectionFailed(String error) {
    return 'Pripojenie zlyhalo: $error';
  }

  @override
  String get scanner_backgroundBleMayDrop =>
      'Background BLE may drop without notification permission.';

  @override
  String get scanner_stop => 'Zastavte';

  @override
  String get scanner_scan => 'Skončiť';

  @override
  String get scanner_bluetoothOff => 'Bluetooth je vypnutý';

  @override
  String get scanner_bluetoothOffMessage =>
      'Prosím, zapnite Bluetooth, aby ste mohli skenovať pre zariadenia.';

  @override
  String get scanner_enableBluetooth => 'Povolte Bluetooth';

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
  String get device_quickSwitch => 'Rýchle prepínač';

  @override
  String get device_meshcore => 'MeshCore';

  @override
  String get settings_title => 'Nastavenia';

  @override
  String get settings_deviceInfo => 'Informácie o zariadení';

  @override
  String get settings_appSettings => 'Nastavenia aplikácie';

  @override
  String get settings_appSettingsSubtitle =>
      'Upozornenia, správy a nastavenia mapy';

  @override
  String get settings_nodeSettings => 'Nastavenia uzla';

  @override
  String get settings_nodeName => 'Názov uzla';

  @override
  String get settings_nodeNameNotSet => 'Nezriadené';

  @override
  String get settings_nodeNameHint => 'Zadajte názov uzla';

  @override
  String get settings_nodeNameUpdated => 'Meno aktualizované';

  @override
  String get settings_radioSettings => 'Nastavenia rádia';

  @override
  String get settings_radioSettingsSubtitle =>
      'Frekvencia, výkon, rozptylovací faktor';

  @override
  String get settings_radioSettingsUpdated => 'Nastavenia rádia aktualizované';

  @override
  String get settings_location => 'Lokalita';

  @override
  String get settings_locationSubtitle => 'GPS súradnice';

  @override
  String get settings_locationUpdated => 'Lokalita aktualizovaná';

  @override
  String get settings_locationBothRequired =>
      'Zadajte obidve zložky zemyslenia a zložky meracieho kruhu.';

  @override
  String get settings_locationInvalid => 'Neplatná šírka alebo dĺžka.';

  @override
  String get settings_locationGPSEnable => 'Aktivovať GPS';

  @override
  String get settings_locationGPSEnableSubtitle =>
      'Povolí automatické aktualizovanie polohy pomocou GPS.';

  @override
  String get settings_locationIntervalSec => 'Interval pre GPS (Sekundy)';

  @override
  String get settings_usePhoneGps => 'Use phone GPS';

  @override
  String get settings_locationIntervalInvalid =>
      'Interval musí byť aspoň 60 sekúnd a menej ako 86400 sekúnd.';

  @override
  String get settings_latitude => 'Súradnica';

  @override
  String get settings_longitude => 'Dĺžka';

  @override
  String get settings_privacyMode => 'Režim ochrany súkromia';

  @override
  String get settings_privacyModeSubtitle => 'Skryť meno/poloha v reklamách';

  @override
  String get settings_privacyModeToggle =>
      'Prepínač súkromného režimu skryje vaše meno a polohu v reklamách.';

  @override
  String get settings_privacyModeEnabled => 'Ochranný režim je povolený.';

  @override
  String get settings_privacyModeDisabled => 'Ochranný režim je vypnutý';

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
  String get settings_actions => 'Možné akcie';

  @override
  String get settings_sendAdvertisement => 'Odoslať reklamu';

  @override
  String get settings_sendAdvertisementSubtitle => 'Momentálne priezornejšie.';

  @override
  String get settings_advertisementSent => 'Reklama odeslaná';

  @override
  String get settings_syncTime => 'Čas synchronizácie';

  @override
  String get settings_syncTimeSubtitle =>
      'Nastaviť hodiny zariadenia na čas telefónu';

  @override
  String get settings_timeSynchronized => 'Čas synchronizovaný';

  @override
  String get settings_refreshContacts => 'Načítať Kontakty';

  @override
  String get settings_refreshContactsSubtitle =>
      'Načítať zoznam kontaktov z zariadenia';

  @override
  String get settings_rebootDevice => 'Restartovať zariadenie';

  @override
  String get settings_rebootDeviceSubtitle =>
      'Restartujte zariadenie MeshCore.';

  @override
  String get settings_rebootDeviceConfirm =>
      'Ste si istý, že chcete zariadenie reštartovať? Budete odpojení.';

  @override
  String get settings_debug => 'Ladenie';

  @override
  String get settings_bleDebugLog => 'Log BLE Debug';

  @override
  String get settings_bleDebugLogSubtitle =>
      'Príkazy BLE, odpovede a surové dáta';

  @override
  String get settings_appDebugLog => 'Záznam ladenia aplikácie';

  @override
  String get settings_appDebugLogSubtitle => 'Správy z ladenia aplikácie';

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
  String get settings_about => 'O nás';

  @override
  String settings_aboutVersion(String version) {
    return 'Gulf Coast Mesh App v$version';
  }

  @override
  String get settings_aboutLegalese => 'Gulf Coast Mesh App 2024';

  @override
  String get settings_aboutDescription =>
      'Otvorený zdrojový Flutter klient pre MeshCore LoRa sieťové zariadenia.';

  @override
  String get settings_aboutOpenMeteoAttribution =>
      'Údaje o nadmorskej výške LOS: Open-Meteo (CC BY 4.0)';

  @override
  String get settings_infoName => 'Meno';

  @override
  String get settings_infoId => 'ID';

  @override
  String get settings_infoStatus => 'Status';

  @override
  String get settings_infoBattery => 'Batéria';

  @override
  String get settings_infoPublicKey => 'Verejný kľúč';

  @override
  String get settings_infoContactsCount => 'Počet kontaktov';

  @override
  String get settings_infoChannelCount => 'Počet kanálov';

  @override
  String get settings_presets => 'Prednastavenia';

  @override
  String get settings_frequency => 'Frekvencia (MHz)';

  @override
  String get settings_frequencyHelper => '300,0 – 2500,0';

  @override
  String get settings_frequencyInvalid => 'Neplatná frekvencia (300-2500 MHz)';

  @override
  String get settings_bandwidth => 'Šírka pásma';

  @override
  String get settings_spreadingFactor => 'Rozptýľovací faktor';

  @override
  String get settings_codingRate => 'Cenový kurz pre programovanie';

  @override
  String get settings_txPower => 'TX Výkon (dBm)';

  @override
  String get settings_txPowerHelper => '0 - 22';

  @override
  String get settings_txPowerInvalid => 'Neplatná hodnota výkonu TX (0-22 dBm)';

  @override
  String get settings_clientRepeat => 'Opätovné použitie bez elektrickej siete';

  @override
  String get settings_clientRepeatSubtitle =>
      'Umožnite, aby toto zariadenie opakovávalo siete pre ostatných.';

  @override
  String get settings_clientRepeatFreqWarning =>
      'Použitie off-grid systému vyžaduje frekvencie 433, 869 alebo 918 MHz.';

  @override
  String settings_error(String message) {
    return 'Chyba: $message';
  }

  @override
  String get appSettings_title => 'Nastavenia aplikácie';

  @override
  String get appSettings_appearance => 'Vzhľad';

  @override
  String get appSettings_theme => 'Téma';

  @override
  String get appSettings_themeSystem => 'Predvolený systém';

  @override
  String get appSettings_themeLight => 'Svetlo';

  @override
  String get appSettings_themeDark => 'Tmavé';

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
  String get appSettings_language => 'Jazyk';

  @override
  String get appSettings_languageSystem => 'Predvolený systém';

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
  String get appSettings_languageRu => 'Ruština';

  @override
  String get appSettings_languageUk => 'Ukrajinská';

  @override
  String get appSettings_enableMessageTracing => 'Povoliť sledovanie správ';

  @override
  String get appSettings_enableMessageTracingSubtitle =>
      'Zobraziť podrobné metadáta o smerovaní a časovaní správ';

  @override
  String get appSettings_notifications => 'Upozornenia';

  @override
  String get appSettings_enableNotifications => 'Povolte Notifikácie';

  @override
  String get appSettings_enableNotificationsSubtitle =>
      'Zísť o upozornenia na správy a inzeráty';

  @override
  String get appSettings_notificationPermissionDenied =>
      'Odmietená povolenie notifikácií';

  @override
  String get appSettings_notificationsEnabled => 'Upozornenia povolené';

  @override
  String get appSettings_notificationsDisabled => 'Upozornenia sú vypnuté';

  @override
  String get appSettings_messageNotifications => 'Správy od upozornení';

  @override
  String get appSettings_messageNotificationsSubtitle =>
      'Zobraziť upozornenie pri prijímaní nových správ';

  @override
  String get appSettings_channelMessageNotifications => 'Notifikácie z kanálov';

  @override
  String get appSettings_channelMessageNotificationsSubtitle =>
      'Zobraziť upozornenie pri prijímaní správ z kanálu';

  @override
  String get appSettings_advertisementNotifications => 'Upozornenia na reklamy';

  @override
  String get appSettings_advertisementNotificationsSubtitle =>
      'Zobraziť upozornenie, keď sa objavia nové uzly.';

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
  String get appSettings_messaging => 'Správy';

  @override
  String get appSettings_clearPathOnMaxRetry => 'Vyčisti cestu na Max Retry';

  @override
  String get appSettings_clearPathOnMaxRetrySubtitle =>
      'Resetovať kontaktný priebeh po 5 neúspešných pokusoch o doručenie';

  @override
  String get appSettings_pathsWillBeCleared =>
      'Cesty budú vymazané po 5 neúspešných pokusoch.';

  @override
  String get appSettings_pathsWillNotBeCleared =>
      'Cesty sa automaticky nevymazávajú.';

  @override
  String get appSettings_autoRouteRotation => 'Automatické prechodové trasy';

  @override
  String get appSettings_autoRouteRotationSubtitle =>
      'Striedajte sa medzi najlepšími trasami a režimom povodňovej analýzy.';

  @override
  String get appSettings_autoRouteRotationEnabled =>
      'Automatické otáčanie trasy povolené';

  @override
  String get appSettings_autoRouteRotationDisabled =>
      'Automatické prekladanie trás pozastavené';

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
  String get appSettings_battery => 'Batéria';

  @override
  String get appSettings_batteryChemistry => 'Chemická zloženie batérie';

  @override
  String appSettings_batteryChemistryPerDevice(String deviceName) {
    return 'Nastavenie pre $deviceName';
  }

  @override
  String get appSettings_batteryChemistryConnectFirst =>
      'Pripojte sa k zariadeniu na výber';

  @override
  String get appSettings_batteryNmc => '18650 NMC (3,0-4,2V)';

  @override
  String get appSettings_batteryLifepo4 => 'LiFePO4 (2,6–3,65V)';

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
  String get appSettings_mapDisplay => 'Zobrazenie mapy';

  @override
  String get appSettings_showRepeaters => 'Zobraziť opakovače';

  @override
  String get appSettings_showRepeatersSubtitle =>
      'Zobraziť opakujúce sa uzly na mape';

  @override
  String get appSettings_showChatNodes => 'Zobraziť uzly chatových správ';

  @override
  String get appSettings_showChatNodesSubtitle =>
      'Zobraziť chatové uzly na mape';

  @override
  String get appSettings_showOtherNodes => 'Zobraziť ďalšie uzly';

  @override
  String get appSettings_showOtherNodesSubtitle =>
      'Zobraziť ostatné typy uzlov na mape';

  @override
  String get appSettings_timeFilter => 'Filtrovacie Časové Obdoby';

  @override
  String get appSettings_timeFilterShowAll => 'Zobraziť všetky uzly';

  @override
  String appSettings_timeFilterShowLast(int hours) {
    return 'Zobraziť uzly z posledných $hours hodín';
  }

  @override
  String get appSettings_mapTimeFilter => 'Filtračný čas mapy';

  @override
  String get appSettings_showNodesDiscoveredWithin =>
      'Zobraziť uzly objavené v:';

  @override
  String get appSettings_allTime => 'Všetky časy';

  @override
  String get appSettings_lastHour => 'Posledná hodina';

  @override
  String get appSettings_last6Hours => 'Posledné 6 hodín';

  @override
  String get appSettings_last24Hours => 'Posledných 24 hodín';

  @override
  String get appSettings_lastWeek => 'Minul týždeň';

  @override
  String get appSettings_offlineMapCache => 'Offline Mapa Pamäť';

  @override
  String get appSettings_unitsTitle => 'Jednotky';

  @override
  String get appSettings_unitsMetric => 'Metrické (m / km)';

  @override
  String get appSettings_unitsImperial => 'Imperiálne (ft / mi)';

  @override
  String get appSettings_noAreaSelected => 'Neoznačila sa žiadna oblasť';

  @override
  String appSettings_areaSelectedZoom(int minZoom, int maxZoom) {
    return 'Vyberená oblasť (zoom $minZoom-$maxZoom)';
  }

  @override
  String get appSettings_debugCard => 'Ladenie';

  @override
  String get appSettings_appDebugLogging => 'Záznamy ladenia aplikácie';

  @override
  String get appSettings_appDebugLoggingSubtitle =>
      'Logovací správy aplikácie pre ladenie';

  @override
  String get appSettings_appDebugLoggingEnabled =>
      'Aplikácia povolila ladenie protokolmi';

  @override
  String get appSettings_appDebugLoggingDisabled =>
      'Zabudované ladenie aplikácie je vypnuté.';

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
  String get contacts_title => 'Kontakty';

  @override
  String get contacts_noContacts => 'Zatiaľ žiadne kontakty.';

  @override
  String get contacts_contactsWillAppear =>
      'Kontakty sa zobrazia, keď zariadenia spúšťajú reklamu.';

  @override
  String get contacts_searchContacts => 'Vyhľadávajte kontakty...';

  @override
  String get contacts_noUnreadContacts => 'Žiadne neprečítané kontakty';

  @override
  String get contacts_noContactsFound =>
      'Neboli nájdených žiadnych kontaktov ani skupiny.';

  @override
  String get contacts_deleteContact => 'Odstrániť kontakt';

  @override
  String contacts_removeConfirm(String contactName) {
    return 'Odstrániť $contactName z kontaktov?';
  }

  @override
  String get contacts_manageRepeater => 'Spravovať opakované zoznamy';

  @override
  String get contacts_manageRoom => 'Spravovať server miestnosti';

  @override
  String get contacts_roomLogin => 'Prihlásenie do miestnosti';

  @override
  String get contacts_openChat => 'Otvorené Chat';

  @override
  String get contacts_editGroup => 'Upraviť skupinu';

  @override
  String get contacts_deleteGroup => 'Vymažť skupinu';

  @override
  String contacts_deleteGroupConfirm(String groupName) {
    return 'Odstrániť \"$groupName\"?';
  }

  @override
  String get contacts_newGroup => 'Nová skupina';

  @override
  String get contacts_groupName => 'Názov skupiny';

  @override
  String get contacts_groupNameRequired => 'Skupina musí mať názov.';

  @override
  String contacts_groupAlreadyExists(String name) {
    return 'Skupina \"$name\" už existuje';
  }

  @override
  String get contacts_filterContacts => 'Filtrovať kontakty...';

  @override
  String get contacts_noContactsMatchFilter =>
      'Žiadne kontakty neodídu vášmu filtru.';

  @override
  String get contacts_noMembers => 'Žiadni členovia';

  @override
  String get contacts_lastSeenNow => 'Posledné zreteľné zobrazenie teraz';

  @override
  String contacts_lastSeenMinsAgo(int minutes) {
    return 'Posledné zobrazenie $minutes min. dozadu';
  }

  @override
  String get contacts_lastSeenHourAgo =>
      'Zobral/Zabral poslednýkrát pred hodinou.';

  @override
  String contacts_lastSeenHoursAgo(int hours) {
    return 'Posledné zobrazenie $hours hodín dozadu';
  }

  @override
  String get contacts_lastSeenDayAgo =>
      'Zobral/Zabral posledný raz pred 1 dňom.';

  @override
  String contacts_lastSeenDaysAgo(int days) {
    return 'Posledné zobrazenie $days dní dozadu';
  }

  @override
  String get channels_title => 'Kanály';

  @override
  String get channels_noChannelsConfigured => 'Neobsiahnuté žiadne kanály';

  @override
  String get channels_addPublicChannel => 'Pridať verejný kanál';

  @override
  String get channels_searchChannels => 'Vyhľadávajte kanály...';

  @override
  String get channels_noChannelsFound => 'Neobsiahlo sa žiadnych kanálov.';

  @override
  String get channels_channelSlotsFull =>
      'All device channel slots are in use. Delete a channel before adding another.';

  @override
  String channels_channelAddFailed(String error) {
    return 'Could not add channel: $error';
  }

  @override
  String channels_channelIndex(int index) {
    return 'Kanál $index';
  }

  @override
  String get channels_hashtagChannel => 'Kanál s hashtagom';

  @override
  String get channels_public => 'Veľké verejné';

  @override
  String get channels_private => 'Osobné';

  @override
  String get channels_publicChannel => 'Veľké verejne kanály';

  @override
  String get channels_privateChannel => 'Osobné kanál';

  @override
  String get channels_editChannel => 'Upraviť kanál';

  @override
  String get channels_deleteChannel => 'Odstrániť kanál';

  @override
  String channels_deleteChannelConfirm(String name) {
    return 'Odstrániť \"$name\"? To sa nedá zrušiť.';
  }

  @override
  String get channels_deleteChannelRequiresConnection =>
      'Connect to a device to delete a channel';

  @override
  String channels_channelDeleted(String name) {
    return 'Kanál \"$name\" bol odstránený';
  }

  @override
  String get channels_addChannel => 'Pridať kanál';

  @override
  String get channels_channelIndexLabel => 'Index kanála';

  @override
  String get channels_channelName => 'Názov kanálu';

  @override
  String get channels_usePublicChannel => 'Použite verejný kanál';

  @override
  String get channels_standardPublicPsk => 'Štandardný verejný PSK';

  @override
  String get channels_pskHex => 'PSK (Šifrovacia kľúčik)';

  @override
  String get channels_generateRandomPsk => 'Generovať náhodný PSK';

  @override
  String get channels_enterChannelName => 'Prosím, zadajte názov kanála.';

  @override
  String get channels_pskMustBe32Hex =>
      'PSK musí mať 32 hexadecimálových znakov.';

  @override
  String channels_channelAdded(String name) {
    return 'Kanál \"$name\" pridaný';
  }

  @override
  String channels_editChannelTitle(int index) {
    return 'Upraviť kanál $index';
  }

  @override
  String get channels_smazCompression => 'Odstránenie kompresie SMAZ';

  @override
  String channels_channelUpdated(String name) {
    return 'Kanál \"$name\" bol aktualizovaný';
  }

  @override
  String get channels_publicChannelAdded => 'Veľký kanál pridaný';

  @override
  String get channels_sortBy => 'Triediť podľa';

  @override
  String get channels_sortManual => 'Ručne';

  @override
  String get channels_sortAZ => 'A-Z';

  @override
  String get channels_sortLatestMessages => 'Posledné správy';

  @override
  String get channels_sortUnread => 'Nezriadené';

  @override
  String get channels_createPrivateChannel => 'Vytvorte súkromný kanál';

  @override
  String get channels_createPrivateChannelDesc =>
      'Zabezpečené pomocou tajného kľúča.';

  @override
  String get channels_joinPrivateChannel => 'Pripojiť sa k súkromnému kanálu';

  @override
  String get channels_joinPrivateChannelDesc => 'Ručne zadajte tajný kľúč.';

  @override
  String get channels_joinPublicChannel => 'Pripojte sa k verejnému kanálu';

  @override
  String get channels_joinPublicChannelDesc =>
      'Któvek sátó na tutó kanalizovát.';

  @override
  String get channels_joinHashtagChannel => 'Pripojte sa k Hashtag Kanálu';

  @override
  String get channels_joinHashtagChannelDesc =>
      'Ktoekolikoľvek sa môže pridať do hashtag kanálov.';

  @override
  String get channels_scanQrCode => 'Skenujte QR kód';

  @override
  String get channels_scanQrCodeDesc =>
      'Import a channel invite with name, key, and optional region.';

  @override
  String get channels_scanQrCodeComingSoon => 'Čoskoro';

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
  String get channels_enterHashtag => 'Zadajte hashtag';

  @override
  String get channels_hashtagHint => 'napr. #tím';

  @override
  String get chat_noMessages => 'Zatiaľ žiadne správy.';

  @override
  String get chat_sendMessageToStart => 'Pošlite správu na začiatok';

  @override
  String get chat_originalMessageNotFound => 'Neznámy pôvodný odkaz.';

  @override
  String chat_replyingTo(String name) {
    return 'Odpovedám $name';
  }

  @override
  String chat_replyTo(String name) {
    return 'Odpovedať $name';
  }

  @override
  String get chat_location => 'Lokalita';

  @override
  String chat_sendMessageTo(String contactName) {
    return 'Pošli správu $contactName';
  }

  @override
  String get chat_typeMessage => 'Napište správu...';

  @override
  String chat_messageTooLong(int maxBytes) {
    return 'Správa je príliš dlhá (max $maxBytes bytov).';
  }

  @override
  String get chat_messageCopied => 'Správa skopírovaná';

  @override
  String get chat_messageDeleted => 'Posolstvo odstránené';

  @override
  String get chat_retryingMessage => 'Pokus o obnovenie';

  @override
  String chat_retryCount(int current, int max) {
    return 'Skúsiť $current/$max';
  }

  @override
  String get chat_sendGif => 'Odoslať GIF';

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
  String get chat_reply => 'Odpovedať';

  @override
  String get chat_addReaction => 'Pridať Reakciu';

  @override
  String get chat_editMessage => 'Edit message';

  @override
  String get chat_editedLabel => '(edited)';

  @override
  String get chat_messageEdited => 'Message edited';

  @override
  String get chat_me => 'Mne';

  @override
  String get emojiCategorySmileys => 'Emoji';

  @override
  String get emojiCategoryGestures => 'Gestá';

  @override
  String get emojiCategoryHearts => 'Srdcia';

  @override
  String get emojiCategoryObjects => 'Objekty';

  @override
  String get gifPicker_title => 'Vyberte GIF';

  @override
  String get gifPicker_searchHint => 'Vyhľadávajte GIFy...';

  @override
  String get gifPicker_poweredBy => 'Napájané spoločnosťou GIPHY';

  @override
  String get gifPicker_noGifsFound => 'Neboli nájdené žiadne GIFy.';

  @override
  String get gifPicker_failedLoad => 'Nepodarilo sa načítať GIFy';

  @override
  String get gifPicker_failedSearch => 'Nepodarilo sa vyhľadať GIFy';

  @override
  String get gifPicker_noInternet => 'Žiadna internetová konektivita';

  @override
  String get debugLog_appTitle => 'Záznam ladenia aplikácie';

  @override
  String get debugLog_bleTitle => 'Log BLE Debug';

  @override
  String get debugLog_copyLog => 'Kopírovať záznam';

  @override
  String get debugLog_clearLog => 'Vymažať záznam';

  @override
  String get debugLog_copied => 'Záznam ladenia skopírovaný';

  @override
  String get debugLog_bleCopied => 'Kopírovaný záznam z BLE.';

  @override
  String get debugLog_noEntries =>
      'Zatiaľ neboli zaznamenané žiadne debug logy.';

  @override
  String get debugLog_enableInSettings =>
      'Povolte ladicové logy v nastaveniach';

  @override
  String get debugLog_frames => 'Rámce';

  @override
  String get debugLog_rawLogRx => 'Raw Log-RX';

  @override
  String get debugLog_noBleActivity => 'Zatiaľ žiadna aktivita BLE.';

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
    return 'Dĺžka rámca: $count bajtov';
  }

  @override
  String debugFrame_command(String value) {
    return 'Prikáž: 0x$value';
  }

  @override
  String get debugFrame_textMessageHeader => 'Textová zvesť:';

  @override
  String debugFrame_destinationPubKey(String pubKey) {
    return '- Cieľový PubKey: $pubKey';
  }

  @override
  String debugFrame_timestamp(int timestamp) {
    return '- Časové označenie: $timestamp';
  }

  @override
  String debugFrame_flags(String value) {
    return '- Žiadne vlajky: 0x$value';
  }

  @override
  String debugFrame_textType(int type, String label) {
    return '- Typ textu: $type ($label)';
  }

  @override
  String get debugFrame_textTypeCli => 'CLI';

  @override
  String get debugFrame_textTypePlain => 'Jednoduché';

  @override
  String debugFrame_text(String text) {
    return '- Text: \"$text\"';
  }

  @override
  String get debugFrame_hexDump => 'Hex Dump:';

  @override
  String get chat_pathManagement => 'Správa ciest';

  @override
  String get chat_ShowAllPaths => 'Zobraziť všetky cesty';

  @override
  String get chat_routingMode => 'Režim trasy';

  @override
  String get chat_autoUseSavedPath => 'Použiť uloženú cestu';

  @override
  String get chat_forceFloodMode =>
      'Zavrieť režim núdzového povodňového režimu';

  @override
  String get chat_recentAckPaths => 'Nedávne cesty ACK (klepni na použitie):';

  @override
  String get chat_pathHistoryFull =>
      'História ciest je plná. Odstráňte záznamy, aby ste mohli pridať nové.';

  @override
  String get chat_hopSingular => 'Skok';

  @override
  String get chat_hopPlural => 'Skákať';

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
  String get chat_successes => 'Úspechy';

  @override
  String get chat_removePath => 'Odstrániť cestu';

  @override
  String get chat_noPathHistoryYet =>
      'Zatiaľ žiadna história trás.\nPošlite správu a objavte trasy.';

  @override
  String get chat_pathActions => 'Cesty:';

  @override
  String get chat_setCustomPath => 'Nastaviť vlastnú cestu';

  @override
  String get chat_setCustomPathSubtitle => 'Ručne zadajte trasu.';

  @override
  String get chat_clearPath => 'Vyčistiš cestu';

  @override
  String get chat_clearPathSubtitle =>
      'Znovu nájsť vynútene pri nasledujúcej pošlite';

  @override
  String get chat_pathCleared =>
      'Cesta vyčistená. Nasledujúce prepočetné získa trasu znova.';

  @override
  String get chat_floodModeSubtitle =>
      'Použite prepínanie trasy v navigačnom paneli.';

  @override
  String get chat_floodModeEnabled =>
      'Odosporňovacia prevádzka je zapnutá. Vypnite ju znova cez ikonu routovania v navigačnom páse.';

  @override
  String get chat_fullPath => 'Celá cesta';

  @override
  String get chat_pathDetailsNotAvailable =>
      'Podrobnosti o ceste zatiaľ dostupné nie sú. Skúste poslať správu na obnovenie.';

  @override
  String chat_pathSetHops(int hopCount, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      hopCount,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Cesta nastavená: $hopCount $_temp0 - $status';
  }

  @override
  String get chat_pathSavedLocally =>
      'Uložené lokálne. Spojte sa na synchronizáciu.';

  @override
  String get chat_pathDeviceConfirmed => 'Zariadenie potvrdené.';

  @override
  String get chat_pathDeviceNotConfirmed =>
      'Zariadenie zatiaľ nebolo potvrdené.';

  @override
  String get chat_type => 'Napište';

  @override
  String get chat_path => 'Cesta';

  @override
  String get chat_publicKey => 'Verejný kľúč';

  @override
  String get chat_compressOutgoingMessages => 'Komprimovať odoslané správy';

  @override
  String get chat_floodForced => 'Povodňová (nutená)';

  @override
  String get chat_directForced => 'Priame (donútené)';

  @override
  String chat_hopsForced(int count) {
    return '$count skokov (nutené)';
  }

  @override
  String get chat_floodAuto => 'Povod (automaticky)';

  @override
  String get chat_direct => 'Priamo';

  @override
  String get chat_poiShared => 'Zdieľané body záujmu';

  @override
  String chat_unread(int count) {
    return 'Nezriadené: $count';
  }

  @override
  String get chat_openLink => 'Otvoriť odkaz?';

  @override
  String get chat_openLinkConfirmation =>
      'Chcete otvoriť tento odkaz v prehliadači?';

  @override
  String get chat_open => 'Otvoriť';

  @override
  String chat_couldNotOpenLink(String url) {
    return 'Nepodarilo sa otvoriť odkaz: $url';
  }

  @override
  String get chat_invalidLink => 'Neplatný formát odkazu';

  @override
  String get map_title => 'Mapa uzlov';

  @override
  String get map_lineOfSight => 'Line of Sight';

  @override
  String get map_losScreenTitle => 'Line of Sight';

  @override
  String get map_noNodesWithLocation => 'Žiadne uzly s údajmi o polohe';

  @override
  String get map_nodesNeedGps =>
      'Uholníky musia zdieľať svoje GPS súradnice, aby sa zobrazili na mape.';

  @override
  String map_nodesCount(int count) {
    return 'Uzly: $count';
  }

  @override
  String map_pinsCount(int count) {
    return 'Krúžky: $count';
  }

  @override
  String get map_chat => 'Rozhovor';

  @override
  String get map_repeater => 'Opakovanie';

  @override
  String get map_room => 'Izba';

  @override
  String get map_sensor => 'Senzor';

  @override
  String get map_pinDm => 'Zabudka (DM)';

  @override
  String get map_pinPrivate => 'Zabudka (Osobná)';

  @override
  String get map_pinPublic => 'Zablokovať (verejne)';

  @override
  String get map_lastSeen => 'Posledné zreteľné zobrazenie';

  @override
  String get map_disconnectConfirm =>
      'Ste si istý/á, že chcete odpojiť od tohto zariadenia?';

  @override
  String get map_from => 'Od';

  @override
  String get map_source => 'Zdroj';

  @override
  String get map_flags => 'Zástavy';

  @override
  String get map_pinLabel => 'Označka upozornenia';

  @override
  String get map_label => 'Značka';

  @override
  String get map_publicLocationShare => 'Zdieľiť verejnú lokalitu';

  @override
  String map_publicLocationShareConfirm(String channelLabel) {
    return 'Čoskoro budete zdieľať polohu v $channelLabel. Tento kanál je verejný a môže ho vidieť každý s PSK.';
  }

  @override
  String get map_connectToShareMarkers =>
      'Pripojte sa k zariadeniu na zdieľanie značiek';

  @override
  String get map_filterNodes => 'Filtrovať uzly';

  @override
  String get map_nodeTypes => 'Typy uzlov';

  @override
  String get map_chatNodes => 'Chatové uzly';

  @override
  String get map_repeaters => 'Opakovadlá';

  @override
  String get map_otherNodes => 'Ostatné uzly';

  @override
  String get map_keyPrefix => 'Päťciferné predpona';

  @override
  String get map_filterByKeyPrefix => 'Filtrovať podľa predponového kľúča';

  @override
  String get map_publicKeyPrefix => 'Prefix verejného kľúča';

  @override
  String get map_markers => 'Označkovače';

  @override
  String get map_showSharedMarkers => 'Zobraziť zdieľané značky';

  @override
  String get map_lastSeenTime => 'Posledný čas sledovania';

  @override
  String get map_joinRoom => 'Pripojiť miestnosť';

  @override
  String get map_manageRepeater => 'Spravovať Opakovanie';

  @override
  String get map_tapToAdd => 'Kliknite na uzly, aby ste ich pridali k ceste.';

  @override
  String get map_runTrace => 'Spustiť trasovaním cesty';

  @override
  String get map_removeLast => 'Odstrániť posledný';

  @override
  String get map_pathTraceCancelled => 'Zrušenie stopáže cesty bolo zrušené.';

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
  String get mapCache_title => 'Offline Mapa Pamäť';

  @override
  String get mapCache_selectAreaFirst => 'Vyberte si oblasť na predprerúčenie.';

  @override
  String get mapCache_noTilesToDownload =>
      'Žiadne dlaždice na stiahnutie pre toto zóna';

  @override
  String get mapCache_downloadTilesTitle => 'Stiahnuť dlaždice';

  @override
  String mapCache_downloadTilesPrompt(int count) {
    return 'Stiahnuť $count dlaždíc na offline použitie?';
  }

  @override
  String get mapCache_downloadAction => 'Stiahnuť';

  @override
  String mapCache_cachedTiles(int count) {
    return 'Zabudené $count dlaždíc';
  }

  @override
  String mapCache_cachedTilesWithFailed(int downloaded, int failed) {
    return 'Uložené $downloaded dlaždice ($failed neúspešné)';
  }

  @override
  String get mapCache_clearOfflineCacheTitle => 'Vymazať offline uloženie';

  @override
  String get mapCache_clearOfflineCachePrompt =>
      'Odstrániť všetky uložené mapové dlaždice?';

  @override
  String get mapCache_offlineCacheCleared => 'Offline polia vymazaná';

  @override
  String get mapCache_noAreaSelected => 'Neoznačila sa žiadna oblasť';

  @override
  String get mapCache_cacheArea => 'Obdĺžková oblasť';

  @override
  String get mapCache_useCurrentView => 'Použite aktuálny zobrazenie';

  @override
  String get mapCache_zoomRange => 'Rozsah zväčšenia';

  @override
  String mapCache_estimatedTiles(int count) {
    return 'Odhadnuté dlaždice: $count';
  }

  @override
  String mapCache_downloadedTiles(int completed, int total) {
    return 'Stiahnuté $completed / $total';
  }

  @override
  String get mapCache_downloadTilesButton => 'Stiahnuť dlaždice';

  @override
  String get mapCache_clearCacheButton => 'Vyprázdniť Vädsť';

  @override
  String mapCache_failedDownloads(int count) {
    return 'Neúspešné stiahnutia: $count';
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
  String get time_justNow => 'Príbeh';

  @override
  String time_minutesAgo(int minutes) {
    return '$minutes min dozadu';
  }

  @override
  String time_hoursAgo(int hours) {
    return '$hours h dozadu';
  }

  @override
  String time_daysAgo(int days) {
    return '$days dní dozadu';
  }

  @override
  String get time_hour => 'hodina';

  @override
  String get time_hours => 'hodiny';

  @override
  String get time_day => 'deň';

  @override
  String get time_days => 'dni';

  @override
  String get time_week => 'týždeň';

  @override
  String get time_weeks => 'týždne';

  @override
  String get time_month => 'mesiac';

  @override
  String get time_months => 'mesiace';

  @override
  String get time_minutes => 'minúty';

  @override
  String get time_allTime => 'Všetko Časom';

  @override
  String get dialog_disconnect => 'Odpojiť';

  @override
  String get dialog_disconnectConfirm =>
      'Ste si istý/á, že chcete odpojiť od tohto zariadenia?';

  @override
  String get login_repeaterLogin => 'Opätovné prihlásenie';

  @override
  String get login_roomLogin => 'Prihlásenie do miestnosti';

  @override
  String get login_password => 'Heslo';

  @override
  String get login_enterPassword => 'Zadajte heslo';

  @override
  String get login_savePassword => 'Uložiť heslo';

  @override
  String get login_savePasswordSubtitle =>
      'Heslo bude bezpečne uložené na tomto zariadení.';

  @override
  String get login_repeaterDescription =>
      'Zadajte heslo opakovača, aby ste získali prístup k nastaveniam a stavu.';

  @override
  String get login_roomDescription =>
      'Zadajte heslo do miestnosti na prístup k nastaveniam a stavu.';

  @override
  String get login_routing => 'Rútiace';

  @override
  String get login_routingMode => 'Režim trasy';

  @override
  String get login_autoUseSavedPath => 'Použiť uloženú cestu';

  @override
  String get login_forceFloodMode =>
      'Zavrieť režim núdzového povodňového režimu';

  @override
  String get login_managePaths => 'Spravovať Cesty';

  @override
  String get login_login => 'Prihlásiť';

  @override
  String login_attempt(int current, int max) {
    return 'Skúšaj $current/$max';
  }

  @override
  String login_failed(String error) {
    return 'Prihlásenie zlyhalo: $error';
  }

  @override
  String get login_failedMessage =>
      'Prihlásenie zlyhalo. Heslo je nesprávne alebo je opakovač nedostupný.';

  @override
  String get common_reload => 'Načítať';

  @override
  String get common_clear => 'Zmazať';

  @override
  String path_currentPath(String path) {
    return 'Aktívna cesta: $path';
  }

  @override
  String path_usingHopsPath(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Používa $count $_temp0 cestu';
  }

  @override
  String get path_enterCustomPath => 'Zadajte vlastný priebeh';

  @override
  String get path_currentPathLabel => 'Aktuálny priebeh';

  @override
  String get path_hexPrefixInstructions =>
      'Zadajte 2-miestne hexové predpony pre každú fázu, oddelené čiarkami.';

  @override
  String get path_hexPrefixExample =>
      'A1,F2,3C (každý uzel používa prvý bajt svojho verejného kľúča)';

  @override
  String get path_labelHexPrefixes => 'Cesty (hexové predpony)';

  @override
  String get path_helperMaxHops =>
      'Max 64 skokov. Každý prefix je 2 hexadecimálne znaky (1 bajt).';

  @override
  String get path_selectFromContacts => 'Vyberte sa z kontaktov:';

  @override
  String get path_noRepeatersFound =>
      'Nenašli sa žiadne opakovače ani serverové miestnosti.';

  @override
  String get path_customPathsRequire =>
      'Vlastné cesty vyžadujú medziletoch, ktoré môžu prenášať správky.';

  @override
  String path_invalidHexPrefixes(String prefixes) {
    return 'Neplatné hexové predpony: $prefixes';
  }

  @override
  String get path_tooLong =>
      'Cesta je príliš dlhá. Umožnené je maximum 64 skokov.';

  @override
  String get path_setPath => 'Nastaviť cestu';

  @override
  String get repeater_management => 'Správa opakérov';

  @override
  String get room_management => 'Správa servera miestnosti';

  @override
  String get repeater_managementTools => 'Nástroje na správu';

  @override
  String get repeater_status => 'Status';

  @override
  String get repeater_statusSubtitle =>
      'Zobraziť stav, štatistiky a susedov repeatera';

  @override
  String get repeater_sendAdvert => 'Send Advert';

  @override
  String get repeater_sendAdvertSubtitle =>
      'Broadcast an advertisement packet now';

  @override
  String get repeater_telemetry => 'Telemetria';

  @override
  String get repeater_telemetrySubtitle =>
      'Zobraziť telemetriu senzorov a systémových štatistík';

  @override
  String get repeater_cli => 'CLI';

  @override
  String get repeater_cliSubtitle => 'Pošlite príkazy opakovaču';

  @override
  String get repeater_neighbors => 'Súsezný';

  @override
  String get repeater_neighborsSubtitle => 'Zobraziť susedné body bez skokov.';

  @override
  String get repeater_settings => 'Nastavenia';

  @override
  String get repeater_settingsSubtitle => 'Konfigurujte parametre opakovača';

  @override
  String get repeater_statusTitle => 'Status opakého zboru';

  @override
  String get repeater_routingMode => 'Režim trasy';

  @override
  String get repeater_autoUseSavedPath => 'Použiť uloženú cestu';

  @override
  String get repeater_forceFloodMode =>
      'Zavrieť režim núdzového povodňového režimu';

  @override
  String get repeater_pathManagement => 'Správa trás';

  @override
  String get repeater_refresh => 'Obnoviť';

  @override
  String get repeater_statusRequestTimeout => 'Požiadavka stavu zlyhala.';

  @override
  String repeater_errorLoadingStatus(String error) {
    return 'Chyba pri načítaní stavu: $error';
  }

  @override
  String get repeater_systemInformation => 'Informácie o systéme';

  @override
  String get repeater_firmwareVersion => 'Firmware';

  @override
  String get repeater_battery => 'Batéria';

  @override
  String get repeater_clockAtLogin => 'Čas (při přihlášení)';

  @override
  String get repeater_uptime => 'Dostupnosť';

  @override
  String get repeater_queueLength => 'Dĺžka fronty';

  @override
  String get repeater_debugFlags => 'Kontrolné značky';

  @override
  String get repeater_radioStatistics => 'Rádio Štatistiky';

  @override
  String get repeater_lastRssi => 'Posledná RSSI';

  @override
  String get repeater_lastSnr => 'Posledný SNR';

  @override
  String get repeater_noiseFloor => 'Hladina šumu';

  @override
  String get repeater_txAirtime => 'TX Airtime';

  @override
  String get repeater_rxAirtime => 'RX Airtime';

  @override
  String get repeater_packetStatistics => 'Statistiky balíka';

  @override
  String get repeater_sent => 'Odoslané';

  @override
  String get repeater_received => 'Prišlo';

  @override
  String get repeater_duplicates => 'Duplikáty';

  @override
  String repeater_daysHoursMinsSecs(
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return '$days dní ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  String repeater_packetTxTotal(int total, String flood, String direct) {
    return 'Celkem: $total, Povodňový režim: $flood, Priamy: $direct';
  }

  @override
  String repeater_packetRxTotal(int total, String flood, String direct) {
    return 'Celkem: $total, Povodňový režim: $flood, Priamy: $direct';
  }

  @override
  String repeater_duplicatesFloodDirect(String flood, String direct) {
    return 'Pond: $flood, Priamy: $direct';
  }

  @override
  String repeater_duplicatesTotal(int total) {
    return 'Celkem: $total';
  }

  @override
  String get repeater_settingsTitle => 'Nastavenia Opakovača';

  @override
  String get repeater_basicSettings => 'Základné nastavenia';

  @override
  String get repeater_repeaterName => 'Opakovacia názov';

  @override
  String get repeater_repeaterNameHelper => 'Zobrazenie názvu tohto opakovača';

  @override
  String get repeater_adminPassword => 'Heslo administrátora';

  @override
  String get repeater_adminPasswordHelper => 'Celý prístupový heslo';

  @override
  String get repeater_guestPassword => 'Heslo hosťa';

  @override
  String get repeater_guestPasswordHelper => 'Prístupový heslo iba na čítanie';

  @override
  String get repeater_radioSettings => 'Nastavenia rádia';

  @override
  String get repeater_frequencyMhz => 'Frekvencia (MHz)';

  @override
  String get repeater_frequencyHelper => '300-2500 MHz';

  @override
  String get repeater_txPower => 'TX Power';

  @override
  String get repeater_txPowerHelper => '1-30 dBm';

  @override
  String get repeater_bandwidth => 'Šírka pásma';

  @override
  String get repeater_spreadingFactor => 'Šírenie faktoru';

  @override
  String get repeater_codingRate => 'Rýchlosť kódovania';

  @override
  String get repeater_locationSettings => 'Nastavenia polohy';

  @override
  String get repeater_latitude => 'Súradnica';

  @override
  String get repeater_latitudeHelper => 'Desatinné zložky (napr. 37.7749)';

  @override
  String get repeater_longitude => 'Dĺžka';

  @override
  String get repeater_longitudeHelper => 'Desatinné zložky (napr. -122.4194)';

  @override
  String get repeater_features => 'Funkcie';

  @override
  String get repeater_packetForwarding => 'Riadenie prienikov';

  @override
  String get repeater_packetForwardingSubtitle =>
      'Povolte opakovač na smerovanie paketov.';

  @override
  String get repeater_guestAccess => 'Prístup pre hostí';

  @override
  String get repeater_guestAccessSubtitle =>
      'Umožniť prístup hosta iba na čítanie.';

  @override
  String get repeater_privacyMode => 'Režim ochrany súkromia';

  @override
  String get repeater_privacyModeSubtitle => 'Skryť meno/poloha v reklamách';

  @override
  String get repeater_advertisementSettings => 'Nastavenia reklamy';

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
  String get repeater_localAdvertInterval => 'Lokálna reklamná časová obdoba';

  @override
  String repeater_localAdvertIntervalMinutes(int minutes) {
    return '$minutes minút';
  }

  @override
  String get repeater_floodAdvertInterval =>
      'Interval reklamnej povodňovej reklamy';

  @override
  String repeater_floodAdvertIntervalHours(int hours) {
    return '$hours hodín';
  }

  @override
  String get repeater_encryptedAdvertInterval => 'Šifrovaný reklamný interval';

  @override
  String get repeater_dangerZone => 'Nebezpečná zóna';

  @override
  String get repeater_rebootRepeater => 'Restart Repetér';

  @override
  String get repeater_rebootRepeaterSubtitle => 'Resetovať vysielací prístroj';

  @override
  String get repeater_rebootRepeaterConfirm =>
      'Ste si istý, že chcete tento opakovač restartovať?';

  @override
  String get repeater_regenerateIdentityKeySubtitle =>
      'Generovať nový pár verejných/privátnych kľúčov';

  @override
  String get repeater_regenerateIdentityKeyConfirm =>
      'Toto vytvorí nový identitu pre opakovač. Pokračovať?';

  @override
  String get repeater_eraseFileSystem => 'Vymažať Systémový Reťazec';

  @override
  String get repeater_eraseFileSystemSubtitle =>
      'Formátovať systém opakujúcich sa súborov';

  @override
  String get repeater_eraseFileSystemConfirm =>
      'VAROVANIE: Toto zmaže všetky dáta na opakovači. To sa nedá zrušiť!';

  @override
  String get repeater_eraseSerialOnly =>
      'Odstránenie je dostupné len cez sériové rozhranie.';

  @override
  String repeater_commandSent(String command) {
    return 'Poforovaný príkaz: $command';
  }

  @override
  String repeater_errorSendingCommand(String error) {
    return 'Chyba pri odeslaní príkazu: $error';
  }

  @override
  String get repeater_confirm => 'Potvrdiť';

  @override
  String get repeater_settingsSaved => 'Nastavenia boli uložené úspešne.';

  @override
  String repeater_errorSavingSettings(String error) {
    return 'Chyba pri ukladaní nastavení: $error';
  }

  @override
  String get repeater_refreshBasicSettings => 'Obnoviť základné nastavenia';

  @override
  String get repeater_refreshRadioSettings => 'Obnoviť Nastavenia Rádií';

  @override
  String get repeater_refreshTxPower => 'Obnoviť TX napájanie';

  @override
  String get repeater_refreshLocationSettings => 'Obnoviť Nastavenia Miesta';

  @override
  String get repeater_refreshPacketForwarding => 'Obnoviť smerovanie paketov';

  @override
  String get repeater_refreshGuestAccess => 'Obnoviť prístup hosťa';

  @override
  String get repeater_refreshPrivacyMode => 'Obnoviť Ochranný režim';

  @override
  String get repeater_refreshAdvertisementSettings =>
      'Obnoviť nastavenia reklamy';

  @override
  String repeater_refreshed(String label) {
    return '$label sa znova načítalo';
  }

  @override
  String repeater_errorRefreshing(String label) {
    return 'Chyba pri obnovení $label';
  }

  @override
  String get repeater_cliTitle => 'Opakovacia CLI';

  @override
  String get repeater_debugNextCommand => 'Oprava Nasledujúceho Príkaz';

  @override
  String get repeater_commandHelp => 'Pomoc';

  @override
  String get repeater_clearHistory => 'Vymazať históriu';

  @override
  String get repeater_noCommandsSent =>
      'Zatiaľ neboli odeslané žiadne príkazy.';

  @override
  String get repeater_typeCommandOrUseQuick =>
      'Zadajte príkaz nižšie alebo použite rýchle príkazy';

  @override
  String get repeater_enterCommandHint => 'Zadajte príkaz...';

  @override
  String get repeater_previousCommand => 'Predchádzajúci príkaz';

  @override
  String get repeater_nextCommand => 'Nasledujúci príkaz';

  @override
  String get repeater_enterCommandFirst => 'Zadajte najprv príkaz';

  @override
  String get repeater_cliCommandFrameTitle => 'Rámok Príkaz CLI';

  @override
  String repeater_cliCommandError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get repeater_cliQuickGetName => 'Zísť meno';

  @override
  String get repeater_cliQuickGetRadio => 'Zísť po rádiu';

  @override
  String get repeater_cliQuickGetTx => 'Zísť TX';

  @override
  String get repeater_cliQuickNeighbors => 'Súsezný';

  @override
  String get repeater_cliQuickVersion => 'Verzia';

  @override
  String get repeater_cliQuickAdvertise => 'Reklama';

  @override
  String get repeater_cliQuickClock => 'Hodiny';

  @override
  String get repeater_cliHelpAdvert => 'Odosiela reklamnú balíček.';

  @override
  String get repeater_cliHelpReboot =>
      'Resetuje zariadenie. (pozor, môže dôjsť k \'Timeoutu\', čo je normálne)';

  @override
  String get repeater_cliHelpClock =>
      'Zobrazuje aktuálny čas podľa hodiniek zariadenia.';

  @override
  String get repeater_cliHelpPassword =>
      'Nastaví nový administrátorský prístupový údaj pre zariadenie.';

  @override
  String get repeater_cliHelpVersion =>
      'Zobrazuje verziu zariadenia a dátum zostavenia firmvéru.';

  @override
  String get repeater_cliHelpClearStats =>
      'Resetuje rôzne štatistické počítadlá na nulu.';

  @override
  String get repeater_cliHelpSetAf => 'Nastavuje časový faktor.';

  @override
  String get repeater_cliHelpSetTx =>
      'Nastavenie vysielacej sily LoRa v dBm. (potrebuje sa reštart na aplikáciu)';

  @override
  String get repeater_cliHelpSetRepeat =>
      'Umožňuje alebo vypína zopakovaný príspevok pre tento uzol.';

  @override
  String get repeater_cliHelpSetAllowReadOnly =>
      '(Server miestnosti) Ak je \'zapnuté\', potom bude povolený prístup s prázdnym heslom, ale nebude možné posielať správu do miestnosti. (iba čítať).';

  @override
  String get repeater_cliHelpSetFloodMax =>
      'Nastavuje maximálny počet skokov pre vstupný povelový paket (ak je >= max, paket nie je preposlaný)';

  @override
  String get repeater_cliHelpSetIntThresh =>
      'Nastavuje hranicu ruživeho ladenia (v dB). Predvolené je 14. Nastavením na 0 sa vypne detekcia ruživeho ladenia kanálu.';

  @override
  String get repeater_cliHelpSetAgcResetInterval =>
      'Nastavuje interval na reštartovanie Auto Gain Controlleru. Nastavenie na 0 vypne funkciu.';

  @override
  String get repeater_cliHelpSetMultiAcks =>
      'Povolí alebo pozastaví funkciiu \"dvojité potvrdenia\".';

  @override
  String get repeater_cliHelpSetAdvertInterval =>
      'Nastavuje interval časovača v minútach na odošle miestny (bezprostredný) reklamný paket. Nastavenie na 0 vypne funkciu.';

  @override
  String get repeater_cliHelpSetFloodAdvertInterval =>
      'Nastavuje interval časovača v hodinách na odeslanie reklamnej vlne. Nastavenie na 0 vypne.';

  @override
  String get repeater_cliHelpGetPathHashMode =>
      'Returns advert path hash mode (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetPathHashMode =>
      'Sets advert path hash mode for this repeater (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetGuestPassword =>
      'Nastavuje/aktualizuje heslo hosťa. (pre opakované pripojenia môžu hosťovské prihlásenia posielať požadanie \"Get Stats\")';

  @override
  String get repeater_cliHelpSetName => 'Nastaví názov reklamy.';

  @override
  String get repeater_cliHelpSetLat =>
      'Nastaví geografickú šírku reklamnej mapy. (desatinné stupne)';

  @override
  String get repeater_cliHelpSetLon =>
      'Nastavuje longitudinu reklamnej mapy. (desatinné stupne)';

  @override
  String get repeater_cliHelpSetRadio =>
      'Nastavuje úplne nové parametre rádia a uloží ich do preferencií. Požaduje príkaz \"reboot\" na aplikáciu.';

  @override
  String get repeater_cliHelpSetRxDelay =>
      'Nastavenia (experimentálne) základné (musi byť > 1 pre účel) na aplikáciu mierneho onesenia prijatých paketov, na základe signálu/skóre. Nastavenie na 0 vypne.';

  @override
  String get repeater_cliHelpSetTxDelay =>
      'Nastavuje faktor násobený časom na vzduchu pre paket v režime povodňovej vlny a s náhodným systémom slotov, aby sa oneskorene jeho prenosovanie (s cieľom znížiť pravdepodobnosť kolízii).';

  @override
  String get repeater_cliHelpSetDirectTxDelay =>
      'Podobne ako txdelay, ale pre aplikáciu náhodného oneskorenia pri preposlaní paketov v režime priameho prenosu.';

  @override
  String get repeater_cliHelpSetBridgeEnabled => 'Aktivovať/Zatvárať most.';

  @override
  String get repeater_cliHelpSetBridgeDelay =>
      'Nastaviť odklad pred retransmisiou paketov.';

  @override
  String get repeater_cliHelpSetBridgeSource =>
      'Zvolte, či bude most retransmitovať prijaté alebo vysielané balíčky.';

  @override
  String get repeater_cliHelpSetBridgeBaud =>
      'Nastavte sériový link baudrate pre rs232 mosty.';

  @override
  String get repeater_cliHelpSetBridgeSecret =>
      'Nastaviť tajomstvo mosta pre eshnow mosty.';

  @override
  String get repeater_cliHelpSetAdcMultiplier =>
      'Nastavuje vlastný faktor na úpravu nahlásenej batériovej napätia (podporované len na vybraných doskách).';

  @override
  String get repeater_cliHelpTempRadio =>
      'Nastaví dočasné rádiové parametre pre zadaný počet minút, po skončení sa vráti k pôvodným rádiovým parametrom. (nepočuva sa do preferencií).';

  @override
  String get repeater_cliHelpSetPerm =>
      'Zmení ACL. Odstráni zodpovedný záznam (podľa prefixa pubkey), ak je \"permissions\" rovné 0. Pridá nový záznam, ak je pubkey-hex plnej dĺžky a momentálne sa nenachádza v ACL. Aktualizuje záznam podľa zodpovedajúceho prefixa pubkey. Bitové oprávnenia sa líšia podľa funkčnej roly, ale nízke 2 bity sú: 0 (Hostiteľ), 1 (Čítanie len), 2 (Čítanie a zápis), 3 (Správca).';

  @override
  String get repeater_cliHelpGetBridgeType =>
      'Zísť typ mosta: žiadny, rs232, espnow';

  @override
  String get repeater_cliHelpLogStart =>
      'Začína protokolovanie balíkov do systému súborov.';

  @override
  String get repeater_cliHelpLogStop =>
      'Zastaví protokolovanie paketov do systémového súboru.';

  @override
  String get repeater_cliHelpLogErase =>
      'Odstráni záznamy z balíkov z systému súborov.';

  @override
  String get repeater_cliHelpNeighbors =>
      'Zobrazuje zoznam iných repeaterových uzlov zasielaných cez zero-hop reklamy. Každý riadok je id-prefix-hex:timestamp:snr-times-4';

  @override
  String get repeater_cliHelpNeighborRemove =>
      'Odstráni prvú zhodujúcu položku (podľa prefixu pubkey (hex)) z zoznamu susedov.';

  @override
  String get repeater_cliHelpRegion =>
      '(len sériál) Zobrazuje všetky definované regióny a aktuálne povolenia pre povodňové situácie.';

  @override
  String get repeater_cliHelpRegionLoad =>
      'Poznámka: toto je špeciálna multi-príkázová inštancia. Každé nasledujúce príkaza je názov oblasti (zapustený s medzerami na indikáciu hierarchického pomeru, s minimálne jednou medzerou). Ukončené odeslaním prázdnej platnej linky/príkazu.';

  @override
  String get repeater_cliHelpRegionGet =>
      'Hľadá región s daným príponou názvu (alebo \"\\\" pre globálny rozsah). Odpovedá \"-> región-název (rodič-název) \'F\'\"';

  @override
  String get repeater_cliHelpRegionPut =>
      'Pridá alebo aktualizuje definíciu regiónu s daným menom.';

  @override
  String get repeater_cliHelpRegionRemove =>
      'Odstráni definíciu oblasti s daným názvom. (musí zodpovedať presne a nemala by mať podoblasti)';

  @override
  String get repeater_cliHelpRegionAllowf =>
      'Nastavuje povolenie \'P\'lávu pre zadanú oblasť. (\'\' pre globálny/dedičský rozsah)';

  @override
  String get repeater_cliHelpRegionDenyf =>
      'Odstráni povolenie \'F\'lood\' pre zadanú oblasť. (UPOZORNENIE: v tejto fáze nie je odporúčané ho používať na globálnom/dedskom rozsahu!!).';

  @override
  String get repeater_cliHelpRegionHome =>
      'Odpovedá s aktuálnou \'domovskou\' oblasťou. (Poznámka aplikovaná zatiaľ nikde, vyhradené na budúce)';

  @override
  String get repeater_cliHelpRegionHomeSet => 'Nastaví \'domovskú\' oblasť.';

  @override
  String get repeater_cliHelpRegionSave =>
      'Uloží zoznam/mapu regiónov do úložiska.';

  @override
  String get repeater_cliHelpGps =>
      'Zobrazuje stav GPS. Ak je GPS vypnutý, odpovedá len \"off\", ak je zapnutý, odpovedá s \"on\", stavom, fixom a počtom satelitov.';

  @override
  String get repeater_cliHelpGpsOnOff => 'Prepínač stavu GPS napájania.';

  @override
  String get repeater_cliHelpGpsSync =>
      'Synchronizuje čas uzla s GPS hodinami.';

  @override
  String get repeater_cliHelpGpsSetLoc =>
      'Nastaví polohu uzla na GPS súradnice a uloží preferencie.';

  @override
  String get repeater_cliHelpGpsAdvert =>
      'Poskytuje konfiguráciu reklamy pre uzol:\n- žiadna: nezahrňte polohu do reklám\n- zdieľať: zdieľajte GPS polohu (z SensorManager)\n- nastavenia: zobrazujte polohu uloženú v nastaveniach';

  @override
  String get repeater_cliHelpGpsAdvertSet =>
      'Nastavuje konfiguráciu reklamy na zadané miesto.';

  @override
  String get repeater_commandsListTitle => 'Zoznam príkazov';

  @override
  String get repeater_commandsListNote =>
      'Poznámka: pre rôzne príkazy \"set ...\" existuje aj príkaz \"get ...\".';

  @override
  String get repeater_general => 'Obecné';

  @override
  String get repeater_settingsCategory => 'Nastavenia';

  @override
  String get repeater_bridge => 'Most';

  @override
  String get repeater_logging => 'Záznamy';

  @override
  String get repeater_neighborsRepeaterOnly => 'Súseznýci (iba opakovač)';

  @override
  String get repeater_regionManagementRepeaterOnly =>
      'Správa regiónov (iba opakovač)';

  @override
  String get repeater_regionNote =>
      'Regionové príkazy boli zavádzané na správu regionálnych definícií a oprávnení.';

  @override
  String get repeater_gpsManagement => 'Správa GPS';

  @override
  String get repeater_gpsNote =>
      'GPS príkaz bol zavádzaný na riadenie lokalitných tém.';

  @override
  String get telemetry_receivedData => 'Obdolené Telemetrické dáta';

  @override
  String get telemetry_requestTimeout => 'Požiadavka telemetrie zlyhala.';

  @override
  String telemetry_errorLoading(String error) {
    return 'Chyba pri načítaní telemetrie: $error';
  }

  @override
  String get telemetry_noData => 'Nejsú dostupné žiadne údaje z telemetrie.';

  @override
  String telemetry_channelTitle(int channel) {
    return 'Kanál $channel';
  }

  @override
  String get telemetry_batteryLabel => 'Batéria';

  @override
  String get telemetry_voltageLabel => 'Napätie';

  @override
  String get telemetry_mcuTemperatureLabel => 'MCU teplota';

  @override
  String get telemetry_temperatureLabel => 'Teplota';

  @override
  String get telemetry_currentLabel => 'Aktuálne';

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
  String get neighbors_receivedData => 'Obdielo dáta suseda';

  @override
  String get neighbors_requestTimedOut => 'Súďia žiadajú o časové ukončenie.';

  @override
  String neighbors_errorLoading(String error) {
    return 'Chyba pri načítaní susedov: $error';
  }

  @override
  String get neighbors_repeatersNeighbors => 'Opakovadlá Súsezná';

  @override
  String get neighbors_noData =>
      'Nie je dostupná žiadna informácia o susedoch.';

  @override
  String neighbors_unknownContact(String pubkey) {
    return 'Neznáma $pubkey';
  }

  @override
  String neighbors_heardAgo(String time) {
    return 'Počuli sme to: $time dozadu';
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
  String get channelPath_title => 'Cesta balíka';

  @override
  String get channelPath_viewMap => 'Zobraziť mapu';

  @override
  String get channelPath_otherObservedPaths => 'Ostatné pozorovacie cesty';

  @override
  String get channelPath_repeaterHops => 'Skoky opakovača';

  @override
  String get channelPath_noHopDetails =>
      'Podrobnosti o balíčku zatiaľ nie sú dostupné.';

  @override
  String get channelPath_messageDetails => 'Podrobnosti o zprávach';

  @override
  String get channelPath_senderLabel => 'Posielateľ';

  @override
  String get channelPath_timeLabel => 'Čas';

  @override
  String get channelPath_repeatsLabel => 'Opakovanie';

  @override
  String channelPath_pathLabel(int index) {
    return 'Cesta $index';
  }

  @override
  String get channelPath_observedLabel => 'Pozorované';

  @override
  String channelPath_observedPathTitle(int index, String hops) {
    return 'Sledovaný postup $index • $hops';
  }

  @override
  String get channelPath_noLocationData => 'Žiadne údaje o polohe';

  @override
  String channelPath_timeWithDate(int day, int month, String time) {
    return '$day/$month $time';
  }

  @override
  String channelPath_timeOnly(String time) {
    return '$time';
  }

  @override
  String get channelPath_unknownPath => 'Neznáme';

  @override
  String get channelPath_floodPath => 'Povodňová';

  @override
  String get channelPath_directPath => 'Priamo';

  @override
  String channelPath_observedZeroOf(int total) {
    return '0 z $total skokov';
  }

  @override
  String channelPath_observedSomeOf(int observed, int total) {
    return '$observed z $total skokov';
  }

  @override
  String get channelPath_mapTitle => 'Mapa Trasy';

  @override
  String get channelPath_noRepeaterLocations =>
      'Pre túto cestu nie je dostupných žiadne polohy opakovačov.';

  @override
  String channelPath_primaryPath(int index) {
    return 'Cesta $index (Hlavná)';
  }

  @override
  String get channelPath_pathLabelTitle => 'Cesta';

  @override
  String get channelPath_observedPathHeader => 'Sledovaná cesta';

  @override
  String channelPath_selectedPathLabel(String label, String prefixes) {
    return '$label • $prefixes';
  }

  @override
  String get channelPath_noHopDetailsAvailable =>
      'Pre toto balíček nie sú dostupné údaje o skokoch.';

  @override
  String get channelPath_unknownRepeater => 'Neznáme opakovače';

  @override
  String get community_title => 'Komunita';

  @override
  String get community_create => 'Vytvoriť komunitu';

  @override
  String get community_createDesc =>
      'Vytvorte novú komunitu a zdieľajte cez QR kód.';

  @override
  String get community_join => 'Pripojiť';

  @override
  String get community_joinTitle => 'Pripojiť sa k spoločenstvu';

  @override
  String community_joinConfirmation(String name) {
    return 'Chceš sa pridať do komunity \"$name\"?';
  }

  @override
  String get community_scanQr => 'Skontrolujte komunitný QR kód';

  @override
  String get community_scanInstructions =>
      'Zamerte kameru na komunitný QR kód.';

  @override
  String get community_showQr => 'Zobraziť QR kód';

  @override
  String get community_publicChannel => 'Komunita verejná';

  @override
  String get community_hashtagChannel => 'Komunitný Hashtag';

  @override
  String get community_name => 'Komunita';

  @override
  String get community_enterName => 'Zadajte názov komunity';

  @override
  String community_created(String name) {
    return 'Komunita \"$name\" vytvorená';
  }

  @override
  String community_joined(String name) {
    return 'Pripojená komunita \"$name\"';
  }

  @override
  String get community_qrTitle => 'Zdieľť komunitu';

  @override
  String community_qrInstructions(String name) {
    return 'Skenejte tento QR kód, aby ste sa pripojili k $name.';
  }

  @override
  String get community_hashtagPrivacyHint =>
      'Hashtagové kanály komunity sú prístupné len členom komunity';

  @override
  String get community_invalidQrCode => 'Neplatná QR kód komunity.';

  @override
  String get community_alreadyMember => 'Už ste členom.';

  @override
  String community_alreadyMemberMessage(String name) {
    return 'Vy ste už členom \"$name\".';
  }

  @override
  String get community_addPublicChannel => 'Pridať verejný komunikačný kanál';

  @override
  String get community_addPublicChannelHint =>
      'Automaticky prida verejný kanál pre túto komunitu.';

  @override
  String get community_noCommunities =>
      'Zatiaľ ste sa nepripojili k žiadnej komunite';

  @override
  String get community_scanOrCreate =>
      'Skene QR kód alebo vytvor komunitu na začiatok.';

  @override
  String get community_manageCommunities => 'Spravovať komunity';

  @override
  String get community_delete => 'Nechajte komunitu';

  @override
  String community_deleteConfirm(String name) {
    return 'Opustiť \"$name\"?';
  }

  @override
  String community_deleteChannelsWarning(int count) {
    return 'Tým sa tiež vymaže $count kanál/kanálov a ich správy.';
  }

  @override
  String community_deleted(String name) {
    return 'Opustená komunita \"$name\"';
  }

  @override
  String get community_regenerateSecret => 'Zobraziť nový tajný kód';

  @override
  String community_regenerateSecretConfirm(String name) {
    return 'Znovu vygenerovať tajný kľúč pre \"$name\"? Všetci členovia budú musieť skanovať nový QR kód, aby mohli nadviazať komunikáciu.';
  }

  @override
  String get community_regenerate => 'Znovu vygenerovať';

  @override
  String community_secretRegenerated(String name) {
    return 'Záznam pre \"$name\" bol regenerovaný tajne';
  }

  @override
  String get community_updateSecret => 'Aktualizovať tajné heslo';

  @override
  String community_secretUpdated(String name) {
    return 'Zmena tajnej slova pre \"$name\"';
  }

  @override
  String community_scanToUpdateSecret(String name) {
    return 'Skáňte nový QR kód na aktualizáciu tajného hesla pre \"$name\"';
  }

  @override
  String get community_addHashtagChannel => 'Pridať komunitný hashtag';

  @override
  String get community_addHashtagChannelDesc =>
      'Pridajte hashtagový kanál pre túto komunitu.';

  @override
  String get community_selectCommunity => 'Vyberte komunitu';

  @override
  String get community_regularHashtag => 'Zvyčajný hashtag';

  @override
  String get community_regularHashtagDesc =>
      'Veľký hashtag (ktočokoľvek sa môže pridať)';

  @override
  String get community_communityHashtag => 'Komunitný Hashtag';

  @override
  String get community_communityHashtagDesc => 'Špecifické pre členov komunity';

  @override
  String community_forCommunity(String name) {
    return 'Pre $name';
  }

  @override
  String get listFilter_tooltip => 'Filtrovať a triediť';

  @override
  String get listFilter_sortBy => 'Triediť podľa';

  @override
  String get listFilter_latestMessages => 'Posledné správy';

  @override
  String get listFilter_heardRecently => 'Nedávno počuli.';

  @override
  String get listFilter_az => 'A-Z';

  @override
  String get listFilter_filters => 'Filtre';

  @override
  String get listFilter_all => 'Všetko';

  @override
  String get listFilter_users => 'Používatelia';

  @override
  String get listFilter_repeaters => 'Opakovadlá';

  @override
  String get listFilter_roomServers => 'Servéry miestnosti';

  @override
  String get listFilter_unreadOnly => 'Nezaregistrované len';

  @override
  String get listFilter_newGroup => 'Nová skupina';

  @override
  String get pathTrace_you => 'Vy';

  @override
  String get pathTrace_failed => 'Sledovanie cesty zlyhalo.';

  @override
  String get pathTrace_notAvailable => 'Path trace nie je k dispozícii.';

  @override
  String get pathTrace_refreshTooltip => 'Obnoviť Path Trace.';

  @override
  String get pathTrace_someHopsNoLocation =>
      'Jedna alebo viac chmeľov chýba lokalita!';

  @override
  String get pathTrace_clearTooltip => 'Zmazať cestu';

  @override
  String get losSelectStartEnd => 'Vyberte počiatočný a koncový uzol pre LOS.';

  @override
  String losRunFailed(String error) {
    return 'Kontrola priamej viditeľnosti zlyhala: $error';
  }

  @override
  String get losClearAllPoints => 'Vymazať všetky body';

  @override
  String get losRunToViewElevationProfile =>
      'Ak chcete zobraziť výškový profil, spustite LOS';

  @override
  String get losMenuTitle => 'Menu LOS';

  @override
  String get losMenuSubtitle =>
      'Klepnutím na uzly alebo dlhým stlačením mapy získate vlastné body';

  @override
  String get losShowDisplayNodes => 'Zobraziť uzly zobrazenia';

  @override
  String get losCustomPoints => 'Vlastné body';

  @override
  String losCustomPointLabel(int index) {
    return 'Vlastné $index';
  }

  @override
  String get losPointA => 'Bod A';

  @override
  String get losPointB => 'Bod B';

  @override
  String losAntennaA(String value, String unit) {
    return 'Anténa A: $value $unit';
  }

  @override
  String losAntennaB(String value, String unit) {
    return 'Anténa B: $value $unit';
  }

  @override
  String get losRun => 'Spustite LOS';

  @override
  String get losNoElevationData => 'Žiadne údaje o nadmorskej výške';

  @override
  String losProfileClear(
    String distance,
    String distanceUnit,
    String clearance,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, vymazať LOS, min. vôľa $clearance $heightUnit';
  }

  @override
  String losProfileBlocked(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, blokovaný $obstruction $heightUnit';
  }

  @override
  String get losStatusChecking => 'LOS: kontrolujem...';

  @override
  String get losStatusNoData => 'LOS: žiadne údaje';

  @override
  String losStatusSummary(int clear, int total, int blocked, int unknown) {
    return 'LOS: $clear/$total vymazané, $blocked blokované, $unknown neznáme';
  }

  @override
  String get losErrorElevationUnavailable =>
      'Údaje o nadmorskej výške nie sú k dispozícii pre jednu alebo viacero vzoriek.';

  @override
  String get losErrorInvalidInput =>
      'Neplatné body/údaje o nadmorskej výške pre výpočet LOS.';

  @override
  String get losRenameCustomPoint => 'Premenovať vlastný bod';

  @override
  String get losPointName => 'Názov bodu';

  @override
  String get losShowPanelTooltip => 'Zobraziť panel LOS';

  @override
  String get losHidePanelTooltip => 'Skryť panel LOS';

  @override
  String get losElevationAttribution =>
      'Údaje o nadmorskej výške: Open-Meteo (CC BY 4.0)';

  @override
  String get contacts_pathTrace => 'Sledovanie lúčov';

  @override
  String get contacts_ping => 'Pingovať';

  @override
  String get contacts_repeaterPathTrace => 'Sledovanie cesty k opakovaču';

  @override
  String get contacts_repeaterPing => 'Pingovať opakovač';

  @override
  String get contacts_roomPathTrace => 'Sledovanie cesty k serveru miestnosti';

  @override
  String get contacts_roomPing => 'Ping server miestnosti';

  @override
  String get contacts_chatTraceRoute => 'Sledovať trasu lúča';

  @override
  String contacts_pathTraceTo(String name) {
    return 'Sledovať trasu k $name';
  }

  @override
  String get contacts_clipboardEmpty => 'Schránka je prázdna.';

  @override
  String get contacts_invalidAdvertFormat => 'Neplatné kontaktné údaje';

  @override
  String get contacts_contactImported => 'Kontakt bol importovaný.';

  @override
  String get contacts_contactImportFailed =>
      'Kontakt sa nepodarilo importovať.';

  @override
  String get contacts_zeroHopAdvert => 'Inzerát Zero Hop';

  @override
  String get contacts_floodAdvert => 'Inzerát povodní';

  @override
  String get contacts_copyAdvertToClipboard => 'Kopírovať reklamu do schránky';

  @override
  String get contacts_addContactFromClipboard => 'Pridať kontakt z schránky';

  @override
  String get contacts_ShareContact => 'Kopírovať kontakt do schránky';

  @override
  String get contacts_ShareContactZeroHop => 'Zdieľať kontakt cez inzerát';

  @override
  String get contacts_zeroHopContactAdvertSent => 'Poslal kontakt cez inzerát.';

  @override
  String get contacts_zeroHopContactAdvertFailed =>
      'Zlyhalo odoslanie kontaktu.';

  @override
  String get contacts_contactAdvertCopied =>
      'Inzerát bol skopírovaný do schránky.';

  @override
  String get contacts_contactAdvertCopyFailed =>
      'Kopírovanie inzerátu do schránky zlyhalo.';

  @override
  String get notification_activityTitle => 'Aktivita MeshCore';

  @override
  String notification_messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'správ',
      few: 'správy',
      one: 'správa',
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
      other: 'správ kanálu',
      few: 'správy kanálu',
      one: 'správa kanálu',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nových uzlov',
      few: 'nové uzly',
      one: 'nový uzol',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newTypeDiscovered(String contactType) {
    return 'Nový $contactType objavený';
  }

  @override
  String get notification_receivedNewMessage => 'Prijatá nová správa';

  @override
  String get settings_gpxExportRepeaters =>
      'Exportovať repeater / server miestnosti do GPX';

  @override
  String get settings_gpxExportRepeatersSubtitle =>
      'Exportuje repeater / roomserver s lokalitou do súboru GPX.';

  @override
  String get settings_gpxExportContacts => 'Export sprievodcov do GPX';

  @override
  String get settings_gpxExportContactsSubtitle =>
      'Exportuje sprievodcov s umiestnením do súboru GPX.';

  @override
  String get settings_gpxExportAll => 'Exportovať všetky kontakty do GPX';

  @override
  String get settings_gpxExportAllSubtitle =>
      'Exportuje všetky kontakty s lokalitou do súboru GPX.';

  @override
  String get settings_gpxExportSuccess => 'Úspešne exportovaný súbor GPX.';

  @override
  String get settings_gpxExportNoContacts => 'Žiadne kontakty na export.';

  @override
  String get settings_gpxExportNotAvailable =>
      'Nie je podporované na vašom zariadení/operáciomnom systéme';

  @override
  String get settings_gpxExportError => 'Vyskytol sa chyba počas exportu.';

  @override
  String get settings_gpxExportRepeatersRoom =>
      'Umiestnenia opakovačov a serverov miestností';

  @override
  String get settings_gpxExportChat => 'Lokácie sprievodcov';

  @override
  String get settings_gpxExportAllContacts => 'Všetky kontaktné lokality';

  @override
  String get settings_gpxExportShareText =>
      'Mapové údaje exportované z Gulf Coast Mesh App';

  @override
  String get settings_gpxExportShareSubject =>
      'Gulf Coast Mesh App export dát GPX mapových údajov';

  @override
  String get snrIndicator_nearByRepeaters => 'Miestne opakovače';

  @override
  String get snrIndicator_lastSeen => 'Naposledy videný';

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
  String get repeater_regenerateIdentityKey => 'Generovať kľúč identity';

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
  String get appSettings_nodeBlocking => 'Blokovanie uzlov';

  @override
  String get appSettings_nodeBlockingSubtitle =>
      'Skrývať vybrané uzly na mape, v kontaktoch a chatoch a stlmiť ich upozornenia. Len v aplikácii: z rádia sa nič nemaže.';

  @override
  String get appSettings_blockedNodes => 'Zablokované uzly';

  @override
  String appSettings_blockedNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zablokovaných uzlov',
      few: '$count zablokované uzly',
      one: '1 zablokovaný uzol',
      zero: 'Zatiaľ žiadne zablokované',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_title => 'Zablokované uzly';

  @override
  String get blockedNodes_howItWorks => 'Ako blokovanie funguje';

  @override
  String get blockedNodes_infoHidden =>
      'Skryté na mape, v kontaktoch a chatoch';

  @override
  String get blockedNodes_infoMuted =>
      'Žiadne upozornenia na nové uzly ani upozornenia na správy od nich';

  @override
  String get blockedNodes_infoKept =>
      'Nič sa nemaže. Uzly zostávajú v sprievodnom rádiu a ich správy sa uchovávajú';

  @override
  String get blockedNodes_infoRelay =>
      'Zablokované opakovače môžu naďalej preposielať vaše správy cez mesh';

  @override
  String get blockedNodes_infoChannels =>
      'Ich správy v kanáloch sa stále zobrazujú';

  @override
  String get blockedNodes_emptyTitle => 'Žiadne zablokované uzly';

  @override
  String get blockedNodes_emptyHint =>
      'Dlho stlačte uzol v Kontaktoch alebo na Mape a vyberte Zablokovať uzol.';

  @override
  String get blockedNodes_unblock => 'Odblokovať';

  @override
  String get blockedNodes_unblockAll => 'Odblokovať všetko';

  @override
  String blockedNodes_unblockAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Odblokovať $count uzlov? Znova sa zobrazia na mape a v kontaktoch.',
      few: 'Odblokovať $count uzly? Znova sa zobrazia na mape a v kontaktoch.',
      one: 'Odblokovať 1 uzol? Znova sa zobrazí na mape a v kontaktoch.',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_unknownNode => 'Neznámy uzol';

  @override
  String blockedNodes_blockedOn(String date) {
    return 'Zablokované $date';
  }

  @override
  String get blockedNodes_blockAction => 'Zablokovať uzol';

  @override
  String blockedNodes_blockConfirmTitle(String name) {
    return 'Zablokovať $name?';
  }

  @override
  String get blockedNodes_blockConfirmBody =>
      'Bude skrytý na mape, v kontaktoch a chatoch a nebudete dostávať jeho upozornenia ani upozornenia na správy. Z rádia sa nič nemaže. Odblokovať ho môžete kedykoľvek v Nastaveniach aplikácie > Experimentálne > Zablokované uzly.';

  @override
  String get blockedNodes_blockConfirmButton => 'Zablokovať';

  @override
  String blockedNodes_blocked(String name) {
    return 'Zablokované: $name';
  }

  @override
  String blockedNodes_unblocked(String name) {
    return 'Odblokované: $name';
  }

  @override
  String get blockedNodes_undo => 'Späť';
}
