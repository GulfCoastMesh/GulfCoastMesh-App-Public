// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

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
  String get nav_contacts => 'Контакты';

  @override
  String get nav_channels => 'Каналы';

  @override
  String get nav_map => 'Карта';

  @override
  String get nav_chats => 'Чаты';

  @override
  String get nav_nodes => 'Узлы';

  @override
  String get nav_settings => 'Настройки';

  @override
  String get common_cancel => 'Отмена';

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
  String get common_connect => 'Коннект';

  @override
  String get common_unknownDevice => 'Неизвестное устройство';

  @override
  String get common_save => 'Сохранить';

  @override
  String get common_delete => 'Удалить';

  @override
  String get common_close => 'Закрыть';

  @override
  String get common_edit => 'Изменить';

  @override
  String get common_add => 'Добавить';

  @override
  String get common_settings => 'Настройки';

  @override
  String get common_disconnect => 'Отключить';

  @override
  String get common_connected => 'Подключено';

  @override
  String get common_disconnected => 'Отключено';

  @override
  String get common_reconnecting => 'Reconnecting';

  @override
  String get common_create => 'Создать';

  @override
  String get common_continue => 'Продолжить';

  @override
  String get common_share => 'Поделиться';

  @override
  String get common_copy => 'Копировать';

  @override
  String get common_retry => 'Повторить';

  @override
  String get common_hide => 'Скрыть';

  @override
  String get common_remove => 'Убрать';

  @override
  String get common_enable => 'Включить';

  @override
  String get common_disable => 'Выключить';

  @override
  String get common_reboot => 'Перезагрузить';

  @override
  String get common_loading => 'Загрузка...';

  @override
  String get common_notAvailable => '—';

  @override
  String common_voltageValue(String volts) {
    return '$volts В';
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
  String get scanner_scanning => 'Поиск устройств...';

  @override
  String get scanner_connecting => 'Подключение...';

  @override
  String get scanner_disconnecting => 'Отключение...';

  @override
  String get scanner_notConnected => 'Не подключено';

  @override
  String scanner_connectedTo(String deviceName) {
    return 'Подключено к $deviceName';
  }

  @override
  String get scanner_searchingDevices => 'Поиск устройств MeshCore...';

  @override
  String get scanner_tapToScan => 'Нажмите для поиска MeshCore устройств';

  @override
  String scanner_connectionFailed(String error) {
    return 'Подключение не удалось: $error';
  }

  @override
  String get scanner_backgroundBleMayDrop =>
      'Background BLE may drop without notification permission.';

  @override
  String get scanner_stop => 'Стоп';

  @override
  String get scanner_scan => 'Сканирование';

  @override
  String get scanner_bluetoothOff => 'Bluetooth выключен';

  @override
  String get scanner_bluetoothOffMessage =>
      'Пожалуйста, включите Bluetooth, чтобы найти устройства.';

  @override
  String get scanner_enableBluetooth => 'Включите Bluetooth';

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
  String get device_quickSwitch => 'Быстрое переключение';

  @override
  String get device_meshcore => 'MeshCore';

  @override
  String get settings_title => 'Настройки';

  @override
  String get settings_deviceInfo => 'Информация об устройстве';

  @override
  String get settings_appSettings => 'Настройки приложения';

  @override
  String get settings_appSettingsSubtitle =>
      'Уведомления, сообщения и настройки карты';

  @override
  String get settings_nodeSettings => 'Настройки ноды';

  @override
  String get settings_nodeName => 'Имя ноды';

  @override
  String get settings_nodeNameNotSet => 'Не установлено';

  @override
  String get settings_nodeNameHint => 'Введите имя ноды';

  @override
  String get settings_nodeNameUpdated => 'Имя обновлено';

  @override
  String get settings_radioSettings => 'Настройки радио';

  @override
  String get settings_radioSettingsSubtitle =>
      'Частота, мощность и коэффициент распространения';

  @override
  String get settings_radioSettingsUpdated => 'Настройки радио обновлены';

  @override
  String get settings_location => 'Позиция';

  @override
  String get settings_locationSubtitle => 'Координаты GPS';

  @override
  String get settings_locationUpdated => 'Позиция и настройки GPS обновлены';

  @override
  String get settings_locationBothRequired => 'Введите широту и долготу.';

  @override
  String get settings_locationInvalid => 'Неверная широта или долгота.';

  @override
  String get settings_locationGPSEnable => 'Включить GPS';

  @override
  String get settings_locationGPSEnableSubtitle =>
      'Включение GPS для автоматического обновления позиции.';

  @override
  String get settings_locationIntervalSec =>
      'Интервал для позиционирования GPS (секунды)';

  @override
  String get settings_usePhoneGps => 'Use phone GPS';

  @override
  String get settings_locationIntervalInvalid =>
      'Интервал должен составлять не менее 60 секунд и не более 86400 секунд.';

  @override
  String get settings_latitude => 'Широта';

  @override
  String get settings_longitude => 'Долгота';

  @override
  String get settings_privacyMode => 'Режим конфиденциальности';

  @override
  String get settings_privacyModeSubtitle =>
      'Скрыть имя/позицию в анонсировании';

  @override
  String get settings_privacyModeToggle =>
      'Включите режим конфиденциальности, чтобы скрыть свое имя и местоположение в анонсировании.';

  @override
  String get settings_privacyModeEnabled => 'Режим конфиденциальности включен';

  @override
  String get settings_privacyModeDisabled =>
      'Режим конфиденциальности выключен';

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
  String get settings_sendAdvertisement => 'Отправить анонсирование';

  @override
  String get settings_sendAdvertisementSubtitle =>
      'Отправить анонсирование о присутствии сейчас';

  @override
  String get settings_advertisementSent => 'Анонсирование отправлено';

  @override
  String get settings_syncTime => 'Синхронизация времени';

  @override
  String get settings_syncTimeSubtitle => 'Синхронизировать время с телефоном';

  @override
  String get settings_timeSynchronized => 'Время синхронизировано';

  @override
  String get settings_refreshContacts => 'Обновить контакты';

  @override
  String get settings_refreshContactsSubtitle =>
      'Перезагрузить список контактов с устройства';

  @override
  String get settings_rebootDevice => 'Перезагрузить устройство';

  @override
  String get settings_rebootDeviceSubtitle =>
      'Перезапустить устройство MeshCore';

  @override
  String get settings_rebootDeviceConfirm =>
      'Вы уверены, что хотите перезагрузить устройство? Вы будете отключены.';

  @override
  String get settings_debug => 'Отладка';

  @override
  String get settings_bleDebugLog => 'Журнал отладки BLE';

  @override
  String get settings_bleDebugLogSubtitle =>
      'Команды BLE, ответы и сырые данные';

  @override
  String get settings_appDebugLog => 'Журнал отладки приложения';

  @override
  String get settings_appDebugLogSubtitle => 'Сообщения отладки приложения';

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
  String get settings_about => 'О программе';

  @override
  String settings_aboutVersion(String version) {
    return 'Gulf Coast Mesh App v$version';
  }

  @override
  String get settings_aboutLegalese => '2026 Gulf Coast Mesh App';

  @override
  String get settings_aboutDescription =>
      'Открытое клиентское приложение на Flutter для устройств MeshCore с LoRa-сетями.';

  @override
  String get settings_aboutOpenMeteoAttribution =>
      'Данные о высоте LOS: Open-Meteo (CC BY 4.0)';

  @override
  String get settings_infoName => 'Имя';

  @override
  String get settings_infoId => 'ID';

  @override
  String get settings_infoStatus => 'Статус';

  @override
  String get settings_infoBattery => 'Батарея';

  @override
  String get settings_infoPublicKey => 'Публичный ключ';

  @override
  String get settings_infoContactsCount => 'Количество контактов';

  @override
  String get settings_infoChannelCount => 'Количество каналов';

  @override
  String get settings_presets => 'Пресеты';

  @override
  String get settings_frequency => 'Частота (МГц)';

  @override
  String get settings_frequencyHelper => '300.0 – 2500.0';

  @override
  String get settings_frequencyInvalid => 'Недопустимая частота (300–2500 МГц)';

  @override
  String get settings_bandwidth => 'Полоса пропускания';

  @override
  String get settings_spreadingFactor => 'Коэффициент расширения';

  @override
  String get settings_codingRate => 'Коэффициент кодирования';

  @override
  String get settings_txPower => 'Мощность передачи (дБм)';

  @override
  String get settings_txPowerHelper => '0 – 22';

  @override
  String get settings_txPowerInvalid =>
      'Недопустимая мощность передачи (0–22 дБм)';

  @override
  String get settings_clientRepeat => 'Повторение \"вне сети\"';

  @override
  String get settings_clientRepeatSubtitle =>
      'Позвольте этому устройству повторять пакеты данных для других устройств.';

  @override
  String get settings_clientRepeatFreqWarning =>
      'Для работы в режиме \"без подключения к сети\" требуется частота 433, 869 или 918 МГц.';

  @override
  String settings_error(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get appSettings_title => 'Настройки приложения';

  @override
  String get appSettings_appearance => 'Внешний вид';

  @override
  String get appSettings_theme => 'Тема';

  @override
  String get appSettings_themeSystem => 'Как в системе';

  @override
  String get appSettings_themeLight => 'Светлая';

  @override
  String get appSettings_themeDark => 'Тёмная';

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
  String get appSettings_language => 'Язык';

  @override
  String get appSettings_languageSystem => 'Как в системе';

  @override
  String get appSettings_languageEn => 'Английский';

  @override
  String get appSettings_languageFr => 'Французский';

  @override
  String get appSettings_languageEs => 'Испанский';

  @override
  String get appSettings_languageDe => 'Немецкий';

  @override
  String get appSettings_languagePl => 'Польский';

  @override
  String get appSettings_languageSl => 'Словенский';

  @override
  String get appSettings_languagePt => 'Португальский';

  @override
  String get appSettings_languageIt => 'Итальянский';

  @override
  String get appSettings_languageZh => 'Китайский';

  @override
  String get appSettings_languageSv => 'Шведский';

  @override
  String get appSettings_languageNl => 'Нидерландский';

  @override
  String get appSettings_languageSk => 'Словацкий';

  @override
  String get appSettings_languageBg => 'Болгарский';

  @override
  String get appSettings_languageRu => 'Русский';

  @override
  String get appSettings_languageUk => 'Українська';

  @override
  String get appSettings_enableMessageTracing =>
      'Включить трассировку сообщений';

  @override
  String get appSettings_enableMessageTracingSubtitle =>
      'Показывать подробные метаданные о маршрутизации и времени для сообщений';

  @override
  String get appSettings_notifications => 'Уведомления';

  @override
  String get appSettings_enableNotifications => 'Включить уведомления';

  @override
  String get appSettings_enableNotificationsSubtitle =>
      'Получать уведомления о сообщениях и оповещениях';

  @override
  String get appSettings_notificationPermissionDenied =>
      'Разрешение на уведомления отклонено';

  @override
  String get appSettings_notificationsEnabled => 'Уведомления включены';

  @override
  String get appSettings_notificationsDisabled => 'Уведомления отключены';

  @override
  String get appSettings_messageNotifications => 'Уведомления о сообщениях';

  @override
  String get appSettings_messageNotificationsSubtitle =>
      'Показывать уведомление при получении новых сообщений';

  @override
  String get appSettings_channelMessageNotifications =>
      'Уведомления о сообщениях в каналах';

  @override
  String get appSettings_channelMessageNotificationsSubtitle =>
      'Показывать уведомление при получении сообщений в каналах';

  @override
  String get appSettings_advertisementNotifications =>
      'Уведомления об анонсированиях';

  @override
  String get appSettings_advertisementNotificationsSubtitle =>
      'Показывать уведомление при обнаружении новых нод';

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
  String get appSettings_messaging => 'Обмен сообщениями';

  @override
  String get appSettings_clearPathOnMaxRetry =>
      'Сбросить маршрут после максимального числа попыток';

  @override
  String get appSettings_clearPathOnMaxRetrySubtitle =>
      'Сбросить маршрут контакта после 5 неудачных попыток отправки';

  @override
  String get appSettings_pathsWillBeCleared =>
      'Маршруты будут сброшены после 5 неудачных попыток';

  @override
  String get appSettings_pathsWillNotBeCleared =>
      'Маршруты не будут автоматически сбрасываться';

  @override
  String get appSettings_autoRouteRotation =>
      'Автоматическое переключение маршрутов';

  @override
  String get appSettings_autoRouteRotationSubtitle =>
      'Циклически переключаться между лучшими маршрутами и режимом рассылки';

  @override
  String get appSettings_autoRouteRotationEnabled =>
      'Автоматическое переключение маршрутов включено';

  @override
  String get appSettings_autoRouteRotationDisabled =>
      'Автоматическое переключение маршрутов отключено';

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
  String get appSettings_battery => 'Батарея';

  @override
  String get appSettings_batteryChemistry => 'Химия батареи';

  @override
  String appSettings_batteryChemistryPerDevice(String deviceName) {
    return 'Установить для устройства ($deviceName)';
  }

  @override
  String get appSettings_batteryChemistryConnectFirst =>
      'Подключитесь к устройству, чтобы выбрать';

  @override
  String get appSettings_batteryNmc => '18650 NMC (3.0–4.2 В)';

  @override
  String get appSettings_batteryLifepo4 => 'LiFePO4 (2.6–3.65 В)';

  @override
  String get appSettings_batteryLipo => 'LiPo (3.0–4.2 В)';

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
  String get appSettings_mapDisplay => 'Отображение карты';

  @override
  String get appSettings_showRepeaters => 'Показывать репитеры';

  @override
  String get appSettings_showRepeatersSubtitle =>
      'Отображать репитеры на карте';

  @override
  String get appSettings_showChatNodes => 'Показывать чат-ноды';

  @override
  String get appSettings_showChatNodesSubtitle =>
      'Отображать чат-ноды на карте';

  @override
  String get appSettings_showOtherNodes => 'Показывать другие ноды';

  @override
  String get appSettings_showOtherNodesSubtitle =>
      'Отображать другие типы нод на карте';

  @override
  String get appSettings_timeFilter => 'Фильтр по времени';

  @override
  String get appSettings_timeFilterShowAll => 'Показывать все ноды';

  @override
  String appSettings_timeFilterShowLast(int hours) {
    return 'Показывать ноды за последние $hours ч';
  }

  @override
  String get appSettings_mapTimeFilter => 'Временной фильтр карты';

  @override
  String get appSettings_showNodesDiscoveredWithin =>
      'Показывать ноды, обнаруженные за:';

  @override
  String get appSettings_allTime => 'Всё время';

  @override
  String get appSettings_lastHour => 'Последний час';

  @override
  String get appSettings_last6Hours => 'Последние 6 часов';

  @override
  String get appSettings_last24Hours => 'Последние 24 часа';

  @override
  String get appSettings_lastWeek => 'Последнюю неделю';

  @override
  String get appSettings_offlineMapCache => 'Кэш офлайн-карты';

  @override
  String get appSettings_unitsTitle => 'Единицы';

  @override
  String get appSettings_unitsMetric => 'Метрическая (м/км)';

  @override
  String get appSettings_unitsImperial => 'Имперская (ft / mi)';

  @override
  String get appSettings_noAreaSelected => 'Область не выбрана';

  @override
  String appSettings_areaSelectedZoom(int minZoom, int maxZoom) {
    return 'Область выбрана (масштаб $minZoom–$maxZoom)';
  }

  @override
  String get appSettings_debugCard => 'Отладка';

  @override
  String get appSettings_appDebugLogging => 'Журнал отладки приложения';

  @override
  String get appSettings_appDebugLoggingSubtitle =>
      'Записывать отладочные сообщения приложения для диагностики';

  @override
  String get appSettings_appDebugLoggingEnabled =>
      'Журнал отладки приложения включён';

  @override
  String get appSettings_appDebugLoggingDisabled =>
      'Журнал отладки приложения отключён';

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
  String get contacts_title => 'Контакты';

  @override
  String get contacts_noContacts => 'Контактов пока нет';

  @override
  String get contacts_contactsWillAppear =>
      'Контакты появятся, когда устройства начнут рассылать оповещения';

  @override
  String get contacts_searchContacts => 'Поиск контактов...';

  @override
  String get contacts_noUnreadContacts => 'Нет непрочитанных контактов';

  @override
  String get contacts_noContactsFound => 'Контакты или группы не найдены';

  @override
  String get contacts_deleteContact => 'Удалить контакт';

  @override
  String contacts_removeConfirm(String contactName) {
    return 'Удалить $contactName из контактов?';
  }

  @override
  String get contacts_manageRepeater => 'Управление репитером';

  @override
  String get contacts_manageRoom => 'Управление сервером комнат';

  @override
  String get contacts_roomLogin => 'Вход на сервер комнат';

  @override
  String get contacts_openChat => 'Открыть чат';

  @override
  String get contacts_editGroup => 'Изменить группу';

  @override
  String get contacts_deleteGroup => 'Удалить группу';

  @override
  String contacts_deleteGroupConfirm(String groupName) {
    return 'Удалить \"$groupName\"?';
  }

  @override
  String get contacts_newGroup => 'Новая группа';

  @override
  String get contacts_groupName => 'Имя группы';

  @override
  String get contacts_groupNameRequired => 'Имя группы обязательно';

  @override
  String contacts_groupAlreadyExists(String name) {
    return 'Группа \"$name\" уже существует';
  }

  @override
  String get contacts_filterContacts => 'Фильтр контактов...';

  @override
  String get contacts_noContactsMatchFilter =>
      'Нет контактов, соответствующих фильтру';

  @override
  String get contacts_noMembers => 'Нет участников';

  @override
  String get contacts_lastSeenNow => 'Видели только что';

  @override
  String contacts_lastSeenMinsAgo(int minutes) {
    return 'Видели $minutes мин назад';
  }

  @override
  String get contacts_lastSeenHourAgo => 'Видели 1 час назад';

  @override
  String contacts_lastSeenHoursAgo(int hours) {
    return 'Видели $hours ч назад';
  }

  @override
  String get contacts_lastSeenDayAgo => 'Видели 1 день назад';

  @override
  String contacts_lastSeenDaysAgo(int days) {
    return 'Видели $days дн. назад';
  }

  @override
  String get channels_title => 'Каналы';

  @override
  String get channels_noChannelsConfigured => 'Каналы не настроены';

  @override
  String get channels_addPublicChannel => 'Добавить публичный канал';

  @override
  String get channels_searchChannels => 'Поиск каналов...';

  @override
  String get channels_noChannelsFound => 'Каналы не найдены';

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
  String get channels_hashtagChannel => 'Хэштег-канал';

  @override
  String get channels_public => 'Публичный';

  @override
  String get channels_private => 'Приватный';

  @override
  String get channels_publicChannel => 'Публичный канал';

  @override
  String get channels_privateChannel => 'Приватный канал';

  @override
  String get channels_editChannel => 'Изменить канал';

  @override
  String get channels_deleteChannel => 'Удалить канал';

  @override
  String channels_deleteChannelConfirm(String name) {
    return 'Удалить \"$name\"? Это действие нельзя отменить.';
  }

  @override
  String get channels_deleteChannelRequiresConnection =>
      'Connect to a device to delete a channel';

  @override
  String channels_channelDeleted(String name) {
    return 'Канал \"$name\" удалён';
  }

  @override
  String get channels_addChannel => 'Добавить канал';

  @override
  String get channels_channelIndexLabel => 'Индекс канала';

  @override
  String get channels_channelName => 'Имя канала';

  @override
  String get channels_usePublicChannel => 'Использовать публичный канал';

  @override
  String get channels_standardPublicPsk => 'Стандартный публичный PSK';

  @override
  String get channels_pskHex => 'PSK (Hex)';

  @override
  String get channels_generateRandomPsk => 'Сгенерировать случайный PSK';

  @override
  String get channels_enterChannelName => 'Введите имя канала';

  @override
  String get channels_pskMustBe32Hex =>
      'PSK должен содержать 32 шестнадцатеричных символа';

  @override
  String channels_channelAdded(String name) {
    return 'Канал \"$name\" добавлен';
  }

  @override
  String channels_editChannelTitle(int index) {
    return 'Изменить канал $index';
  }

  @override
  String get channels_smazCompression => 'Сжатие SMAZ';

  @override
  String channels_channelUpdated(String name) {
    return 'Канал \"$name\" обновлён';
  }

  @override
  String get channels_publicChannelAdded => 'Публичный канал добавлен';

  @override
  String get channels_sortBy => 'Сортировка';

  @override
  String get channels_sortManual => 'Вручную';

  @override
  String get channels_sortAZ => 'По алфавиту';

  @override
  String get channels_sortLatestMessages => 'По последним сообщениям';

  @override
  String get channels_sortUnread => 'По непрочитанным';

  @override
  String get channels_createPrivateChannel => 'Создать приватный канал';

  @override
  String get channels_createPrivateChannelDesc => 'Защищён секретным ключом.';

  @override
  String get channels_joinPrivateChannel =>
      'Присоединиться к приватному каналу';

  @override
  String get channels_joinPrivateChannelDesc =>
      'Введите секретный ключ вручную.';

  @override
  String get channels_joinPublicChannel => 'Присоединиться к публичному каналу';

  @override
  String get channels_joinPublicChannelDesc =>
      'К этому каналу может присоединиться любой.';

  @override
  String get channels_joinHashtagChannel => 'Присоединиться к хэштег-каналу';

  @override
  String get channels_joinHashtagChannelDesc =>
      'К хэштег-каналам может присоединиться любой.';

  @override
  String get channels_scanQrCode => 'Сканировать QR-код';

  @override
  String get channels_scanQrCodeDesc =>
      'Import a channel invite with name, key, and optional region.';

  @override
  String get channels_scanQrCodeComingSoon => 'Скоро будет';

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
  String get channels_enterHashtag => 'Введите хэштег';

  @override
  String get channels_hashtagHint => 'например, #команда';

  @override
  String get chat_noMessages => 'Сообщений пока нет';

  @override
  String get chat_sendMessageToStart => 'Отправьте сообщение, чтобы начать';

  @override
  String get chat_originalMessageNotFound => 'Исходное сообщение не найдено';

  @override
  String chat_replyingTo(String name) {
    return 'Ответ для $name';
  }

  @override
  String chat_replyTo(String name) {
    return 'Ответить $name';
  }

  @override
  String get chat_location => 'Местоположение';

  @override
  String chat_sendMessageTo(String contactName) {
    return 'Отправить сообщение $contactName';
  }

  @override
  String get chat_typeMessage => 'Напишите сообщение...';

  @override
  String chat_messageTooLong(int maxBytes) {
    return 'Сообщение слишком длинное (макс. $maxBytes байт).';
  }

  @override
  String get chat_messageCopied => 'Сообщение скопировано';

  @override
  String get chat_messageDeleted => 'Сообщение удалено';

  @override
  String get chat_retryingMessage => 'Повтор отправки сообщения';

  @override
  String chat_retryCount(int current, int max) {
    return 'Попытка $current/$max';
  }

  @override
  String get chat_sendGif => 'Отправить GIF';

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
  String get chat_reply => 'Ответить';

  @override
  String get chat_addReaction => 'Добавить реакцию';

  @override
  String get chat_editMessage => 'Edit message';

  @override
  String get chat_editedLabel => '(edited)';

  @override
  String get chat_messageEdited => 'Message edited';

  @override
  String get chat_me => 'Я';

  @override
  String get emojiCategorySmileys => 'Смайлы';

  @override
  String get emojiCategoryGestures => 'Жесты';

  @override
  String get emojiCategoryHearts => 'Сердечки';

  @override
  String get emojiCategoryObjects => 'Предметы';

  @override
  String get gifPicker_title => 'Выберите GIF';

  @override
  String get gifPicker_searchHint => 'Поиск GIF...';

  @override
  String get gifPicker_poweredBy => 'Работает на GIPHY';

  @override
  String get gifPicker_noGifsFound => 'GIF не найдены';

  @override
  String get gifPicker_failedLoad => 'Не удалось загрузить GIF';

  @override
  String get gifPicker_failedSearch => 'Не удалось выполнить поиск GIF';

  @override
  String get gifPicker_noInternet => 'Нет подключения к интернету';

  @override
  String get debugLog_appTitle => 'Журнал отладки приложения';

  @override
  String get debugLog_bleTitle => 'Журнал отладки BLE';

  @override
  String get debugLog_copyLog => 'Копировать журнал';

  @override
  String get debugLog_clearLog => 'Очистить журнал';

  @override
  String get debugLog_copied => 'Журнал отладки скопирован';

  @override
  String get debugLog_bleCopied => 'Журнал BLE скопирован';

  @override
  String get debugLog_noEntries => 'Журнал отладки пока пуст';

  @override
  String get debugLog_enableInSettings =>
      'Включите запись журнала отладки в настройках';

  @override
  String get debugLog_frames => 'Фреймы';

  @override
  String get debugLog_rawLogRx => 'Сырой журнал приёма';

  @override
  String get debugLog_noBleActivity => 'Активность BLE пока отсутствует';

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
    return 'Длина фрейма: $count байт';
  }

  @override
  String debugFrame_command(String value) {
    return 'Команда: 0x$value';
  }

  @override
  String get debugFrame_textMessageHeader => 'Фрейм текстового сообщения:';

  @override
  String debugFrame_destinationPubKey(String pubKey) {
    return '- Публичный ключ получателя: $pubKey';
  }

  @override
  String debugFrame_timestamp(int timestamp) {
    return '- Временная метка: $timestamp';
  }

  @override
  String debugFrame_flags(String value) {
    return '- Флаги: 0x$value';
  }

  @override
  String debugFrame_textType(int type, String label) {
    return '- Тип текста: $type ($label)';
  }

  @override
  String get debugFrame_textTypeCli => 'CLI';

  @override
  String get debugFrame_textTypePlain => 'Обычный';

  @override
  String debugFrame_text(String text) {
    return '- Текст: \"$text\"';
  }

  @override
  String get debugFrame_hexDump => 'Шестнадцатеричный дамп:';

  @override
  String get chat_pathManagement => 'Управление маршрутами';

  @override
  String get chat_ShowAllPaths => 'Показать все пути';

  @override
  String get chat_routingMode => 'Режим маршрутизации';

  @override
  String get chat_autoUseSavedPath => 'Авто (использовать сохранённый маршрут)';

  @override
  String get chat_forceFloodMode => 'Принудительный режим рассылки';

  @override
  String get chat_recentAckPaths =>
      'Недавние подтверждённые маршруты (нажмите, чтобы использовать):';

  @override
  String get chat_pathHistoryFull =>
      'История маршрутов заполнена. Удалите записи, чтобы добавить новые.';

  @override
  String get chat_hopSingular => 'хоп';

  @override
  String get chat_hopPlural => 'хопов';

  @override
  String chat_hopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'хопов',
      many: 'хопов',
      few: 'хопа',
      one: 'хоп',
    );
    return '$count $_temp0';
  }

  @override
  String get chat_successes => 'успешно';

  @override
  String get chat_removePath => 'Удалить маршрут';

  @override
  String get chat_noPathHistoryYet =>
      'История маршрутов пока пуста.\nОтправьте сообщение, чтобы обнаружить маршруты.';

  @override
  String get chat_pathActions => 'Действия с маршрутом:';

  @override
  String get chat_setCustomPath => 'Указать маршрут вручную';

  @override
  String get chat_setCustomPathSubtitle => 'Вручную задать маршрут передачи';

  @override
  String get chat_clearPath => 'Очистить маршрут';

  @override
  String get chat_clearPathSubtitle =>
      'Принудительно обновить маршрут при следующей отправке';

  @override
  String get chat_pathCleared =>
      'Маршрут очищен. Следующее сообщение обновит маршрут.';

  @override
  String get chat_floodModeSubtitle =>
      'Используйте переключатель маршрутизации в панели приложения';

  @override
  String get chat_floodModeEnabled =>
      'Режим рассылки включён. Отключите через значок маршрутизации в панели приложения.';

  @override
  String get chat_fullPath => 'Полный маршрут';

  @override
  String get chat_pathDetailsNotAvailable =>
      'Детали маршрута ещё недоступны. Попробуйте отправить сообщение для обновления.';

  @override
  String chat_pathSetHops(int hopCount, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      hopCount,
      locale: localeName,
      other: 'хопов',
      many: 'хопов',
      few: 'хопа',
      one: 'хоп',
    );
    return 'Маршрут установлен: $hopCount $_temp0 — $status';
  }

  @override
  String get chat_pathSavedLocally =>
      'Сохранено локально. Подключитесь для синхронизации.';

  @override
  String get chat_pathDeviceConfirmed => 'Подтверждено устройством.';

  @override
  String get chat_pathDeviceNotConfirmed => 'Ещё не подтверждено устройством.';

  @override
  String get chat_type => 'Тип';

  @override
  String get chat_path => 'Маршрут';

  @override
  String get chat_publicKey => 'Публичный ключ';

  @override
  String get chat_compressOutgoingMessages => 'Сжимать исходящие сообщения';

  @override
  String get chat_floodForced => 'Рассылка (принудительно)';

  @override
  String get chat_directForced => 'Прямой (принудительно)';

  @override
  String chat_hopsForced(int count) {
    return '$count хоп(ов) (принудительно)';
  }

  @override
  String get chat_floodAuto => 'Рассылка (авто)';

  @override
  String get chat_direct => 'Прямой';

  @override
  String get chat_poiShared => 'Точка интереса отправлена';

  @override
  String chat_unread(int count) {
    return 'Непрочитанных: $count';
  }

  @override
  String get chat_openLink => 'Открыть ссылку?';

  @override
  String get chat_openLinkConfirmation =>
      'Хотите открыть эту ссылку в вашем браузере?';

  @override
  String get chat_open => 'Открыть';

  @override
  String chat_couldNotOpenLink(String url) {
    return 'Не удалось открыть ссылку: $url';
  }

  @override
  String get chat_invalidLink => 'Неправильный формат ссылки';

  @override
  String get map_title => 'Карта нод';

  @override
  String get map_lineOfSight => 'Линия видимости';

  @override
  String get map_losScreenTitle => 'Линия видимости';

  @override
  String get map_noNodesWithLocation => 'Нет нод с данными о местоположении';

  @override
  String get map_nodesNeedGps =>
      'Ноды должны передавать свои GPS-координаты, чтобы отображаться на карте';

  @override
  String map_nodesCount(int count) {
    return 'Нод: $count';
  }

  @override
  String map_pinsCount(int count) {
    return 'Меток: $count';
  }

  @override
  String get map_chat => 'Чат';

  @override
  String get map_repeater => 'Репитер';

  @override
  String get map_room => 'Комната';

  @override
  String get map_sensor => 'Сенсор';

  @override
  String get map_pinDm => 'Метка (ЛС)';

  @override
  String get map_pinPrivate => 'Метка (Приватная)';

  @override
  String get map_pinPublic => 'Метка (Публичная)';

  @override
  String get map_lastSeen => 'Последнее появление';

  @override
  String get map_disconnectConfirm =>
      'Вы уверены, что хотите отключиться от этого устройства?';

  @override
  String get map_from => 'От';

  @override
  String get map_source => 'Источник';

  @override
  String get map_flags => 'Флаги';

  @override
  String get map_pinLabel => 'Метка';

  @override
  String get map_label => 'Подпись';

  @override
  String get map_publicLocationShare => 'Публичная передача местоположения';

  @override
  String map_publicLocationShareConfirm(String channelLabel) {
    return 'Вы собираетесь поделиться местоположением в $channelLabel. Этот канал публичный, и любой, у кого есть PSK, сможет его увидеть.';
  }

  @override
  String get map_connectToShareMarkers =>
      'Подключитесь к устройству, чтобы делиться метками';

  @override
  String get map_filterNodes => 'Фильтр нод';

  @override
  String get map_nodeTypes => 'Типы нод';

  @override
  String get map_chatNodes => 'Чат-ноды';

  @override
  String get map_repeaters => 'Репитеры';

  @override
  String get map_otherNodes => 'Другие ноды';

  @override
  String get map_keyPrefix => 'Префикс ключа';

  @override
  String get map_filterByKeyPrefix => 'Фильтр по префиксу ключа';

  @override
  String get map_publicKeyPrefix => 'Префикс публичного ключа';

  @override
  String get map_markers => 'Метки';

  @override
  String get map_showSharedMarkers => 'Показывать общие метки';

  @override
  String get map_lastSeenTime => 'Время последнего появления';

  @override
  String get map_joinRoom => 'Присоединиться к комнате';

  @override
  String get map_manageRepeater => 'Управление репитером';

  @override
  String get map_tapToAdd => 'Нажимайте на узлы, чтобы добавить их в путь.';

  @override
  String get map_runTrace => 'Запустить трассировку пути';

  @override
  String get map_removeLast => 'Удалить последний';

  @override
  String get map_pathTraceCancelled => 'Отмена трассировки пути';

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
  String get mapCache_title => 'Кэш офлайн-карты';

  @override
  String get mapCache_selectAreaFirst =>
      'Сначала выберите область для кэширования';

  @override
  String get mapCache_noTilesToDownload =>
      'Нет плиток для загрузки в этой области';

  @override
  String get mapCache_downloadTilesTitle => 'Загрузить плитки';

  @override
  String mapCache_downloadTilesPrompt(int count) {
    return 'Загрузить $count плиток для офлайн-использования?';
  }

  @override
  String get mapCache_downloadAction => 'Загрузить';

  @override
  String mapCache_cachedTiles(int count) {
    return 'Закэшировано $count плиток';
  }

  @override
  String mapCache_cachedTilesWithFailed(int downloaded, int failed) {
    return 'Закэшировано $downloaded плиток ($failed не загружено)';
  }

  @override
  String get mapCache_clearOfflineCacheTitle => 'Очистить офлайн-кэш';

  @override
  String get mapCache_clearOfflineCachePrompt =>
      'Удалить все закэшированные плитки карты?';

  @override
  String get mapCache_offlineCacheCleared => 'Офлайн-кэш очищен';

  @override
  String get mapCache_noAreaSelected => 'Область не выбрана';

  @override
  String get mapCache_cacheArea => 'Область кэширования';

  @override
  String get mapCache_useCurrentView => 'Использовать текущий вид';

  @override
  String get mapCache_zoomRange => 'Диапазон масштаба';

  @override
  String mapCache_estimatedTiles(int count) {
    return 'Оценочное количество плиток: $count';
  }

  @override
  String mapCache_downloadedTiles(int completed, int total) {
    return 'Загружено $completed из $total';
  }

  @override
  String get mapCache_downloadTilesButton => 'Загрузить плитки';

  @override
  String get mapCache_clearCacheButton => 'Очистить кэш';

  @override
  String mapCache_failedDownloads(int count) {
    return 'Неудачных загрузок: $count';
  }

  @override
  String mapCache_boundsLabel(
    String north,
    String south,
    String east,
    String west,
  ) {
    return 'С $north, Ю $south, В $east, З $west';
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
  String get time_justNow => 'Только что';

  @override
  String time_minutesAgo(int minutes) {
    return '$minutes мин назад';
  }

  @override
  String time_hoursAgo(int hours) {
    return '$hours ч назад';
  }

  @override
  String time_daysAgo(int days) {
    return '$days дн. назад';
  }

  @override
  String get time_hour => 'час';

  @override
  String get time_hours => 'часов';

  @override
  String get time_day => 'день';

  @override
  String get time_days => 'дней';

  @override
  String get time_week => 'неделя';

  @override
  String get time_weeks => 'недель';

  @override
  String get time_month => 'месяц';

  @override
  String get time_months => 'месяцев';

  @override
  String get time_minutes => 'минут';

  @override
  String get time_allTime => 'Всё время';

  @override
  String get dialog_disconnect => 'Отключиться';

  @override
  String get dialog_disconnectConfirm =>
      'Вы уверены, что хотите отключиться от этого устройства?';

  @override
  String get login_repeaterLogin => 'Вход в репитер';

  @override
  String get login_roomLogin => 'Вход на сервер комнат';

  @override
  String get login_password => 'Пароль';

  @override
  String get login_enterPassword => 'Введите пароль';

  @override
  String get login_savePassword => 'Сохранить пароль';

  @override
  String get login_savePasswordSubtitle =>
      'Пароль будет надёжно сохранён на этом устройстве';

  @override
  String get login_repeaterDescription =>
      'Введите пароль репитера для доступа к настройкам и статусу.';

  @override
  String get login_roomDescription =>
      'Введите пароль комнаты для доступа к настройкам и статусу.';

  @override
  String get login_routing => 'Маршрутизация';

  @override
  String get login_routingMode => 'Режим маршрутизации';

  @override
  String get login_autoUseSavedPath =>
      'Авто (использовать сохранённый маршрут)';

  @override
  String get login_forceFloodMode => 'Принудительный режим рассылки';

  @override
  String get login_managePaths => 'Управление маршрутами';

  @override
  String get login_login => 'Войти';

  @override
  String login_attempt(int current, int max) {
    return 'Попытка $current/$max';
  }

  @override
  String login_failed(String error) {
    return 'Ошибка входа: $error';
  }

  @override
  String get login_failedMessage =>
      'Не удалось войти. Либо пароль неверен, либо репитер недоступен.';

  @override
  String get common_reload => 'Обновить';

  @override
  String get common_clear => 'Очистить';

  @override
  String path_currentPath(String path) {
    return 'Текущий маршрут: $path';
  }

  @override
  String path_usingHopsPath(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'хопов',
      many: 'хопов',
      few: 'хопа',
      one: 'хоп',
    );
    return 'Используется маршрут из $count $_temp0';
  }

  @override
  String get path_enterCustomPath => 'Введите маршрут вручную';

  @override
  String get path_currentPathLabel => 'Текущий маршрут';

  @override
  String get path_hexPrefixInstructions =>
      'Введите 2-символьные шестнадцатеричные префиксы для каждого хопа, разделённые запятыми.';

  @override
  String get path_hexPrefixExample =>
      'Пример: A1,F2,3C (каждый узел использует первый байт своего публичного ключа)';

  @override
  String get path_labelHexPrefixes => 'Маршрут (шестнадцатеричные префиксы)';

  @override
  String get path_helperMaxHops =>
      'Максимум 64 хопа. Каждый префикс — 2 шестнадцатеричных символа (1 байт)';

  @override
  String get path_selectFromContacts => 'Или выберите из контактов:';

  @override
  String get path_noRepeatersFound => 'Репитеры или серверы комнат не найдены.';

  @override
  String get path_customPathsRequire =>
      'Пользовательские маршруты требуют промежуточных узлов, способных ретранслировать сообщения.';

  @override
  String path_invalidHexPrefixes(String prefixes) {
    return 'Недопустимые шестнадцатеричные префиксы: $prefixes';
  }

  @override
  String get path_tooLong => 'Маршрут слишком длинный. Максимум 64 хопа.';

  @override
  String get path_setPath => 'Установить маршрут';

  @override
  String get repeater_management => 'Управление репитером';

  @override
  String get room_management => 'Управление сервером комнат';

  @override
  String get repeater_managementTools => 'Инструменты управления';

  @override
  String get repeater_status => 'Статус';

  @override
  String get repeater_statusSubtitle =>
      'Просмотр статуса, статистики и соседей репитера';

  @override
  String get repeater_sendAdvert => 'Send Advert';

  @override
  String get repeater_sendAdvertSubtitle =>
      'Broadcast an advertisement packet now';

  @override
  String get repeater_telemetry => 'Телеметрия';

  @override
  String get repeater_telemetrySubtitle =>
      'Просмотр телеметрии датчиков и системной статистики';

  @override
  String get repeater_cli => 'CLI';

  @override
  String get repeater_cliSubtitle => 'Отправка команд репитеру';

  @override
  String get repeater_neighbors => 'Соседи';

  @override
  String get repeater_neighborsSubtitle => 'Просмотр соседей на нулевом хопе.';

  @override
  String get repeater_settings => 'Настройки';

  @override
  String get repeater_settingsSubtitle => 'Настройка параметров репитера';

  @override
  String get repeater_statusTitle => 'Статус репитера';

  @override
  String get repeater_routingMode => 'Режим маршрутизации';

  @override
  String get repeater_autoUseSavedPath =>
      'Авто (использовать сохранённый маршрут)';

  @override
  String get repeater_forceFloodMode => 'Принудительный режим рассылки';

  @override
  String get repeater_pathManagement => 'Управление маршрутами';

  @override
  String get repeater_refresh => 'Обновить';

  @override
  String get repeater_statusRequestTimeout => 'Время ожидания статуса истекло.';

  @override
  String repeater_errorLoadingStatus(String error) {
    return 'Ошибка загрузки статуса: $error';
  }

  @override
  String get repeater_systemInformation => 'Системная информация';

  @override
  String get repeater_firmwareVersion => 'Firmware';

  @override
  String get repeater_battery => 'Батарея';

  @override
  String get repeater_clockAtLogin => 'Время (при входе)';

  @override
  String get repeater_uptime => 'Время работы';

  @override
  String get repeater_queueLength => 'Длина очереди';

  @override
  String get repeater_debugFlags => 'Флаги отладки';

  @override
  String get repeater_radioStatistics => 'Радиостатистика';

  @override
  String get repeater_lastRssi => 'Последний RSSI';

  @override
  String get repeater_lastSnr => 'Последний SNR';

  @override
  String get repeater_noiseFloor => 'Уровень шума';

  @override
  String get repeater_txAirtime => 'Время эфира (передача)';

  @override
  String get repeater_rxAirtime => 'Время эфира (приём)';

  @override
  String get repeater_packetStatistics => 'Статистика пакетов';

  @override
  String get repeater_sent => 'Отправлено';

  @override
  String get repeater_received => 'Получено';

  @override
  String get repeater_duplicates => 'Дубликаты';

  @override
  String repeater_daysHoursMinsSecs(
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return '$days дн. $hoursч $minutesм $secondsс';
  }

  @override
  String repeater_packetTxTotal(int total, String flood, String direct) {
    return 'Всего: $total, Рассылка: $flood, Прямые: $direct';
  }

  @override
  String repeater_packetRxTotal(int total, String flood, String direct) {
    return 'Всего: $total, Рассылка: $flood, Прямые: $direct';
  }

  @override
  String repeater_duplicatesFloodDirect(String flood, String direct) {
    return 'Рассылка: $flood, Прямые: $direct';
  }

  @override
  String repeater_duplicatesTotal(int total) {
    return 'Всего: $total';
  }

  @override
  String get repeater_settingsTitle => 'Настройки репитера';

  @override
  String get repeater_basicSettings => 'Основные настройки';

  @override
  String get repeater_repeaterName => 'Имя репитера';

  @override
  String get repeater_repeaterNameHelper => 'Отображаемое имя этого репитера';

  @override
  String get repeater_adminPassword => 'Пароль администратора';

  @override
  String get repeater_adminPasswordHelper => 'Пароль с полным доступом';

  @override
  String get repeater_guestPassword => 'Гостевой пароль';

  @override
  String get repeater_guestPasswordHelper =>
      'Пароль для доступа только для чтения';

  @override
  String get repeater_radioSettings => 'Настройки радио';

  @override
  String get repeater_frequencyMhz => 'Частота (МГц)';

  @override
  String get repeater_frequencyHelper => '300–2500 МГц';

  @override
  String get repeater_txPower => 'Мощность передачи';

  @override
  String get repeater_txPowerHelper => '1–30 дБм';

  @override
  String get repeater_bandwidth => 'Полоса пропускания';

  @override
  String get repeater_spreadingFactor => 'Коэффициент расширения';

  @override
  String get repeater_codingRate => 'Коэффициент кодирования';

  @override
  String get repeater_locationSettings => 'Настройки местоположения';

  @override
  String get repeater_latitude => 'Широта';

  @override
  String get repeater_latitudeHelper =>
      'В десятичных градусах (напр., 37.7749)';

  @override
  String get repeater_longitude => 'Долгота';

  @override
  String get repeater_longitudeHelper =>
      'В десятичных градусах (напр., -122.4194)';

  @override
  String get repeater_features => 'Функции';

  @override
  String get repeater_packetForwarding => 'Пересылка пакетов';

  @override
  String get repeater_packetForwardingSubtitle =>
      'Разрешить репитеру пересылать пакеты';

  @override
  String get repeater_guestAccess => 'Гостевой доступ';

  @override
  String get repeater_guestAccessSubtitle =>
      'Разрешить гостевой доступ только для чтения';

  @override
  String get repeater_privacyMode => 'Режим конфиденциальности';

  @override
  String get repeater_privacyModeSubtitle =>
      'Скрывать имя/местоположение в оповещениях';

  @override
  String get repeater_advertisementSettings => 'Настройки анонсирования';

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
  String get repeater_localAdvertInterval => 'Интервал локальных анонсирований';

  @override
  String repeater_localAdvertIntervalMinutes(int minutes) {
    return '$minutes минут';
  }

  @override
  String get repeater_floodAdvertInterval =>
      'Интервал анонсирований рассылкой (flood)';

  @override
  String repeater_floodAdvertIntervalHours(int hours) {
    return '$hours часов';
  }

  @override
  String get repeater_encryptedAdvertInterval =>
      'Интервал зашифрованных анонсирований';

  @override
  String get repeater_dangerZone => 'Опасная зона';

  @override
  String get repeater_rebootRepeater => 'Перезагрузить репитер';

  @override
  String get repeater_rebootRepeaterSubtitle =>
      'Перезапустить устройство репитера';

  @override
  String get repeater_rebootRepeaterConfirm =>
      'Вы уверены, что хотите перезагрузить этот репитер?';

  @override
  String get repeater_regenerateIdentityKeySubtitle =>
      'Сгенерировать новую пару публичного/приватного ключей';

  @override
  String get repeater_regenerateIdentityKeyConfirm =>
      'Это создаст новую идентичность для репитера. Продолжить?';

  @override
  String get repeater_eraseFileSystem => 'Стереть файловую систему';

  @override
  String get repeater_eraseFileSystemSubtitle =>
      'Отформатировать файловую систему репитера';

  @override
  String get repeater_eraseFileSystemConfirm =>
      'ВНИМАНИЕ: это удалит все данные на репитере. Действие нельзя отменить!';

  @override
  String get repeater_eraseSerialOnly =>
      'Очистка доступна только через последовательную консоль.';

  @override
  String repeater_commandSent(String command) {
    return 'Команда отправлена: $command';
  }

  @override
  String repeater_errorSendingCommand(String error) {
    return 'Ошибка отправки команды: $error';
  }

  @override
  String get repeater_confirm => 'Подтвердить';

  @override
  String get repeater_settingsSaved => 'Настройки успешно сохранены';

  @override
  String repeater_errorSavingSettings(String error) {
    return 'Ошибка сохранения настроек: $error';
  }

  @override
  String get repeater_refreshBasicSettings => 'Обновить основные настройки';

  @override
  String get repeater_refreshRadioSettings => 'Обновить настройки радио';

  @override
  String get repeater_refreshTxPower => 'Обновить мощность передачи';

  @override
  String get repeater_refreshLocationSettings =>
      'Обновить настройки местоположения';

  @override
  String get repeater_refreshPacketForwarding => 'Обновить пересылку пакетов';

  @override
  String get repeater_refreshGuestAccess => 'Обновить гостевой доступ';

  @override
  String get repeater_refreshPrivacyMode => 'Обновить режим конфиденциальности';

  @override
  String get repeater_refreshAdvertisementSettings =>
      'Обновить настройки анонсирований';

  @override
  String repeater_refreshed(String label) {
    return '$label обновлён';
  }

  @override
  String repeater_errorRefreshing(String label) {
    return 'Ошибка обновления $label';
  }

  @override
  String get repeater_cliTitle => 'CLI репитера';

  @override
  String get repeater_debugNextCommand => 'Отладка следующей команды';

  @override
  String get repeater_commandHelp => 'Справка по командам';

  @override
  String get repeater_clearHistory => 'Очистить историю';

  @override
  String get repeater_noCommandsSent => 'Команды ещё не отправлялись';

  @override
  String get repeater_typeCommandOrUseQuick =>
      'Введите команду ниже или используйте быстрые команды';

  @override
  String get repeater_enterCommandHint => 'Введите команду...';

  @override
  String get repeater_previousCommand => 'Предыдущая команда';

  @override
  String get repeater_nextCommand => 'Следующая команда';

  @override
  String get repeater_enterCommandFirst => 'Сначала введите команду';

  @override
  String get repeater_cliCommandFrameTitle => 'Фрейм CLI-команды';

  @override
  String repeater_cliCommandError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get repeater_cliQuickGetName => 'Получить имя';

  @override
  String get repeater_cliQuickGetRadio => 'Получить радио';

  @override
  String get repeater_cliQuickGetTx => 'Получить TX';

  @override
  String get repeater_cliQuickNeighbors => 'Соседи';

  @override
  String get repeater_cliQuickVersion => 'Версия';

  @override
  String get repeater_cliQuickAdvertise => 'Анонсировать';

  @override
  String get repeater_cliQuickClock => 'Время';

  @override
  String get repeater_cliHelpAdvert => 'Отправляет пакет анонсирования';

  @override
  String get repeater_cliHelpReboot =>
      'Перезагружает устройство. (обычно вы получите «Тайм-аут» — это нормально)';

  @override
  String get repeater_cliHelpClock =>
      'Показывает текущее время по часам устройства.';

  @override
  String get repeater_cliHelpPassword =>
      'Устанавливает новый пароль администратора для устройства.';

  @override
  String get repeater_cliHelpVersion =>
      'Показывает версию устройства и дату сборки прошивки.';

  @override
  String get repeater_cliHelpClearStats =>
      'Сбрасывает различные счётчики статистики в ноль.';

  @override
  String get repeater_cliHelpSetAf =>
      'Устанавливает коэффициент времени в эфире.';

  @override
  String get repeater_cliHelpSetTx =>
      'Устанавливает мощность передачи LoRa в дБм. (требуется перезагрузка)';

  @override
  String get repeater_cliHelpSetRepeat =>
      'Включает или отключает роль репитера для этой ноды.';

  @override
  String get repeater_cliHelpSetAllowReadOnly =>
      '(Сервер комнат) Если «on», то вход без пароля разрешён, но публиковать в комнату нельзя (только чтение)';

  @override
  String get repeater_cliHelpSetFloodMax =>
      'Устанавливает максимальное число хопов для входящих пакетов в режиме рассылки (если >= макс., пакет не пересылается)';

  @override
  String get repeater_cliHelpSetIntThresh =>
      'Устанавливает порог интерференции (в дБ). По умолчанию 14. Установите 0, чтобы отключить обнаружение помех.';

  @override
  String get repeater_cliHelpSetAgcResetInterval =>
      'Устанавливает интервал сброса автоматической регулировки усиления. Установите 0, чтобы отключить.';

  @override
  String get repeater_cliHelpSetMultiAcks =>
      'Включает или отключает функцию «двойных ACK».';

  @override
  String get repeater_cliHelpSetAdvertInterval =>
      'Устанавливает интервал (в минутах) отправки локального (нулевой хоп) анонсирования. Установите 0, чтобы отключить.';

  @override
  String get repeater_cliHelpSetFloodAdvertInterval =>
      'Устанавливает интервал (в часах) отправки анонсирований рассылкой. Установите 0, чтобы отключить.';

  @override
  String get repeater_cliHelpGetPathHashMode =>
      'Returns advert path hash mode (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetPathHashMode =>
      'Sets advert path hash mode for this repeater (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetGuestPassword =>
      'Устанавливает/обновляет гостевой пароль. (для репитеров гости могут отправлять запрос «Get Stats»)';

  @override
  String get repeater_cliHelpSetName => 'Устанавливает имя в оповещениях.';

  @override
  String get repeater_cliHelpSetLat =>
      'Устанавливает широту для карты в оповещениях. (десятичные градусы)';

  @override
  String get repeater_cliHelpSetLon =>
      'Устанавливает долготу для карты в оповещениях. (десятичные градусы)';

  @override
  String get repeater_cliHelpSetRadio =>
      'Устанавливает полностью новые параметры радио и сохраняет их в настройки. Требуется команда «reboot» для применения.';

  @override
  String get repeater_cliHelpSetRxDelay =>
      'Устанавливает (экспериментально) базовую задержку (>1 для эффекта) для принятых пакетов на основе качества сигнала. Установите 0, чтобы отключить.';

  @override
  String get repeater_cliHelpSetTxDelay =>
      'Устанавливает множитель времени в эфире для пакета в режиме рассылки и применяет случайную задержку перед пересылкой (чтобы уменьшить коллизии).';

  @override
  String get repeater_cliHelpSetDirectTxDelay =>
      'То же, что txdelay, но для случайной задержки пересылки пакетов в прямом режиме.';

  @override
  String get repeater_cliHelpSetBridgeEnabled => 'Включить/выключить мост.';

  @override
  String get repeater_cliHelpSetBridgeDelay =>
      'Установить задержку перед ретрансляцией пакетов.';

  @override
  String get repeater_cliHelpSetBridgeSource =>
      'Выбрать, будет ли мост ретранслировать полученные или отправленные пакеты.';

  @override
  String get repeater_cliHelpSetBridgeBaud =>
      'Установить скорость последовательного соединения для мостов RS232.';

  @override
  String get repeater_cliHelpSetBridgeSecret =>
      'Установить секрет моста для мостов ESP-NOW.';

  @override
  String get repeater_cliHelpSetAdcMultiplier =>
      'Устанавливает пользовательский коэффициент коррекции напряжения батареи (поддерживается только на некоторых платах).';

  @override
  String get repeater_cliHelpTempRadio =>
      'Устанавливает временные параметры радио на заданное число минут, затем возвращает исходные. (НЕ сохраняется в настройки).';

  @override
  String get repeater_cliHelpSetPerm =>
      'Изменяет ACL. Удаляет запись (по префиксу публичного ключа), если «permissions» равен нулю. Добавляет новую запись, если указан полный ключ и он отсутствует в ACL. Обновляет запись по совпадению префикса. Биты прав зависят от роли прошивки, но младшие 2 бита: 0 (Гость), 1 (Только чтение), 2 (Чтение/запись), 3 (Админ)';

  @override
  String get repeater_cliHelpGetBridgeType =>
      'Получает тип моста: none, rs232, espnow';

  @override
  String get repeater_cliHelpLogStart =>
      'Начинает запись пакетов в файловую систему.';

  @override
  String get repeater_cliHelpLogStop =>
      'Останавливает запись пакетов в файловую систему.';

  @override
  String get repeater_cliHelpLogErase =>
      'Удаляет журналы пакетов из файловой системы.';

  @override
  String get repeater_cliHelpNeighbors =>
      'Показывает список других репитеров, услышанных через оповещения нулевого хопа. Каждая строка: префикс-id-в-hex:временная-метка:snr×4';

  @override
  String get repeater_cliHelpNeighborRemove =>
      'Удаляет первую подходящую запись (по префиксу публичного ключа в hex) из списка соседей.';

  @override
  String get repeater_cliHelpRegion =>
      '(только через последовательный порт) Показывает все определённые регионы и текущие права на рассылку.';

  @override
  String get repeater_cliHelpRegionLoad =>
      'ПРИМЕЧАНИЕ: это специальная многострочная команда. Каждая следующая строка — имя региона (с отступом пробелами для указания иерархии, минимум один пробел). Завершается пустой строкой.';

  @override
  String get repeater_cliHelpRegionGet =>
      'Ищет регион по префиксу имени (или «*» для глобальной области). Отвечает: «-> имя-региона (родитель) \'F\'»';

  @override
  String get repeater_cliHelpRegionPut =>
      'Добавляет или обновляет определение региона с заданным именем.';

  @override
  String get repeater_cliHelpRegionRemove =>
      'Удаляет определение региона с заданным именем. (должно точно совпадать и не иметь дочерних регионов)';

  @override
  String get repeater_cliHelpRegionAllowf =>
      'Разрешает рассылку («F»lood) для заданного региона. («*» для глобальной/устаревшей области)';

  @override
  String get repeater_cliHelpRegionDenyf =>
      'Запрещает рассылку («F»lood) для заданного региона. (НЕ рекомендуется для глобальной области!)';

  @override
  String get repeater_cliHelpRegionHome =>
      'Показывает текущий «домашний» регион. (Пока не используется, зарезервировано на будущее)';

  @override
  String get repeater_cliHelpRegionHomeSet =>
      'Устанавливает «домашний» регион.';

  @override
  String get repeater_cliHelpRegionSave =>
      'Сохраняет список/карту регионов в память.';

  @override
  String get repeater_cliHelpGps =>
      'Показывает статус GPS. Если GPS выключен — отвечает только «off». Если включён — показывает статус, фиксацию, количество спутников.';

  @override
  String get repeater_cliHelpGpsOnOff => 'Переключает состояние питания GPS.';

  @override
  String get repeater_cliHelpGpsSync =>
      'Синхронизирует время ноды с часами GPS.';

  @override
  String get repeater_cliHelpGpsSetLoc =>
      'Устанавливает позицию ноды по координатам GPS и сохраняет в настройки.';

  @override
  String get repeater_cliHelpGpsAdvert =>
      'Показывает конфигурацию передачи местоположения в анонсированиях:\n- none: не включать местоположение\n- share: передавать GPS-координаты (из SensorManager)\n- prefs: передавать координаты из настроек';

  @override
  String get repeater_cliHelpGpsAdvertSet =>
      'Устанавливает конфигурацию передачи местоположения.';

  @override
  String get repeater_commandsListTitle => 'Список команд';

  @override
  String get repeater_commandsListNote =>
      'ПРИМЕЧАНИЕ: для большинства команд «set ...» существуют соответствующие команды «get ...».';

  @override
  String get repeater_general => 'Общие';

  @override
  String get repeater_settingsCategory => 'Настройки';

  @override
  String get repeater_bridge => 'Мост';

  @override
  String get repeater_logging => 'Журналирование';

  @override
  String get repeater_neighborsRepeaterOnly => 'Соседи (только для репитеров)';

  @override
  String get repeater_regionManagementRepeaterOnly =>
      'Управление регионами (только для репитеров)';

  @override
  String get repeater_regionNote =>
      'Команды регионов введены для управления определениями регионов и правами доступа.';

  @override
  String get repeater_gpsManagement => 'Управление GPS';

  @override
  String get repeater_gpsNote =>
      'Команда gps введена для управления параметрами, связанными с местоположением.';

  @override
  String get telemetry_receivedData => 'Полученные телеметрические данные';

  @override
  String get telemetry_requestTimeout => 'Время ожидания телеметрии истекло.';

  @override
  String telemetry_errorLoading(String error) {
    return 'Ошибка загрузки телеметрии: $error';
  }

  @override
  String get telemetry_noData => 'Данные телеметрии недоступны.';

  @override
  String telemetry_channelTitle(int channel) {
    return 'Канал $channel';
  }

  @override
  String get telemetry_batteryLabel => 'Батарея';

  @override
  String get telemetry_voltageLabel => 'Напряжение';

  @override
  String get telemetry_mcuTemperatureLabel => 'Температура МК';

  @override
  String get telemetry_temperatureLabel => 'Температура';

  @override
  String get telemetry_currentLabel => 'Ток';

  @override
  String telemetry_batteryValue(int percent, String volts) {
    return '$percent% / $voltsВ';
  }

  @override
  String telemetry_voltageValue(String volts) {
    return '$voltsВ';
  }

  @override
  String telemetry_currentValue(String amps) {
    return '$ampsА';
  }

  @override
  String telemetry_temperatureValue(String celsius, String fahrenheit) {
    return '$celsius°C / $fahrenheit°F';
  }

  @override
  String get neighbors_receivedData => 'Полученные данные о соседях';

  @override
  String get neighbors_requestTimedOut =>
      'Время ожидания данных о соседях истекло.';

  @override
  String neighbors_errorLoading(String error) {
    return 'Ошибка загрузки соседей: $error';
  }

  @override
  String get neighbors_repeatersNeighbors => 'Соседи репитеров';

  @override
  String get neighbors_noData => 'Данные о соседях недоступны.';

  @override
  String neighbors_unknownContact(String pubkey) {
    return 'Неизвестный $pubkey';
  }

  @override
  String neighbors_heardAgo(String time) {
    return 'Слушал(а): $time назад';
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
  String get channelPath_title => 'Путь пакета';

  @override
  String get channelPath_viewMap => 'Посмотреть на карте';

  @override
  String get channelPath_otherObservedPaths => 'Другие наблюдаемые пути';

  @override
  String get channelPath_repeaterHops => 'Хопы через репитеры';

  @override
  String get channelPath_noHopDetails =>
      'Детали хопов для этого пакета не предоставлены.';

  @override
  String get channelPath_messageDetails => 'Детали сообщения';

  @override
  String get channelPath_senderLabel => 'Отправитель';

  @override
  String get channelPath_timeLabel => 'Время';

  @override
  String get channelPath_repeatsLabel => 'Повторы';

  @override
  String channelPath_pathLabel(int index) {
    return 'Путь $index';
  }

  @override
  String get channelPath_observedLabel => 'Наблюдаемый';

  @override
  String channelPath_observedPathTitle(int index, String hops) {
    return 'Наблюдаемый путь $index • $hops';
  }

  @override
  String get channelPath_noLocationData => 'Нет данных о местоположении';

  @override
  String channelPath_timeWithDate(int day, int month, String time) {
    return '$day/$month $time';
  }

  @override
  String channelPath_timeOnly(String time) {
    return '$time';
  }

  @override
  String get channelPath_unknownPath => 'Неизвестный';

  @override
  String get channelPath_floodPath => 'Рассылка';

  @override
  String get channelPath_directPath => 'Прямой';

  @override
  String channelPath_observedZeroOf(int total) {
    return '0 из $total хопов';
  }

  @override
  String channelPath_observedSomeOf(int observed, int total) {
    return '$observed из $total хопов';
  }

  @override
  String get channelPath_mapTitle => 'Карта пути';

  @override
  String get channelPath_noRepeaterLocations =>
      'Нет данных о местоположении репитеров для этого пути.';

  @override
  String channelPath_primaryPath(int index) {
    return 'Путь $index (Основной)';
  }

  @override
  String get channelPath_pathLabelTitle => 'Путь';

  @override
  String get channelPath_observedPathHeader => 'Наблюдаемый путь';

  @override
  String channelPath_selectedPathLabel(String label, String prefixes) {
    return '$label • $prefixes';
  }

  @override
  String get channelPath_noHopDetailsAvailable =>
      'Детали хопов для этого пакета недоступны.';

  @override
  String get channelPath_unknownRepeater => 'Неизвестный репитер';

  @override
  String get community_title => 'Сообщество';

  @override
  String get community_create => 'Создать сообщество';

  @override
  String get community_createDesc =>
      'Создать новое сообщество и поделиться через QR-код.';

  @override
  String get community_join => 'Присоединиться';

  @override
  String get community_joinTitle => 'Присоединиться к сообществу';

  @override
  String community_joinConfirmation(String name) {
    return 'Вы хотите присоединиться к сообществу  \"$name\"?';
  }

  @override
  String get community_scanQr => 'Сканировать QR-код сообщества';

  @override
  String get community_scanInstructions =>
      'Наведите камеру на QR-код сообщества';

  @override
  String get community_showQr => 'Показать QR-код';

  @override
  String get community_publicChannel => 'Публичный канал сообщества';

  @override
  String get community_hashtagChannel => 'Хэштег-канал сообщества';

  @override
  String get community_name => 'Имя сообщества';

  @override
  String get community_enterName => 'Введите имя сообщества';

  @override
  String community_created(String name) {
    return 'Сообщество \"$name\" создано';
  }

  @override
  String community_joined(String name) {
    return 'Присоединились к сообществу \"$name\"';
  }

  @override
  String get community_qrTitle => 'Поделиться сообществом';

  @override
  String community_qrInstructions(String name) {
    return 'Отсканируйте этот QR-код, чтобы присоединиться к \"$name\"';
  }

  @override
  String get community_hashtagPrivacyHint =>
      'Хэштег-каналы сообщества доступны только его участникам';

  @override
  String get community_invalidQrCode => 'Недопустимый QR-код сообщества';

  @override
  String get community_alreadyMember => 'Уже участник';

  @override
  String community_alreadyMemberMessage(String name) {
    return 'Вы уже участник сообщества \"$name\".';
  }

  @override
  String get community_addPublicChannel =>
      'Добавить публичный канал сообщества';

  @override
  String get community_addPublicChannelHint =>
      'Автоматически добавить публичный канал для этого сообщества';

  @override
  String get community_noCommunities =>
      'Вы ещё не присоединились ни к одному сообществу';

  @override
  String get community_scanOrCreate =>
      'Отсканируйте QR-код или создайте сообщество, чтобы начать';

  @override
  String get community_manageCommunities => 'Управление сообществами';

  @override
  String get community_delete => 'Покинуть сообщество';

  @override
  String community_deleteConfirm(String name) {
    return 'Покинуть \"$name\"?';
  }

  @override
  String community_deleteChannelsWarning(int count) {
    return 'Это также удалит $count канал(ов) и их сообщения.';
  }

  @override
  String community_deleted(String name) {
    return 'Покинули сообщество \"$name\"';
  }

  @override
  String get community_regenerateSecret => 'Пересоздать секрет';

  @override
  String community_regenerateSecretConfirm(String name) {
    return 'Пересоздать секретный ключ для \"$name\"? Все участники должны будут отсканировать новый QR-код для продолжения общения.';
  }

  @override
  String get community_regenerate => 'Пересоздать';

  @override
  String community_secretRegenerated(String name) {
    return 'Секрет пересоздан для \"$name\"';
  }

  @override
  String get community_updateSecret => 'Обновить секрет';

  @override
  String community_secretUpdated(String name) {
    return 'Секрет обновлён для \"$name\"';
  }

  @override
  String community_scanToUpdateSecret(String name) {
    return 'Отсканируйте новый QR-код, чтобы обновить секрет для \"$name\"';
  }

  @override
  String get community_addHashtagChannel => 'Добавить хэштег-канал сообщества';

  @override
  String get community_addHashtagChannelDesc =>
      'Добавить хэштег-канал для этого сообщества';

  @override
  String get community_selectCommunity => 'Выбрать сообщество';

  @override
  String get community_regularHashtag => 'Обычный хэштег';

  @override
  String get community_regularHashtagDesc =>
      'Публичный хэштег (любой может присоединиться)';

  @override
  String get community_communityHashtag => 'Хэштег сообщества';

  @override
  String get community_communityHashtagDesc =>
      'Доступен только участникам сообщества';

  @override
  String community_forCommunity(String name) {
    return 'Для $name';
  }

  @override
  String get listFilter_tooltip => 'Фильтр и сортировка';

  @override
  String get listFilter_sortBy => 'Сортировка по';

  @override
  String get listFilter_latestMessages => 'Последние сообщения';

  @override
  String get listFilter_heardRecently => 'Слышали недавно';

  @override
  String get listFilter_az => 'По алфавиту';

  @override
  String get listFilter_filters => 'Фильтры';

  @override
  String get listFilter_all => 'Все';

  @override
  String get listFilter_users => 'Пользователи';

  @override
  String get listFilter_repeaters => 'Репитеры';

  @override
  String get listFilter_roomServers => 'Серверы комнат';

  @override
  String get listFilter_unreadOnly => 'Только непрочитанные';

  @override
  String get listFilter_newGroup => 'Новая группа';

  @override
  String get pathTrace_you => 'Вы';

  @override
  String get pathTrace_failed => 'Путь трассировки не выполнен.';

  @override
  String get pathTrace_notAvailable => 'Трассировка пути недоступна.';

  @override
  String get pathTrace_refreshTooltip => 'Обновить Path Trace';

  @override
  String get pathTrace_someHopsNoLocation =>
      'Одному или нескольким хмелям не указано местоположение!';

  @override
  String get pathTrace_clearTooltip => 'Очистить путь';

  @override
  String get losSelectStartEnd => 'Выберите начальный и конечный узлы для LOS.';

  @override
  String losRunFailed(String error) {
    return 'Проверка прямой видимости не удалась: $error';
  }

  @override
  String get losClearAllPoints => 'Очистить все точки';

  @override
  String get losRunToViewElevationProfile =>
      'Запустите LOS, чтобы просмотреть профиль высот.';

  @override
  String get losMenuTitle => 'ЛОС Меню';

  @override
  String get losMenuSubtitle =>
      'Коснитесь узлов или нажмите и удерживайте карту для выбора пользовательских точек.';

  @override
  String get losShowDisplayNodes => 'Показать узлы отображения';

  @override
  String get losCustomPoints => 'Пользовательские точки';

  @override
  String losCustomPointLabel(int index) {
    return 'Пользовательский $index';
  }

  @override
  String get losPointA => 'Точка А';

  @override
  String get losPointB => 'Точка Б';

  @override
  String losAntennaA(String value, String unit) {
    return 'Антенна А: $value $unit';
  }

  @override
  String losAntennaB(String value, String unit) {
    return 'Антенна Б: $value $unit';
  }

  @override
  String get losRun => 'Запустить ЛОС';

  @override
  String get losNoElevationData => 'Нет данных о высоте';

  @override
  String losProfileClear(
    String distance,
    String distanceUnit,
    String clearance,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, свободная зона видимости, минимальный зазор $clearance $heightUnit';
  }

  @override
  String losProfileBlocked(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, заблокирован $obstruction $heightUnit';
  }

  @override
  String get losStatusChecking => 'ЛОС: проверяю...';

  @override
  String get losStatusNoData => 'ЛОС: нет данных';

  @override
  String losStatusSummary(int clear, int total, int blocked, int unknown) {
    return 'LOS: $clear/$total очищено, $blocked заблокировано, $unknown неизвестно.';
  }

  @override
  String get losErrorElevationUnavailable =>
      'Данные о высоте недоступны для одного или нескольких образцов.';

  @override
  String get losErrorInvalidInput =>
      'Неверные данные о точках/высоте для расчета LOS.';

  @override
  String get losRenameCustomPoint => 'Переименовать пользовательскую точку';

  @override
  String get losPointName => 'Имя точки';

  @override
  String get losShowPanelTooltip => 'Показать панель LOS';

  @override
  String get losHidePanelTooltip => 'Скрыть панель LOS';

  @override
  String get losElevationAttribution =>
      'Данные о высоте: Open-Meteo (CC BY 4.0)';

  @override
  String get contacts_pathTrace => 'Трассировка пути';

  @override
  String get contacts_ping => 'Пинговать';

  @override
  String get contacts_repeaterPathTrace => 'Отследить путь к ретранслятору';

  @override
  String get contacts_repeaterPing => 'Пинговать повторитель';

  @override
  String get contacts_roomPathTrace => 'Трассировка пути к серверу комнаты';

  @override
  String get contacts_roomPing => 'Пинговать сервер комнаты';

  @override
  String get contacts_chatTraceRoute => 'Трассировка маршрута';

  @override
  String contacts_pathTraceTo(String name) {
    return 'Показать маршрут к $name';
  }

  @override
  String get contacts_clipboardEmpty => 'Буфер обмена пуст.';

  @override
  String get contacts_invalidAdvertFormat =>
      'Недействительные контактные данные';

  @override
  String get contacts_contactImported => 'Контакт был импортирован';

  @override
  String get contacts_contactImportFailed => 'Контакт не удалось импортировать';

  @override
  String get contacts_zeroHopAdvert => 'Реклама Zero Hop';

  @override
  String get contacts_floodAdvert => 'Рекламный поток';

  @override
  String get contacts_copyAdvertToClipboard =>
      'Копировать рекламу в буфер обмена';

  @override
  String get contacts_addContactFromClipboard =>
      'Добавить контакт из буфера обмена';

  @override
  String get contacts_ShareContact => 'Копировать контакт в буфер обмена';

  @override
  String get contacts_ShareContactZeroHop =>
      'Поделиться контактом по объявлению';

  @override
  String get contacts_zeroHopContactAdvertSent =>
      'Отправлено сообщение по объявлению.';

  @override
  String get contacts_zeroHopContactAdvertFailed =>
      'Не удалось отправить контакт.';

  @override
  String get contacts_contactAdvertCopied =>
      'Реклама скопирована в буфер обмена.';

  @override
  String get contacts_contactAdvertCopyFailed =>
      'Копирование рекламы в буфер обмена не удалось.';

  @override
  String get notification_activityTitle => 'Активность MeshCore';

  @override
  String notification_messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'сообщений',
      many: 'сообщений',
      few: 'сообщения',
      one: 'сообщение',
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
      other: 'сообщений канала',
      many: 'сообщений канала',
      few: 'сообщения канала',
      one: 'сообщение канала',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'новых узлов',
      many: 'новых узлов',
      few: 'новых узла',
      one: 'новый узел',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newTypeDiscovered(String contactType) {
    return 'Обнаружен новый $contactType';
  }

  @override
  String get notification_receivedNewMessage => 'Получено новое сообщение';

  @override
  String get settings_gpxExportRepeaters =>
      'Экспортировать рипитеры / сервер комнаты в GPX';

  @override
  String get settings_gpxExportRepeatersSubtitle =>
      'Экспортирует ретрансляторы / сервер комнат с местоположением в файл GPX.';

  @override
  String get settings_gpxExportContacts => 'Экспортировать спутников в GPX';

  @override
  String get settings_gpxExportContactsSubtitle =>
      'Экспортирует спутников с местоположением в файл GPX.';

  @override
  String get settings_gpxExportAll => 'Экспортировать все контакты в GPX';

  @override
  String get settings_gpxExportAllSubtitle =>
      'Экспортирует все контакты с местоположением в файл GPX.';

  @override
  String get settings_gpxExportSuccess => 'Успешно экспортирован файл GPX.';

  @override
  String get settings_gpxExportNoContacts => 'Нет контактов для экспорта.';

  @override
  String get settings_gpxExportNotAvailable =>
      'Не поддерживается на вашем устройстве/ОС';

  @override
  String get settings_gpxExportError => 'Произошла ошибка при экспорте.';

  @override
  String get settings_gpxExportRepeatersRoom =>
      'Местоположения повторителей и серверов комнат';

  @override
  String get settings_gpxExportChat => 'Местоположения спутников';

  @override
  String get settings_gpxExportAllContacts => 'Все местоположения контактов';

  @override
  String get settings_gpxExportShareText =>
      'Данные карты экспортированы из Gulf Coast Mesh App';

  @override
  String get settings_gpxExportShareSubject =>
      'Gulf Coast Mesh App экспорт данных карты GPX';

  @override
  String get snrIndicator_nearByRepeaters => 'Ближайшие ретрансляторы';

  @override
  String get snrIndicator_lastSeen => 'Последний раз видели';

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
  String get repeater_regenerateIdentityKey => 'Пересоздать ключ идентификации';

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
  String get appSettings_nodeBlocking => 'Блокировка нод';

  @override
  String get appSettings_nodeBlockingSubtitle =>
      'Скрывать выбранные ноды на карте, в контактах и чатах и отключать их уведомления. Только в приложении: ничего не удаляется с вашей радиостанции.';

  @override
  String get appSettings_blockedNodes => 'Заблокированные ноды';

  @override
  String appSettings_blockedNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заблокированной ноды',
      many: '$count заблокированных нод',
      few: '$count заблокированные ноды',
      one: '1 заблокированная нода',
      zero: 'Пока нет заблокированных',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_title => 'Заблокированные ноды';

  @override
  String get blockedNodes_howItWorks => 'Как работает блокировка';

  @override
  String get blockedNodes_infoHidden => 'Скрыты на карте, в контактах и чатах';

  @override
  String get blockedNodes_infoMuted =>
      'Без уведомлений о новых нодах и о сообщениях от них';

  @override
  String get blockedNodes_infoKept =>
      'Ничего не удаляется. Они остаются на вашем сопутствующем устройстве, а их сообщения сохраняются';

  @override
  String get blockedNodes_infoRelay =>
      'Заблокированные ретрансляторы по-прежнему могут передавать ваши сообщения по сети';

  @override
  String get blockedNodes_infoChannels =>
      'Их сообщения в каналах по-прежнему отображаются';

  @override
  String get blockedNodes_emptyTitle => 'Нет заблокированных нод';

  @override
  String get blockedNodes_emptyHint =>
      'Нажмите и удерживайте ноду в Контактах или на Карте и выберите «Заблокировать ноду».';

  @override
  String get blockedNodes_unblock => 'Разблокировать';

  @override
  String get blockedNodes_unblockAll => 'Разблокировать все';

  @override
  String blockedNodes_unblockAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Разблокировать $count ноды? Они снова появятся на карте и в контактах.',
      many:
          'Разблокировать $count нод? Они снова появятся на карте и в контактах.',
      few:
          'Разблокировать $count ноды? Они снова появятся на карте и в контактах.',
      one: 'Разблокировать 1 ноду? Она снова появится на карте и в контактах.',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_unknownNode => 'Неизвестная нода';

  @override
  String blockedNodes_blockedOn(String date) {
    return 'Заблокировано: $date';
  }

  @override
  String get blockedNodes_blockAction => 'Заблокировать ноду';

  @override
  String blockedNodes_blockConfirmTitle(String name) {
    return 'Заблокировать $name?';
  }

  @override
  String get blockedNodes_blockConfirmBody =>
      'Нода будет скрыта на карте, в контактах и чатах, и вы не будете получать от неё уведомления о новых нодах или сообщениях. Ничего не удаляется с вашей радиостанции. Разблокировать можно в любое время: Настройки приложения > Экспериментальное > Заблокированные ноды.';

  @override
  String get blockedNodes_blockConfirmButton => 'Заблокировать';

  @override
  String blockedNodes_blocked(String name) {
    return 'Заблокировано: $name';
  }

  @override
  String blockedNodes_unblocked(String name) {
    return 'Разблокировано: $name';
  }

  @override
  String get blockedNodes_undo => 'Отменить';
}
