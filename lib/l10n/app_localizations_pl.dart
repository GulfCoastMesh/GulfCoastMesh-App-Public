// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

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
  String get nav_channels => 'Kanały';

  @override
  String get nav_map => 'Mapa';

  @override
  String get nav_chats => 'Czaty';

  @override
  String get nav_nodes => 'Węzły';

  @override
  String get nav_settings => 'Ustawienia';

  @override
  String get common_cancel => 'Anuluj';

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
  String get common_connect => 'Połącz';

  @override
  String get common_unknownDevice => 'Nieznane urządzenie';

  @override
  String get common_save => 'Zapisz';

  @override
  String get common_delete => 'Usuń';

  @override
  String get common_close => 'Zamknąć';

  @override
  String get common_edit => 'Edytuj';

  @override
  String get common_add => 'Dodaj';

  @override
  String get common_settings => 'Ustawienia';

  @override
  String get common_disconnect => 'Odłącz';

  @override
  String get common_connected => 'Połączono';

  @override
  String get common_disconnected => 'Odłączony';

  @override
  String get common_reconnecting => 'Reconnecting';

  @override
  String get common_create => 'Utwórz';

  @override
  String get common_continue => 'Kontynuuj';

  @override
  String get common_share => 'Udostępnij';

  @override
  String get common_copy => 'Kopiuj';

  @override
  String get common_retry => 'Spróbować';

  @override
  String get common_hide => 'Ukryj';

  @override
  String get common_remove => 'Usuń';

  @override
  String get common_enable => 'Włącz';

  @override
  String get common_disable => 'Wyłączyć';

  @override
  String get common_reboot => 'Zrestartować';

  @override
  String get common_loading => 'Ładowanie...';

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
  String get scanner_scanning => 'Skanowanie urządzeń...';

  @override
  String get scanner_connecting => 'Łączenie...';

  @override
  String get scanner_disconnecting => 'Odłączanie...';

  @override
  String get scanner_notConnected => 'Niepołączony';

  @override
  String scanner_connectedTo(String deviceName) {
    return 'Połączono z $deviceName';
  }

  @override
  String get scanner_searchingDevices => 'Wyszukiwanie urządzeń MeshCore...';

  @override
  String get scanner_tapToScan =>
      'Naciśnij Skan, aby znaleźć urządzenia MeshCore';

  @override
  String scanner_connectionFailed(String error) {
    return 'Połączenie nieudane: $error';
  }

  @override
  String get scanner_backgroundBleMayDrop =>
      'Background BLE may drop without notification permission.';

  @override
  String get scanner_stop => 'Zatrzymaj';

  @override
  String get scanner_scan => 'Przeskanuj';

  @override
  String get scanner_bluetoothOff => 'Bluetooth jest wyłączony';

  @override
  String get scanner_bluetoothOffMessage =>
      'Prosimy włączyć Bluetooth, aby przeskanować urządzenia.';

  @override
  String get scanner_enableBluetooth => 'Włącz Bluetooth';

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
  String get device_quickSwitch => 'Szybka zmiana';

  @override
  String get device_meshcore => 'MeshCore';

  @override
  String get settings_title => 'Ustawienia';

  @override
  String get settings_deviceInfo => 'Informacje o urządzeniu';

  @override
  String get settings_appSettings => 'Ustawienia aplikacji';

  @override
  String get settings_appSettingsSubtitle =>
      'Powiadomienia, wiadomości i preferencje mapy';

  @override
  String get settings_nodeSettings => 'Ustawienia węzła';

  @override
  String get settings_nodeName => 'Nazwa węzła';

  @override
  String get settings_nodeNameNotSet => 'Nie ustawione';

  @override
  String get settings_nodeNameHint => 'Wprowadź nazwę węzła';

  @override
  String get settings_nodeNameUpdated => 'Imię zaktualizowane';

  @override
  String get settings_radioSettings => 'Ustawienia radia';

  @override
  String get settings_radioSettingsSubtitle =>
      'Częstotliwość, moc, współczynnik rozpraszania';

  @override
  String get settings_radioSettingsUpdated =>
      'Ustawienia radia zostały zaktualizowane';

  @override
  String get settings_location => 'Lokalizacja';

  @override
  String get settings_locationSubtitle => 'Koordynaty GPS';

  @override
  String get settings_locationUpdated => 'Lokalizacja zaktualizowana';

  @override
  String get settings_locationBothRequired =>
      'Wprowadź zarówno szerokość, jak i długość geograficzną.';

  @override
  String get settings_locationInvalid =>
      'Nieprawidłowa szerokość geograficzna lub długość geograficzna.';

  @override
  String get settings_locationGPSEnable => 'Włącz GPS';

  @override
  String get settings_locationGPSEnableSubtitle =>
      'Włącza automatyczne aktualizowanie pozycji za pomocą GPS.';

  @override
  String get settings_locationIntervalSec => 'Interwał dla GPS (Sekundy)';

  @override
  String get settings_usePhoneGps => 'Use phone GPS';

  @override
  String get settings_locationIntervalInvalid =>
      'Interwał musi wynosić co najmniej 60 sekund i mniej niż 86400 sekund.';

  @override
  String get settings_latitude => 'Szerokość';

  @override
  String get settings_longitude => 'Długość';

  @override
  String get settings_privacyMode => 'Tryb Prywatny';

  @override
  String get settings_privacyModeSubtitle =>
      'Ukryj imię/lokalizację w reklamach';

  @override
  String get settings_privacyModeToggle =>
      'Włącz tryb prywatności, aby ukryć swoje imię i lokalizację w reklamach.';

  @override
  String get settings_privacyModeEnabled => 'Tryb prywatności włączony';

  @override
  String get settings_privacyModeDisabled => 'Tryb prywatności wyłączony';

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
  String get settings_actions => 'Działania';

  @override
  String get settings_sendAdvertisement => 'Wyślij Reklamę';

  @override
  String get settings_sendAdvertisementSubtitle =>
      'Obecność transmisji jest teraz';

  @override
  String get settings_advertisementSent => 'Reklama wysłana';

  @override
  String get settings_syncTime => 'Czas synchronizacji';

  @override
  String get settings_syncTimeSubtitle =>
      'Ustaw zegar urządzenia na czas telefonu.';

  @override
  String get settings_timeSynchronized => 'Synchronizacja czasu';

  @override
  String get settings_refreshContacts => 'Odśwież Kontakty';

  @override
  String get settings_refreshContactsSubtitle =>
      'Odśwież listę kontaktów z urządzenia';

  @override
  String get settings_rebootDevice => 'Zrestartuj Urządzenie';

  @override
  String get settings_rebootDeviceSubtitle => 'Zrestartuj urządzenie MeshCore';

  @override
  String get settings_rebootDeviceConfirm =>
      'Czy na pewno chcesz zrestartować urządzenie? Będziesz odłączony.';

  @override
  String get settings_debug => 'Debug';

  @override
  String get settings_bleDebugLog => 'Log błędów BLE';

  @override
  String get settings_bleDebugLogSubtitle =>
      'Polecenia BLE, odpowiedzi i surowe dane';

  @override
  String get settings_appDebugLog => 'Log Wykonywania Aplikacji';

  @override
  String get settings_appDebugLogSubtitle => 'Komunikaty debugowania aplikacji';

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
  String get settings_about => 'O mnie';

  @override
  String settings_aboutVersion(String version) {
    return 'Gulf Coast Mesh App v$version';
  }

  @override
  String get settings_aboutLegalese => 'Gulf Coast Mesh App 2026';

  @override
  String get settings_aboutDescription =>
      'Otwarty kod źródłowy klient Flutter dla urządzeń do sieci mesh LoRa MeshCore.';

  @override
  String get settings_aboutOpenMeteoAttribution =>
      'Dane wysokościowe LOS: Open-Meteo (CC BY 4.0)';

  @override
  String get settings_infoName => 'Imię';

  @override
  String get settings_infoId => 'ID';

  @override
  String get settings_infoStatus => 'Status';

  @override
  String get settings_infoBattery => 'Bateria';

  @override
  String get settings_infoPublicKey => 'Klucz Publiczny';

  @override
  String get settings_infoContactsCount => 'Liczba kontaktów';

  @override
  String get settings_infoChannelCount => 'Liczba kanałów';

  @override
  String get settings_presets => 'Preset';

  @override
  String get settings_frequency => 'Częstotliwość (MHz)';

  @override
  String get settings_frequencyHelper => '300,0 - 2500,0';

  @override
  String get settings_frequencyInvalid =>
      'Nieprawidłowa częstotliwość (300-2500 MHz)';

  @override
  String get settings_bandwidth => 'Przepustowość';

  @override
  String get settings_spreadingFactor => 'Rozkład Czynnika';

  @override
  String get settings_codingRate => 'Stawka Kodowania';

  @override
  String get settings_txPower => 'TX Moc (dBm)';

  @override
  String get settings_txPowerHelper => '0 - 22';

  @override
  String get settings_txPowerInvalid => 'Nieprawidłowa moc TX (0-22 dBm)';

  @override
  String get settings_clientRepeat => 'Powtórzenie: Niezależne od sieci';

  @override
  String get settings_clientRepeatSubtitle =>
      'Pozwól temu urządzeniu powtarzać pakiety danych dla innych urządzeń.';

  @override
  String get settings_clientRepeatFreqWarning =>
      'Powtórka poza siecią wymaga częstotliwości 433, 869 lub 918 MHz.';

  @override
  String settings_error(String message) {
    return 'Błąd: $message';
  }

  @override
  String get appSettings_title => 'Ustawienia aplikacji';

  @override
  String get appSettings_appearance => 'Wygląd';

  @override
  String get appSettings_theme => 'Motyw';

  @override
  String get appSettings_themeSystem => 'Domyślne ustawienia systemu';

  @override
  String get appSettings_themeLight => 'Jasne';

  @override
  String get appSettings_themeDark => 'Ciemny';

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
  String get appSettings_language => 'Język';

  @override
  String get appSettings_languageSystem => 'Domyślny systemowy';

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
  String get appSettings_languageRu => 'Rosyjski';

  @override
  String get appSettings_languageUk => 'Ukraińska';

  @override
  String get appSettings_enableMessageTracing => 'Włącz śledzenie wiadomości';

  @override
  String get appSettings_enableMessageTracingSubtitle =>
      'Pokaż szczegółowe metadane trasowania i czasu dla wiadomości';

  @override
  String get appSettings_notifications => 'Powiadomienia';

  @override
  String get appSettings_enableNotifications => 'Włącz Powiadomienia';

  @override
  String get appSettings_enableNotificationsSubtitle =>
      'Otrzymuj powiadomienia o wiadomościach i reklamach.';

  @override
  String get appSettings_notificationPermissionDenied =>
      'Odmowa zezwolenia na powiadomienia';

  @override
  String get appSettings_notificationsEnabled => 'Powiadomienia włączone';

  @override
  String get appSettings_notificationsDisabled => 'Powiadomienia wyłączone';

  @override
  String get appSettings_messageNotifications =>
      'Powiadomienia o wiadomościach';

  @override
  String get appSettings_messageNotificationsSubtitle =>
      'Pokaż powiadomienie przy otrzymywaniu nowych wiadomości';

  @override
  String get appSettings_channelMessageNotifications =>
      'Powiadomienia o Wiadomościach na Kanałach';

  @override
  String get appSettings_channelMessageNotificationsSubtitle =>
      'Pokaż powiadomienie przy odbieraniu wiadomości z kanału';

  @override
  String get appSettings_advertisementNotifications =>
      'Powiadomienia Reklamowe';

  @override
  String get appSettings_advertisementNotificationsSubtitle =>
      'Wyświetl powiadomienie, gdy zostaną odkryte nowe węzły.';

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
  String get appSettings_messaging => 'Wiadomości';

  @override
  String get appSettings_clearPathOnMaxRetry =>
      'Wyczyść Ścieżkę na Maksymalnej Próbie';

  @override
  String get appSettings_clearPathOnMaxRetrySubtitle =>
      'Resetuj ścieżkę kontaktu po 5 nieudanych próbach wysłania';

  @override
  String get appSettings_pathsWillBeCleared =>
      'Droga będzie wyczyszczona po 5 nieudanych próbach.';

  @override
  String get appSettings_pathsWillNotBeCleared =>
      'Droga nie zostanie automatycznie wyczyszczona.';

  @override
  String get appSettings_autoRouteRotation => 'Automatyczne Rotowanie Trasy';

  @override
  String get appSettings_autoRouteRotationSubtitle =>
      'Przełączaj się między najlepszymi ścieżkami a trybem zalewowym.';

  @override
  String get appSettings_autoRouteRotationEnabled =>
      'Automatyczne obracanie tras włączone';

  @override
  String get appSettings_autoRouteRotationDisabled =>
      'Automatyczne obracanie tras wyłączone';

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
  String get appSettings_battery => 'Bateria';

  @override
  String get appSettings_batteryChemistry => 'Chemia Baterii';

  @override
  String appSettings_batteryChemistryPerDevice(String deviceName) {
    return 'Ustawione na urządzenie ($deviceName)';
  }

  @override
  String get appSettings_batteryChemistryConnectFirst =>
      'Połącz się z urządzeniem, aby wybrać';

  @override
  String get appSettings_batteryNmc => '18650 NMC (3,0-4,2V)';

  @override
  String get appSettings_batteryLifepo4 => 'LiFePO4 (2,6-3,65 V)';

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
  String get appSettings_mapDisplay => 'Wyświetlanie mapy';

  @override
  String get appSettings_showRepeaters => 'Pokaż Powtórniki';

  @override
  String get appSettings_showRepeatersSubtitle =>
      'Wyświetl węzły powtarzające się na mapie';

  @override
  String get appSettings_showChatNodes => 'Pokaż Węzły Rozmowy';

  @override
  String get appSettings_showChatNodesSubtitle =>
      'Wyświetl węzły czatu na mapie';

  @override
  String get appSettings_showOtherNodes => 'Pokaż inne węzły';

  @override
  String get appSettings_showOtherNodesSubtitle =>
      'Wyświetl inne typy węzłów na mapie';

  @override
  String get appSettings_timeFilter => 'Filtrowanie Czasu';

  @override
  String get appSettings_timeFilterShowAll => 'Pokaż wszystkie węzły';

  @override
  String appSettings_timeFilterShowLast(int hours) {
    return 'Pokaż węzły z ostatnich $hours godzin';
  }

  @override
  String get appSettings_mapTimeFilter => 'Filtrowanie Czasu Mapy';

  @override
  String get appSettings_showNodesDiscoveredWithin => 'Pokaż węzły odkryte w:';

  @override
  String get appSettings_allTime => 'Wszystko czasowo';

  @override
  String get appSettings_lastHour => 'Ostatnia godzina';

  @override
  String get appSettings_last6Hours => 'Ostatnie 6 godzin';

  @override
  String get appSettings_last24Hours => 'Ostatnie 24 godziny';

  @override
  String get appSettings_lastWeek => 'Tydzień temu';

  @override
  String get appSettings_offlineMapCache => 'Bufor Map Offline';

  @override
  String get appSettings_unitsTitle => 'Jednostki';

  @override
  String get appSettings_unitsMetric => 'Metryczne (m / km)';

  @override
  String get appSettings_unitsImperial => 'Imperialne (ft / mi)';

  @override
  String get appSettings_noAreaSelected => 'Nie zaznaczono żadnej powierzchni.';

  @override
  String appSettings_areaSelectedZoom(int minZoom, int maxZoom) {
    return 'Wybrany obszar (skala $minZoom-$maxZoom)';
  }

  @override
  String get appSettings_debugCard => 'Debug';

  @override
  String get appSettings_appDebugLogging => 'Logowanie Debugowania Aplikacji';

  @override
  String get appSettings_appDebugLoggingSubtitle =>
      'Loguj wiadomości debugowania aplikacji w celu rozwiązywania problemów.';

  @override
  String get appSettings_appDebugLoggingEnabled =>
      'Zdebugowanie aplikacji włączone';

  @override
  String get appSettings_appDebugLoggingDisabled =>
      'Zasubskrybowane logi debugowania aplikacji wyłączone.';

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
  String get contacts_noContacts => 'Brak jeszcze kontaktów.';

  @override
  String get contacts_contactsWillAppear =>
      'Kontakty będą wyświetlane, gdy urządzenia reklamują się.';

  @override
  String get contacts_searchContacts => 'Wyszukaj kontakty...';

  @override
  String get contacts_noUnreadContacts => 'Brak nieprzeczytanych kontaktów';

  @override
  String get contacts_noContactsFound =>
      'Brak znalezionych kontaktów ani grup.';

  @override
  String get contacts_deleteContact => 'Usuń Kontakt';

  @override
  String contacts_removeConfirm(String contactName) {
    return 'Usuń $contactName z kontaktów?';
  }

  @override
  String get contacts_manageRepeater => 'Zarządzaj Powtórzami';

  @override
  String get contacts_manageRoom => 'Zarządzaj Serwerem Pokoju';

  @override
  String get contacts_roomLogin => 'Logowanie do pokoju';

  @override
  String get contacts_openChat => 'Otwórz czat';

  @override
  String get contacts_editGroup => 'Edytuj Grupę';

  @override
  String get contacts_deleteGroup => 'Usuń Grupę';

  @override
  String contacts_deleteGroupConfirm(String groupName) {
    return 'Usuń \"$groupName\"?';
  }

  @override
  String get contacts_newGroup => 'Nowa Grupa';

  @override
  String get contacts_groupName => 'Nazwa grupy';

  @override
  String get contacts_groupNameRequired => 'Nazwa grupy jest wymagana';

  @override
  String contacts_groupAlreadyExists(String name) {
    return 'Grupa \"$name\" już istnieje';
  }

  @override
  String get contacts_filterContacts => 'Filtruj kontakty...';

  @override
  String get contacts_noContactsMatchFilter =>
      'Brak pasujących kontaktów do Twojego filtra';

  @override
  String get contacts_noMembers => 'Brak członków';

  @override
  String get contacts_lastSeenNow => 'Ostatnie połączenie';

  @override
  String contacts_lastSeenMinsAgo(int minutes) {
    return 'Ostatnie połączenie $minutes min temu';
  }

  @override
  String get contacts_lastSeenHourAgo => 'Ostatni raz widziany 1 godzinę temu';

  @override
  String contacts_lastSeenHoursAgo(int hours) {
    return 'Ostatnie połączenie $hours godzin temu';
  }

  @override
  String get contacts_lastSeenDayAgo => 'Ostatni raz widziany 1 dzień temu';

  @override
  String contacts_lastSeenDaysAgo(int days) {
    return 'Ostatnie połączenie $days dni temu';
  }

  @override
  String get channels_title => 'Kanały';

  @override
  String get channels_noChannelsConfigured => 'Brak skonfigurowanych kanałów';

  @override
  String get channels_addPublicChannel => 'Dodaj kanał publiczny';

  @override
  String get channels_searchChannels => 'Wyszukaj kanały...';

  @override
  String get channels_noChannelsFound => 'Brak znalezionych kanałów';

  @override
  String get channels_channelSlotsFull =>
      'All device channel slots are in use. Delete a channel before adding another.';

  @override
  String channels_channelAddFailed(String error) {
    return 'Could not add channel: $error';
  }

  @override
  String channels_channelIndex(int index) {
    return 'Kanał $index';
  }

  @override
  String get channels_hashtagChannel => 'Kanał z hashtagami';

  @override
  String get channels_public => 'Publiczny';

  @override
  String get channels_private => 'Prywatne';

  @override
  String get channels_publicChannel => 'Kanał publiczny';

  @override
  String get channels_privateChannel => 'Prywatny kanał';

  @override
  String get channels_editChannel => 'Edytuj kanał';

  @override
  String get channels_deleteChannel => 'Usuń kanał';

  @override
  String channels_deleteChannelConfirm(String name) {
    return 'Usuń \"$name\"? Nie można tego cofnąć.';
  }

  @override
  String get channels_deleteChannelRequiresConnection =>
      'Connect to a device to delete a channel';

  @override
  String channels_channelDeleted(String name) {
    return 'Kanał \"$name\" usunięto';
  }

  @override
  String get channels_addChannel => 'Dodaj Kanał';

  @override
  String get channels_channelIndexLabel => 'Indeks kanału';

  @override
  String get channels_channelName => 'Nazwa kanału';

  @override
  String get channels_usePublicChannel => 'Użyj kanału publicznego';

  @override
  String get channels_standardPublicPsk => 'Standard public PSK';

  @override
  String get channels_pskHex => 'PSK (Hex)';

  @override
  String get channels_generateRandomPsk => 'Wygeneruj losowy klucz PSK';

  @override
  String get channels_enterChannelName => 'Proszę podać nazwę kanału.';

  @override
  String get channels_pskMustBe32Hex => 'PSK musi mieć 32 znaki szesnastkowe.';

  @override
  String channels_channelAdded(String name) {
    return 'Kanał \"$name\" dodany';
  }

  @override
  String channels_editChannelTitle(int index) {
    return 'Edytuj Kanał $index';
  }

  @override
  String get channels_smazCompression => 'Kompresja SMAZ';

  @override
  String channels_channelUpdated(String name) {
    return 'Kanał \"$name\" został zaktualizowany';
  }

  @override
  String get channels_publicChannelAdded => 'Kanał publiczny dodany';

  @override
  String get channels_sortBy => 'Sortuj po';

  @override
  String get channels_sortManual => 'Ręczna';

  @override
  String get channels_sortAZ => 'A-Z';

  @override
  String get channels_sortLatestMessages => 'Najnowsze wiadomości';

  @override
  String get channels_sortUnread => 'Niezgłoszone';

  @override
  String get channels_createPrivateChannel => 'Utwórz Prywatny Kanał';

  @override
  String get channels_createPrivateChannelDesc =>
      'Zabezpieczone kluczem szyfrowym.';

  @override
  String get channels_joinPrivateChannel => 'Dołącz do Prywatnego Kanału';

  @override
  String get channels_joinPrivateChannelDesc => 'Ręcznie wprowadź klucz tajny.';

  @override
  String get channels_joinPublicChannel => 'Dołącz do kanału publicznego.';

  @override
  String get channels_joinPublicChannelDesc =>
      'Każdy może dołączyć do tego kanału.';

  @override
  String get channels_joinHashtagChannel =>
      'Dołącz do kanału oznaczanego hashtagiem';

  @override
  String get channels_joinHashtagChannelDesc =>
      'Każdy może dołączyć do kanałów z hashtagami.';

  @override
  String get channels_scanQrCode => 'Skanuj kod QR';

  @override
  String get channels_scanQrCodeDesc =>
      'Import a channel invite with name, key, and optional region.';

  @override
  String get channels_scanQrCodeComingSoon => 'Wkrótce';

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
  String get channels_enterHashtag => 'Wprowadź hashtag';

  @override
  String get channels_hashtagHint => 'np. #zespół';

  @override
  String get chat_noMessages => 'Brak jeszcze wiadomości';

  @override
  String get chat_sendMessageToStart => 'Wyślij wiadomość, aby rozpocząć.';

  @override
  String get chat_originalMessageNotFound =>
      'Błąd: Nie znaleziono oryginalnego komunikatu';

  @override
  String chat_replyingTo(String name) {
    return 'Odpowiadanie na $name';
  }

  @override
  String chat_replyTo(String name) {
    return 'Odpowiedz $name';
  }

  @override
  String get chat_location => 'Lokalizacja';

  @override
  String chat_sendMessageTo(String contactName) {
    return 'Wyślij wiadomość do $contactName';
  }

  @override
  String get chat_typeMessage => 'Wpisz wiadomość...';

  @override
  String chat_messageTooLong(int maxBytes) {
    return 'Wiadomość jest za długa (maksymalnie $maxBytes bajtów).';
  }

  @override
  String get chat_messageCopied => 'Wiadomość skopiowana';

  @override
  String get chat_messageDeleted => 'Wiadomość usunięta';

  @override
  String get chat_retryingMessage => 'Próba ponowienia';

  @override
  String chat_retryCount(int current, int max) {
    return 'Spróbuj $current/$max';
  }

  @override
  String get chat_sendGif => 'Wyślij GIF';

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
  String get chat_reply => 'Odpowiedz';

  @override
  String get chat_addReaction => 'Dodaj Reakcję';

  @override
  String get chat_editMessage => 'Edit message';

  @override
  String get chat_editedLabel => '(edited)';

  @override
  String get chat_messageEdited => 'Message edited';

  @override
  String get chat_me => 'Ja';

  @override
  String get emojiCategorySmileys => 'Emoji';

  @override
  String get emojiCategoryGestures => 'Gestikulacje';

  @override
  String get emojiCategoryHearts => 'Serce';

  @override
  String get emojiCategoryObjects => 'Obiekty';

  @override
  String get gifPicker_title => 'Wybierz GIF';

  @override
  String get gifPicker_searchHint => 'Wyszukaj GIF-y...';

  @override
  String get gifPicker_poweredBy => 'Zasilane przez GIPHY';

  @override
  String get gifPicker_noGifsFound => 'Nie znaleziono GIF-ów';

  @override
  String get gifPicker_failedLoad => 'Nie udało się załadować GIF-ów';

  @override
  String get gifPicker_failedSearch => 'Nie udało się znaleźć GIF-ów';

  @override
  String get gifPicker_noInternet => 'Brak połączenia internetowego';

  @override
  String get debugLog_appTitle => 'Log Wykonywania Aplikacji';

  @override
  String get debugLog_bleTitle => 'Log błędów BLE';

  @override
  String get debugLog_copyLog => 'Kopiuj log';

  @override
  String get debugLog_clearLog => 'Wyczyść dziennik';

  @override
  String get debugLog_copied => 'Skopiowano dziennik debugowania';

  @override
  String get debugLog_bleCopied => 'Skopiowany log BLE';

  @override
  String get debugLog_noEntries => 'Nie ma jeszcze żadnych logów debugowania.';

  @override
  String get debugLog_enableInSettings =>
      'Włącz logowanie debugowania aplikacji w ustawieniach';

  @override
  String get debugLog_frames => 'Ramy';

  @override
  String get debugLog_rawLogRx => 'Surowe Log-RX';

  @override
  String get debugLog_noBleActivity => 'Brak aktywności BLE jeszcze.';

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
    return 'Długość ramy: $count bajtów';
  }

  @override
  String debugFrame_command(String value) {
    return 'Polecenie: 0x$value';
  }

  @override
  String get debugFrame_textMessageHeader => 'Wiadomość tekstowa:';

  @override
  String debugFrame_destinationPubKey(String pubKey) {
    return '- Oznaczenie PubKey: $pubKey';
  }

  @override
  String debugFrame_timestamp(int timestamp) {
    return '- Timestamp: $timestamp';
  }

  @override
  String debugFrame_flags(String value) {
    return '- Flagi: 0x$value';
  }

  @override
  String debugFrame_textType(int type, String label) {
    return '- Typ tekstu: $type ($label)';
  }

  @override
  String get debugFrame_textTypeCli => 'CLI';

  @override
  String get debugFrame_textTypePlain => 'Proste';

  @override
  String debugFrame_text(String text) {
    return '- Tekst: \"$text\"';
  }

  @override
  String get debugFrame_hexDump => 'Wyjście SzESZCZNULNE:';

  @override
  String get chat_pathManagement => 'Zarządzanie ścieżkami';

  @override
  String get chat_ShowAllPaths => 'Pokaż wszystkie ścieżki';

  @override
  String get chat_routingMode => 'Tryb routingu';

  @override
  String get chat_autoUseSavedPath => 'Automatyczne (użyj zapisanej ścieżki)';

  @override
  String get chat_forceFloodMode => 'Wymusz Tryb Powodowany';

  @override
  String get chat_recentAckPaths =>
      'Ostatnie ścieżki ACK (naciśnij, aby użyć):';

  @override
  String get chat_pathHistoryFull =>
      'Historia ścieżek jest pełna. Usuń wpisy, aby dodać nowe.';

  @override
  String get chat_hopSingular => 'Skacz';

  @override
  String get chat_hopPlural => 'skoczkowie';

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
  String get chat_successes => 'Sukcesy';

  @override
  String get chat_removePath => 'Usuń ścieżkę';

  @override
  String get chat_noPathHistoryYet =>
      'Brak jeszcze historii ścieżek.\nWyślij wiadomość, aby odkryć ścieżki.';

  @override
  String get chat_pathActions => 'Działania ścieżki:';

  @override
  String get chat_setCustomPath => 'Ustaw Ścieżkę Dostosowaną';

  @override
  String get chat_setCustomPathSubtitle => 'Ręcznie określ trasę.';

  @override
  String get chat_clearPath => 'Wyczyść Ścieżkę';

  @override
  String get chat_clearPathSubtitle =>
      'Zmusz do ponownej identyfikacji przy następnym wysłaniu';

  @override
  String get chat_pathCleared =>
      'Ścieżka oczyszczona. Kolejne powiadomienie odnajdzie trasę.';

  @override
  String get chat_floodModeSubtitle =>
      'Użyj przełącznika routingu w pasku narzędzi.';

  @override
  String get chat_floodModeEnabled =>
      'Tryb powodziowy włączony. Włącz ponownie za pomocą ikony routingu w pasku narzędzi.';

  @override
  String get chat_fullPath => 'Pełna ścieżka';

  @override
  String get chat_pathDetailsNotAvailable =>
      'Szczegóły ścieżki jeszcze niedostępne. Spróbuj wysłać wiadomość, aby odświeżyć.';

  @override
  String chat_pathSetHops(int hopCount, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      hopCount,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Ścieżka ustawiona: $hopCount $_temp0 - $status';
  }

  @override
  String get chat_pathSavedLocally =>
      'Zapisano lokalnie. Połącz się, aby zsynchronizować.';

  @override
  String get chat_pathDeviceConfirmed => 'Urządzenie potwierdzone.';

  @override
  String get chat_pathDeviceNotConfirmed =>
      'Urządzenie nie zostało jeszcze potwierdzone.';

  @override
  String get chat_type => 'Wprowadź';

  @override
  String get chat_path => 'Ścieżka';

  @override
  String get chat_publicKey => 'Klucz Publiczny';

  @override
  String get chat_compressOutgoingMessages => 'Kompresuj wychodzące wiadomości';

  @override
  String get chat_floodForced => 'Powodowana Powódź';

  @override
  String get chat_directForced => 'Bezpośrednio (wymuszono)';

  @override
  String chat_hopsForced(int count) {
    return '$count skoków (wymuszonych)';
  }

  @override
  String get chat_floodAuto => 'Powodzie (automatyczne)';

  @override
  String get chat_direct => 'Bezpośrednio';

  @override
  String get chat_poiShared => 'Wspólny POI';

  @override
  String chat_unread(int count) {
    return 'Niezgłoszone: $count';
  }

  @override
  String get chat_openLink => 'Otworzyć link?';

  @override
  String get chat_openLinkConfirmation =>
      'Czy chcesz otworzyć ten link w przeglądarce?';

  @override
  String get chat_open => 'Otwórz';

  @override
  String chat_couldNotOpenLink(String url) {
    return 'Nie można otworzyć linku: $url';
  }

  @override
  String get chat_invalidLink => 'Nieprawidłowy format linku';

  @override
  String get map_title => 'Mapa węzłów';

  @override
  String get map_lineOfSight => 'Linia wzroku';

  @override
  String get map_losScreenTitle => 'Linia wzroku';

  @override
  String get map_noNodesWithLocation => 'Brak węzłów z danymi lokalizacyjnymi';

  @override
  String get map_nodesNeedGps =>
      'Węzły muszą udostępniać swoje współrzędne GPS,\naby pojawić się na mapie.';

  @override
  String map_nodesCount(int count) {
    return 'Węzły: $count';
  }

  @override
  String map_pinsCount(int count) {
    return 'Pinki: $count';
  }

  @override
  String get map_chat => 'Rozmowa';

  @override
  String get map_repeater => 'Powtórzacz';

  @override
  String get map_room => 'Pokój';

  @override
  String get map_sensor => 'Czujnik';

  @override
  String get map_pinDm => 'Zablokuj (DM)';

  @override
  String get map_pinPrivate => 'Zablokuj (Prywatnie)';

  @override
  String get map_pinPublic => 'Oznacz jako publiczne';

  @override
  String get map_lastSeen => 'Ostatni raz widziany';

  @override
  String get map_disconnectConfirm =>
      'Czy na pewno chcesz się odłączyć od tego urządzenia?';

  @override
  String get map_from => 'Od';

  @override
  String get map_source => 'Źródło';

  @override
  String get map_flags => 'Flagi';

  @override
  String get map_pinLabel => 'Oznacz etykietę';

  @override
  String get map_label => 'Etykieta';

  @override
  String get map_publicLocationShare => 'Udostępnij lokalizację publicznie';

  @override
  String map_publicLocationShareConfirm(String channelLabel) {
    return 'Wkrótce udostępnisz lokalizację w $channelLabel. Ten kanał jest publiczny i każdy z PSK może go zobaczyć.';
  }

  @override
  String get map_connectToShareMarkers =>
      'Połącz się z urządzeniem, aby udostępniać znacznik.';

  @override
  String get map_filterNodes => 'Filtruj Węzły';

  @override
  String get map_nodeTypes => 'Typy węzłów';

  @override
  String get map_chatNodes => 'Węzły czatu';

  @override
  String get map_repeaters => 'Powtarzacze';

  @override
  String get map_otherNodes => 'Inne węzły';

  @override
  String get map_keyPrefix => 'Prefiks klucza';

  @override
  String get map_filterByKeyPrefix => 'Filtruj po prefiksie klucza';

  @override
  String get map_publicKeyPrefix => 'Przewód klucza publicznego';

  @override
  String get map_markers => 'Oznaczarki';

  @override
  String get map_showSharedMarkers => 'Pokaż współdzielone znaki.';

  @override
  String get map_lastSeenTime => 'Ostatni raz widiany';

  @override
  String get map_joinRoom => 'Dołącz do pokoju';

  @override
  String get map_manageRepeater => 'Zarządzaj Powtórzami';

  @override
  String get map_tapToAdd => 'Kliknij na węzły, aby dodać je do ścieżki.';

  @override
  String get map_runTrace => 'Uruchom ślad ścieżki';

  @override
  String get map_removeLast => 'Usuń ostatni';

  @override
  String get map_pathTraceCancelled => 'Śledzenie ścieżki anulowano.';

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
  String get mapCache_title => 'Bufor Map Offline';

  @override
  String get mapCache_selectAreaFirst =>
      'Wybierz obszar do wstępnego pobrania.';

  @override
  String get mapCache_noTilesToDownload =>
      'Brak dostępnych płytek do pobrania dla tego obszaru.';

  @override
  String get mapCache_downloadTilesTitle => 'Pobierz płytki';

  @override
  String mapCache_downloadTilesPrompt(int count) {
    return 'Pobierz $count płytek do użytku offline?';
  }

  @override
  String get mapCache_downloadAction => 'Pobierz';

  @override
  String mapCache_cachedTiles(int count) {
    return 'Pamiętanych $count płytek';
  }

  @override
  String mapCache_cachedTilesWithFailed(int downloaded, int failed) {
    return 'Pamiętane $downloaded płytki ($failed nieudane)';
  }

  @override
  String get mapCache_clearOfflineCacheTitle =>
      'Wyczyść pamięć podręczną offline';

  @override
  String get mapCache_clearOfflineCachePrompt =>
      'Usuń wszystkie tymczasowe kafelki mapy?';

  @override
  String get mapCache_offlineCacheCleared =>
      'Pamięć podręczna offline została wyczyszczona';

  @override
  String get mapCache_noAreaSelected => 'Nie zaznaczono żadnej powierzchni.';

  @override
  String get mapCache_cacheArea => 'Obszar pamięci podręcznej';

  @override
  String get mapCache_useCurrentView => 'Użyj aktualnego widoku';

  @override
  String get mapCache_zoomRange => 'Zakres powiększenia';

  @override
  String mapCache_estimatedTiles(int count) {
    return 'Szacunkowa liczba płytek: $count';
  }

  @override
  String mapCache_downloadedTiles(int completed, int total) {
    return 'Pobrano $completed / $total';
  }

  @override
  String get mapCache_downloadTilesButton => 'Pobierz Paski';

  @override
  String get mapCache_clearCacheButton => 'Wyczyść pamięć podręczną';

  @override
  String mapCache_failedDownloads(int count) {
    return 'Nieudane pobrania: $count';
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
  String get time_justNow => 'Właśnie teraz';

  @override
  String time_minutesAgo(int minutes) {
    return '$minutes minut temu';
  }

  @override
  String time_hoursAgo(int hours) {
    return '${hours}h temu';
  }

  @override
  String time_daysAgo(int days) {
    return '$days dni temu';
  }

  @override
  String get time_hour => 'godzina';

  @override
  String get time_hours => 'godziny';

  @override
  String get time_day => 'dzień';

  @override
  String get time_days => 'dni';

  @override
  String get time_week => 'tydzień';

  @override
  String get time_weeks => 'tygodnie';

  @override
  String get time_month => 'miesiąc';

  @override
  String get time_months => 'miesiace';

  @override
  String get time_minutes => 'minuty';

  @override
  String get time_allTime => 'Wszystko czasowo';

  @override
  String get dialog_disconnect => 'Odłącz';

  @override
  String get dialog_disconnectConfirm =>
      'Czy na pewno chcesz się odłączyć od tego urządzenia?';

  @override
  String get login_repeaterLogin => 'Powtórz Logowanie';

  @override
  String get login_roomLogin => 'Logowanie do pokoju';

  @override
  String get login_password => 'Hasło';

  @override
  String get login_enterPassword => 'Wprowadź hasło';

  @override
  String get login_savePassword => 'Zapisz hasło';

  @override
  String get login_savePasswordSubtitle =>
      'Hasło będzie bezpiecznie przechowywane na tym urządzeniu.';

  @override
  String get login_repeaterDescription =>
      'Wprowadź hasło do powtarzacza, aby uzyskać dostęp do ustawień i statusu.';

  @override
  String get login_roomDescription =>
      'Wprowadź hasło do pokoju, aby uzyskać dostęp do ustawień i statusu.';

  @override
  String get login_routing => 'Przekierowanie';

  @override
  String get login_routingMode => 'Tryb routingu';

  @override
  String get login_autoUseSavedPath => 'Automatycznie (użyj zapisanej ścieżki)';

  @override
  String get login_forceFloodMode => 'Wymusz Tryb Powodowany';

  @override
  String get login_managePaths => 'Zarządzaj Ścieżkami';

  @override
  String get login_login => 'Zaloguj się';

  @override
  String login_attempt(int current, int max) {
    return 'Próba $current/$max';
  }

  @override
  String login_failed(String error) {
    return 'Zalogowanie się nie powiodło: $error';
  }

  @override
  String get login_failedMessage =>
      'Logowanie nie powiodło się. Hasło jest nieprawidłowe albo repeater jest nieosiągalny.';

  @override
  String get common_reload => 'Ponownie załadować';

  @override
  String get common_clear => 'Wyczyść';

  @override
  String path_currentPath(String path) {
    return 'Aktualny ścieżka: $path';
  }

  @override
  String path_usingHopsPath(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Użyj ścieżki $count $_temp0.';
  }

  @override
  String get path_enterCustomPath => 'Wprowadź własną ścieżkę';

  @override
  String get path_currentPathLabel => 'Aktualny ścieżka';

  @override
  String get path_hexPrefixInstructions =>
      'Wprowadź 2-znakowe prefiksy szesnastkowe dla każdego skoku, oddzielone przecinkami.';

  @override
  String get path_hexPrefixExample =>
      'A1,F2,3C (każedy węzeł używa pierwszego bajtu swojego klucza publicznego)';

  @override
  String get path_labelHexPrefixes => 'Ścieżka (przesunięcia bitowe)';

  @override
  String get path_helperMaxHops =>
      'Maksymalnie 64 skoki. Każda prefiks ma 2 znaki szesnastkowe (1 bajt).';

  @override
  String get path_selectFromContacts => 'Albo wybierz z kontaktów:';

  @override
  String get path_noRepeatersFound =>
      'Nie znaleziono repeaterów ani serwerów pokoi.';

  @override
  String get path_customPathsRequire =>
      'Dostosowane ścieżki wymagają pośrednich skoków, które mogą przekazywać wiadomości.';

  @override
  String path_invalidHexPrefixes(String prefixes) {
    return 'Nieprawidłowe prefiksy szesnastkowe: $prefixes';
  }

  @override
  String get path_tooLong =>
      'Ścieżka jest zbyt długa. Dozwolonych skoków wynosi 64.';

  @override
  String get path_setPath => 'Ustaw Ścieżkę';

  @override
  String get repeater_management => 'Zarządzanie Powtórzami';

  @override
  String get room_management => 'Zarządzanie Serwerem Pokoju';

  @override
  String get repeater_managementTools => 'Narzędzia Zarządzania';

  @override
  String get repeater_status => 'Status';

  @override
  String get repeater_statusSubtitle =>
      'Wyświetl status powtarzacza, statystyki i sąsiadów.';

  @override
  String get repeater_sendAdvert => 'Send Advert';

  @override
  String get repeater_sendAdvertSubtitle =>
      'Broadcast an advertisement packet now';

  @override
  String get repeater_telemetry => 'Telemetry';

  @override
  String get repeater_telemetrySubtitle =>
      'Wyświetl dane telemetryczne z czujników i statystyki systemu';

  @override
  String get repeater_cli => 'CLI';

  @override
  String get repeater_cliSubtitle => 'Wyślij polecenia do powielacza';

  @override
  String get repeater_neighbors => 'Sąsiedzi';

  @override
  String get repeater_neighborsSubtitle =>
      'Wyświetl sąsiedztwo zerowych hopów.';

  @override
  String get repeater_settings => 'Ustawienia';

  @override
  String get repeater_settingsSubtitle => 'Skonfiguruj parametry powtarzacza';

  @override
  String get repeater_statusTitle => 'Status powtarzacza';

  @override
  String get repeater_routingMode => 'Tryb routingu';

  @override
  String get repeater_autoUseSavedPath =>
      'Automatycznie (użyj zapisanej ścieżki)';

  @override
  String get repeater_forceFloodMode => 'Wymusz Tryb Powodowany';

  @override
  String get repeater_pathManagement => 'Zarządzanie ścieżkami';

  @override
  String get repeater_refresh => 'Odśwież';

  @override
  String get repeater_statusRequestTimeout => 'Życzenie statusu timed out.';

  @override
  String repeater_errorLoadingStatus(String error) {
    return 'Błąd podczas ładowania statusu: $error';
  }

  @override
  String get repeater_systemInformation => 'Informacje o systemie';

  @override
  String get repeater_firmwareVersion => 'Firmware';

  @override
  String get repeater_battery => 'Bateria';

  @override
  String get repeater_clockAtLogin => 'Godzina (przy logowaniu)';

  @override
  String get repeater_uptime => 'Dostępność';

  @override
  String get repeater_queueLength => 'Długość kolejki';

  @override
  String get repeater_debugFlags => 'Opcje debugowania';

  @override
  String get repeater_radioStatistics => 'Statystyki Radia';

  @override
  String get repeater_lastRssi => 'Ostatni RSSI';

  @override
  String get repeater_lastSnr => 'Ostatnie SNR';

  @override
  String get repeater_noiseFloor => 'Poziom Szumów';

  @override
  String get repeater_txAirtime => 'TX Airtime';

  @override
  String get repeater_rxAirtime => 'RX Airtime';

  @override
  String get repeater_packetStatistics => 'Statystyki pakietów';

  @override
  String get repeater_sent => 'Wysłane';

  @override
  String get repeater_received => 'Otrzymano';

  @override
  String get repeater_duplicates => 'Powtórzenia';

  @override
  String repeater_daysHoursMinsSecs(
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return '$days dni ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  String repeater_packetTxTotal(int total, String flood, String direct) {
    return 'Razem: $total, Powodzenie: $flood, Bezpośrednio: $direct';
  }

  @override
  String repeater_packetRxTotal(int total, String flood, String direct) {
    return 'Razem: $total, Powodzenie: $flood, Bezpośrednio: $direct';
  }

  @override
  String repeater_duplicatesFloodDirect(String flood, String direct) {
    return 'Powodzie: $flood, Bezpośrednie: $direct';
  }

  @override
  String repeater_duplicatesTotal(int total) {
    return 'Razem: $total';
  }

  @override
  String get repeater_settingsTitle => 'Ustawienia Powtórki';

  @override
  String get repeater_basicSettings => 'Podstawowe Ustawienia';

  @override
  String get repeater_repeaterName => 'Nazwa Powtórnika';

  @override
  String get repeater_repeaterNameHelper => 'Wyświetl nazwę tego powtarzacza';

  @override
  String get repeater_adminPassword => 'Hasło Administracyjne';

  @override
  String get repeater_adminPasswordHelper => 'Pełny dostęp hasło';

  @override
  String get repeater_guestPassword => 'Hasło gościa';

  @override
  String get repeater_guestPasswordHelper => 'Dostęp tylko do odczytu hasło';

  @override
  String get repeater_radioSettings => 'Ustawienia radia';

  @override
  String get repeater_frequencyMhz => 'Częstotliwość (MHz)';

  @override
  String get repeater_frequencyHelper => '300-2500 MHz';

  @override
  String get repeater_txPower => 'TX Power';

  @override
  String get repeater_txPowerHelper => '1-30 dBm';

  @override
  String get repeater_bandwidth => 'Przepustowość';

  @override
  String get repeater_spreadingFactor => 'Rozkład Czynnika';

  @override
  String get repeater_codingRate => 'Stawka kodowania';

  @override
  String get repeater_locationSettings => 'Ustawienia Lokalizacji';

  @override
  String get repeater_latitude => 'Szerokość';

  @override
  String get repeater_latitudeHelper => 'Stopnie dziesiętne (np. 37.7749)';

  @override
  String get repeater_longitude => 'Długość';

  @override
  String get repeater_longitudeHelper => 'Stopnie dziesiętne (np. -122,4194)';

  @override
  String get repeater_features => 'Funkcje';

  @override
  String get repeater_packetForwarding => 'Przekierowanie pakietów';

  @override
  String get repeater_packetForwardingSubtitle =>
      'Włącz repeater, aby przekazywać pakiety.';

  @override
  String get repeater_guestAccess => 'Dostęp dla gości';

  @override
  String get repeater_guestAccessSubtitle =>
      'Umożliw dostęp tylko do odczytu dla gości.';

  @override
  String get repeater_privacyMode => 'Tryb Prywatności';

  @override
  String get repeater_privacyModeSubtitle =>
      'Ukryj imię/lokalizację w reklamach';

  @override
  String get repeater_advertisementSettings => 'Ustawienia Reklam';

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
  String get repeater_localAdvertInterval => 'Interwał Reklamy Lokalnej';

  @override
  String repeater_localAdvertIntervalMinutes(int minutes) {
    return '$minutes minut';
  }

  @override
  String get repeater_floodAdvertInterval => 'Interwał Reklamy Powodziowej';

  @override
  String repeater_floodAdvertIntervalHours(int hours) {
    return '$hours godzin';
  }

  @override
  String get repeater_encryptedAdvertInterval =>
      'Zaszyfrowany Interwał Reklamowy';

  @override
  String get repeater_dangerZone => 'Strefa Zagrożeń';

  @override
  String get repeater_rebootRepeater => 'Zrestartuj Powtarzacz';

  @override
  String get repeater_rebootRepeaterSubtitle =>
      'Zrestartuj urządzenie powtarzające.';

  @override
  String get repeater_rebootRepeaterConfirm =>
      'Czy na pewno chcesz zrestartować ten repeater?';

  @override
  String get repeater_regenerateIdentityKeySubtitle =>
      'Wygeneruj nową parę kluczy publicznych/prywatnych';

  @override
  String get repeater_regenerateIdentityKeyConfirm =>
      'To zostanie wygenerowane nowe tożsamość dla powtarzacza. Kontynuować?';

  @override
  String get repeater_eraseFileSystem => 'Wyczyść System Plików';

  @override
  String get repeater_eraseFileSystemSubtitle =>
      'Sformatuj system plików powielacza';

  @override
  String get repeater_eraseFileSystemConfirm =>
      'OSTRZEŻENIE: To spowoduje usunięcie wszystkich danych z powtarzacza. Nie da się tego cofnąć!';

  @override
  String get repeater_eraseSerialOnly =>
      'Usunięcie jest dostępne tylko przez konsolę szeregową.';

  @override
  String repeater_commandSent(String command) {
    return 'Polecenie wysłane: $command';
  }

  @override
  String repeater_errorSendingCommand(String error) {
    return 'Błąd podczas wysyłania polecenia: $error';
  }

  @override
  String get repeater_confirm => 'Potwierdź';

  @override
  String get repeater_settingsSaved => 'Ustawienia zostały pomyślnie zapisane.';

  @override
  String repeater_errorSavingSettings(String error) {
    return 'Błąd zapisu ustawień: $error';
  }

  @override
  String get repeater_refreshBasicSettings => 'Odśwież Podstawowe Ustawienia';

  @override
  String get repeater_refreshRadioSettings => 'Odśwież Ustawienia Radio';

  @override
  String get repeater_refreshTxPower => 'Odśwież TX power';

  @override
  String get repeater_refreshLocationSettings =>
      'Odśwież Ustawienia Lokalizacji';

  @override
  String get repeater_refreshPacketForwarding => 'Odśwież trasowanie pakietów';

  @override
  String get repeater_refreshGuestAccess => 'Odśwież dostęp gościa';

  @override
  String get repeater_refreshPrivacyMode => 'Odśwież Tryb Prywatności';

  @override
  String get repeater_refreshAdvertisementSettings =>
      'Odśwież Ustawienia Reklamy';

  @override
  String repeater_refreshed(String label) {
    return '$label odświeżone';
  }

  @override
  String repeater_errorRefreshing(String label) {
    return 'Błąd podczas odświeżania $label';
  }

  @override
  String get repeater_cliTitle => 'Powtarzacz CLI';

  @override
  String get repeater_debugNextCommand => 'Debug Następną Komendę';

  @override
  String get repeater_commandHelp => 'Pomoc';

  @override
  String get repeater_clearHistory => 'Wyczyść historię';

  @override
  String get repeater_noCommandsSent => 'Nie wysłano jeszcze żadnych poleceń';

  @override
  String get repeater_typeCommandOrUseQuick =>
      'Wprowadź polecenie poniżej lub użyj szybkich poleceń';

  @override
  String get repeater_enterCommandHint => 'Wprowadź polecenie...';

  @override
  String get repeater_previousCommand => 'Poprzednia komenda';

  @override
  String get repeater_nextCommand => 'Następna komenda';

  @override
  String get repeater_enterCommandFirst => 'Wprowadź najpierw polecenie';

  @override
  String get repeater_cliCommandFrameTitle => 'Określony Wyraz Polecenia CLI';

  @override
  String repeater_cliCommandError(String error) {
    return 'Błąd: $error';
  }

  @override
  String get repeater_cliQuickGetName => 'Pobierz imię';

  @override
  String get repeater_cliQuickGetRadio => 'Uzyskaj Radio';

  @override
  String get repeater_cliQuickGetTx => 'Pobierz TX';

  @override
  String get repeater_cliQuickNeighbors => 'Sąsiedzi';

  @override
  String get repeater_cliQuickVersion => 'Wersja';

  @override
  String get repeater_cliQuickAdvertise => 'Reklama';

  @override
  String get repeater_cliQuickClock => 'Godzina';

  @override
  String get repeater_cliHelpAdvert => 'Wysyła pakiet reklamowy';

  @override
  String get repeater_cliHelpReboot =>
      'Zresetuj urządzenie. (Uwaga, może pojawić się \'Timeout\', co jest normalne)';

  @override
  String get repeater_cliHelpClock =>
      'Wyświetla aktualny czas zgodnie z zegarem urządzenia.';

  @override
  String get repeater_cliHelpPassword =>
      'Ustawia nowe hasło administratora dla urządzenia.';

  @override
  String get repeater_cliHelpVersion =>
      'Wyświetla wersję urządzenia i datę budowy oprogramowania.';

  @override
  String get repeater_cliHelpClearStats =>
      'Resetuje różne wskaźniki statystyk do zera.';

  @override
  String get repeater_cliHelpSetAf => 'Ustawia czynnik czasu powietrznego.';

  @override
  String get repeater_cliHelpSetTx =>
      'Ustawia moc transmisji LoRa w dBm. (zrestartuj, aby zastosować)';

  @override
  String get repeater_cliHelpSetRepeat =>
      'Włącza lub wyłącza rolę powtarzacza dla tego węzła.';

  @override
  String get repeater_cliHelpSetAllowReadOnly =>
      '(Serwer pokoju) Jeśli \'włączone\', to logowanie z pustym hasłem będzie dozwolone, ale nie można publikować w pokoju (tylko czytać).';

  @override
  String get repeater_cliHelpSetFloodMax =>
      'Ustawia maksymalną liczbę skoków pakietu powrotnego (jeśli >= max, pakiet nie jest przekierowywany)';

  @override
  String get repeater_cliHelpSetIntThresh =>
      'Ustawia Próg Interferencji (w dB). Domyślnie wynosi 14. Ustaw na 0, aby wyłączyć wykrywanie zakłóceń kanału.';

  @override
  String get repeater_cliHelpSetAgcResetInterval =>
      'Ustawia interwał do zresetowania Automatycznego Sterownika Głośności. Ustaw na 0, aby wyłączyć.';

  @override
  String get repeater_cliHelpSetMultiAcks =>
      'Włącza lub wyłącza funkcję \'podwójnych potwierdzeń\'.';

  @override
  String get repeater_cliHelpSetAdvertInterval =>
      'Ustawia interwał timera w minutach do wysyłania pakietu reklamy lokalnej (bezpośredniej). Ustaw na 0, aby wyłączyć.';

  @override
  String get repeater_cliHelpSetFloodAdvertInterval =>
      'Ustawia interwał timera w godzinach do wysłania pakietu reklamowego typu \"powiew\". Ustaw na 0, aby wyłączyć.';

  @override
  String get repeater_cliHelpGetPathHashMode =>
      'Returns advert path hash mode (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetPathHashMode =>
      'Sets advert path hash mode for this repeater (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetGuestPassword =>
      'Ustawia/aktualizuje hasło gościa. (dla repeaterów, loginy gości mogą wysyłać żądanie \"Get Stats\")';

  @override
  String get repeater_cliHelpSetName => 'Ustawia nazwę reklamy.';

  @override
  String get repeater_cliHelpSetLat =>
      'Ustawia współrzędną geograficzne (w stopniach dziesiętnych) mapy reklam.';

  @override
  String get repeater_cliHelpSetLon =>
      'Ustawia współrzędną długościową mapy reklamy. (stopnie dziesiętne)';

  @override
  String get repeater_cliHelpSetRadio =>
      'Ustawia nowe parametry radia i zapisuje je w preferencjach. Wymaga polecenia \"reboot\" do zastosowania.';

  @override
  String get repeater_cliHelpSetRxDelay =>
      'Ustawienia (eksperymentalne) bazowe (muszą być > 1, aby działać) do stosowania lekkiego opóźnienia dla odebranych pakietów, w oparciu o siłę sygnału/wynik. Ustaw na 0, aby wyłączyć.';

  @override
  String get repeater_cliHelpSetTxDelay =>
      'Ustawia czynnik mnożony przez czas utrzymania w trybie zalewowym dla pakietu oraz z wykorzystaniem losowego systemu slotów, aby opóźnić jego przesyłanie (zmniejszając prawdopodobieństwo kolizji).';

  @override
  String get repeater_cliHelpSetDirectTxDelay =>
      'Taki sam jak txdelay, ale dla stosowania losowej opóźnienia przy przekazywaniu pakietów w trybie bezpośrednim.';

  @override
  String get repeater_cliHelpSetBridgeEnabled => 'Włącz/Wyłącz mostek.';

  @override
  String get repeater_cliHelpSetBridgeDelay =>
      'Ustaw czas opóźnienia przed ponownym wysyłaniem pakietów.';

  @override
  String get repeater_cliHelpSetBridgeSource =>
      'Wybierz, czy most będzie ponownie transmitował otrzymywane pakiety, czy też wysyłane.';

  @override
  String get repeater_cliHelpSetBridgeBaud =>
      'Ustaw prędkość transmisji magistrali szeregowej dla mostów rs232.';

  @override
  String get repeater_cliHelpSetBridgeSecret =>
      'Ustaw sekret dla mostów ESPNOW.';

  @override
  String get repeater_cliHelpSetAdcMultiplier =>
      'Ustawia niestandardowy współczynnik do korekty zgłaszanego napięcia baterii (obsługa tylko na wybranych płytach).';

  @override
  String get repeater_cliHelpTempRadio =>
      'Ustawia tymczasowe parametry radia na podany czas trwania w minutach, a następnie powraca do oryginalnych parametrów radia. (nie zapisuje zmian w preferencjach).';

  @override
  String get repeater_cliHelpSetPerm =>
      'Modyfikuje ACL. Usuwa dopasowaną wpis (z prefiksem pubkey), jeśli \"permissions\" wynosi zero. Dodaje nowy wpis, jeśli pubkey-hex ma pełną długość i nie znajduje się obecnie w ACL. Aktualizuje wpis, dopasowując prefiks pubkey. Bit uprawnień zależy od roli firmware, ale dolne 2 bity to: 0 (Gość), 1 (tylko odczyt), 2 (odczyt i zapis), 3 (administrator).';

  @override
  String get repeater_cliHelpGetBridgeType =>
      'Uzyskano typ mostu: brak, rs232, espnow';

  @override
  String get repeater_cliHelpLogStart =>
      'Rozpoczyna się logowanie pakietów do systemu plików.';

  @override
  String get repeater_cliHelpLogStop =>
      'Zatrzymuje logowanie pakietów do systemu plików.';

  @override
  String get repeater_cliHelpLogErase =>
      'Usuwa logi pakietów z systemu plików.';

  @override
  String get repeater_cliHelpNeighbors =>
      'Wyświetla listę innych węzłów powtarzających się, które usłyszano dzięki reklamom zero-hop. Każda linia to: id-prefix-hex:timestamp:snr-times-4';

  @override
  String get repeater_cliHelpNeighborRemove =>
      'Usuwa pierwszy pasujący wpis (z prefiksem pubkey (hex)) z listy sąsiadów.';

  @override
  String get repeater_cliHelpRegion =>
      '(tylko seria) Wyświetla wszystkie zdefiniowane regiony i aktualne uprawnienia do powodzi.';

  @override
  String get repeater_cliHelpRegionLoad =>
      'ZAPOMNIJ: to jest specjalne wywołanie wielokomendowe. Każda następna komenda jest nazwą regionu (wcięta spacjami, aby wskazywać hierarchię nadrzędną, z minimum jedną spacją). Zakończona wysłaniem pustej linii/komendy.';

  @override
  String get repeater_cliHelpRegionGet =>
      'Wyszukuje region o podanej nazwie prefiksu (lub \"\" dla zakresu globalnego). Odpowiada \"-> region-name (parent-name) \'F\'\"';

  @override
  String get repeater_cliHelpRegionPut =>
      'Dodaje lub aktualizuje definicję regionu z podaną nazwą.';

  @override
  String get repeater_cliHelpRegionRemove =>
      'Usuwa definicję regionu o podanej nazwie. (musi się dokładnie zgadzać i nie może mieć podregionów).';

  @override
  String get repeater_cliHelpRegionAllowf =>
      'Ustawia uprawnienia \'P\'łytkowe dla podanego regionu. (\'\' dla zakresu globalnego/starszego)';

  @override
  String get repeater_cliHelpRegionDenyf =>
      'Usuwa uprawnienie \'Pływające\' dla podanej strefy. (ZALECANE: na tym etapie NIE zaleca się używania tego na globalnym/starszym zakresie!!).';

  @override
  String get repeater_cliHelpRegionHome =>
      'Odpowiada z aktualnej \'home\' region. (Uwaga: nie zostało jeszcze zastosowane, zarezerwowane na przyszłość).';

  @override
  String get repeater_cliHelpRegionHomeSet => 'Ustawia region \'domowe\'.';

  @override
  String get repeater_cliHelpRegionSave =>
      'Zapisuje listę/mapę regionów do pamięci.';

  @override
  String get repeater_cliHelpGps =>
      'Wyświetla status GPS. Jeśli GPS jest wyłączony, odpowiada tylko \"off\", jeśli jest włączony, odpowiada z \"on\", \"status\", \"fix\", liczbą satelitów.';

  @override
  String get repeater_cliHelpGpsOnOff => 'Włącza/wyłącza nawigację GPS.';

  @override
  String get repeater_cliHelpGpsSync =>
      'Synchronizuje czas węzła z zegarem GPS.';

  @override
  String get repeater_cliHelpGpsSetLoc =>
      'Ustawia pozycję węzła na współrzędne GPS i zapisuje preferencje.';

  @override
  String get repeater_cliHelpGpsAdvert =>
      'Udostępnia konfigurację reklamy lokalizacji węzła:\n- brak: nie uwzględniaj lokalizacji w reklamach\n- udostępnia: udostępnia lokalizację GPS (z SensorManager)\n- ustawienia: reklamuj lokalizację przechowywaną w ustawieniach';

  @override
  String get repeater_cliHelpGpsAdvertSet =>
      'Ustawia konfigurację reklamy w lokalizacji.';

  @override
  String get repeater_commandsListTitle => 'Lista poleceń';

  @override
  String get repeater_commandsListNote =>
      'ZAPAMIĘTAJ: dla różnych poleceń \"set ...\" istnieje również polecenie \"get ...\".';

  @override
  String get repeater_general => 'Ogólne';

  @override
  String get repeater_settingsCategory => 'Ustawienia';

  @override
  String get repeater_bridge => 'Most';

  @override
  String get repeater_logging => 'Rejestrowanie';

  @override
  String get repeater_neighborsRepeaterOnly => 'Sąsiedzi (tylko powtarzacz)';

  @override
  String get repeater_regionManagementRepeaterOnly =>
      'Zarządzanie Regionem (tylko Powtarzacz)';

  @override
  String get repeater_regionNote =>
      'Wprowadzono komendy regionalne w celu zarządzania definicjami i uprawnieniami regionów.';

  @override
  String get repeater_gpsManagement => 'Zarządzanie GPS';

  @override
  String get repeater_gpsNote =>
      'Polecenie GPS zostało wprowadzone w celu zarządzania tematami związanymi z lokalizacją.';

  @override
  String get telemetry_receivedData => 'Otrzymano Dane Telemetrii';

  @override
  String get telemetry_requestTimeout =>
      'Życzenie o danych telemetrycznych nie udało się.';

  @override
  String telemetry_errorLoading(String error) {
    return 'Błąd podczas ładowania telemetry: $error';
  }

  @override
  String get telemetry_noData => 'Brak dostępnych danych telemetrycznych.';

  @override
  String telemetry_channelTitle(int channel) {
    return 'Kanał $channel';
  }

  @override
  String get telemetry_batteryLabel => 'Bateria';

  @override
  String get telemetry_voltageLabel => 'Napięcie';

  @override
  String get telemetry_mcuTemperatureLabel => 'Temperatura MCU';

  @override
  String get telemetry_temperatureLabel => 'Temperatura';

  @override
  String get telemetry_currentLabel => 'Obecny';

  @override
  String telemetry_batteryValue(int percent, String volts) {
    return '$percent% / ${volts}V';
  }

  @override
  String telemetry_voltageValue(String volts) {
    return '${volts}W';
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
  String get neighbors_receivedData => 'Otrzymano dane sąsiedztwa';

  @override
  String get neighbors_requestTimedOut =>
      'Sąsiedzi proszą o wyłączenie timingu.';

  @override
  String neighbors_errorLoading(String error) {
    return 'Błąd podczas ładowania sąsiadów: $error';
  }

  @override
  String get neighbors_repeatersNeighbors => 'Powtarzacze Sąsiedzi';

  @override
  String get neighbors_noData => 'Brak danych dotyczących sąsiadów.';

  @override
  String neighbors_unknownContact(String pubkey) {
    return 'Nieznana $pubkey';
  }

  @override
  String neighbors_heardAgo(String time) {
    return 'Usłyszano: $time temu';
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
  String get channelPath_title => 'Ścieżka pakietu';

  @override
  String get channelPath_viewMap => 'Wyświetl mapę';

  @override
  String get channelPath_otherObservedPaths => 'Inne Zauważone Ścieżki';

  @override
  String get channelPath_repeaterHops => 'Skoki Powtórki';

  @override
  String get channelPath_noHopDetails =>
      'Szczegóły dotyczące tego pakietu nie zostały podane.';

  @override
  String get channelPath_messageDetails => 'Szczegóły wiadomości';

  @override
  String get channelPath_senderLabel => 'Nadawca';

  @override
  String get channelPath_timeLabel => 'Czas';

  @override
  String get channelPath_repeatsLabel => 'Powtórzenia';

  @override
  String channelPath_pathLabel(int index) {
    return 'Ścieżka $index';
  }

  @override
  String get channelPath_observedLabel => 'Obserwowane';

  @override
  String channelPath_observedPathTitle(int index, String hops) {
    return 'Obserwowany ścieżka $index • $hops';
  }

  @override
  String get channelPath_noLocationData => 'Brak danych lokalizacyjnych';

  @override
  String channelPath_timeWithDate(int day, int month, String time) {
    return '$day/$month $time';
  }

  @override
  String channelPath_timeOnly(String time) {
    return '$time';
  }

  @override
  String get channelPath_unknownPath => 'Nieznane';

  @override
  String get channelPath_floodPath => 'Powodzenie';

  @override
  String get channelPath_directPath => 'Bezpośrednio';

  @override
  String channelPath_observedZeroOf(int total) {
    return '0 z $total skoków';
  }

  @override
  String channelPath_observedSomeOf(int observed, int total) {
    return '$observed z $total skoków';
  }

  @override
  String get channelPath_mapTitle => 'Mapa ścieżek';

  @override
  String get channelPath_noRepeaterLocations =>
      'Brak dostępnych lokalizacji powtarzaczy dla tego ścieżki.';

  @override
  String channelPath_primaryPath(int index) {
    return 'Ścieżka $index (Główna)';
  }

  @override
  String get channelPath_pathLabelTitle => 'Ścieżka';

  @override
  String get channelPath_observedPathHeader => 'Obserwowana ścieżka';

  @override
  String channelPath_selectedPathLabel(String label, String prefixes) {
    return '$label • $prefixes';
  }

  @override
  String get channelPath_noHopDetailsAvailable =>
      'Brak dostępnych szczegółów hopa dla tego pakietu.';

  @override
  String get channelPath_unknownRepeater => 'Nieznany Powtarzacz';

  @override
  String get community_title => 'Społeczność';

  @override
  String get community_create => 'Utwórz Społeczność';

  @override
  String get community_createDesc =>
      'Utwórz nową społeczność i udostępnij za pomocą kodu QR.';

  @override
  String get community_join => 'Dołącz';

  @override
  String get community_joinTitle => 'Dołącz do społeczności';

  @override
  String community_joinConfirmation(String name) {
    return 'Czy chcesz dołączyć do społeczności \"$name\"?';
  }

  @override
  String get community_scanQr => 'Skanuj QR kod społeczności';

  @override
  String get community_scanInstructions =>
      'Skieruj kamerę w kierunku kodu QR społeczności.';

  @override
  String get community_showQr => 'Pokaż kod QR';

  @override
  String get community_publicChannel => 'Społeczność Publiczna';

  @override
  String get community_hashtagChannel => 'Hashtag Społeczności';

  @override
  String get community_name => 'Nazwa Społeczności';

  @override
  String get community_enterName => 'Wprowadź nazwę społeczności';

  @override
  String community_created(String name) {
    return 'Społeczność \"$name\" została utworzona';
  }

  @override
  String community_joined(String name) {
    return 'Dołączył do społeczności \"$name\"';
  }

  @override
  String get community_qrTitle => 'Dziel się Społecznością';

  @override
  String community_qrInstructions(String name) {
    return 'Skanuj ten kod QR, aby dołączyć $name';
  }

  @override
  String get community_hashtagPrivacyHint =>
      'Kanały hashtagowe społeczności są dostępne tylko dla członków społeczności';

  @override
  String get community_invalidQrCode => 'Nieprawidłowy kod QR społeczności.';

  @override
  String get community_alreadyMember => 'Już jesteś członkiem.';

  @override
  String community_alreadyMemberMessage(String name) {
    return 'Jesteś już członkiem \"$name\".';
  }

  @override
  String get community_addPublicChannel => 'Dodaj Kanał Publiczny Społeczności';

  @override
  String get community_addPublicChannelHint =>
      'Automatycznie dodaj kanał publiczny dla tej społeczności.';

  @override
  String get community_noCommunities =>
      'Nie dołączono jeszcze żadnych społeczności.';

  @override
  String get community_scanOrCreate =>
      'Skanuj kod QR lub utwórz społeczność, aby zacząć.';

  @override
  String get community_manageCommunities => 'Zarządzaj Grupami';

  @override
  String get community_delete => 'Opuszczenie Społeczności';

  @override
  String community_deleteConfirm(String name) {
    return 'Opuścić \"$name\"?';
  }

  @override
  String community_deleteChannelsWarning(int count) {
    return 'Spowoduje to również usunięcie $count kanału/kanałów i ich wiadomości.';
  }

  @override
  String community_deleted(String name) {
    return 'Opuszczono społeczność \"$name\"';
  }

  @override
  String get community_regenerateSecret => 'Zregeneruj sekret';

  @override
  String community_regenerateSecretConfirm(String name) {
    return 'Regeneruj tajny klucz dla \"$name\"? Wszyscy członkowie będą musieli zeskanować nowy kod QR, aby kontynuować komunikację.';
  }

  @override
  String get community_regenerate => 'Zregeneruj';

  @override
  String community_secretRegenerated(String name) {
    return 'Hasło ponownie wygenerowane dla \"$name\"';
  }

  @override
  String get community_updateSecret => 'Zaktualizuj tajny klucz';

  @override
  String community_secretUpdated(String name) {
    return 'Hasło zaktualizowane dla \"$name\"';
  }

  @override
  String community_scanToUpdateSecret(String name) {
    return 'Skanuj nowy kod QR, aby zaktualizować sekret dla \"$name\"';
  }

  @override
  String get community_addHashtagChannel => 'Dodaj hashtag społeczności';

  @override
  String get community_addHashtagChannelDesc =>
      'Dodaj kanał z hashtagiem dla tej społeczności';

  @override
  String get community_selectCommunity => 'Wybierz społeczność';

  @override
  String get community_regularHashtag => 'Hashtag regular';

  @override
  String get community_regularHashtagDesc =>
      'Publiczny hashtag (każdy może dołączyć)';

  @override
  String get community_communityHashtag => 'Hashtag Społeczności';

  @override
  String get community_communityHashtagDesc =>
      'Dostępne tylko dla członków społeczności';

  @override
  String community_forCommunity(String name) {
    return 'Dla $name';
  }

  @override
  String get listFilter_tooltip => 'Filtruj i sortuj';

  @override
  String get listFilter_sortBy => 'Sortuj po';

  @override
  String get listFilter_latestMessages => 'Najnowsze wiadomości';

  @override
  String get listFilter_heardRecently => 'Słyszano niedawno';

  @override
  String get listFilter_az => 'A-Z';

  @override
  String get listFilter_filters => 'Filtry';

  @override
  String get listFilter_all => 'Wszystko';

  @override
  String get listFilter_users => 'Użytkownicy';

  @override
  String get listFilter_repeaters => 'Powtarzacze';

  @override
  String get listFilter_roomServers => 'Serwery pokoju';

  @override
  String get listFilter_unreadOnly => 'Tylko nieprzeczytane';

  @override
  String get listFilter_newGroup => 'Nowa grupa';

  @override
  String get pathTrace_you => 'Ty';

  @override
  String get pathTrace_failed => 'Śledzenie ścieżki nie powiodło się.';

  @override
  String get pathTrace_notAvailable => 'Ścieżka śledzenia niedostępna.';

  @override
  String get pathTrace_refreshTooltip => 'Odśwież ścieżkę.';

  @override
  String get pathTrace_someHopsNoLocation =>
      'Jeden lub więcej z chmieli nie ma określonej lokalizacji!';

  @override
  String get pathTrace_clearTooltip => 'Wyczyść ścieżkę';

  @override
  String get losSelectStartEnd => 'Wybierz węzły początkowe i końcowe dla LOS.';

  @override
  String losRunFailed(String error) {
    return 'Sprawdzenie pola widzenia nie powiodło się: $error';
  }

  @override
  String get losClearAllPoints => 'Wyczyść wszystkie punkty';

  @override
  String get losRunToViewElevationProfile =>
      'Uruchom LOS, aby wyświetlić profil wysokości';

  @override
  String get losMenuTitle => 'Menu LOS';

  @override
  String get losMenuSubtitle =>
      'Stuknij węzły lub naciśnij i przytrzymaj mapę, aby uzyskać niestandardowe punkty';

  @override
  String get losShowDisplayNodes => 'Pokaż węzły wyświetlające';

  @override
  String get losCustomPoints => 'Punkty niestandardowe';

  @override
  String losCustomPointLabel(int index) {
    return 'Niestandardowe $index';
  }

  @override
  String get losPointA => 'Punkt A';

  @override
  String get losPointB => 'Punkt B';

  @override
  String losAntennaA(String value, String unit) {
    return 'Antena A: $value $unit';
  }

  @override
  String losAntennaB(String value, String unit) {
    return 'Antena B: $value $unit';
  }

  @override
  String get losRun => 'Uruchom LOS-a';

  @override
  String get losNoElevationData => 'Brak danych o wysokości';

  @override
  String losProfileClear(
    String distance,
    String distanceUnit,
    String clearance,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, czysty LOS, minimalny prześwit $clearance $heightUnit';
  }

  @override
  String losProfileBlocked(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, zablokowane przez $obstruction $heightUnit';
  }

  @override
  String get losStatusChecking => 'LOS: sprawdzam...';

  @override
  String get losStatusNoData => 'LOS: brak danych';

  @override
  String losStatusSummary(int clear, int total, int blocked, int unknown) {
    return 'LOS: $clear/$total jasne, $blocked zablokowane, $unknown nieznane';
  }

  @override
  String get losErrorElevationUnavailable =>
      'Dane dotyczące wysokości są niedostępne dla jednej lub większej liczby próbek.';

  @override
  String get losErrorInvalidInput =>
      'Nieprawidłowe dane punktów/wysokości do obliczenia LOS.';

  @override
  String get losRenameCustomPoint => 'Zmień nazwę punktu niestandardowego';

  @override
  String get losPointName => 'Nazwa punktu';

  @override
  String get losShowPanelTooltip => 'Pokaż panel LOS';

  @override
  String get losHidePanelTooltip => 'Ukryj panel LOS';

  @override
  String get losElevationAttribution =>
      'Dane dotyczące wysokości: Open-Meteo (CC BY 4.0)';

  @override
  String get contacts_pathTrace => 'Śledzenie Ścieżek';

  @override
  String get contacts_ping => 'Pingować';

  @override
  String get contacts_repeaterPathTrace => 'Śledzenie ścieżki do repeatera';

  @override
  String get contacts_repeaterPing => 'Repeater pingowy';

  @override
  String get contacts_roomPathTrace =>
      'Śledzenie ścieżki do serwera pokojowego';

  @override
  String get contacts_roomPing => 'Pinguj serwer pokoju';

  @override
  String get contacts_chatTraceRoute => 'Śledź trasę promienia';

  @override
  String contacts_pathTraceTo(String name) {
    return 'Śledź trasę do $name';
  }

  @override
  String get contacts_clipboardEmpty => 'Schowek jest pusty.';

  @override
  String get contacts_invalidAdvertFormat => 'Nieprawidłowe dane kontaktowe';

  @override
  String get contacts_contactImported => 'Kontakt został zaimportowany.';

  @override
  String get contacts_contactImportFailed =>
      'Kontakt nie został zaimportowany.';

  @override
  String get contacts_zeroHopAdvert => 'Reklama Zero Hop';

  @override
  String get contacts_floodAdvert => 'Reklama powodziowa';

  @override
  String get contacts_copyAdvertToClipboard => 'Kopiuj ogłoszenie do schowka';

  @override
  String get contacts_addContactFromClipboard => 'Dodaj kontakt z schowka';

  @override
  String get contacts_ShareContact => 'Kopiuj kontakt do schowka';

  @override
  String get contacts_ShareContactZeroHop =>
      'Udostępnij kontakt przez ogłoszenie';

  @override
  String get contacts_zeroHopContactAdvertSent =>
      'Wysłano kontakt przez ogłoszenie.';

  @override
  String get contacts_zeroHopContactAdvertFailed =>
      'Nie udało się wysłać kontaktu.';

  @override
  String get contacts_contactAdvertCopied => 'Reklama skopiowana do schowka.';

  @override
  String get contacts_contactAdvertCopyFailed =>
      'Kopiowanie ogłoszenia do schowka nie powiodło się.';

  @override
  String get notification_activityTitle => 'Aktywność MeshCore';

  @override
  String notification_messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'wiadomości',
      many: 'wiadomości',
      few: 'wiadomości',
      one: 'wiadomość',
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
      other: 'wiadomości kanału',
      many: 'wiadomości kanału',
      few: 'wiadomości kanału',
      one: 'wiadomość kanału',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nowych węzłów',
      many: 'nowych węzłów',
      few: 'nowe węzły',
      one: 'nowy węzeł',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newTypeDiscovered(String contactType) {
    return 'Nowy $contactType wykryty';
  }

  @override
  String get notification_receivedNewMessage => 'Otrzymano nową wiadomość';

  @override
  String get settings_gpxExportRepeaters =>
      'Eksportuj powtórki / serwer pokojowy do GPX';

  @override
  String get settings_gpxExportRepeatersSubtitle =>
      'Eksportuje powtarzacze / roomserver z lokalizacją do pliku GPX.';

  @override
  String get settings_gpxExportContacts => 'Eksportuj towarzyszy do GPX';

  @override
  String get settings_gpxExportContactsSubtitle =>
      'Eksportuje towarzyszy z lokalizacją do pliku GPX.';

  @override
  String get settings_gpxExportAll => 'Eksportuj wszystkie kontakty do GPX';

  @override
  String get settings_gpxExportAllSubtitle =>
      'Eksportuje wszystkie kontakty z lokalizacją do pliku GPX.';

  @override
  String get settings_gpxExportSuccess => 'Pomyślnie wyeksportowano plik GPX.';

  @override
  String get settings_gpxExportNoContacts =>
      'Brak kontaktów do wyeksportowania.';

  @override
  String get settings_gpxExportNotAvailable =>
      'Nie obsługiwane na Twoim urządzeniu/systemie operacyjnym';

  @override
  String get settings_gpxExportError => 'Wystąpił błąd podczas eksportowania.';

  @override
  String get settings_gpxExportRepeatersRoom =>
      'Lokalizacje serwerów powtarzających i pomieszczeń';

  @override
  String get settings_gpxExportChat => 'Lokalizacje towarzyszy';

  @override
  String get settings_gpxExportAllContacts => 'Wszystkie lokalizacje kontaktów';

  @override
  String get settings_gpxExportShareText =>
      'Dane mapy wyeksportowane z Gulf Coast Mesh App';

  @override
  String get settings_gpxExportShareSubject =>
      'Eksport danych mapy GPX Gulf Coast Mesh App';

  @override
  String get snrIndicator_nearByRepeaters => 'Nadajniki w pobliżu';

  @override
  String get snrIndicator_lastSeen => 'Ostatnio widziany';

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
  String get repeater_regenerateIdentityKey => 'Wygeneruj klucz tożsamości';

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
  String get appSettings_nodeBlocking => 'Blokuj węzły';

  @override
  String get appSettings_nodeBlockingSubtitle =>
      'Ukrywaj wybrane węzły na mapie, w kontaktach i czatach oraz wyciszaj ich alerty. Tylko w aplikacji: nic nie jest usuwane z radia.';

  @override
  String get appSettings_blockedNodes => 'Zablokowane węzły';

  @override
  String appSettings_blockedNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count węzła',
      many: '$count zablokowanych węzłów',
      few: '$count zablokowane węzły',
      one: '1 zablokowany węzeł',
      zero: 'Brak zablokowanych',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_title => 'Zablokowane węzły';

  @override
  String get blockedNodes_howItWorks => 'Jak działa blokowanie';

  @override
  String get blockedNodes_infoHidden =>
      'Ukryte na mapie, w kontaktach i czatach';

  @override
  String get blockedNodes_infoMuted =>
      'Bez alertów o nowych węzłach i powiadomień o wiadomościach od nich';

  @override
  String get blockedNodes_infoKept =>
      'Nic nie zostaje usunięte. Węzły pozostają w radiu towarzyszącym, a ich wiadomości są zachowane';

  @override
  String get blockedNodes_infoRelay =>
      'Zablokowane repeatery nadal mogą przekazywać Twoje wiadomości w sieci mesh';

  @override
  String get blockedNodes_infoChannels =>
      'Ich wiadomości na kanałach nadal są widoczne';

  @override
  String get blockedNodes_emptyTitle => 'Brak zablokowanych węzłów';

  @override
  String get blockedNodes_emptyHint =>
      'Przytrzymaj węzeł w Kontaktach lub na Mapie i wybierz Zablokuj węzeł.';

  @override
  String get blockedNodes_unblock => 'Odblokuj';

  @override
  String get blockedNodes_unblockAll => 'Odblokuj wszystkie';

  @override
  String blockedNodes_unblockAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Odblokować $count węzła? Ponownie pojawią się na mapie i w kontaktach.',
      many:
          'Odblokować $count węzłów? Ponownie pojawią się na mapie i w kontaktach.',
      few:
          'Odblokować $count węzły? Ponownie pojawią się na mapie i w kontaktach.',
      one: 'Odblokować 1 węzeł? Ponownie pojawi się na mapie i w kontaktach.',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_unknownNode => 'Nieznany węzeł';

  @override
  String blockedNodes_blockedOn(String date) {
    return 'Zablokowano $date';
  }

  @override
  String get blockedNodes_blockAction => 'Zablokuj węzeł';

  @override
  String blockedNodes_blockConfirmTitle(String name) {
    return 'Zablokować $name?';
  }

  @override
  String get blockedNodes_blockConfirmBody =>
      'Zostanie ukryty na mapie, w kontaktach i czatach, a nie będziesz otrzymywać od niego alertów ani powiadomień o wiadomościach. Nic nie jest usuwane z radia. Możesz go odblokować w dowolnym momencie w Ustawienia aplikacji > Eksperymentalne > Zablokowane węzły.';

  @override
  String get blockedNodes_blockConfirmButton => 'Zablokuj';

  @override
  String blockedNodes_blocked(String name) {
    return 'Zablokowano: $name';
  }

  @override
  String blockedNodes_unblocked(String name) {
    return 'Odblokowano: $name';
  }

  @override
  String get blockedNodes_undo => 'Cofnij';
}
