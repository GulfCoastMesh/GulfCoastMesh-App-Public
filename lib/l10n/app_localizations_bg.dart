// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

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
  String get nav_contacts => 'Контакти';

  @override
  String get nav_channels => 'Канали';

  @override
  String get nav_map => 'Карта';

  @override
  String get nav_chats => 'Чатове';

  @override
  String get nav_nodes => 'Възли';

  @override
  String get nav_settings => 'Настройки';

  @override
  String get common_cancel => 'Отказ';

  @override
  String get common_ok => 'Добре';

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
  String get common_connect => 'Свържи се';

  @override
  String get common_unknownDevice => 'Неизвестно устройство';

  @override
  String get common_save => 'Запази';

  @override
  String get common_delete => 'Изтрий';

  @override
  String get common_close => 'Затвори';

  @override
  String get common_edit => 'Редактирай';

  @override
  String get common_add => 'Добави';

  @override
  String get common_settings => 'Настройки';

  @override
  String get common_disconnect => 'Прекъсни';

  @override
  String get common_connected => 'Свързано';

  @override
  String get common_disconnected => 'Откъснато';

  @override
  String get common_reconnecting => 'Reconnecting';

  @override
  String get common_create => 'Създай';

  @override
  String get common_continue => 'Продължи';

  @override
  String get common_share => 'Сподели';

  @override
  String get common_copy => 'Копирай';

  @override
  String get common_retry => 'Опитай отново';

  @override
  String get common_hide => 'Скриване';

  @override
  String get common_remove => 'Изтрий';

  @override
  String get common_enable => 'Активирай';

  @override
  String get common_disable => 'Деактивирай';

  @override
  String get common_reboot => 'Рестартирай';

  @override
  String get common_loading => 'Зареждане...';

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
  String get scanner_scanning => 'Сканиране за устройства...';

  @override
  String get scanner_connecting => 'Свързвам се...';

  @override
  String get scanner_disconnecting => 'Изключване...';

  @override
  String get scanner_notConnected => 'Не е свързан';

  @override
  String scanner_connectedTo(String deviceName) {
    return 'Свързано с $deviceName';
  }

  @override
  String get scanner_searchingDevices => 'Търсене на устройства MeshCore...';

  @override
  String get scanner_tapToScan =>
      'Натиснете Сканиране, за да намерите устройства MeshCore.';

  @override
  String scanner_connectionFailed(String error) {
    return 'Връзката не успя: $error';
  }

  @override
  String get scanner_backgroundBleMayDrop =>
      'Background BLE may drop without notification permission.';

  @override
  String get scanner_stop => 'Спрете';

  @override
  String get scanner_scan => 'Сканирай';

  @override
  String get scanner_bluetoothOff => 'Bluetooth е изключен.';

  @override
  String get scanner_bluetoothOffMessage =>
      'Моля, активирайте Bluetooth, за да сканирате за устройства.';

  @override
  String get scanner_enableBluetooth => 'Активирайте Bluetooth';

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
  String get device_quickSwitch => 'Бързо превключване';

  @override
  String get device_meshcore => 'MeshCore';

  @override
  String get settings_title => 'Настройки';

  @override
  String get settings_deviceInfo => 'Информация за устройството';

  @override
  String get settings_appSettings => 'Настройки на приложението';

  @override
  String get settings_appSettingsSubtitle =>
      'Уведомления, съобщения и предпочитания за карта';

  @override
  String get settings_nodeSettings => 'Настройки на възела';

  @override
  String get settings_nodeName => 'Име на възела';

  @override
  String get settings_nodeNameNotSet => 'Не е зададено';

  @override
  String get settings_nodeNameHint => 'Въведете име на възел';

  @override
  String get settings_nodeNameUpdated => 'Името е актуализирано';

  @override
  String get settings_radioSettings => 'Настройки на радиопредавателя';

  @override
  String get settings_radioSettingsSubtitle =>
      'Честота, мощност, разпространяващ фактор';

  @override
  String get settings_radioSettingsUpdated =>
      'Радио настройките са актуализирани';

  @override
  String get settings_location => 'Местоположение';

  @override
  String get settings_locationSubtitle => 'Координати на GPS';

  @override
  String get settings_locationUpdated => 'Местоположението е актуализирано';

  @override
  String get settings_locationBothRequired =>
      'Въведете както географска ширина, така и географска дължина.';

  @override
  String get settings_locationInvalid => 'Невалидна ширина или дължина.';

  @override
  String get settings_locationGPSEnable => 'Активиране на GPS';

  @override
  String get settings_locationGPSEnableSubtitle =>
      'Активирайте автоматичното актуализиране на местоположението чрез GPS.';

  @override
  String get settings_locationIntervalSec => 'Интервал за GPS (Секунди)';

  @override
  String get settings_usePhoneGps => 'Use phone GPS';

  @override
  String get settings_locationIntervalInvalid =>
      'Интервалът трябва да бъде поне 60 секунди и по-малко от 86400 секунди.';

  @override
  String get settings_latitude => 'Широчина';

  @override
  String get settings_longitude => 'Дължина';

  @override
  String get settings_privacyMode => 'Режим на поверителност';

  @override
  String get settings_privacyModeSubtitle =>
      'Скриване на име/местоположение в рекламите';

  @override
  String get settings_privacyModeToggle =>
      'Активирайте режим на поверителност, за да скриете името и местоположението си в рекламите.';

  @override
  String get settings_privacyModeEnabled =>
      'Режим на поверителност е активиран';

  @override
  String get settings_privacyModeDisabled =>
      'Режим на поверителност е деактивиран';

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
  String get settings_actions => 'Действия';

  @override
  String get settings_sendAdvertisement => 'Изпрати Реклама';

  @override
  String get settings_sendAdvertisementSubtitle => 'Сега присъствие в ефир';

  @override
  String get settings_advertisementSent => 'Реклама изпратена';

  @override
  String get settings_syncTime => 'Време за синхронизация';

  @override
  String get settings_syncTimeSubtitle =>
      'Задайте часовника на устройството да отговаря на времето на телефона.';

  @override
  String get settings_timeSynchronized => 'Синхронизирано във времето';

  @override
  String get settings_refreshContacts => 'Презареди контакти';

  @override
  String get settings_refreshContactsSubtitle =>
      'Презареди списъка с контакти от устройството';

  @override
  String get settings_rebootDevice => 'Рестартирайте устройството';

  @override
  String get settings_rebootDeviceSubtitle =>
      'Рестартирайте устройството MeshCore';

  @override
  String get settings_rebootDeviceConfirm =>
      'Сигурни ли сте, че искате да рестартирате устройството? Ще бъдете откъснати.';

  @override
  String get settings_debug => 'Отстрани';

  @override
  String get settings_bleDebugLog => 'Лог за отстраняване на грешки на BLE';

  @override
  String get settings_bleDebugLogSubtitle =>
      'Команди, отговори и сурови данни BLE';

  @override
  String get settings_appDebugLog =>
      'Лог на отстраняване на грешки на приложението';

  @override
  String get settings_appDebugLogSubtitle =>
      'Съобщения за отстраняване на грешки на приложението';

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
  String get settings_about => 'За нас';

  @override
  String settings_aboutVersion(String version) {
    return 'Gulf Coast Mesh App v$version';
  }

  @override
  String get settings_aboutLegalese => 'Gulf Coast Mesh App 2024';

  @override
  String get settings_aboutDescription =>
      'Отворен софтуер за Flutter клиент за MeshCore LoRa мрежови устройства.';

  @override
  String get settings_aboutOpenMeteoAttribution =>
      'Данни за надморска височина на LOS: Open-Meteo (CC BY 4.0)';

  @override
  String get settings_infoName => 'Име';

  @override
  String get settings_infoId => 'ИД';

  @override
  String get settings_infoStatus => 'Статус';

  @override
  String get settings_infoBattery => 'Батерия';

  @override
  String get settings_infoPublicKey => 'Общ публичен ключ';

  @override
  String get settings_infoContactsCount => 'Брой контакти';

  @override
  String get settings_infoChannelCount => 'Брой канали';

  @override
  String get settings_presets => 'Предварителни настройки';

  @override
  String get settings_frequency => 'Честота (MHz)';

  @override
  String get settings_frequencyHelper => '300.0 - 2500.0';

  @override
  String get settings_frequencyInvalid => 'Невалидна честота (300-2500 MHz)';

  @override
  String get settings_bandwidth => 'Ширина на честотния спектър';

  @override
  String get settings_spreadingFactor => 'Фактор на разпространение';

  @override
  String get settings_codingRate => 'Такса за кодиране';

  @override
  String get settings_txPower => 'TX Мощност (dBm)';

  @override
  String get settings_txPowerHelper => '0 - 22';

  @override
  String get settings_txPowerInvalid => 'Невалидна мощност на TX (0-22 dBm)';

  @override
  String get settings_clientRepeat => 'Без електричество – повторение';

  @override
  String get settings_clientRepeatSubtitle =>
      'Позволете на това устройство да предава пакети към мрежата за други устройства.';

  @override
  String get settings_clientRepeatFreqWarning =>
      'За повторение извън мрежата са необходими честоти от 433, 869 или 918 MHz.';

  @override
  String settings_error(String message) {
    return 'Грешка: $message';
  }

  @override
  String get appSettings_title => 'Настройки на приложението';

  @override
  String get appSettings_appearance => 'Външен вид';

  @override
  String get appSettings_theme => 'Тема';

  @override
  String get appSettings_themeSystem => 'Система по подразбиране';

  @override
  String get appSettings_themeLight => 'Ярка';

  @override
  String get appSettings_themeDark => 'Тъмно';

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
  String get appSettings_language => 'Език';

  @override
  String get appSettings_languageSystem => 'Система по подразбиране';

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
  String get appSettings_languageRu => 'Руски';

  @override
  String get appSettings_languageUk => 'Украински';

  @override
  String get appSettings_enableMessageTracing =>
      'Разрешаване на проследяване на съобщения';

  @override
  String get appSettings_enableMessageTracingSubtitle =>
      'Показване на подробни метаданни за маршрутизация и синхронизация за съобщения';

  @override
  String get appSettings_notifications => 'Уведомления';

  @override
  String get appSettings_enableNotifications => 'Активирай Известия';

  @override
  String get appSettings_enableNotificationsSubtitle =>
      'Получете известия за съобщения и реклами';

  @override
  String get appSettings_notificationPermissionDenied =>
      'Отказвано е разрешение за известия';

  @override
  String get appSettings_notificationsEnabled => 'Уведомителни са активирани';

  @override
  String get appSettings_notificationsDisabled => 'Известия са изключени';

  @override
  String get appSettings_messageNotifications => 'Уведомления';

  @override
  String get appSettings_messageNotificationsSubtitle =>
      'Покажи известие при получаване на нови съобщения';

  @override
  String get appSettings_channelMessageNotifications =>
      'Уведомления за съобщения от канал';

  @override
  String get appSettings_channelMessageNotificationsSubtitle =>
      'Покажи известие при получаване на съобщения от канали';

  @override
  String get appSettings_advertisementNotifications => 'Уведомления за реклами';

  @override
  String get appSettings_advertisementNotificationsSubtitle =>
      'Покажи известие, когато бъдат открити нови възли.';

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
  String get appSettings_messaging => 'Съобщения';

  @override
  String get appSettings_clearPathOnMaxRetry => 'Изчисти Път на Макс Опит';

  @override
  String get appSettings_clearPathOnMaxRetrySubtitle =>
      'Възстанови контактния път след 5 неуспешни опита за изпращане';

  @override
  String get appSettings_pathsWillBeCleared =>
      'Пътищата ще бъдат почистени след 5 неуспешни опита.';

  @override
  String get appSettings_pathsWillNotBeCleared =>
      'Пътищата няма да бъдат автоматично изчистени.';

  @override
  String get appSettings_autoRouteRotation =>
      'Автоматично маршрутизиране на завъртания';

  @override
  String get appSettings_autoRouteRotationSubtitle =>
      'Превключете между най-добрите пътища и режим на наводняване';

  @override
  String get appSettings_autoRouteRotationEnabled =>
      'Автоматично маршрутизиране вкл.';

  @override
  String get appSettings_autoRouteRotationDisabled =>
      'Автоматично маршрутизирането е деактивирано';

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
  String get appSettings_battery => 'Батерия';

  @override
  String get appSettings_batteryChemistry => 'Химия на батерията';

  @override
  String appSettings_batteryChemistryPerDevice(String deviceName) {
    return 'Зададено за устройство ($deviceName)';
  }

  @override
  String get appSettings_batteryChemistryConnectFirst =>
      'Свържете се с устройство, за да изберете.';

  @override
  String get appSettings_batteryNmc => '18650 NMC (3.0-4.2V)';

  @override
  String get appSettings_batteryLifepo4 => 'Литиево желязо фосфат (2.6-3.65V)';

  @override
  String get appSettings_batteryLipo => 'Литиев полимер (3.0-4.2V)';

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
  String get appSettings_mapDisplay => 'Карта за показване';

  @override
  String get appSettings_showRepeaters => 'Показване на повторители';

  @override
  String get appSettings_showRepeatersSubtitle =>
      'Показване на възпроизвеждащи се възли на картата';

  @override
  String get appSettings_showChatNodes => 'Покажи Възли на Чат';

  @override
  String get appSettings_showChatNodesSubtitle =>
      'Показване на чат възли на картата';

  @override
  String get appSettings_showOtherNodes => 'Покажи други възли';

  @override
  String get appSettings_showOtherNodesSubtitle =>
      'Покажи други типове възли на картата';

  @override
  String get appSettings_timeFilter => 'Филтриране по време';

  @override
  String get appSettings_timeFilterShowAll => 'Покажи всички възли';

  @override
  String appSettings_timeFilterShowLast(int hours) {
    return 'Покажи възли от последните $hours часа';
  }

  @override
  String get appSettings_mapTimeFilter => 'Филтри за време на картата';

  @override
  String get appSettings_showNodesDiscoveredWithin =>
      'Покажи възлите, открити в:';

  @override
  String get appSettings_allTime => 'Всичко време';

  @override
  String get appSettings_lastHour => 'Последната минута';

  @override
  String get appSettings_last6Hours => 'Последни 6 часа';

  @override
  String get appSettings_last24Hours => 'Последно 24 часа';

  @override
  String get appSettings_lastWeek => 'Миналата седмица';

  @override
  String get appSettings_offlineMapCache => 'Кеш на офлайн карти';

  @override
  String get appSettings_unitsTitle => 'единици';

  @override
  String get appSettings_unitsMetric => 'Метрика (m / km)';

  @override
  String get appSettings_unitsImperial => 'Имперска (ft / mi)';

  @override
  String get appSettings_noAreaSelected => 'Няма избрана област';

  @override
  String appSettings_areaSelectedZoom(int minZoom, int maxZoom) {
    return 'Избрана е област (мащаб $minZoom-$maxZoom)';
  }

  @override
  String get appSettings_debugCard => 'Отстрани';

  @override
  String get appSettings_appDebugLogging =>
      'Логване за отстраняване на грешки на приложението';

  @override
  String get appSettings_appDebugLoggingSubtitle =>
      'Записване на съобщения за отстраняване на грешки от приложението за отстраняване на грешки.';

  @override
  String get appSettings_appDebugLoggingEnabled =>
      'Режимът за отстраняване на грешки в приложението е активиран.';

  @override
  String get appSettings_appDebugLoggingDisabled =>
      'Логването за отстраняване на грешки в приложението е изключено.';

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
  String get contacts_title => 'Контакти';

  @override
  String get contacts_noContacts => 'Няма контакти към момента.';

  @override
  String get contacts_contactsWillAppear =>
      'Контактите ще се появят, когато устройствата рекламират.';

  @override
  String get contacts_searchContacts => 'Търсене на контакти...';

  @override
  String get contacts_noUnreadContacts => 'Няма непрочетени контакти';

  @override
  String get contacts_noContactsFound => 'Няма намерени контакти или групи.';

  @override
  String get contacts_deleteContact => 'Изтрий Контакт';

  @override
  String contacts_removeConfirm(String contactName) {
    return 'Изтрий $contactName от контактите?';
  }

  @override
  String get contacts_manageRepeater => 'Управление на Повтарящ се Елемент';

  @override
  String get contacts_manageRoom => 'Управление на сървър за стая';

  @override
  String get contacts_roomLogin => 'Вход в стаята';

  @override
  String get contacts_openChat => 'Отвори чат';

  @override
  String get contacts_editGroup => 'Редактирай Група';

  @override
  String get contacts_deleteGroup => 'Изтрий група';

  @override
  String contacts_deleteGroupConfirm(String groupName) {
    return 'Премахнете \"$groupName\"?';
  }

  @override
  String get contacts_newGroup => 'Нова група';

  @override
  String get contacts_groupName => 'Група';

  @override
  String get contacts_groupNameRequired => 'Името на групата е задължително.';

  @override
  String contacts_groupAlreadyExists(String name) {
    return 'Групата \"$name\" вече съществува.';
  }

  @override
  String get contacts_filterContacts => 'Филтрирайте контактите...';

  @override
  String get contacts_noContactsMatchFilter =>
      'Няма съвпадения с вашия филтър.';

  @override
  String get contacts_noMembers => 'Няма членове';

  @override
  String get contacts_lastSeenNow => 'Последно видяно сега';

  @override
  String contacts_lastSeenMinsAgo(int minutes) {
    return 'Последна активност $minutes минути преди';
  }

  @override
  String get contacts_lastSeenHourAgo => 'Последно видяно преди час';

  @override
  String contacts_lastSeenHoursAgo(int hours) {
    return 'Последно видян $hours часа преди.';
  }

  @override
  String get contacts_lastSeenDayAgo => 'Последно видяно преди 1 ден';

  @override
  String contacts_lastSeenDaysAgo(int days) {
    return 'Последно видян $days дни преди.';
  }

  @override
  String get channels_title => 'Канали';

  @override
  String get channels_noChannelsConfigured => 'Няма конфигурирани канали';

  @override
  String get channels_addPublicChannel => 'Добави публичен канал';

  @override
  String get channels_searchChannels => 'Търсене на канали...';

  @override
  String get channels_noChannelsFound => 'Няма намерени канали';

  @override
  String get channels_channelSlotsFull =>
      'All device channel slots are in use. Delete a channel before adding another.';

  @override
  String channels_channelAddFailed(String error) {
    return 'Could not add channel: $error';
  }

  @override
  String channels_channelIndex(int index) {
    return 'Канал $index';
  }

  @override
  String get channels_hashtagChannel => 'Канал с хаштаг';

  @override
  String get channels_public => 'Публично';

  @override
  String get channels_private => 'Личен';

  @override
  String get channels_publicChannel => 'Публичен канал';

  @override
  String get channels_privateChannel => 'Частен канал';

  @override
  String get channels_editChannel => 'Редактирай канал';

  @override
  String get channels_deleteChannel => 'Изтрий канала';

  @override
  String channels_deleteChannelConfirm(String name) {
    return 'Изтрий \"$name\"? Това не може да бъде отменено.';
  }

  @override
  String get channels_deleteChannelRequiresConnection =>
      'Connect to a device to delete a channel';

  @override
  String channels_channelDeleted(String name) {
    return 'Каналът \"$name\" е изтрит';
  }

  @override
  String get channels_addChannel => 'Добави Канал';

  @override
  String get channels_channelIndexLabel => 'Индекс на канал';

  @override
  String get channels_channelName => 'Име на канала';

  @override
  String get channels_usePublicChannel => 'Използвайте публичен канал';

  @override
  String get channels_standardPublicPsk => 'Стандартен публичен PSK';

  @override
  String get channels_pskHex => 'PSK (Hex)';

  @override
  String get channels_generateRandomPsk => 'Генерирай случайна PSK';

  @override
  String get channels_enterChannelName => 'Моля, въведете име на канал.';

  @override
  String get channels_pskMustBe32Hex =>
      'PSK трябва да бъде 32 шестнаредни знака.';

  @override
  String channels_channelAdded(String name) {
    return 'Каналът \"$name\" е добавен';
  }

  @override
  String channels_editChannelTitle(int index) {
    return 'Редактирай Канал $index';
  }

  @override
  String get channels_smazCompression => 'Компресия SMAZ';

  @override
  String channels_channelUpdated(String name) {
    return 'Каналът \"$name\" е актуализиран';
  }

  @override
  String get channels_publicChannelAdded => 'Публичен канал добавен';

  @override
  String get channels_sortBy => 'Сортирай по';

  @override
  String get channels_sortManual => 'Ръчно';

  @override
  String get channels_sortAZ => 'A-Z';

  @override
  String get channels_sortLatestMessages => 'Последни съобщения';

  @override
  String get channels_sortUnread => 'Непрочетено';

  @override
  String get channels_createPrivateChannel => 'Създай Частен Канал';

  @override
  String get channels_createPrivateChannelDesc => 'Защитено с таен ключ.';

  @override
  String get channels_joinPrivateChannel => 'Присъедини се към Частен Канал';

  @override
  String get channels_joinPrivateChannelDesc => 'Ръчно въведете таен ключ.';

  @override
  String get channels_joinPublicChannel =>
      'Присъединете се към Публичния канал';

  @override
  String get channels_joinPublicChannelDesc =>
      'Всеки може да се присъедини към този канал.';

  @override
  String get channels_joinHashtagChannel => 'Присъедини се към Хаштаг Канал';

  @override
  String get channels_joinHashtagChannelDesc =>
      'Всеки може да се присъедини към хаштаговите канали.';

  @override
  String get channels_scanQrCode => 'Сканирайте QR код';

  @override
  String get channels_scanQrCodeDesc =>
      'Import a channel invite with name, key, and optional region.';

  @override
  String get channels_scanQrCodeComingSoon => 'Ще излезе скоро';

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
  String get channels_enterHashtag => 'Въведете хаштаг';

  @override
  String get channels_hashtagHint => 'напр. #отбор';

  @override
  String get chat_noMessages => 'Няма съобщения.';

  @override
  String get chat_sendMessageToStart => 'Изпрати съобщение, за да започнеш.';

  @override
  String get chat_originalMessageNotFound => 'Съобщението не е намерено';

  @override
  String chat_replyingTo(String name) {
    return 'Отговарям на $name';
  }

  @override
  String chat_replyTo(String name) {
    return 'Отговори на $name';
  }

  @override
  String get chat_location => 'Местоположение';

  @override
  String chat_sendMessageTo(String contactName) {
    return 'Изпрати съобщение на $contactName';
  }

  @override
  String get chat_typeMessage => 'Въведете съобщение...';

  @override
  String chat_messageTooLong(int maxBytes) {
    return 'Съобщението е твърде дълго (макс $maxBytes байта).';
  }

  @override
  String get chat_messageCopied => 'Съобщението е копирано';

  @override
  String get chat_messageDeleted => 'Съобщението е изтрито';

  @override
  String get chat_retryingMessage => 'Опитваме се отново.';

  @override
  String chat_retryCount(int current, int max) {
    return 'Опитай отново $current/$max';
  }

  @override
  String get chat_sendGif => 'Изпрати GIF';

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
  String get chat_reply => 'Отговори';

  @override
  String get chat_addReaction => 'Добави Реакция';

  @override
  String get chat_editMessage => 'Edit message';

  @override
  String get chat_editedLabel => '(edited)';

  @override
  String get chat_messageEdited => 'Message edited';

  @override
  String get chat_me => 'Аз';

  @override
  String get emojiCategorySmileys => 'Емотикони';

  @override
  String get emojiCategoryGestures => 'Жестове';

  @override
  String get emojiCategoryHearts => 'Сърца';

  @override
  String get emojiCategoryObjects => 'Обекти';

  @override
  String get gifPicker_title => 'Изберете GIF';

  @override
  String get gifPicker_searchHint => 'Търсене на GIF-ове...';

  @override
  String get gifPicker_poweredBy => 'Задвижвано от GIPHY';

  @override
  String get gifPicker_noGifsFound => 'Няма намерени GIF файлове.';

  @override
  String get gifPicker_failedLoad => 'Не можа да се заредят GIF файловете';

  @override
  String get gifPicker_failedSearch => 'Неуспешно търсене на GIF-ове';

  @override
  String get gifPicker_noInternet => 'Няма интернет връзка';

  @override
  String get debugLog_appTitle =>
      'Лог на отстраняване на грешки на приложението';

  @override
  String get debugLog_bleTitle => 'Лог за отстраняване на грешки на BLE';

  @override
  String get debugLog_copyLog => 'Копирай лог';

  @override
  String get debugLog_clearLog => 'Изчисти логовете';

  @override
  String get debugLog_copied => 'Копирано лого за отстраняване на грешки';

  @override
  String get debugLog_bleCopied => 'Копиран лог от BLE';

  @override
  String get debugLog_noEntries => 'Все още няма дебъг логове.';

  @override
  String get debugLog_enableInSettings =>
      'Активирайте отстраняване на грешки в настройките на приложението';

  @override
  String get debugLog_frames => 'Рамки';

  @override
  String get debugLog_rawLogRx => 'Raw Log-RX';

  @override
  String get debugLog_noBleActivity => 'Няма BLE активност към момента.';

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
    return 'Дължина на кадъра: $count байта';
  }

  @override
  String debugFrame_command(String value) {
    return 'Команда: 0x$value';
  }

  @override
  String get debugFrame_textMessageHeader => 'Съобщение:';

  @override
  String debugFrame_destinationPubKey(String pubKey) {
    return '- Дестинация Публичен Ключ: $pubKey';
  }

  @override
  String debugFrame_timestamp(int timestamp) {
    return '- Време: $timestamp';
  }

  @override
  String debugFrame_flags(String value) {
    return '- Флагове: 0x$value';
  }

  @override
  String debugFrame_textType(int type, String label) {
    return '- Тип текст: $type ($label)';
  }

  @override
  String get debugFrame_textTypeCli => 'CLI';

  @override
  String get debugFrame_textTypePlain => 'Просто';

  @override
  String debugFrame_text(String text) {
    return '- Текст: \"$text\"';
  }

  @override
  String get debugFrame_hexDump => 'Хексадесетичен Dump:';

  @override
  String get chat_pathManagement => 'Управление на пътища';

  @override
  String get chat_ShowAllPaths => 'Покажи всички пътища';

  @override
  String get chat_routingMode => 'Режим на маршрутизиране';

  @override
  String get chat_autoUseSavedPath => 'Автоматично (използвай запазения път)';

  @override
  String get chat_forceFloodMode => 'Принуди режим на наводняване';

  @override
  String get chat_recentAckPaths =>
      'Неотдавни ACK пътища (докоснете, за да използвате):';

  @override
  String get chat_pathHistoryFull =>
      'Историята на пътя е пълна. Премахнете записи, за да добавите нови.';

  @override
  String get chat_hopSingular => 'скочи';

  @override
  String get chat_hopPlural => 'скоци';

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
  String get chat_successes => 'Успехи';

  @override
  String get chat_removePath => 'Премахни пътя';

  @override
  String get chat_noPathHistoryYet =>
      'Няма история на пътищата още.\nИзпратете съобщение, за да откриете пътища.';

  @override
  String get chat_pathActions => 'Действия по пътя:';

  @override
  String get chat_setCustomPath => 'Задайте персонализиран път';

  @override
  String get chat_setCustomPathSubtitle => 'Ръчно укажете маршрутен път';

  @override
  String get chat_clearPath => 'Почисти Път';

  @override
  String get chat_clearPathSubtitle =>
      'Принуди преоткриване при следващо изпращане';

  @override
  String get chat_pathCleared =>
      'Пътят е почистен. Следващото съобщение ще открие маршрута отново.';

  @override
  String get chat_floodModeSubtitle =>
      'Използвайте превключвателя за маршрутизиране в лентата на приложението.';

  @override
  String get chat_floodModeEnabled =>
      'Режим на наводнение е активиран. Включете го отново чрез иконката за маршрутизиране в лентата на приложението.';

  @override
  String get chat_fullPath => 'Пълен път';

  @override
  String get chat_pathDetailsNotAvailable =>
      'Детайлите за пътя все още не са налични. Опитайте да изпратите съобщение, за да освежите.';

  @override
  String chat_pathSetHops(int hopCount, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      hopCount,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Пътят е зададен: $hopCount $_temp0 - $status';
  }

  @override
  String get chat_pathSavedLocally =>
      'Запазено локално. Свържете се за синхронизиране.';

  @override
  String get chat_pathDeviceConfirmed => 'Устройство потвърдено.';

  @override
  String get chat_pathDeviceNotConfirmed =>
      'Устройството все още не е потвърдено.';

  @override
  String get chat_type => 'Въведете';

  @override
  String get chat_path => 'Пътекино';

  @override
  String get chat_publicKey => 'Публичен ключ';

  @override
  String get chat_compressOutgoingMessages =>
      'Компресиране на изходящи съобщения';

  @override
  String get chat_floodForced => 'Потоп (принуден)';

  @override
  String get chat_directForced => 'Директно (принудително)';

  @override
  String chat_hopsForced(int count) {
    return '$count скока (принудително)';
  }

  @override
  String get chat_floodAuto => 'Потоп (автоматично)';

  @override
  String get chat_direct => 'Директно';

  @override
  String get chat_poiShared => 'Споделено място от интерес';

  @override
  String chat_unread(int count) {
    return 'Непрочетени: $count';
  }

  @override
  String get chat_openLink => 'Отваряне на връзката?';

  @override
  String get chat_openLinkConfirmation =>
      'Искате ли да отворите тази връзка в браузъра си?';

  @override
  String get chat_open => 'Отвори';

  @override
  String chat_couldNotOpenLink(String url) {
    return 'Не можа да се отвори връзката: $url';
  }

  @override
  String get chat_invalidLink => 'Невалиден формат на връзката';

  @override
  String get map_title => 'Карта на възлите';

  @override
  String get map_lineOfSight => 'Линия на видимост';

  @override
  String get map_losScreenTitle => 'Линия на видимост';

  @override
  String get map_noNodesWithLocation => 'Няма възли с данни за местоположение.';

  @override
  String get map_nodesNeedGps =>
      'Възлагат се възлозите да споделят техните GPS координати,\nза да се появят на картата.';

  @override
  String map_nodesCount(int count) {
    return 'Нодове: $count';
  }

  @override
  String map_pinsCount(int count) {
    return 'Ключове: $count';
  }

  @override
  String get map_chat => 'Чат';

  @override
  String get map_repeater => 'Повтарящ се';

  @override
  String get map_room => 'Стая';

  @override
  String get map_sensor => 'Датчик';

  @override
  String get map_pinDm => 'Задържане (DM)';

  @override
  String get map_pinPrivate => 'Задържане (Приватно)';

  @override
  String get map_pinPublic => 'Публичен ключ';

  @override
  String get map_lastSeen => 'Последна видяна';

  @override
  String get map_disconnectConfirm =>
      'Сигурни ли сте, че искате да се откъснете от това устройство?';

  @override
  String get map_from => 'От';

  @override
  String get map_source => 'Източник';

  @override
  String get map_flags => 'Флаг';

  @override
  String get map_pinLabel => 'Етикетиране на пин';

  @override
  String get map_label => 'Етикет';

  @override
  String get map_publicLocationShare => 'Споделяне на публично място';

  @override
  String map_publicLocationShareConfirm(String channelLabel) {
    return 'Ще споделите местоположение в $channelLabel. Този канал е публичен и всеки с PSK може да го види.';
  }

  @override
  String get map_connectToShareMarkers =>
      'Свържете се с устройство, за да споделите маркери.';

  @override
  String get map_filterNodes => 'Филтрирайте възли';

  @override
  String get map_nodeTypes => 'Типове възли';

  @override
  String get map_chatNodes => 'Възли на чата';

  @override
  String get map_repeaters => 'Повторители';

  @override
  String get map_otherNodes => 'Други възли';

  @override
  String get map_keyPrefix => 'Префикс на ключа';

  @override
  String get map_filterByKeyPrefix => 'Филтрирайте по префикс на ключ';

  @override
  String get map_publicKeyPrefix => 'Префикс на публичен ключ';

  @override
  String get map_markers => 'Маркери';

  @override
  String get map_showSharedMarkers => 'Покажи споделени маркери';

  @override
  String get map_lastSeenTime => 'Последна видяна дата';

  @override
  String get map_joinRoom => 'Присъедини се към стаята';

  @override
  String get map_manageRepeater => 'Управление на Повтарящ се Елемент';

  @override
  String get map_tapToAdd =>
      'Натиснете върху възлите, за да ги добавите към пътя.';

  @override
  String get map_runTrace => 'Изпълни Път на Следване';

  @override
  String get map_removeLast => 'Премахни Последно';

  @override
  String get map_pathTraceCancelled => 'Отменен е следването на пътя.';

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
  String get mapCache_title => 'Кеш на офлайн карти';

  @override
  String get mapCache_selectAreaFirst => 'Изберете област за кеширане първа';

  @override
  String get mapCache_noTilesToDownload =>
      'Няма плочки за изтегляне за тази област.';

  @override
  String get mapCache_downloadTilesTitle => 'Изтегли плочки';

  @override
  String mapCache_downloadTilesPrompt(int count) {
    return 'Изтегли $count плочки за офлайн употреба?';
  }

  @override
  String get mapCache_downloadAction => 'Изтегли';

  @override
  String mapCache_cachedTiles(int count) {
    return 'Кеширани $count плочки';
  }

  @override
  String mapCache_cachedTilesWithFailed(int downloaded, int failed) {
    return 'Запазени $downloaded плочки ($failed неуспешни)';
  }

  @override
  String get mapCache_clearOfflineCacheTitle => 'Изчисти офлайн кеша';

  @override
  String get mapCache_clearOfflineCachePrompt =>
      'Премахнете всички кеширани плочки на картата?';

  @override
  String get mapCache_offlineCacheCleared =>
      'Кешът на устройството е изчистен.';

  @override
  String get mapCache_noAreaSelected => 'Няма избрана област';

  @override
  String get mapCache_cacheArea => 'Област с кеш';

  @override
  String get mapCache_useCurrentView => 'Използвайте текущия изглед';

  @override
  String get mapCache_zoomRange => 'Обхват на увеличението';

  @override
  String mapCache_estimatedTiles(int count) {
    return 'Очаквани плочки: $count';
  }

  @override
  String mapCache_downloadedTiles(int completed, int total) {
    return 'Изтеглено $completed / $total';
  }

  @override
  String get mapCache_downloadTilesButton => 'Изтегли Плочки';

  @override
  String get mapCache_clearCacheButton => 'Изчисти кеша';

  @override
  String mapCache_failedDownloads(int count) {
    return 'Неуспешни изтегляния: $count';
  }

  @override
  String mapCache_boundsLabel(
    String north,
    String south,
    String east,
    String west,
  ) {
    return 'Север $north, Юг $south, Изток $east, Запад $west';
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
  String get time_justNow => 'Сега';

  @override
  String time_minutesAgo(int minutes) {
    return '$minutes минути преди';
  }

  @override
  String time_hoursAgo(int hours) {
    return '$hours часа преди';
  }

  @override
  String time_daysAgo(int days) {
    return '$days дни преди';
  }

  @override
  String get time_hour => 'час';

  @override
  String get time_hours => 'часове';

  @override
  String get time_day => 'ден';

  @override
  String get time_days => 'дни';

  @override
  String get time_week => 'седмица';

  @override
  String get time_weeks => 'секти';

  @override
  String get time_month => 'месец';

  @override
  String get time_months => 'месеци';

  @override
  String get time_minutes => 'минути';

  @override
  String get time_allTime => 'Всичко време';

  @override
  String get dialog_disconnect => 'Прекъсни';

  @override
  String get dialog_disconnectConfirm =>
      'Сигурни ли сте, че искате да се откъснете от това устройство?';

  @override
  String get login_repeaterLogin => 'Повторител Вход';

  @override
  String get login_roomLogin => 'Вход в стаята';

  @override
  String get login_password => 'Парола';

  @override
  String get login_enterPassword => 'Въведете парола';

  @override
  String get login_savePassword => 'Запази парола';

  @override
  String get login_savePasswordSubtitle =>
      'Паролата ще бъде съхранена сигурно на това устройство.';

  @override
  String get login_repeaterDescription =>
      'Въведете паролата на репитера, за да получите достъп до настройките и статуса.';

  @override
  String get login_roomDescription =>
      'Въведете паролата на стаята, за да получите достъп до настройките и статуса.';

  @override
  String get login_routing => 'Маршрутизиране';

  @override
  String get login_routingMode => 'Режим на маршрутизиране';

  @override
  String get login_autoUseSavedPath => 'Автоматично (използвай запазения път)';

  @override
  String get login_forceFloodMode => 'Принуди режим на наводняване';

  @override
  String get login_managePaths => 'Управление на пътища';

  @override
  String get login_login => 'Вход';

  @override
  String login_attempt(int current, int max) {
    return 'Опитвате $current/$max';
  }

  @override
  String login_failed(String error) {
    return 'Входът не беше успешен: $error';
  }

  @override
  String get login_failedMessage =>
      'Входът не беше успешен. Или паролата е грешна, или повторителят е недостъпен.';

  @override
  String get common_reload => 'Презареди';

  @override
  String get common_clear => 'Изчисти';

  @override
  String path_currentPath(String path) {
    return 'Текущ път: $path';
  }

  @override
  String path_usingHopsPath(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Използване на $count $_temp0 път';
  }

  @override
  String get path_enterCustomPath => 'Въведете персонализиран път';

  @override
  String get path_currentPathLabel => 'Текущ път';

  @override
  String get path_hexPrefixInstructions =>
      'Въведете 2-символни шестнадесетични префикси за всеки хоп, разделени с кама.';

  @override
  String get path_hexPrefixExample =>
      'A1,F2,3C (всяка нода използва първия байт от публичния си ключ)';

  @override
  String get path_labelHexPrefixes => 'Пътеки (шестнадесетични префикси)';

  @override
  String get path_helperMaxHops =>
      'Максимум 64 скока. Всеки префикс е 2 шестнадесетични знака (1 байт).';

  @override
  String get path_selectFromContacts => 'Изберете от контакти:';

  @override
  String get path_noRepeatersFound =>
      'Няма намерени репетитори или сървъри на стаи.';

  @override
  String get path_customPathsRequire =>
      'Персонализираните пътища изискват междинни скокове, които могат да препращат съобщения.';

  @override
  String path_invalidHexPrefixes(String prefixes) {
    return 'Невалидни шестнадесетични префикси: $prefixes';
  }

  @override
  String get path_tooLong =>
      'Пътят е твърде дълъг. Максимум 64 скока са разрешени.';

  @override
  String get path_setPath => 'Задайте път';

  @override
  String get repeater_management => 'Управление на повторители';

  @override
  String get room_management => 'Управление на сървъра за стая';

  @override
  String get repeater_managementTools => 'Инструменти за управление';

  @override
  String get repeater_status => 'Статус';

  @override
  String get repeater_statusSubtitle =>
      'Прегледайте статуса, статистиката и съседните устройства.';

  @override
  String get repeater_sendAdvert => 'Send Advert';

  @override
  String get repeater_sendAdvertSubtitle =>
      'Broadcast an advertisement packet now';

  @override
  String get repeater_telemetry => 'Телеметрия';

  @override
  String get repeater_telemetrySubtitle =>
      'Прегледайте телеметрията на сензорите и системните статистики';

  @override
  String get repeater_cli => 'CLI';

  @override
  String get repeater_cliSubtitle => 'Изпрати команди към ретранслатора';

  @override
  String get repeater_neighbors => 'Съседи';

  @override
  String get repeater_neighborsSubtitle =>
      'Преглед на съседни възли с нулев скок.';

  @override
  String get repeater_settings => 'Настройки';

  @override
  String get repeater_settingsSubtitle =>
      'Конфигурирайте параметрите на репитера';

  @override
  String get repeater_statusTitle => 'Статус на повтарянето';

  @override
  String get repeater_routingMode => 'Режим на маршрутизиране';

  @override
  String get repeater_autoUseSavedPath =>
      'Автоматично (използвай запазения път)';

  @override
  String get repeater_forceFloodMode => 'Принуди режим на наводняване';

  @override
  String get repeater_pathManagement => 'Управление на пътища';

  @override
  String get repeater_refresh => 'Презареди';

  @override
  String get repeater_statusRequestTimeout =>
      'Заявката за статус премина прекалено дълго.';

  @override
  String repeater_errorLoadingStatus(String error) {
    return 'Грешка при зареждане на статуса: $error';
  }

  @override
  String get repeater_systemInformation => 'Информация за системата';

  @override
  String get repeater_firmwareVersion => 'Firmware';

  @override
  String get repeater_battery => 'Батерия';

  @override
  String get repeater_clockAtLogin => 'Часовник (при влизане)';

  @override
  String get repeater_uptime => 'Наличност';

  @override
  String get repeater_queueLength => 'Дължина на опашката';

  @override
  String get repeater_debugFlags => 'Контролни точки за отстраняване на грешки';

  @override
  String get repeater_radioStatistics => 'Статистика на радиостанциите';

  @override
  String get repeater_lastRssi => 'Последна RSSI';

  @override
  String get repeater_lastSnr => 'Последна SNR';

  @override
  String get repeater_noiseFloor => 'Ниво на шум';

  @override
  String get repeater_txAirtime => 'TX Airtime';

  @override
  String get repeater_rxAirtime => 'RX Airtime';

  @override
  String get repeater_packetStatistics => 'Статистика на пакетите';

  @override
  String get repeater_sent => 'Изпратено';

  @override
  String get repeater_received => 'Получено';

  @override
  String get repeater_duplicates => 'Дубликати';

  @override
  String repeater_daysHoursMinsSecs(
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return '$days дни $hoursч $minutesм $secondsс';
  }

  @override
  String repeater_packetTxTotal(int total, String flood, String direct) {
    return 'Общо: $total, Наводнение: $flood, Директно: $direct';
  }

  @override
  String repeater_packetRxTotal(int total, String flood, String direct) {
    return 'Общо: $total, Наводнение: $flood, Директно: $direct';
  }

  @override
  String repeater_duplicatesFloodDirect(String flood, String direct) {
    return 'Поливане: $flood, Директен: $direct';
  }

  @override
  String repeater_duplicatesTotal(int total) {
    return 'Общо: $total';
  }

  @override
  String get repeater_settingsTitle => 'Настройки на повтарящия се елемент';

  @override
  String get repeater_basicSettings => 'Основни настройки';

  @override
  String get repeater_repeaterName => 'Име на повтарящ се елемент';

  @override
  String get repeater_repeaterNameHelper =>
      'Показване на името на този репитер';

  @override
  String get repeater_adminPassword => 'Парола на администратора';

  @override
  String get repeater_adminPasswordHelper => 'Пълен достъпен парола';

  @override
  String get repeater_guestPassword => 'Парола на гост';

  @override
  String get repeater_guestPasswordHelper => 'Достъп с ограничен достъп';

  @override
  String get repeater_radioSettings => 'Настройки на радиостанцията';

  @override
  String get repeater_frequencyMhz => 'Честота (MHz)';

  @override
  String get repeater_frequencyHelper => '300-2500 MHz';

  @override
  String get repeater_txPower => 'TX Power';

  @override
  String get repeater_txPowerHelper => '1-30 dBm';

  @override
  String get repeater_bandwidth => 'Ширина на честотния спектър';

  @override
  String get repeater_spreadingFactor => 'Фактор на разпространение';

  @override
  String get repeater_codingRate => 'Такса за кодиране';

  @override
  String get repeater_locationSettings => 'Настройки на местоположението';

  @override
  String get repeater_latitude => 'Широчина';

  @override
  String get repeater_latitudeHelper => 'Десетични градуси (напр. 37.7749)';

  @override
  String get repeater_longitude => 'Дължина';

  @override
  String get repeater_longitudeHelper =>
      'Градуси с десетични знаци (напр. -122.4194)';

  @override
  String get repeater_features => 'Характеристики';

  @override
  String get repeater_packetForwarding => 'Пренасочване на пакети';

  @override
  String get repeater_packetForwardingSubtitle =>
      'Активирайте репитера, за да препращате пакети.';

  @override
  String get repeater_guestAccess => 'Достъп за Гост';

  @override
  String get repeater_guestAccessSubtitle => 'Разрешете самочетене за гости';

  @override
  String get repeater_privacyMode => 'Режим на поверителност';

  @override
  String get repeater_privacyModeSubtitle =>
      'Скриване на име/местоположение в рекламите';

  @override
  String get repeater_advertisementSettings => 'Настройки на рекламите';

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
  String get repeater_localAdvertInterval => 'Местен Рекламен Интервал';

  @override
  String repeater_localAdvertIntervalMinutes(int minutes) {
    return '$minutes минути';
  }

  @override
  String get repeater_floodAdvertInterval =>
      'Интервал на рекламата за наводнения';

  @override
  String repeater_floodAdvertIntervalHours(int hours) {
    return '$hours часа';
  }

  @override
  String get repeater_encryptedAdvertInterval => 'Криптиран Рекламен Интервал';

  @override
  String get repeater_dangerZone =>
      'Опасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно Безопасно';

  @override
  String get repeater_rebootRepeater => 'БеРестартирай Репитер';

  @override
  String get repeater_rebootRepeaterSubtitle => 'Рестартирайте ретранслатора.';

  @override
  String get repeater_rebootRepeaterConfirm =>
      'Сигурни ли сте, че искате да рестартирате този репитер?';

  @override
  String get repeater_regenerateIdentityKeySubtitle =>
      'Генериране на нова двойка публичен/частен ключ';

  @override
  String get repeater_regenerateIdentityKeyConfirm =>
      'БеТова ще генерира нова идентичност за репитера. Продължете?';

  @override
  String get repeater_eraseFileSystem => 'Изтрий Файлова Система';

  @override
  String get repeater_eraseFileSystemSubtitle =>
      'Форматирайте файла на репитера';

  @override
  String get repeater_eraseFileSystemConfirm =>
      'ВНИМАНИЕ: Това ще изтрие всички данни от репетитора. Това не може да бъде отменено!';

  @override
  String get repeater_eraseSerialOnly =>
      'Изтриването е достъпно само през серийния терминал.';

  @override
  String repeater_commandSent(String command) {
    return 'Командата е изпратена: $command';
  }

  @override
  String repeater_errorSendingCommand(String error) {
    return 'Грешка при изпращане на командата: $error';
  }

  @override
  String get repeater_confirm => 'БеПотвърди';

  @override
  String get repeater_settingsSaved => 'Настройките са запазени успешно.';

  @override
  String repeater_errorSavingSettings(String error) {
    return 'Грешка при запазване на настройките: $error';
  }

  @override
  String get repeater_refreshBasicSettings => 'Обнови Основни Настройки';

  @override
  String get repeater_refreshRadioSettings =>
      'Обнови настройките на радиопредавателите';

  @override
  String get repeater_refreshTxPower => 'Обнови TX захранване';

  @override
  String get repeater_refreshLocationSettings =>
      'Обнови настройките на местоположението';

  @override
  String get repeater_refreshPacketForwarding => 'Обнови пакетно пренасочване';

  @override
  String get repeater_refreshGuestAccess => 'Обнови достъп за гости';

  @override
  String get repeater_refreshPrivacyMode => 'Обнови Режим на поверителност';

  @override
  String get repeater_refreshAdvertisementSettings =>
      'Обнови Настройки на Рекламата';

  @override
  String repeater_refreshed(String label) {
    return '$label е обновено';
  }

  @override
  String repeater_errorRefreshing(String label) {
    return 'Грешка при обновяване на $label';
  }

  @override
  String get repeater_cliTitle => 'Повторител CLI';

  @override
  String get repeater_debugNextCommand => 'Поправи Следваща Команда';

  @override
  String get repeater_commandHelp => 'Помощ';

  @override
  String get repeater_clearHistory => 'Изчисти История';

  @override
  String get repeater_noCommandsSent => 'Няма изпратени команди засега.';

  @override
  String get repeater_typeCommandOrUseQuick =>
      'Въведете команда по-долу или използвайте бързи команди';

  @override
  String get repeater_enterCommandHint => 'Въведете команда...';

  @override
  String get repeater_previousCommand => 'Предходна команда';

  @override
  String get repeater_nextCommand => 'Следваща команда';

  @override
  String get repeater_enterCommandFirst => 'Въведете първо команда.';

  @override
  String get repeater_cliCommandFrameTitle => 'Рамка за команда CLI';

  @override
  String repeater_cliCommandError(String error) {
    return 'Грешка: $error';
  }

  @override
  String get repeater_cliQuickGetName => 'Получи име';

  @override
  String get repeater_cliQuickGetRadio => 'Получи радио';

  @override
  String get repeater_cliQuickGetTx => 'Получи TX';

  @override
  String get repeater_cliQuickNeighbors => 'Съседи';

  @override
  String get repeater_cliQuickVersion => 'Версия';

  @override
  String get repeater_cliQuickAdvertise => 'Рекламирай';

  @override
  String get repeater_cliQuickClock => 'Часовник';

  @override
  String get repeater_cliHelpAdvert => 'Изпраща рекламен пакет';

  @override
  String get repeater_cliHelpReboot =>
      'Рестартира устройството. (Забележка, може да получите \'Timeout\', което е нормално)';

  @override
  String get repeater_cliHelpClock =>
      'Показва текущото време според часовника на всяко устройство.';

  @override
  String get repeater_cliHelpPassword =>
      'Задава се нова администраторска парола за устройството.';

  @override
  String get repeater_cliHelpVersion =>
      'Показва версията на устройството и датата на компилация на фърмуера.';

  @override
  String get repeater_cliHelpClearStats =>
      'Рестартира различни статистики броячи до нула.';

  @override
  String get repeater_cliHelpSetAf => 'Задава времето на фактора.';

  @override
  String get repeater_cliHelpSetTx =>
      'Задава се мощността на предаване на LoRa в dBm (отчитане спрямо референтно ниво).';

  @override
  String get repeater_cliHelpSetRepeat =>
      'Активира или деактивира ролята на репитера за този възел.';

  @override
  String get repeater_cliHelpSetAllowReadOnly =>
      '(Сървър на стаята) Ако е \"включено\", тогава влизането с празен парола ще бъде разрешено, но не може да публикува в стаята (само четене).';

  @override
  String get repeater_cliHelpSetFloodMax =>
      'Задава максималния брой хопове на входящ пакет за заливване (ако >= max, пакетът не се предава).';

  @override
  String get repeater_cliHelpSetIntThresh =>
      'Задава праг на интерференцията (в dB). По подразбиране е 14. Задайте на 0, за да деактивирате откриването на интерференция на каналите.';

  @override
  String get repeater_cliHelpSetAgcResetInterval =>
      'Задава интервала за рестартиране на Автоматичния контролер за усилване. Задайте на 0, за да го деактивирате.';

  @override
  String get repeater_cliHelpSetMultiAcks =>
      'Активира или деактивира функцията \'двойни ACKs\'.';

  @override
  String get repeater_cliHelpSetAdvertInterval =>
      'Задава интервала на таймера в минути за изпращане на локален (безпроблемен) рекламен пакет. Задайте на 0, за да го деактивирате.';

  @override
  String get repeater_cliHelpSetFloodAdvertInterval =>
      'Задава интервала на таймера в часове за изпращане на пакет с реклама за наводнение. Задайте на 0, за да го деактивирате.';

  @override
  String get repeater_cliHelpGetPathHashMode =>
      'Returns advert path hash mode (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetPathHashMode =>
      'Sets advert path hash mode for this repeater (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetGuestPassword =>
      'Задава/обновява паролата на гост. (за повторители, гостите могат да изпращат заявката \"Get Stats\")';

  @override
  String get repeater_cliHelpSetName => 'Задава име на обявата.';

  @override
  String get repeater_cliHelpSetLat =>
      'Задава географска ширина на картата с реклами (в десетими градуси).';

  @override
  String get repeater_cliHelpSetLon =>
      'Задава обхвата на дължина на картата на рекламата. (десетими градуса)';

  @override
  String get repeater_cliHelpSetRadio =>
      'Задава напълно нови радио параметри и ги запазва в предпочитанията. Изисква команда \"рестарт\", за да бъдат приложени.';

  @override
  String get repeater_cliHelpSetRxDelay =>
      'Зададени (експериментални) основи (трябва да е > 1 за ефект) за прилагане на леко забавяне на получените пакети, базирано на силата на сигнала/резултата. Задайте на 0, за да го деактивирате.';

  @override
  String get repeater_cliHelpSetTxDelay =>
      'Задава фактор, умножен по времето на въздух за пакет в режим на наводнение и с рандомизирана система за слотове, за да забави предаването му (за да намали вероятността от сблъсъци).';

  @override
  String get repeater_cliHelpSetDirectTxDelay =>
      'Същото като txdelay, но за прилагане на случайна забавяне при препращането на пакети в директен режим.';

  @override
  String get repeater_cliHelpSetBridgeEnabled =>
      'Активиране/Деактивиране на мост.';

  @override
  String get repeater_cliHelpSetBridgeDelay =>
      'Задайте забавяне преди преизпращане на пакети.';

  @override
  String get repeater_cliHelpSetBridgeSource =>
      'Изберете дали мостът ще предава препратени пакети или получени пакети.';

  @override
  String get repeater_cliHelpSetBridgeBaud =>
      'Задайте скоростта на предаване за RS232 мостовете.';

  @override
  String get repeater_cliHelpSetBridgeSecret =>
      'Задайте тайна за мостовете на EspNow.';

  @override
  String get repeater_cliHelpSetAdcMultiplier =>
      'Задава персонализиран коефициент за коригиране на отчетеното напрежение на батерията (поддържа се само на избрани дъски).';

  @override
  String get repeater_cliHelpTempRadio =>
      'Задава временни радио параметри за посочения брой минути, връщайки се към оригиналните радио параметри след това. (не се запазва в предпочитанията).';

  @override
  String get repeater_cliHelpSetPerm =>
      'Променя ACL. Премахва съответстващия запис (по префикс на pubkey), ако \"permissions\" е нула. Добавя нов запис, ако pubkey-hex е с пълна дължина и не е в ACL. Актуализира запис, съответстващ на префикса на pubkey. Битовете за разрешения варират според ролята на firmware, но долните 2 бита са: 0 (Гост), 1 (Само четене), 2 (Четене и писане), 3 (Администратор).';

  @override
  String get repeater_cliHelpGetBridgeType =>
      'Получава тип мост none, rs232, espnow';

  @override
  String get repeater_cliHelpLogStart =>
      'Започва записване на пакети във файловата система.';

  @override
  String get repeater_cliHelpLogStop =>
      'Спира записването на пакети във файловата система.';

  @override
  String get repeater_cliHelpLogErase =>
      'Изтрива логовете от пакета от файловата система.';

  @override
  String get repeater_cliHelpNeighbors =>
      'Показва списък с други възли на репитер, чути чрез нулев хоп реклами. Всяка линия е id-prefix-hex:timestamp:snr-times-4';

  @override
  String get repeater_cliHelpNeighborRemove =>
      'Премахва първия съвпадащ запис (по префикси на pubkey (hex)) от списъка с съседи.';

  @override
  String get repeater_cliHelpRegion =>
      '(сериен режим) Изброява всички дефинирани региони и текущите разрешения за наводнения.';

  @override
  String get repeater_cliHelpRegionLoad =>
      'Забележка: това е специално многокомандно извикване. Всяка следваща команда е име на регион (отстъпен с интервали, за да се покаже йерархията, с минимум един интервал). Завършва се чрез изпращане на празен ред/команда.';

  @override
  String get repeater_cliHelpRegionGet =>
      'Търси регион с даден префикс на име (или \"\" за глобалния обхват). Отговаря с \"-> region-name (parent-name) \'F\'\"';

  @override
  String get repeater_cliHelpRegionPut =>
      'Добавя или актуализира дефиниция на регион с дадено име.';

  @override
  String get repeater_cliHelpRegionRemove =>
      'Премахва дефиниция на регион с дадено име. (трябва да съвпада точно и да няма подрегиони)';

  @override
  String get repeater_cliHelpRegionAllowf =>
      'Задава \'Потоп\' разрешение за посочената област. (\'\' за глобалния/стария обхват)';

  @override
  String get repeater_cliHelpRegionDenyf =>
      'Премахва разрешението \"F\"лоуд за посочената област. (ЗАБЕЛЕЖКА: в момента не се препоръчва да се използва на глобалното/старото ниво!! )';

  @override
  String get repeater_cliHelpRegionHome =>
      'Отговаря с текущия \'home\' регион. (Забележка: не е приложена никъде, запазена за бъдещи нужди).';

  @override
  String get repeater_cliHelpRegionHomeSet => 'Задава \'домашно\' региона.';

  @override
  String get repeater_cliHelpRegionSave =>
      'Запазва списъка/картата с региони в съхранение.';

  @override
  String get repeater_cliHelpGps =>
      'Показва статуса на GPS. Когато GPS е изключен, отговаря само с \"off\", ако е включен отговаря с \"on\", статус, fix, брой на сателити.';

  @override
  String get repeater_cliHelpGpsOnOff => 'Включва/Изключва GPS захранването.';

  @override
  String get repeater_cliHelpGpsSync =>
      'Синхронизира времето на възела с GPS часовника.';

  @override
  String get repeater_cliHelpGpsSetLoc =>
      'Задава координатите на нодата по GPS и запазва предпочитанията.';

  @override
  String get repeater_cliHelpGpsAdvert =>
      'Предоставя конфигурацията на рекламата за местоположението на възела:\n- none: не включвайте местоположението в рекламите\n- share: споделяйте gps местоположението (от SensorManager)\n- prefs: рекламирайте местоположението, съхранено в предпочитанията';

  @override
  String get repeater_cliHelpGpsAdvertSet =>
      'Задава конфигурация на обявите за местоположение.';

  @override
  String get repeater_commandsListTitle => 'Списък с команди';

  @override
  String get repeater_commandsListNote =>
      'ЗАБЕЛЕЖКА: за различните команди \"set ...\", също така съществува команда \"get ...\".';

  @override
  String get repeater_general => 'Общо';

  @override
  String get repeater_settingsCategory => 'Настройки';

  @override
  String get repeater_bridge => 'Мост';

  @override
  String get repeater_logging => 'Логване';

  @override
  String get repeater_neighborsRepeaterOnly => 'Съседи (Само за повтаряне)';

  @override
  String get repeater_regionManagementRepeaterOnly =>
      'Управление на региони (Само за повтарящ се канал)';

  @override
  String get repeater_regionNote =>
      'Регионните команди са въведени, за да управляват дефинициите и разрешенията на регионите.';

  @override
  String get repeater_gpsManagement => 'Управление на GPS';

  @override
  String get repeater_gpsNote =>
      'GPS командата е въведена, за да управлява теми, свързани с местоположението.';

  @override
  String get telemetry_receivedData => 'Получени телеметрични данни';

  @override
  String get telemetry_requestTimeout => 'Заявката за телеметрия е прекъсната.';

  @override
  String telemetry_errorLoading(String error) {
    return 'Грешка при зареждане на телеметрията: $error';
  }

  @override
  String get telemetry_noData => 'Няма налични данни за телеметрията.';

  @override
  String telemetry_channelTitle(int channel) {
    return 'Канал $channel';
  }

  @override
  String get telemetry_batteryLabel => 'Батерия';

  @override
  String get telemetry_voltageLabel => 'Напрежение';

  @override
  String get telemetry_mcuTemperatureLabel => 'Температура на MCU';

  @override
  String get telemetry_temperatureLabel => 'Температура';

  @override
  String get telemetry_currentLabel => 'Текущо';

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
  String get neighbors_receivedData => 'Получени данни за съседи';

  @override
  String get neighbors_requestTimedOut => 'Съседите поискат изтичане на време.';

  @override
  String neighbors_errorLoading(String error) {
    return 'Грешка при зареждане на съседи: $error';
  }

  @override
  String get neighbors_repeatersNeighbors => 'Повторители Съседи';

  @override
  String get neighbors_noData => 'Няма налични данни за съседи.';

  @override
  String neighbors_unknownContact(String pubkey) {
    return 'Неизвестна $pubkey';
  }

  @override
  String neighbors_heardAgo(String time) {
    return 'Слушано преди $time.';
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
  String get channelPath_title => 'Пътеки пъзел';

  @override
  String get channelPath_viewMap => 'Преглед на картата';

  @override
  String get channelPath_otherObservedPaths => 'Други Наблюдавани Пътища';

  @override
  String get channelPath_repeaterHops => 'Повтарящи се скокове';

  @override
  String get channelPath_noHopDetails =>
      'Детайлите за пакета не са предоставени.';

  @override
  String get channelPath_messageDetails => 'Подробности на съобщението';

  @override
  String get channelPath_senderLabel => 'Изпращач';

  @override
  String get channelPath_timeLabel => 'Време';

  @override
  String get channelPath_repeatsLabel => 'Повтаря';

  @override
  String channelPath_pathLabel(int index) {
    return 'Път $index';
  }

  @override
  String get channelPath_observedLabel => 'Наблюдавано';

  @override
  String channelPath_observedPathTitle(int index, String hops) {
    return 'Наблюдаван път $index • $hops';
  }

  @override
  String get channelPath_noLocationData => 'Няма данни за местоположение.';

  @override
  String channelPath_timeWithDate(int day, int month, String time) {
    return '$day/$month $time';
  }

  @override
  String channelPath_timeOnly(String time) {
    return '$time';
  }

  @override
  String get channelPath_unknownPath => 'Неизвестно';

  @override
  String get channelPath_floodPath => 'Поливане';

  @override
  String get channelPath_directPath => 'Директно';

  @override
  String channelPath_observedZeroOf(int total) {
    return '0 от $total скокове';
  }

  @override
  String channelPath_observedSomeOf(int observed, int total) {
    return '$observed от $total скокове';
  }

  @override
  String get channelPath_mapTitle => 'Карта на пътя';

  @override
  String get channelPath_noRepeaterLocations =>
      'Няма налични местоположения на повторителите за този път.';

  @override
  String channelPath_primaryPath(int index) {
    return 'Път $index (Основен)';
  }

  @override
  String get channelPath_pathLabelTitle => 'Пътекино';

  @override
  String get channelPath_observedPathHeader => 'Наблюдаван път';

  @override
  String channelPath_selectedPathLabel(String label, String prefixes) {
    return '$label • $prefixes';
  }

  @override
  String get channelPath_noHopDetailsAvailable =>
      'Няма налични детайли за този пакет.';

  @override
  String get channelPath_unknownRepeater => 'Неизвестен повторител';

  @override
  String get community_title => 'Общност';

  @override
  String get community_create => 'Създай общност';

  @override
  String get community_createDesc =>
      'Създайте нова общност и я споделете чрез QR код.';

  @override
  String get community_join => 'Присъедини се';

  @override
  String get community_joinTitle => 'Присъедини се към общността';

  @override
  String community_joinConfirmation(String name) {
    return 'Искате ли да се присъедините към общността \"$name\"?';
  }

  @override
  String get community_scanQr => 'Сканирайте QR кода на общността';

  @override
  String get community_scanInstructions =>
      'Насочете камерата към QR код на общността';

  @override
  String get community_showQr => 'Покажи QR код';

  @override
  String get community_publicChannel => 'Обществено общност';

  @override
  String get community_hashtagChannel => 'Хаштаг на общността';

  @override
  String get community_name => 'Име на общността';

  @override
  String get community_enterName => 'Въведете име на общността';

  @override
  String community_created(String name) {
    return 'Общността \"$name\" е създадена';
  }

  @override
  String community_joined(String name) {
    return 'Присъединено общност \"$name\"';
  }

  @override
  String get community_qrTitle => 'Споделяне в общността';

  @override
  String community_qrInstructions(String name) {
    return 'Сканирайте този QR код, за да се присъедините към $name.';
  }

  @override
  String get community_hashtagPrivacyHint =>
      'Хаштаг каналите на общността са достъпни само за членове на общността';

  @override
  String get community_invalidQrCode => 'Невалиден QR код на общността';

  @override
  String get community_alreadyMember => 'Вече съм член';

  @override
  String community_alreadyMemberMessage(String name) {
    return 'Вие вече сте член на \"$name\".';
  }

  @override
  String get community_addPublicChannel => 'Добави публичен общностен канал';

  @override
  String get community_addPublicChannelHint =>
      'Автоматично добавете публичния канал за тази общност.';

  @override
  String get community_noCommunities => 'Няма присъединени общности още.';

  @override
  String get community_scanOrCreate =>
      'Сканирайте QR код или създайте общност, за да започнете.';

  @override
  String get community_manageCommunities => 'Управление на общности';

  @override
  String get community_delete => 'Напусни общността';

  @override
  String community_deleteConfirm(String name) {
    return 'Напускате \"$name\"?';
  }

  @override
  String community_deleteChannelsWarning(int count) {
    return 'Това ще изтрие също $count канал(а) и техните съобщения.';
  }

  @override
  String community_deleted(String name) {
    return 'Остави общността \"$name\"';
  }

  @override
  String get community_regenerateSecret => 'Регенерейрай секрет';

  @override
  String community_regenerateSecretConfirm(String name) {
    return 'Регенерация на секретния ключ за \"$name\"? Всички членове ще трябва да сканират новия QR код, за да продължат комуникацията.';
  }

  @override
  String get community_regenerate => 'Регенерация';

  @override
  String community_secretRegenerated(String name) {
    return 'Секретно презареждане за \"$name\"';
  }

  @override
  String get community_updateSecret => 'Актуализирай тайна';

  @override
  String community_secretUpdated(String name) {
    return 'Секретно обновено за \"$name\"';
  }

  @override
  String community_scanToUpdateSecret(String name) {
    return 'Сканьорвайте новия QR код, за да актуализирате секрета за \"$name\"';
  }

  @override
  String get community_addHashtagChannel => 'Добави общностен хаштаг';

  @override
  String get community_addHashtagChannelDesc =>
      'Добавете хаштаг канал за тази общност';

  @override
  String get community_selectCommunity => 'Изберете общност';

  @override
  String get community_regularHashtag => 'Обикновен хаштаг';

  @override
  String get community_regularHashtagDesc =>
      'Общ хаштаг (всеки може да се присъедини)';

  @override
  String get community_communityHashtag => 'Общностен хаштаг';

  @override
  String get community_communityHashtagDesc => 'Само за членове на общността';

  @override
  String community_forCommunity(String name) {
    return 'За $name';
  }

  @override
  String get listFilter_tooltip => 'Филтрирайте и сортирайте';

  @override
  String get listFilter_sortBy => 'Сортирай по';

  @override
  String get listFilter_latestMessages => 'Последни съобщения';

  @override
  String get listFilter_heardRecently => 'Слушано е наскоро';

  @override
  String get listFilter_az => 'A-Z';

  @override
  String get listFilter_filters => 'Филтри';

  @override
  String get listFilter_all => 'Всички';

  @override
  String get listFilter_users => 'Потребители';

  @override
  String get listFilter_repeaters => 'Повторители';

  @override
  String get listFilter_roomServers => 'Сървъри на стая';

  @override
  String get listFilter_unreadOnly => 'Само непрочетените';

  @override
  String get listFilter_newGroup => 'Нова група';

  @override
  String get pathTrace_you => 'Вие';

  @override
  String get pathTrace_failed => 'Пътят за проследяване не успя.';

  @override
  String get pathTrace_notAvailable => 'Пътека за проследяване не е достъпна.';

  @override
  String get pathTrace_refreshTooltip => 'Обнови Path Trace.';

  @override
  String get pathTrace_someHopsNoLocation =>
      'Един или повече от хмелите липсва местоположение!';

  @override
  String get pathTrace_clearTooltip => 'Изчисти пътя';

  @override
  String get losSelectStartEnd => 'Изберете начални и крайни възли за LOS.';

  @override
  String losRunFailed(String error) {
    return 'Проверката на пряката видимост е неуспешна: $error';
  }

  @override
  String get losClearAllPoints => 'Изчистете всички точки';

  @override
  String get losRunToViewElevationProfile =>
      'Стартирайте LOS, за да видите профила на надморската височина';

  @override
  String get losMenuTitle => 'LOS меню';

  @override
  String get losMenuSubtitle =>
      'Докоснете възли или натиснете продължително карта за персонализирани точки';

  @override
  String get losShowDisplayNodes => 'Показване на възли на дисплея';

  @override
  String get losCustomPoints => 'Персонализирани точки';

  @override
  String losCustomPointLabel(int index) {
    return 'Персонализирано $index';
  }

  @override
  String get losPointA => 'Точка А';

  @override
  String get losPointB => 'Точка Б';

  @override
  String losAntennaA(String value, String unit) {
    return 'Антена A: $value $unit';
  }

  @override
  String losAntennaB(String value, String unit) {
    return 'Антена B: $value $unit';
  }

  @override
  String get losRun => 'Стартирайте LOS';

  @override
  String get losNoElevationData => 'Няма данни за надморска височина';

  @override
  String losProfileClear(
    String distance,
    String distanceUnit,
    String clearance,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, чист LOS, минимално разстояние $clearance $heightUnit';
  }

  @override
  String losProfileBlocked(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, блокиран от $obstruction $heightUnit';
  }

  @override
  String get losStatusChecking => 'LOS: проверка...';

  @override
  String get losStatusNoData => 'LOS: няма данни';

  @override
  String losStatusSummary(int clear, int total, int blocked, int unknown) {
    return 'LOS: $clear/$total ясно, $blocked блокирано, $unknown неизвестно';
  }

  @override
  String get losErrorElevationUnavailable =>
      'Няма налични данни за надморска височина за една или повече проби.';

  @override
  String get losErrorInvalidInput =>
      'Невалидни данни за точки/надморска височина за изчисляване на LOS.';

  @override
  String get losRenameCustomPoint => 'Преименувайте персонализирана точка';

  @override
  String get losPointName => 'Име на точката';

  @override
  String get losShowPanelTooltip => 'Показване на LOS панел';

  @override
  String get losHidePanelTooltip => 'Скриване на LOS панела';

  @override
  String get losElevationAttribution =>
      'Данни за надморска височина: Open-Meteo (CC BY 4.0)';

  @override
  String get contacts_pathTrace => 'Пътен проследяване';

  @override
  String get contacts_ping => 'Пинг';

  @override
  String get contacts_repeaterPathTrace => 'Трасировка до повторител';

  @override
  String get contacts_repeaterPing => 'Пингване на повторителя';

  @override
  String get contacts_roomPathTrace => 'Трасиране на път до съ';

  @override
  String get contacts_roomPing => 'Ping на сървъра на стаята';

  @override
  String get contacts_chatTraceRoute => 'Трасиране на път';

  @override
  String contacts_pathTraceTo(String name) {
    return 'Проследи маршрут към $name';
  }

  @override
  String get contacts_clipboardEmpty => 'Клипборда е празна.';

  @override
  String get contacts_invalidAdvertFormat => 'Невалидни данни за контакт';

  @override
  String get contacts_contactImported => 'Контактът е импортиран.';

  @override
  String get contacts_contactImportFailed =>
      'Контактът не е успешно импортиран.';

  @override
  String get contacts_zeroHopAdvert => 'Реклама без скок';

  @override
  String get contacts_floodAdvert => 'Потопна реклама';

  @override
  String get contacts_copyAdvertToClipboard => 'Копирай обявата в клипборда';

  @override
  String get contacts_addContactFromClipboard => 'Добави контакт от клипборда';

  @override
  String get contacts_ShareContact => 'Копирай контакт в клипборда';

  @override
  String get contacts_ShareContactZeroHop => 'Сподели контакт чрез обява';

  @override
  String get contacts_zeroHopContactAdvertSent => 'Изпратен контакт по обява.';

  @override
  String get contacts_zeroHopContactAdvertFailed =>
      'Неуспешно изпращане на контакт.';

  @override
  String get contacts_contactAdvertCopied =>
      'Рекламата е копирана в клипборда.';

  @override
  String get contacts_contactAdvertCopyFailed =>
      'Копирането на обявата в клипборда не успя.';

  @override
  String get notification_activityTitle => 'Активност на MeshCore';

  @override
  String notification_messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'съобщения',
      one: 'съобщение',
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
      other: 'съобщения в канали',
      one: 'съобщение в канал',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'нови възли',
      one: 'нов възел',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newTypeDiscovered(String contactType) {
    return 'Открит нов $contactType';
  }

  @override
  String get notification_receivedNewMessage => 'Получено ново съобщение';

  @override
  String get settings_gpxExportRepeaters =>
      'Експортиране на повтарящи се устройства / сървър на стаята до GPX';

  @override
  String get settings_gpxExportRepeatersSubtitle =>
      'Изпраща повторители / roomserver с местоположение в GPX файл.';

  @override
  String get settings_gpxExportContacts => 'Експортирай спътници към GPX';

  @override
  String get settings_gpxExportContactsSubtitle =>
      'Експортира спътници с местоположение в GPX файл.';

  @override
  String get settings_gpxExportAll => 'Експортирай всички контакти в GPX';

  @override
  String get settings_gpxExportAllSubtitle =>
      'Експортира всички контакти с местоположение в файл GPX.';

  @override
  String get settings_gpxExportSuccess => 'Успешно изlexport на файл GPX.';

  @override
  String get settings_gpxExportNoContacts => 'Няма контакти за изlexport.';

  @override
  String get settings_gpxExportNotAvailable =>
      'Не е поддържан на вашето устройство/ОС';

  @override
  String get settings_gpxExportError => 'Възникна грешка при изнасяне.';

  @override
  String get settings_gpxExportRepeatersRoom =>
      'Местоположения на повторител и сървър на стаята';

  @override
  String get settings_gpxExportChat => 'Местоположения на спътници';

  @override
  String get settings_gpxExportAllContacts =>
      'Местоположения на всички контакти';

  @override
  String get settings_gpxExportShareText =>
      'Картинни данни изнесени от Gulf Coast Mesh App';

  @override
  String get settings_gpxExportShareSubject =>
      'Gulf Coast Mesh App износ на данни за карта в формат GPX';

  @override
  String get snrIndicator_nearByRepeaters => 'Близки повтарящи се устройства';

  @override
  String get snrIndicator_lastSeen => 'Последно видян';

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
      'Генериране на Ключ за Идентичност';

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
  String get appSettings_nodeBlocking => 'Блокиране на възли';

  @override
  String get appSettings_nodeBlockingSubtitle =>
      'Скривайте избраните възли от картата, контактите и чатовете и заглушавайте известията им. Само в приложението: нищо не се премахва от радиото ви.';

  @override
  String get appSettings_blockedNodes => 'Блокирани възли';

  @override
  String appSettings_blockedNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count блокирани възела',
      one: '1 блокиран възел',
      zero: 'Няма блокирани',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_title => 'Блокирани възли';

  @override
  String get blockedNodes_howItWorks => 'Как работи блокирането';

  @override
  String get blockedNodes_infoHidden =>
      'Скрити от картата, контактите и чатовете ви';

  @override
  String get blockedNodes_infoMuted =>
      'Без известия за нови възли и без известия за съобщения от тях';

  @override
  String get blockedNodes_infoKept =>
      'Нищо не се изтрива. Възлите остават на придружаващото ви радио и съобщенията им се запазват';

  @override
  String get blockedNodes_infoRelay =>
      'Блокираните повторители все още могат да предават съобщенията ви през мрежата';

  @override
  String get blockedNodes_infoChannels =>
      'Съобщенията им в канали все още се показват';

  @override
  String get blockedNodes_emptyTitle => 'Няма блокирани възли';

  @override
  String get blockedNodes_emptyHint =>
      'Натиснете и задръжте възел в Контакти или на Картата и изберете Блокиране на възел.';

  @override
  String get blockedNodes_unblock => 'Отблокиране';

  @override
  String get blockedNodes_unblockAll => 'Отблокиране на всички';

  @override
  String blockedNodes_unblockAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Да се отблокират всички $count възела? Те отново ще се показват на картата и в контактите ви.',
      one:
          'Да се отблокира 1 възел? Той отново ще се показва на картата и в контактите ви.',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_unknownNode => 'Неизвестен възел';

  @override
  String blockedNodes_blockedOn(String date) {
    return 'Блокиран на $date';
  }

  @override
  String get blockedNodes_blockAction => 'Блокиране на възел';

  @override
  String blockedNodes_blockConfirmTitle(String name) {
    return 'Да се блокира $name?';
  }

  @override
  String get blockedNodes_blockConfirmBody =>
      'Той ще бъде скрит от картата, контактите и чатовете ви и няма да получавате известия или известия за съобщения от него. Нищо не се изтрива от радиото ви. Можете да го отблокирате по всяко време в Настройки на приложението > Експериментално > Блокирани възли.';

  @override
  String get blockedNodes_blockConfirmButton => 'Блокиране';

  @override
  String blockedNodes_blocked(String name) {
    return '$name е блокиран';
  }

  @override
  String blockedNodes_unblocked(String name) {
    return '$name е отблокиран';
  }

  @override
  String get blockedNodes_undo => 'Отмяна';
}
