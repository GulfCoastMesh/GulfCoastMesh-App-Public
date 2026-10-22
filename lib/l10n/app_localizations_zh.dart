// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

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
  String get nav_contacts => '联系方式';

  @override
  String get nav_channels => '频道';

  @override
  String get nav_map => '地图';

  @override
  String get nav_chats => '聊天';

  @override
  String get nav_nodes => '节点';

  @override
  String get nav_settings => '设置';

  @override
  String get common_cancel => '取消';

  @override
  String get common_ok => '好的';

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
  String get common_connect => '连接';

  @override
  String get common_unknownDevice => '未知设备';

  @override
  String get common_save => '保存';

  @override
  String get common_delete => '删除';

  @override
  String get common_close => '关闭';

  @override
  String get common_edit => '编辑';

  @override
  String get common_add => '添加';

  @override
  String get common_settings => '设置';

  @override
  String get common_disconnect => '断开';

  @override
  String get common_connected => '连接';

  @override
  String get common_disconnected => '断开';

  @override
  String get common_reconnecting => 'Reconnecting';

  @override
  String get common_create => '创造';

  @override
  String get common_continue => '继续';

  @override
  String get common_share => '分享';

  @override
  String get common_copy => '复制';

  @override
  String get common_retry => '重试';

  @override
  String get common_hide => '隐藏';

  @override
  String get common_remove => '移除';

  @override
  String get common_enable => '启用';

  @override
  String get common_disable => '禁用';

  @override
  String get common_reboot => '重新启动';

  @override
  String get common_loading => '正在加载...';

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
  String get scanner_scanning => '正在搜索设备...';

  @override
  String get scanner_connecting => '正在连接...';

  @override
  String get scanner_disconnecting => '断开连接...';

  @override
  String get scanner_notConnected => '未连接';

  @override
  String scanner_connectedTo(String deviceName) {
    return '已连接到 $deviceName';
  }

  @override
  String get scanner_searchingDevices => '正在搜索 MeshCore 设备...';

  @override
  String get scanner_tapToScan => '点击“扫描”功能，以查找 MeshCore 设备。';

  @override
  String scanner_connectionFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get scanner_backgroundBleMayDrop =>
      'Background BLE may drop without notification permission.';

  @override
  String get scanner_stop => '停止';

  @override
  String get scanner_scan => '扫描';

  @override
  String get scanner_bluetoothOff => '蓝牙已关闭';

  @override
  String get scanner_bluetoothOffMessage => '请打开蓝牙功能，以便搜索设备。';

  @override
  String get scanner_enableBluetooth => '启用蓝牙';

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
  String get device_quickSwitch => '快速切换';

  @override
  String get device_meshcore => '网格核心';

  @override
  String get settings_title => '设置';

  @override
  String get settings_deviceInfo => '设备信息';

  @override
  String get settings_appSettings => '应用设置';

  @override
  String get settings_appSettingsSubtitle => '通知、消息和地图偏好';

  @override
  String get settings_nodeSettings => '节点设置';

  @override
  String get settings_nodeName => '节点名称';

  @override
  String get settings_nodeNameNotSet => '未设置';

  @override
  String get settings_nodeNameHint => '请输入节点名称';

  @override
  String get settings_nodeNameUpdated => '姓名已更新';

  @override
  String get settings_radioSettings => '收音机设置';

  @override
  String get settings_radioSettingsSubtitle => '频率、功率、扩频因子';

  @override
  String get settings_radioSettingsUpdated => '收音机设置已更新';

  @override
  String get settings_location => '地点';

  @override
  String get settings_locationSubtitle => 'GPS 坐标';

  @override
  String get settings_locationUpdated => '位置和 GPS 设置已更新';

  @override
  String get settings_locationBothRequired => '请输入经度和纬度。';

  @override
  String get settings_locationInvalid => '无效的经度和纬度。';

  @override
  String get settings_locationGPSEnable => '开启 GPS 功能';

  @override
  String get settings_locationGPSEnableSubtitle => '使 GPS 能够自动更新位置。';

  @override
  String get settings_locationIntervalSec => 'GPS 间隔时间（秒）';

  @override
  String get settings_usePhoneGps => 'Use phone GPS';

  @override
  String get settings_locationIntervalInvalid => '间隔时间必须至少为 60 秒，但不超过 86400 秒。';

  @override
  String get settings_latitude => '纬度';

  @override
  String get settings_longitude => '经度';

  @override
  String get settings_privacyMode => '隐私模式';

  @override
  String get settings_privacyModeSubtitle => '在广告中隐藏姓名/位置';

  @override
  String get settings_privacyModeToggle => '切换隐私模式，以隐藏您的姓名和位置，从而在广告中保护您的个人信息。';

  @override
  String get settings_privacyModeEnabled => '隐私模式已启用';

  @override
  String get settings_privacyModeDisabled => '隐私模式已关闭';

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
  String get settings_actions => '行动';

  @override
  String get settings_sendAdvertisement => '发布广告';

  @override
  String get settings_sendAdvertisementSubtitle => '现已开始进行广播节目';

  @override
  String get settings_advertisementSent => '已发送广告';

  @override
  String get settings_syncTime => '同步时间';

  @override
  String get settings_syncTimeSubtitle => '将设备时钟设置为与手机时间一致';

  @override
  String get settings_timeSynchronized => '时间同步';

  @override
  String get settings_refreshContacts => '刷新联系人';

  @override
  String get settings_refreshContactsSubtitle => '从设备中重新加载联系人列表';

  @override
  String get settings_rebootDevice => '重启设备';

  @override
  String get settings_rebootDeviceSubtitle => '重新启动 MeshCore 设备';

  @override
  String get settings_rebootDeviceConfirm => '您确定要重启设备吗？这将导致您与设备断开连接。';

  @override
  String get settings_debug => '调试';

  @override
  String get settings_bleDebugLog => 'BLE 调试日志';

  @override
  String get settings_bleDebugLogSubtitle => 'BLE 命令、响应和原始数据';

  @override
  String get settings_appDebugLog => '应用程序调试日志';

  @override
  String get settings_appDebugLogSubtitle => '应用程序调试消息';

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
  String get settings_about => '关于';

  @override
  String settings_aboutVersion(String version) {
    return 'Gulf Coast Mesh App v$version';
  }

  @override
  String get settings_aboutLegalese => '2026 Gulf Coast Mesh App';

  @override
  String get settings_aboutDescription =>
      '一个开源的 Flutter 客户端，用于 MeshCore LoRa 无线网络设备。';

  @override
  String get settings_aboutOpenMeteoAttribution =>
      'LOS 高程数据:Open-Meteo (CC BY 4.0)';

  @override
  String get settings_infoName => '姓名';

  @override
  String get settings_infoId => 'ID';

  @override
  String get settings_infoStatus => '状态';

  @override
  String get settings_infoBattery => '电池';

  @override
  String get settings_infoPublicKey => '公钥';

  @override
  String get settings_infoContactsCount => '联系人数量';

  @override
  String get settings_infoChannelCount => '通道数量';

  @override
  String get settings_presets => '预设';

  @override
  String get settings_frequency => '频率 (MHz)';

  @override
  String get settings_frequencyHelper => '300.0 - 2500.0';

  @override
  String get settings_frequencyInvalid => '无效频率（300-2500 MHz）';

  @override
  String get settings_bandwidth => '带宽';

  @override
  String get settings_spreadingFactor => '传播系数';

  @override
  String get settings_codingRate => '编码速率';

  @override
  String get settings_txPower => 'TX 功率（dBm）';

  @override
  String get settings_txPowerHelper => '0 - 22';

  @override
  String get settings_txPowerInvalid => '无效的发射功率（0-22 dBm）';

  @override
  String get settings_clientRepeat => '离网重复';

  @override
  String get settings_clientRepeatSubtitle => '允许此设备重复发送网状数据包给其他设备';

  @override
  String get settings_clientRepeatFreqWarning =>
      '离网重复通信需要使用 433、869 或 918 兆赫兹的频率。';

  @override
  String settings_error(String message) {
    return '[保存：$message]\n错误：$message';
  }

  @override
  String get appSettings_title => '应用设置';

  @override
  String get appSettings_appearance => '外观';

  @override
  String get appSettings_theme => '主题';

  @override
  String get appSettings_themeSystem => '系统默认设置';

  @override
  String get appSettings_themeLight => '光';

  @override
  String get appSettings_themeDark => '黑暗';

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
  String get appSettings_language => '语言';

  @override
  String get appSettings_languageSystem => '系统默认设置';

  @override
  String get appSettings_languageEn => '英语';

  @override
  String get appSettings_languageFr => '法语';

  @override
  String get appSettings_languageEs => '西班牙语';

  @override
  String get appSettings_languageDe => '德语';

  @override
  String get appSettings_languagePl => '波兰语';

  @override
  String get appSettings_languageSl => '斯洛文语';

  @override
  String get appSettings_languagePt => '葡萄牙语';

  @override
  String get appSettings_languageIt => '意大利语';

  @override
  String get appSettings_languageZh => '中文';

  @override
  String get appSettings_languageSv => '瑞典语';

  @override
  String get appSettings_languageNl => '荷兰语';

  @override
  String get appSettings_languageSk => '斯洛伐克语';

  @override
  String get appSettings_languageBg => '保加利亚';

  @override
  String get appSettings_languageRu => '俄语';

  @override
  String get appSettings_languageUk => '乌克兰';

  @override
  String get appSettings_enableMessageTracing => '启用消息追踪';

  @override
  String get appSettings_enableMessageTracingSubtitle => '显示消息的详细路由和时间元数据';

  @override
  String get appSettings_notifications => '通知';

  @override
  String get appSettings_enableNotifications => '启用通知';

  @override
  String get appSettings_enableNotificationsSubtitle => '接收消息和广告的通知';

  @override
  String get appSettings_notificationPermissionDenied => '权限被拒绝';

  @override
  String get appSettings_notificationsEnabled => '通知已启用';

  @override
  String get appSettings_notificationsDisabled => '通知已关闭';

  @override
  String get appSettings_messageNotifications => '消息通知';

  @override
  String get appSettings_messageNotificationsSubtitle => '在收到新消息时显示通知';

  @override
  String get appSettings_channelMessageNotifications => '频道消息通知';

  @override
  String get appSettings_channelMessageNotificationsSubtitle =>
      '在收到频道消息时，显示通知。';

  @override
  String get appSettings_advertisementNotifications => '广告通知';

  @override
  String get appSettings_advertisementNotificationsSubtitle => '在发现新的节点时，显示通知。';

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
  String get appSettings_messaging => '信息传递';

  @override
  String get appSettings_clearPathOnMaxRetry => '关于“最大重试”的清晰说明';

  @override
  String get appSettings_clearPathOnMaxRetrySubtitle => '在尝试发送失败后 5 次，重置联系路径。';

  @override
  String get appSettings_pathsWillBeCleared => '如果尝试 5 次后仍然失败，则将重新规划路径。';

  @override
  String get appSettings_pathsWillNotBeCleared => '路径不会自动清除。';

  @override
  String get appSettings_autoRouteRotation => '自动路径轮换';

  @override
  String get appSettings_autoRouteRotationSubtitle => '在最佳路径和防洪模式之间切换';

  @override
  String get appSettings_autoRouteRotationEnabled => '自动路径轮换已启用';

  @override
  String get appSettings_autoRouteRotationDisabled => '自动路径轮换已禁用';

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
  String get appSettings_battery => '电池';

  @override
  String get appSettings_batteryChemistry => '电池化学';

  @override
  String appSettings_batteryChemistryPerDevice(String deviceName) {
    return '为每个设备设置 ($deviceName)';
  }

  @override
  String get appSettings_batteryChemistryConnectFirst => '连接到设备以进行选择';

  @override
  String get appSettings_batteryNmc => '18650 型号，NMC 电池（3.0-4.2V）';

  @override
  String get appSettings_batteryLifepo4 => '磷酸铁锂 (2.6-3.65V)';

  @override
  String get appSettings_batteryLipo => '锂离子电池 (3.0-4.2V)';

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
  String get appSettings_mapDisplay => '地图展示';

  @override
  String get appSettings_showRepeaters => '显示重复';

  @override
  String get appSettings_showRepeatersSubtitle => '在地图上显示重复节点';

  @override
  String get appSettings_showChatNodes => '显示聊天节点';

  @override
  String get appSettings_showChatNodesSubtitle => '在地图上显示聊天节点';

  @override
  String get appSettings_showOtherNodes => '显示其他节点';

  @override
  String get appSettings_showOtherNodesSubtitle => '在地图上显示其他节点类型';

  @override
  String get appSettings_timeFilter => '时间过滤器';

  @override
  String get appSettings_timeFilterShowAll => '显示所有节点';

  @override
  String appSettings_timeFilterShowLast(int hours) {
    return 'Show nodes from last $hours hours';
  }

  @override
  String get appSettings_mapTimeFilter => '地图时间筛选';

  @override
  String get appSettings_showNodesDiscoveredWithin => '显示在以下范围内发现的节点：';

  @override
  String get appSettings_allTime => '所有时间';

  @override
  String get appSettings_lastHour => '过去一小时';

  @override
  String get appSettings_last6Hours => '过去6小时';

  @override
  String get appSettings_last24Hours => '过去24小时';

  @override
  String get appSettings_lastWeek => '上周';

  @override
  String get appSettings_offlineMapCache => '离线地图缓存';

  @override
  String get appSettings_unitsTitle => '单位';

  @override
  String get appSettings_unitsMetric => '公制（米/公里）';

  @override
  String get appSettings_unitsImperial => '英制 (ft / mi)';

  @override
  String get appSettings_noAreaSelected => '未选择任何区域';

  @override
  String appSettings_areaSelectedZoom(int minZoom, int maxZoom) {
    return '已选择区域（缩放至 $minZoom - $maxZoom）';
  }

  @override
  String get appSettings_debugCard => '调试';

  @override
  String get appSettings_appDebugLogging => '应用程序调试日志';

  @override
  String get appSettings_appDebugLoggingSubtitle => '用于故障排除的日志应用程序调试消息';

  @override
  String get appSettings_appDebugLoggingEnabled => '调试日志已启用';

  @override
  String get appSettings_appDebugLoggingDisabled => '应用程序调试日志已禁用';

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
  String get contacts_title => '联系方式';

  @override
  String get contacts_noContacts => '目前还没有联系人';

  @override
  String get contacts_contactsWillAppear => '当设备发布广告时，联系方式会显示。';

  @override
  String get contacts_searchContacts => '搜索联系人...';

  @override
  String get contacts_noUnreadContacts => '没有未读通讯';

  @override
  String get contacts_noContactsFound => '未找到任何联系人或群组';

  @override
  String get contacts_deleteContact => '删除联系人';

  @override
  String contacts_removeConfirm(String contactName) {
    return 'Remove $contactName from contacts?';
  }

  @override
  String get contacts_manageRepeater => '管理重复器';

  @override
  String get contacts_manageRoom => '管理房间服务器';

  @override
  String get contacts_roomLogin => '服务器登录';

  @override
  String get contacts_openChat => '开放聊天';

  @override
  String get contacts_editGroup => '编辑小组';

  @override
  String get contacts_deleteGroup => '删除群组';

  @override
  String contacts_deleteGroupConfirm(String groupName) {
    return '删除\"$groupName\"？';
  }

  @override
  String get contacts_newGroup => '新的团体';

  @override
  String get contacts_groupName => '团体名称';

  @override
  String get contacts_groupNameRequired => '需要提供组名称';

  @override
  String contacts_groupAlreadyExists(String name) {
    return '名为\"$name\"的组已经存在';
  }

  @override
  String get contacts_filterContacts => '筛选联系人...';

  @override
  String get contacts_noContactsMatchFilter => '未找到符合您筛选条件的联系人';

  @override
  String get contacts_noMembers => '没有会员';

  @override
  String get contacts_lastSeenNow => '最后一次被看到的时间';

  @override
  String contacts_lastSeenMinsAgo(int minutes) {
    return 'Last seen $minutes mins ago';
  }

  @override
  String get contacts_lastSeenHourAgo => '最后一次被看到的时间：1小时前';

  @override
  String contacts_lastSeenHoursAgo(int hours) {
    return 'Last seen $hours hours ago';
  }

  @override
  String get contacts_lastSeenDayAgo => '最后一次被看到的时间是1天前';

  @override
  String contacts_lastSeenDaysAgo(int days) {
    return 'Last seen $days days ago';
  }

  @override
  String get channels_title => '频道';

  @override
  String get channels_noChannelsConfigured => '未配置任何频道';

  @override
  String get channels_addPublicChannel => '添加公共频道';

  @override
  String get channels_searchChannels => '搜索频道...';

  @override
  String get channels_noChannelsFound => '未找到任何频道';

  @override
  String get channels_channelSlotsFull =>
      'All device channel slots are in use. Delete a channel before adding another.';

  @override
  String channels_channelAddFailed(String error) {
    return 'Could not add channel: $error';
  }

  @override
  String channels_channelIndex(int index) {
    return '频道 $index';
  }

  @override
  String get channels_hashtagChannel => '话题标签频道';

  @override
  String get channels_public => '公众';

  @override
  String get channels_private => '私人';

  @override
  String get channels_publicChannel => '公共频道';

  @override
  String get channels_privateChannel => '私密频道';

  @override
  String get channels_editChannel => '编辑频道';

  @override
  String get channels_deleteChannel => '删除频道';

  @override
  String channels_deleteChannelConfirm(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get channels_deleteChannelRequiresConnection =>
      'Connect to a device to delete a channel';

  @override
  String channels_channelDeleted(String name) {
    return '删除频道 \"$name\"';
  }

  @override
  String get channels_addChannel => '添加频道';

  @override
  String get channels_channelIndexLabel => '频道索引';

  @override
  String get channels_channelName => '频道名称';

  @override
  String get channels_usePublicChannel => '使用公共频道';

  @override
  String get channels_standardPublicPsk => '标准公共PSK';

  @override
  String get channels_pskHex => 'PSK (十六进制)';

  @override
  String get channels_generateRandomPsk => '生成随机的PSK（正交相移键控）';

  @override
  String get channels_enterChannelName => '请在此处输入频道名称';

  @override
  String get channels_pskMustBe32Hex => 'PSK 必须包含 32 个十六进制字符。';

  @override
  String channels_channelAdded(String name) {
    return '添加频道 \"$name\"';
  }

  @override
  String channels_editChannelTitle(int index) {
    return '编辑频道 $index';
  }

  @override
  String get channels_smazCompression => 'SMAZ 压缩';

  @override
  String channels_channelUpdated(String name) {
    return '频道 \"$name\" 已更新';
  }

  @override
  String get channels_publicChannelAdded => '已添加公共频道';

  @override
  String get channels_sortBy => '按排序';

  @override
  String get channels_sortManual => '手册';

  @override
  String get channels_sortAZ => 'A 到 Z';

  @override
  String get channels_sortLatestMessages => '最新消息';

  @override
  String get channels_sortUnread => '未读';

  @override
  String get channels_createPrivateChannel => '创建私密频道';

  @override
  String get channels_createPrivateChannelDesc => '使用秘密密钥进行保护。';

  @override
  String get channels_joinPrivateChannel => '加入私密频道';

  @override
  String get channels_joinPrivateChannelDesc => '手动输入密钥。';

  @override
  String get channels_joinPublicChannel => '加入公共频道';

  @override
  String get channels_joinPublicChannelDesc => '任何人都可以加入这个频道。';

  @override
  String get channels_joinHashtagChannel => '加入一个带有特定标签的频道';

  @override
  String get channels_joinHashtagChannelDesc => '任何人都可以加入带有特定标签的频道。';

  @override
  String get channels_scanQrCode => '扫描二维码';

  @override
  String get channels_scanQrCodeDesc =>
      'Import a channel invite with name, key, and optional region.';

  @override
  String get channels_scanQrCodeComingSoon => '即将发布';

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
  String get channels_enterHashtag => '输入标签';

  @override
  String get channels_hashtagHint => '例如：#团队';

  @override
  String get chat_noMessages => '目前还没有收到任何消息。';

  @override
  String get chat_sendMessageToStart => '发送消息以开始';

  @override
  String get chat_originalMessageNotFound => '无法找到原始消息';

  @override
  String chat_replyingTo(String name) {
    return 'Replying to $name';
  }

  @override
  String chat_replyTo(String name) {
    return 'Reply to $name';
  }

  @override
  String get chat_location => '地点';

  @override
  String chat_sendMessageTo(String contactName) {
    return 'Send a message to $contactName';
  }

  @override
  String get chat_typeMessage => '输入消息...';

  @override
  String chat_messageTooLong(int maxBytes) {
    return '消息内容过长（最大 $maxBytes 字节）。';
  }

  @override
  String get chat_messageCopied => '消息已复制';

  @override
  String get chat_messageDeleted => '消息已删除';

  @override
  String get chat_retryingMessage => '重试消息';

  @override
  String chat_retryCount(int current, int max) {
    return 'Retry $current/$max';
  }

  @override
  String get chat_sendGif => '发送 GIF 动画';

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
  String get chat_reply => '回复';

  @override
  String get chat_addReaction => '添加评论';

  @override
  String get chat_editMessage => 'Edit message';

  @override
  String get chat_editedLabel => '(edited)';

  @override
  String get chat_messageEdited => 'Message edited';

  @override
  String get chat_me => '我';

  @override
  String get emojiCategorySmileys => '表情符号';

  @override
  String get emojiCategoryGestures => '手势';

  @override
  String get emojiCategoryHearts => '心脏';

  @override
  String get emojiCategoryObjects => '物体';

  @override
  String get gifPicker_title => '选择一个 GIF 动画';

  @override
  String get gifPicker_searchHint => '搜索 GIF 动画...';

  @override
  String get gifPicker_poweredBy => '由 GIPHY 提供支持';

  @override
  String get gifPicker_noGifsFound => '未找到 GIF 动画';

  @override
  String get gifPicker_failedLoad => '无法加载 GIF 动画';

  @override
  String get gifPicker_failedSearch => '未能搜索 GIF 动画';

  @override
  String get gifPicker_noInternet => '没有互联网连接';

  @override
  String get debugLog_appTitle => '应用程序调试日志';

  @override
  String get debugLog_bleTitle => 'BLE 调试日志';

  @override
  String get debugLog_copyLog => '复制日志';

  @override
  String get debugLog_clearLog => '清晰的日志';

  @override
  String get debugLog_copied => '调试日志已复制';

  @override
  String get debugLog_bleCopied => 'BLE 日志已复制';

  @override
  String get debugLog_noEntries => '目前还没有调试日志';

  @override
  String get debugLog_enableInSettings => '在设置中启用应用程序调试日志功能。';

  @override
  String get debugLog_frames => '框架';

  @override
  String get debugLog_rawLogRx => '原始日志-RX';

  @override
  String get debugLog_noBleActivity => '目前尚未有蓝牙低功耗（BLE）活动。';

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
    return '帧长度：$count 字节';
  }

  @override
  String debugFrame_command(String value) {
    return '命令：0x$value';
  }

  @override
  String get debugFrame_textMessageHeader => '短信模板：';

  @override
  String debugFrame_destinationPubKey(String pubKey) {
    return '- 目标公钥：$pubKey';
  }

  @override
  String debugFrame_timestamp(int timestamp) {
    return '- Timestamp: $timestamp';
  }

  @override
  String debugFrame_flags(String value) {
    return '- 标志：0x$value';
  }

  @override
  String debugFrame_textType(int type, String label) {
    return '- Text Type: $type ($label)';
  }

  @override
  String get debugFrame_textTypeCli => '命令行界面';

  @override
  String get debugFrame_textTypePlain => '简单';

  @override
  String debugFrame_text(String text) {
    return '- 文本：“$text”';
  }

  @override
  String get debugFrame_hexDump => '十六进制数据：';

  @override
  String get chat_pathManagement => '路径管理';

  @override
  String get chat_ShowAllPaths => '显示所有路径';

  @override
  String get chat_routingMode => '路由模式';

  @override
  String get chat_autoUseSavedPath => '自动（使用已保存的路径）';

  @override
  String get chat_forceFloodMode => '强制洪水模式';

  @override
  String get chat_recentAckPaths => '最近使用的 ACK 路径（点击使用）：';

  @override
  String get chat_pathHistoryFull => '路径历史已满。删除条目以添加新的条目。';

  @override
  String get chat_hopSingular => '跳跃';

  @override
  String get chat_hopPlural => '啤酒花';

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
  String get chat_successes => '成功';

  @override
  String get chat_removePath => '删除路径';

  @override
  String get chat_noPathHistoryYet => '目前还没有历史记录。\n发送消息以查找路径。';

  @override
  String get chat_pathActions => '路径操作：';

  @override
  String get chat_setCustomPath => '设置自定义路径';

  @override
  String get chat_setCustomPathSubtitle => '手动指定路由路径';

  @override
  String get chat_clearPath => '明确的道路';

  @override
  String get chat_clearPathSubtitle => '在下一次发送时，重新尝试。';

  @override
  String get chat_pathCleared => '路径已清理。下一条消息将重新确定路线。';

  @override
  String get chat_floodModeSubtitle => '使用应用程序栏中的路由切换功能';

  @override
  String get chat_floodModeEnabled => '防洪模式已启用。通过应用程序栏中的路由图标进行切换。';

  @override
  String get chat_fullPath => '完整路径';

  @override
  String get chat_pathDetailsNotAvailable => '路径信息尚未提供。请尝试发送消息以刷新。';

  @override
  String chat_pathSetHops(int hopCount, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      hopCount,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Path set: $hopCount $_temp0 - $status';
  }

  @override
  String get chat_pathSavedLocally => '已本地保存。连接以进行同步。';

  @override
  String get chat_pathDeviceConfirmed => '设备已确认。';

  @override
  String get chat_pathDeviceNotConfirmed => '该设备尚未得到确认。';

  @override
  String get chat_type => '类型';

  @override
  String get chat_path => '路径';

  @override
  String get chat_publicKey => '公钥';

  @override
  String get chat_compressOutgoingMessages => '压缩发送的消息';

  @override
  String get chat_floodForced => '洪水（被迫）';

  @override
  String get chat_directForced => '直接（强制性的）';

  @override
  String chat_hopsForced(int count) {
    return '$count 根啤酒花（人工种植）';
  }

  @override
  String get chat_floodAuto => '自动洪水';

  @override
  String get chat_direct => '直接';

  @override
  String get chat_poiShared => '共享位置';

  @override
  String chat_unread(int count) {
    return 'Unread: $count';
  }

  @override
  String get chat_openLink => '打开链接？';

  @override
  String get chat_openLinkConfirmation => '您想用浏览器打开这个链接吗？';

  @override
  String get chat_open => '开放';

  @override
  String chat_couldNotOpenLink(String url) {
    return '[保存：$url]\n无法打开链接：$url';
  }

  @override
  String get chat_invalidLink => '无效的链接格式';

  @override
  String get map_title => '节点图';

  @override
  String get map_lineOfSight => '视线';

  @override
  String get map_losScreenTitle => '视线';

  @override
  String get map_noNodesWithLocation => '没有包含位置信息的节点';

  @override
  String get map_nodesNeedGps => '节点需要共享其 GPS 坐标，以便在地图上显示';

  @override
  String map_nodesCount(int count) {
    return 'Nodes: $count';
  }

  @override
  String map_pinsCount(int count) {
    return 'Pins: $count';
  }

  @override
  String get map_chat => '聊天';

  @override
  String get map_repeater => '重复器';

  @override
  String get map_room => '房间';

  @override
  String get map_sensor => '传感器';

  @override
  String get map_pinDm => 'PIN (直接消息)';

  @override
  String get map_pinPrivate => '私密';

  @override
  String get map_pinPublic => '公开';

  @override
  String get map_lastSeen => '最后一次被看到';

  @override
  String get map_disconnectConfirm => '您确定要断开与此设备的连接吗？';

  @override
  String get map_from => '从';

  @override
  String get map_source => '来源';

  @override
  String get map_flags => '旗帜';

  @override
  String get map_pinLabel => '标签';

  @override
  String get map_label => '标签';

  @override
  String get map_publicLocationShare => '公共场所共享';

  @override
  String map_publicLocationShareConfirm(String channelLabel) {
    return '[保存：$channelLabel]\n您即将分享一个位置，该位置位于 $channelLabel。 此频道是公开的，任何拥有 PSK 的人都可以看到它。';
  }

  @override
  String get map_connectToShareMarkers => '连接设备以共享标记';

  @override
  String get map_filterNodes => '过滤节点';

  @override
  String get map_nodeTypes => '节点类型';

  @override
  String get map_chatNodes => '聊天节点';

  @override
  String get map_repeaters => '重复器';

  @override
  String get map_otherNodes => '其他节点';

  @override
  String get map_keyPrefix => '关键前缀';

  @override
  String get map_filterByKeyPrefix => '按关键前缀筛选';

  @override
  String get map_publicKeyPrefix => '公钥前缀';

  @override
  String get map_markers => '标记';

  @override
  String get map_showSharedMarkers => '显示共享标记';

  @override
  String get map_lastSeenTime => '最后一次被看到的时间';

  @override
  String get map_joinRoom => '加入房间';

  @override
  String get map_manageRepeater => '管理重复器';

  @override
  String get map_tapToAdd => '点击节点将其添加到路径中';

  @override
  String get map_runTrace => '运行路径跟踪';

  @override
  String get map_removeLast => '删除最后一个';

  @override
  String get map_pathTraceCancelled => '路径跟踪已取消';

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
  String get mapCache_title => '离线地图缓存';

  @override
  String get mapCache_selectAreaFirst => '选择一个用于缓存的区域';

  @override
  String get mapCache_noTilesToDownload => '此区域没有可下载的瓦片。';

  @override
  String get mapCache_downloadTilesTitle => '下载瓷砖';

  @override
  String mapCache_downloadTilesPrompt(int count) {
    return '[保存：$count]\n下载 $count 个图片用于离线使用？';
  }

  @override
  String get mapCache_downloadAction => '下载';

  @override
  String mapCache_cachedTiles(int count) {
    return '缓存 $count 个瓦片';
  }

  @override
  String mapCache_cachedTilesWithFailed(int downloaded, int failed) {
    return 'Cached $downloaded tiles ($failed failed)';
  }

  @override
  String get mapCache_clearOfflineCacheTitle => '清除离线缓存';

  @override
  String get mapCache_clearOfflineCachePrompt => '清除所有缓存的地图瓦片';

  @override
  String get mapCache_offlineCacheCleared => '离线缓存已清除';

  @override
  String get mapCache_noAreaSelected => '未选择任何区域';

  @override
  String get mapCache_cacheArea => '缓存区域';

  @override
  String get mapCache_useCurrentView => '使用当前视图';

  @override
  String get mapCache_zoomRange => '变焦范围';

  @override
  String mapCache_estimatedTiles(int count) {
    return 'Estimated tiles: $count';
  }

  @override
  String mapCache_downloadedTiles(int completed, int total) {
    return 'Downloaded $completed / $total';
  }

  @override
  String get mapCache_downloadTilesButton => '下载瓷砖';

  @override
  String get mapCache_clearCacheButton => '清除缓存';

  @override
  String mapCache_failedDownloads(int count) {
    return 'Failed downloads: $count';
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
  String get time_justNow => '刚才';

  @override
  String time_minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String time_hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String time_daysAgo(int days) {
    return '$days天前';
  }

  @override
  String get time_hour => '小时';

  @override
  String get time_hours => '小时';

  @override
  String get time_day => '一天';

  @override
  String get time_days => '天';

  @override
  String get time_week => '一周';

  @override
  String get time_weeks => '周';

  @override
  String get time_month => '月份';

  @override
  String get time_months => '月份';

  @override
  String get time_minutes => '分钟';

  @override
  String get time_allTime => '所有时间';

  @override
  String get dialog_disconnect => '断开';

  @override
  String get dialog_disconnectConfirm => '您确定要断开与此设备的连接吗？';

  @override
  String get login_repeaterLogin => '重复登录';

  @override
  String get login_roomLogin => '服务器登录';

  @override
  String get login_password => '密码';

  @override
  String get login_enterPassword => '请输入密码';

  @override
  String get login_savePassword => '保存密码';

  @override
  String get login_savePasswordSubtitle => '密码将安全地存储在此设备上';

  @override
  String get login_repeaterDescription => '输入重复器密码，即可访问设置和状态。';

  @override
  String get login_roomDescription => '输入密码进入房间，即可访问设置和状态。';

  @override
  String get login_routing => '路由';

  @override
  String get login_routingMode => '路由模式';

  @override
  String get login_autoUseSavedPath => '自动（使用已保存的路径）';

  @override
  String get login_forceFloodMode => '强制洪水模式';

  @override
  String get login_managePaths => '管理路径';

  @override
  String get login_login => '登录';

  @override
  String login_attempt(int current, int max) {
    return 'Attempt $current/$max';
  }

  @override
  String login_failed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get login_failedMessage => '登录失败。可能是密码错误，也可能是无法连接到服务器。';

  @override
  String get common_reload => '重新加载';

  @override
  String get common_clear => '清晰';

  @override
  String path_currentPath(String path) {
    return 'Current path: $path';
  }

  @override
  String path_usingHopsPath(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return '使用 $count $_temp0 条路径';
  }

  @override
  String get path_enterCustomPath => '输入自定义路径';

  @override
  String get path_currentPathLabel => '当前路径';

  @override
  String get path_hexPrefixInstructions => '请输入每个跳跃步骤的 2 个字符的十六进制前缀，用逗号分隔。';

  @override
  String get path_hexPrefixExample => '例如：A1, F2, 3C (每个节点使用其公钥的第一字节)';

  @override
  String get path_labelHexPrefixes => '路径（十六进制前缀）';

  @override
  String get path_helperMaxHops => '最大 64 个“hop”（跳跃）。每个前缀由 2 个十六进制字符（1 字节）组成。';

  @override
  String get path_selectFromContacts => '或者从联系人列表中选择：';

  @override
  String get path_noRepeatersFound => '未找到任何重复设备或房间服务器。';

  @override
  String get path_customPathsRequire => '自定义路径需要中间节点，这些节点可以转发消息。';

  @override
  String path_invalidHexPrefixes(String prefixes) {
    return 'Invalid hex prefixes: $prefixes';
  }

  @override
  String get path_tooLong => '路径太长。允许的最大跳跃次数为 64 次。';

  @override
  String get path_setPath => '设置路径';

  @override
  String get repeater_management => '重复器管理';

  @override
  String get room_management => '服务器管理';

  @override
  String get repeater_managementTools => '管理工具';

  @override
  String get repeater_status => '状态';

  @override
  String get repeater_statusSubtitle => '查看重复器状态、统计信息和邻居';

  @override
  String get repeater_sendAdvert => 'Send Advert';

  @override
  String get repeater_sendAdvertSubtitle =>
      'Broadcast an advertisement packet now';

  @override
  String get repeater_telemetry => '远程监控';

  @override
  String get repeater_telemetrySubtitle => '查看传感器和系统状态的数据。';

  @override
  String get repeater_cli => '命令行界面';

  @override
  String get repeater_cliSubtitle => '向复用器发送指令';

  @override
  String get repeater_neighbors => '邻居';

  @override
  String get repeater_neighborsSubtitle => '查看邻居节点（无需中间节点）。';

  @override
  String get repeater_settings => '设置';

  @override
  String get repeater_settingsSubtitle => '配置重复器参数';

  @override
  String get repeater_statusTitle => '重复器状态';

  @override
  String get repeater_routingMode => '路由模式';

  @override
  String get repeater_autoUseSavedPath => '自动（使用已保存的路径）';

  @override
  String get repeater_forceFloodMode => '强制洪水模式';

  @override
  String get repeater_pathManagement => '路径管理';

  @override
  String get repeater_refresh => '更新';

  @override
  String get repeater_statusRequestTimeout => '状态请求超时。';

  @override
  String repeater_errorLoadingStatus(String error) {
    return 'Error loading status: $error';
  }

  @override
  String get repeater_systemInformation => '系统信息';

  @override
  String get repeater_firmwareVersion => 'Firmware';

  @override
  String get repeater_battery => '电池';

  @override
  String get repeater_clockAtLogin => '登录时的时间';

  @override
  String get repeater_uptime => '正常运行时间';

  @override
  String get repeater_queueLength => '排队长度';

  @override
  String get repeater_debugFlags => '调试标志';

  @override
  String get repeater_radioStatistics => '广播统计';

  @override
  String get repeater_lastRssi => '上次的 RSSI 值';

  @override
  String get repeater_lastSnr => '最后一次信噪比';

  @override
  String get repeater_noiseFloor => '噪声水平';

  @override
  String get repeater_txAirtime => 'TX 频道预留时间';

  @override
  String get repeater_rxAirtime => 'RX 空时';

  @override
  String get repeater_packetStatistics => '数据包统计';

  @override
  String get repeater_sent => '发送';

  @override
  String get repeater_received => '已收到';

  @override
  String get repeater_duplicates => '重复';

  @override
  String repeater_daysHoursMinsSecs(
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return '$days天 $hours小时 $minutes分 $seconds秒';
  }

  @override
  String repeater_packetTxTotal(int total, String flood, String direct) {
    return 'Total: $total, Flood: $flood, Direct: $direct';
  }

  @override
  String repeater_packetRxTotal(int total, String flood, String direct) {
    return 'Total: $total, Flood: $flood, Direct: $direct';
  }

  @override
  String repeater_duplicatesFloodDirect(String flood, String direct) {
    return 'Flood: $flood, Direct: $direct';
  }

  @override
  String repeater_duplicatesTotal(int total) {
    return 'Total: $total';
  }

  @override
  String get repeater_settingsTitle => '重复器设置';

  @override
  String get repeater_basicSettings => '基本设置';

  @override
  String get repeater_repeaterName => '重复器名称';

  @override
  String get repeater_repeaterNameHelper => '此复播器的显示名称';

  @override
  String get repeater_adminPassword => '管理员密码';

  @override
  String get repeater_adminPasswordHelper => '完整访问密码';

  @override
  String get repeater_guestPassword => '访客密码';

  @override
  String get repeater_guestPasswordHelper => '只读访问密码';

  @override
  String get repeater_radioSettings => '收音机设置';

  @override
  String get repeater_frequencyMhz => '频率 (MHz)';

  @override
  String get repeater_frequencyHelper => '300-2500 兆赫';

  @override
  String get repeater_txPower => 'TX 功率';

  @override
  String get repeater_txPowerHelper => '1-30 dBm';

  @override
  String get repeater_bandwidth => '带宽';

  @override
  String get repeater_spreadingFactor => '传播系数';

  @override
  String get repeater_codingRate => '编码速率';

  @override
  String get repeater_locationSettings => '位置设置';

  @override
  String get repeater_latitude => '纬度';

  @override
  String get repeater_latitudeHelper => '十进制度（例如：37.7749）';

  @override
  String get repeater_longitude => '经度';

  @override
  String get repeater_longitudeHelper => '十进制度（例如：-122.4194）';

  @override
  String get repeater_features => '特点';

  @override
  String get repeater_packetForwarding => '数据包转发';

  @override
  String get repeater_packetForwardingSubtitle => '启用重复器，使其能够转发数据包';

  @override
  String get repeater_guestAccess => '访客访问';

  @override
  String get repeater_guestAccessSubtitle => '允许访客仅限读取权限';

  @override
  String get repeater_privacyMode => '隐私模式';

  @override
  String get repeater_privacyModeSubtitle => '在广告中隐藏姓名/位置';

  @override
  String get repeater_advertisementSettings => '广告设置';

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
  String get repeater_localAdvertInterval => '本地广告投放时间段';

  @override
  String repeater_localAdvertIntervalMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get repeater_floodAdvertInterval => '洪水广告播放间隔';

  @override
  String repeater_floodAdvertIntervalHours(int hours) {
    return '$hours hours';
  }

  @override
  String get repeater_encryptedAdvertInterval => '加密的广告投放时间段';

  @override
  String get repeater_dangerZone => '危险区域';

  @override
  String get repeater_rebootRepeater => '重启重复器';

  @override
  String get repeater_rebootRepeaterSubtitle => '重新启动重复器设备';

  @override
  String get repeater_rebootRepeaterConfirm => '您确定要重新启动这个中继器吗？';

  @override
  String get repeater_regenerateIdentityKeySubtitle => '生成新的公钥/私钥对';

  @override
  String get repeater_regenerateIdentityKeyConfirm => '这将为复用器生成一个新的身份。继续吗？';

  @override
  String get repeater_eraseFileSystem => '删除文件系统';

  @override
  String get repeater_eraseFileSystemSubtitle => '格式化重复文件系统';

  @override
  String get repeater_eraseFileSystemConfirm => '警告：此操作将清除复用器上的所有数据。 无法恢复！';

  @override
  String get repeater_eraseSerialOnly => '“Erase”功能仅可通过串行控制台使用。';

  @override
  String repeater_commandSent(String command) {
    return 'Command sent: $command';
  }

  @override
  String repeater_errorSendingCommand(String error) {
    return 'Error sending command: $error';
  }

  @override
  String get repeater_confirm => '确认';

  @override
  String get repeater_settingsSaved => '设置已成功保存';

  @override
  String repeater_errorSavingSettings(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String get repeater_refreshBasicSettings => '重置基本设置';

  @override
  String get repeater_refreshRadioSettings => '重置收音机设置';

  @override
  String get repeater_refreshTxPower => '重置 TX 电源';

  @override
  String get repeater_refreshLocationSettings => '重置位置设置';

  @override
  String get repeater_refreshPacketForwarding => '刷新包转发';

  @override
  String get repeater_refreshGuestAccess => '重新获取访客访问权限';

  @override
  String get repeater_refreshPrivacyMode => '重置隐私模式';

  @override
  String get repeater_refreshAdvertisementSettings => '重置广告设置';

  @override
  String repeater_refreshed(String label) {
    return '$label refreshed';
  }

  @override
  String repeater_errorRefreshing(String label) {
    return '[保存：$label]\n刷新 $label 时出错';
  }

  @override
  String get repeater_cliTitle => '重复器命令行界面';

  @override
  String get repeater_debugNextCommand => '调试下一条命令';

  @override
  String get repeater_commandHelp => '帮助';

  @override
  String get repeater_clearHistory => '清晰的历史';

  @override
  String get repeater_noCommandsSent => '尚未发送任何指令';

  @override
  String get repeater_typeCommandOrUseQuick => '在下方输入命令，或使用快捷命令。';

  @override
  String get repeater_enterCommandHint => '输入命令...';

  @override
  String get repeater_previousCommand => '之前的命令';

  @override
  String get repeater_nextCommand => '下一个指令';

  @override
  String get repeater_enterCommandFirst => '首先输入一个命令';

  @override
  String get repeater_cliCommandFrameTitle => 'CLI 命令框架';

  @override
  String repeater_cliCommandError(String error) {
    return 'Error: $error';
  }

  @override
  String get repeater_cliQuickGetName => '获取姓名';

  @override
  String get repeater_cliQuickGetRadio => '收听广播';

  @override
  String get repeater_cliQuickGetTx => '获取 TX';

  @override
  String get repeater_cliQuickNeighbors => '邻居';

  @override
  String get repeater_cliQuickVersion => '版本';

  @override
  String get repeater_cliQuickAdvertise => '发布广告';

  @override
  String get repeater_cliQuickClock => '时钟';

  @override
  String get repeater_cliHelpAdvert => '发送广告资料包';

  @override
  String get repeater_cliHelpReboot => '重置设备。 (请注意，您可能会收到“超时”错误，这是正常的现象)';

  @override
  String get repeater_cliHelpClock => '显示每个设备的当前时间。';

  @override
  String get repeater_cliHelpPassword => '为设备设置新的管理员密码。';

  @override
  String get repeater_cliHelpVersion => '显示设备版本和固件构建日期。';

  @override
  String get repeater_cliHelpClearStats => '重置各种统计指标，将其设置为零。';

  @override
  String get repeater_cliHelpSetAf => '设置时间因素。';

  @override
  String get repeater_cliHelpSetTx =>
      '设置 LoRa 传输功率，单位为 dBm (相对于参考值)。 (重启以应用更改)';

  @override
  String get repeater_cliHelpSetRepeat => '启用或禁用此节点的重复器功能。';

  @override
  String get repeater_cliHelpSetAllowReadOnly =>
      '（房间服务器）如果设置为“开启”，则允许使用空密码登录，但无法向房间发送消息（只能进行读取）。';

  @override
  String get repeater_cliHelpSetFloodMax => '设置最大传入数据包的跳数（如果大于或等于最大值，则不进行转发）。';

  @override
  String get repeater_cliHelpSetIntThresh =>
      '设置干扰阈值（以dB为单位）。默认值为14。将设置为0以禁用频道干扰检测。';

  @override
  String get repeater_cliHelpSetAgcResetInterval =>
      '设置间隔时间，用于重置自动增益控制器。设置为 0 以禁用。';

  @override
  String get repeater_cliHelpSetMultiAcks => '启用或禁用“双重确认”功能。';

  @override
  String get repeater_cliHelpSetAdvertInterval =>
      '设置定时器间隔，单位为分钟，用于发送本地（无中继）的广告数据包。 将设置为 0 以禁用。';

  @override
  String get repeater_cliHelpSetFloodAdvertInterval =>
      '设置定时器间隔时间为小时，以便发送广告信息包。将设置为 0 以禁用。';

  @override
  String get repeater_cliHelpGetPathHashMode =>
      'Returns advert path hash mode (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetPathHashMode =>
      'Sets advert path hash mode for this repeater (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetGuestPassword =>
      '设置/更新访客密码。 (对于访客，登录请求可以发送“获取统计”请求)';

  @override
  String get repeater_cliHelpSetName => '设置广告名称。';

  @override
  String get repeater_cliHelpSetLat => '设置广告地图的纬度。（以十进制表示）';

  @override
  String get repeater_cliHelpSetLon => '设置广告地图的经度。 (十进制度)';

  @override
  String get repeater_cliHelpSetRadio => '完全重新设置无线电参数，并保存到偏好设置。需要执行“重启”命令才能生效。';

  @override
  String get repeater_cliHelpSetRxDelay =>
      '设置（实验性）：设置一个基础值（必须大于1才能生效），用于对接收到的数据包进行轻微延迟处理，该延迟值基于信号强度/评分。将该值设置为0以禁用。';

  @override
  String get repeater_cliHelpSetTxDelay =>
      '通过将一个因子与“浮动模式”数据包的时间在空中停留时间相乘，并结合随机的“时隙”系统，来延迟其转发，从而降低数据包冲突的概率。';

  @override
  String get repeater_cliHelpSetDirectTxDelay =>
      '与txdelay相同，但用于对直接模式数据包的转发进行随机延迟。';

  @override
  String get repeater_cliHelpSetBridgeEnabled => '启用/禁用桥接。';

  @override
  String get repeater_cliHelpSetBridgeDelay => '在重新发送数据包之前，设置延迟时间。';

  @override
  String get repeater_cliHelpSetBridgeSource => '选择桥接器是否会转发收到的数据包，还是转发发送的数据包。';

  @override
  String get repeater_cliHelpSetBridgeBaud => '为 RS232 桥接设置串行链路的波特率。';

  @override
  String get repeater_cliHelpSetBridgeSecret => '设置 ESPNOW 桥的秘密。';

  @override
  String get repeater_cliHelpSetAdcMultiplier =>
      '设置自定义因子，用于调整报告的电池电压（仅在特定板上支持）。';

  @override
  String get repeater_cliHelpTempRadio =>
      '设置临时收音机参数，持续指定分钟数，之后恢复到原始收音机参数。（不保存到偏好设置）。';

  @override
  String get repeater_cliHelpSetPerm =>
      '修改 ACL。如果 \"permissions\" 的值为 0，则删除与 pubkey 相关的条目。如果 pubkey-hex 完整且当前不在 ACL 中，则添加新的条目。通过匹配 pubkey 相关的前缀来更新条目。不同固件角色的权限位有所不同，但低 2 位分别对应：0 (访客)、1 (只读)、2 (读写)、3 (管理员)。';

  @override
  String get repeater_cliHelpGetBridgeType => '支持桥接模式、RS232、ESPNOW。';

  @override
  String get repeater_cliHelpLogStart => '开始将数据包记录到文件系统。';

  @override
  String get repeater_cliHelpLogStop => '停止将数据包记录写入文件系统。';

  @override
  String get repeater_cliHelpLogErase => '从文件系统中删除所有已记录的包信息。';

  @override
  String get repeater_cliHelpNeighbors =>
      '显示了通过零跳广告收到的其他复用节点列表。 每行包含：id-前缀-十六进制：时间戳：信噪比（4次）';

  @override
  String get repeater_cliHelpNeighborRemove =>
      '从邻居列表中删除第一个匹配项（通过十六进制的 pubkey 前缀）。';

  @override
  String get repeater_cliHelpRegion => '（仅限序列）列出所有已定义的区域以及当前的防洪许可。';

  @override
  String get repeater_cliHelpRegionLoad =>
      '请注意：这是一个特殊的、包含多个命令的调用方式。 之后的每个命令都是一个区域名称（使用空格进行缩进，以表示父级关系，至少需要一个空格）。 结束方式是通过发送一个空行/命令。';

  @override
  String get repeater_cliHelpRegionGet =>
      '搜索具有指定名称前缀的区域（或使用“*”表示全局范围）。 返回结果为“-> region-name (parent-name) \'F\'”';

  @override
  String get repeater_cliHelpRegionPut => '添加或更新一个区域定义，并指定其名称。';

  @override
  String get repeater_cliHelpRegionRemove =>
      '删除具有指定名称的区域定义。 (必须与指定名称完全匹配，且不能有子区域)';

  @override
  String get repeater_cliHelpRegionAllowf => '为指定区域设置“洪水”权限。（“*”表示全局/旧版本范围）';

  @override
  String get repeater_cliHelpRegionDenyf =>
      '移除指定区域的“洪水”权限。（请注意：目前不建议在全局/旧版本中使用此功能！！）';

  @override
  String get repeater_cliHelpRegionHome => '回复当前“主区域”。（此功能尚未应用，仅供未来使用）';

  @override
  String get repeater_cliHelpRegionHomeSet => '设置“主”区域。';

  @override
  String get repeater_cliHelpRegionSave => '将区域列表/地图保存到存储中。';

  @override
  String get repeater_cliHelpGps =>
      '显示 GPS 状态。当 GPS 处于关闭状态时，它只会显示“关闭”；当 GPS 处于开启状态时，它会显示“开启”、“状态”、“定位”、“卫星数量”等信息。';

  @override
  String get repeater_cliHelpGpsOnOff => '切换 GPS 设备的电源状态。';

  @override
  String get repeater_cliHelpGpsSync => '将节点时间与 GPS 钟同步。';

  @override
  String get repeater_cliHelpGpsSetLoc => '将节点的坐标设置为 GPS 坐标，并保存设置。';

  @override
  String get repeater_cliHelpGpsAdvert =>
      '设置节点的位置广告配置：\n- none：不将位置信息包含在广告中\n- share：共享 GPS 位置（从 SensorManager 获取）\n- prefs：在偏好设置中展示的位置';

  @override
  String get repeater_cliHelpGpsAdvertSet => '设置广告的位置配置。';

  @override
  String get repeater_commandsListTitle => '命令列表';

  @override
  String get repeater_commandsListNote => '请注意：对于各种“set ...”命令，也存在“get ...”命令。';

  @override
  String get repeater_general => '通用';

  @override
  String get repeater_settingsCategory => '设置';

  @override
  String get repeater_bridge => '桥';

  @override
  String get repeater_logging => '记录';

  @override
  String get repeater_neighborsRepeaterOnly => '邻居（仅限重复功能）';

  @override
  String get repeater_regionManagementRepeaterOnly => '区域管理（仅限重复站点）';

  @override
  String get repeater_regionNote => '区域命令已引入，用于管理区域定义和权限。';

  @override
  String get repeater_gpsManagement => 'GPS 管理';

  @override
  String get repeater_gpsNote => '已引入 GPS 命令，用于管理与位置相关的任务。';

  @override
  String get telemetry_receivedData => '接收到的遥测数据';

  @override
  String get telemetry_requestTimeout => '遥测请求超时。';

  @override
  String telemetry_errorLoading(String error) {
    return 'Error loading telemetry: $error';
  }

  @override
  String get telemetry_noData => '没有可用的 telemetry 数据。';

  @override
  String telemetry_channelTitle(int channel) {
    return '频道 $channel';
  }

  @override
  String get telemetry_batteryLabel => '电池';

  @override
  String get telemetry_voltageLabel => '电压';

  @override
  String get telemetry_mcuTemperatureLabel => 'MCU 的温度';

  @override
  String get telemetry_temperatureLabel => '温度';

  @override
  String get telemetry_currentLabel => '当前';

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
  String get neighbors_receivedData => '已收到邻居信息';

  @override
  String get neighbors_requestTimedOut => '邻居要求停止干扰。';

  @override
  String neighbors_errorLoading(String error) {
    return 'Error loading neighbors: $error';
  }

  @override
  String get neighbors_repeatersNeighbors => '重复使用的邻居';

  @override
  String get neighbors_noData => '没有可用的邻居信息。';

  @override
  String neighbors_unknownContact(String pubkey) {
    return 'Unknown $pubkey';
  }

  @override
  String neighbors_heardAgo(String time) {
    return 'Heard: $time ago';
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
  String get channelPath_title => '数据包路径';

  @override
  String get channelPath_viewMap => '查看地图';

  @override
  String get channelPath_otherObservedPaths => '其他观察到的路径';

  @override
  String get channelPath_repeaterHops => '复用跳跃';

  @override
  String get channelPath_noHopDetails => '对于此包，未提供详细信息。';

  @override
  String get channelPath_messageDetails => '消息详情';

  @override
  String get channelPath_senderLabel => '发件人';

  @override
  String get channelPath_timeLabel => '时间';

  @override
  String get channelPath_repeatsLabel => '重复';

  @override
  String channelPath_pathLabel(int index) {
    return '路径 $index';
  }

  @override
  String get channelPath_observedLabel => '观察到的';

  @override
  String channelPath_observedPathTitle(int index, String hops) {
    return 'Observed path $index • $hops';
  }

  @override
  String get channelPath_noLocationData => '没有位置信息';

  @override
  String channelPath_timeWithDate(int day, int month, String time) {
    return '$day/$month $time';
  }

  @override
  String channelPath_timeOnly(String time) {
    return '$time';
  }

  @override
  String get channelPath_unknownPath => '未知';

  @override
  String get channelPath_floodPath => '洪水';

  @override
  String get channelPath_directPath => '直接';

  @override
  String channelPath_observedZeroOf(int total) {
    return '0 of $total hops';
  }

  @override
  String channelPath_observedSomeOf(int observed, int total) {
    return '$observed of $total hops';
  }

  @override
  String get channelPath_mapTitle => '路线图';

  @override
  String get channelPath_noRepeaterLocations => '这条路径上没有可用的中继器位置。';

  @override
  String channelPath_primaryPath(int index) {
    return '路径 $index (主要路径)';
  }

  @override
  String get channelPath_pathLabelTitle => '路径';

  @override
  String get channelPath_observedPathHeader => '观察路径';

  @override
  String channelPath_selectedPathLabel(String label, String prefixes) {
    return '$label • $prefixes';
  }

  @override
  String get channelPath_noHopDetailsAvailable => '对于此包裹，尚无详细信息。';

  @override
  String get channelPath_unknownRepeater => '未知的重复设备';

  @override
  String get community_title => '社区';

  @override
  String get community_create => '建立社区';

  @override
  String get community_createDesc => '创建一个新的社群，并通过二维码进行分享。';

  @override
  String get community_join => '加入';

  @override
  String get community_joinTitle => '加入社区';

  @override
  String community_joinConfirmation(String name) {
    return 'Do you want to join the community \"$name\"?';
  }

  @override
  String get community_scanQr => '扫描社区二维码';

  @override
  String get community_scanInstructions => '将相机对准社区的二维码。';

  @override
  String get community_showQr => '显示二维码';

  @override
  String get community_publicChannel => '社区公共';

  @override
  String get community_hashtagChannel => '社区标签';

  @override
  String get community_name => '社区名称';

  @override
  String get community_enterName => '请输入社区名称';

  @override
  String community_created(String name) {
    return 'Community \"$name\" created';
  }

  @override
  String community_joined(String name) {
    return 'Joined community \"$name\"';
  }

  @override
  String get community_qrTitle => '分享社区';

  @override
  String community_qrInstructions(String name) {
    return 'Scan this QR code to join \"$name\"';
  }

  @override
  String get community_hashtagPrivacyHint => '仅社区成员才能加入社区话题标签的频道。';

  @override
  String get community_invalidQrCode => '无效的社区二维码';

  @override
  String get community_alreadyMember => '已经是会员';

  @override
  String community_alreadyMemberMessage(String name) {
    return 'You are already a member of \"$name\".';
  }

  @override
  String get community_addPublicChannel => '添加公共频道';

  @override
  String get community_addPublicChannelHint => '自动添加该社区的公共频道';

  @override
  String get community_noCommunities => '目前还没有任何社区加入。';

  @override
  String get community_scanOrCreate => '扫描二维码或创建社群，即可开始。';

  @override
  String get community_manageCommunities => '管理社区';

  @override
  String get community_delete => '退出社区';

  @override
  String community_deleteConfirm(String name) {
    return '是否要删除\"$name\"？';
  }

  @override
  String community_deleteChannelsWarning(int count) {
    return '这将同时删除 $count 个频道及其所有消息。';
  }

  @override
  String community_deleted(String name) {
    return 'Left community \"$name\"';
  }

  @override
  String get community_regenerateSecret => '恢复秘密';

  @override
  String community_regenerateSecretConfirm(String name) {
    return '[保存：$name]\n是否需要重新生成\"$name\"的密钥？所有成员都需要扫描新的二维码才能继续进行通信。';
  }

  @override
  String get community_regenerate => '再生';

  @override
  String community_secretRegenerated(String name) {
    return '[保护对象：$name]\n秘密已恢复至\"$name\"';
  }

  @override
  String get community_updateSecret => '更新秘密';

  @override
  String community_secretUpdated(String name) {
    return '“$name”的秘密已更新';
  }

  @override
  String community_scanToUpdateSecret(String name) {
    return 'Scan the new QR code to update the secret for \"$name\"';
  }

  @override
  String get community_addHashtagChannel => '添加社区标签';

  @override
  String get community_addHashtagChannelDesc => '为这个社区创建一个带有话题标签的频道';

  @override
  String get community_selectCommunity => '选择社区';

  @override
  String get community_regularHashtag => '常用标签';

  @override
  String get community_regularHashtagDesc => '公共话题标签（任何人都可以参与）';

  @override
  String get community_communityHashtag => '社区标签';

  @override
  String get community_communityHashtagDesc => '仅限社区成员';

  @override
  String community_forCommunity(String name) {
    return 'For $name';
  }

  @override
  String get listFilter_tooltip => '筛选和排序';

  @override
  String get listFilter_sortBy => '按排序';

  @override
  String get listFilter_latestMessages => '最新消息';

  @override
  String get listFilter_heardRecently => '最近听到的';

  @override
  String get listFilter_az => 'A 到 Z';

  @override
  String get listFilter_filters => '过滤器';

  @override
  String get listFilter_all => '全部';

  @override
  String get listFilter_users => '用户';

  @override
  String get listFilter_repeaters => '重复器';

  @override
  String get listFilter_roomServers => '房间服务器';

  @override
  String get listFilter_unreadOnly => '仅显示未读消息';

  @override
  String get listFilter_newGroup => '新的团体';

  @override
  String get pathTrace_you => '您';

  @override
  String get pathTrace_failed => '路径追踪失败。';

  @override
  String get pathTrace_notAvailable => '无法获取路径信息。';

  @override
  String get pathTrace_refreshTooltip => '重新绘制路径。';

  @override
  String get pathTrace_someHopsNoLocation => '其中一个或多个啤酒花缺少位置！';

  @override
  String get pathTrace_clearTooltip => '清除路径';

  @override
  String get losSelectStartEnd => '选择 LOS 的起始节点和结束节点。';

  @override
  String losRunFailed(String error) {
    return '视线检查失败：$error';
  }

  @override
  String get losClearAllPoints => '清除所有点';

  @override
  String get losRunToViewElevationProfile => '运行 LOS 查看高程剖面';

  @override
  String get losMenuTitle => '服务水平菜单';

  @override
  String get losMenuSubtitle => '点击节点或长按地图以获取自定义点';

  @override
  String get losShowDisplayNodes => '显示显示节点';

  @override
  String get losCustomPoints => '自定义积分';

  @override
  String losCustomPointLabel(int index) {
    return '自定义 $index';
  }

  @override
  String get losPointA => 'A点';

  @override
  String get losPointB => 'B点';

  @override
  String losAntennaA(String value, String unit) {
    return '天线 A： $value $unit';
  }

  @override
  String losAntennaB(String value, String unit) {
    return '天线 B：$value $unit';
  }

  @override
  String get losRun => '运行视距';

  @override
  String get losNoElevationData => '无海拔数据';

  @override
  String losProfileClear(
    String distance,
    String distanceUnit,
    String clearance,
    String heightUnit,
  ) {
    return '$distance $distanceUnit，清除 LOS，最小间隙 $clearance $heightUnit';
  }

  @override
  String losProfileBlocked(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit，被 $obstruction $heightUnit 阻止';
  }

  @override
  String get losStatusChecking => '洛斯：正在检查...';

  @override
  String get losStatusNoData => 'LOS：无数据';

  @override
  String losStatusSummary(int clear, int total, int blocked, int unknown) {
    return 'LOS：$clear/$total 清除，$blocked 阻塞，$unknown 未知';
  }

  @override
  String get losErrorElevationUnavailable => '一个或多个样本的海拔数据不可用。';

  @override
  String get losErrorInvalidInput => '用于 LOS 计算的点/高程数据无效。';

  @override
  String get losRenameCustomPoint => '重命名自定义点';

  @override
  String get losPointName => '点名称';

  @override
  String get losShowPanelTooltip => '显示 LOS 面板';

  @override
  String get losHidePanelTooltip => '隐藏 LOS 面板';

  @override
  String get losElevationAttribution => '高程数据：Open-Meteo (CC BY 4.0)';

  @override
  String get contacts_pathTrace => '路径追踪';

  @override
  String get contacts_ping => '乒';

  @override
  String get contacts_repeaterPathTrace => '追踪路径至中继器';

  @override
  String get contacts_repeaterPing => '中继器';

  @override
  String get contacts_roomPathTrace => '追踪到房间服务器';

  @override
  String get contacts_roomPing => '会议室服务器';

  @override
  String get contacts_chatTraceRoute => '路径跟踪路线';

  @override
  String contacts_pathTraceTo(String name) {
    return '追踪路径至 $name';
  }

  @override
  String get contacts_clipboardEmpty => '剪贴板为空。';

  @override
  String get contacts_invalidAdvertFormat => '无效的联系信息';

  @override
  String get contacts_contactImported => '已建立联系。';

  @override
  String get contacts_contactImportFailed => '未能导入联系人。';

  @override
  String get contacts_zeroHopAdvert => '零跳广告';

  @override
  String get contacts_floodAdvert => '防洪广告';

  @override
  String get contacts_copyAdvertToClipboard => '复制广告到剪贴板';

  @override
  String get contacts_addContactFromClipboard => '从剪贴板添加联系人';

  @override
  String get contacts_ShareContact => '复制联系方式到剪贴板';

  @override
  String get contacts_ShareContactZeroHop => '通过广告分享联系方式';

  @override
  String get contacts_zeroHopContactAdvertSent => '通过广告获取联系方式。';

  @override
  String get contacts_zeroHopContactAdvertFailed => '发送联系方式失败。';

  @override
  String get contacts_contactAdvertCopied => '广告内容已复制到剪贴板。';

  @override
  String get contacts_contactAdvertCopyFailed => '将广告复制到剪贴板操作失败。';

  @override
  String get notification_activityTitle => 'MeshCore 活动';

  @override
  String notification_messagesCount(int count) {
    return '$count 条消息';
  }

  @override
  String notification_channelPoiShared(String label) {
    return 'POI shared: $label';
  }

  @override
  String notification_channelMessagesCount(int count) {
    return '$count 条频道消息';
  }

  @override
  String notification_newNodesCount(int count) {
    return '$count 个新节点';
  }

  @override
  String notification_newTypeDiscovered(String contactType) {
    return '发现新 $contactType';
  }

  @override
  String get notification_receivedNewMessage => '收到新消息';

  @override
  String get settings_gpxExportRepeaters => '导出重复器/房间服务器到GPX';

  @override
  String get settings_gpxExportRepeatersSubtitle => '导出带有位置的重复器/房间服务器到GPX文件。';

  @override
  String get settings_gpxExportContacts => '导出伴侣到GPX';

  @override
  String get settings_gpxExportContactsSubtitle => '导出带有位置的伙伴到GPX文件。';

  @override
  String get settings_gpxExportAll => '导出所有联系人到GPX';

  @override
  String get settings_gpxExportAllSubtitle => '导出所有带有位置的联系人到GPX文件。';

  @override
  String get settings_gpxExportSuccess => '成功导出GPX文件';

  @override
  String get settings_gpxExportNoContacts => '没有联系人可导出';

  @override
  String get settings_gpxExportNotAvailable => '您的设备/操作系统不支持';

  @override
  String get settings_gpxExportError => '导出时发生错误';

  @override
  String get settings_gpxExportRepeatersRoom => '重复器和房间服务器位置';

  @override
  String get settings_gpxExportChat => '伴侣位置';

  @override
  String get settings_gpxExportAllContacts => '所有联系人位置';

  @override
  String get settings_gpxExportShareText => '来自Gulf Coast Mesh App的导出地图数据';

  @override
  String get settings_gpxExportShareSubject => 'Gulf Coast Mesh App GPX 地图数据导出';

  @override
  String get snrIndicator_nearByRepeaters => '附近的重复器';

  @override
  String get snrIndicator_lastSeen => '最近访问';

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
  String get repeater_regenerateIdentityKey => '重新生成身份密钥';

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
  String get appSettings_nodeBlocking => '屏蔽节点';

  @override
  String get appSettings_nodeBlockingSubtitle =>
      '在地图、联系人和聊天中隐藏你选择的节点，并静音其提醒。仅限应用内：不会从你的电台中删除任何内容。';

  @override
  String get appSettings_blockedNodes => '已屏蔽节点';

  @override
  String appSettings_blockedNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已屏蔽 $count 个节点',
      one: '已屏蔽 1 个节点',
      zero: '暂无已屏蔽节点',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_title => '已屏蔽节点';

  @override
  String get blockedNodes_howItWorks => '屏蔽的工作方式';

  @override
  String get blockedNodes_infoHidden => '在你的地图、联系人和聊天中隐藏';

  @override
  String get blockedNodes_infoMuted => '不再提示其新节点，也不再提示其消息通知';

  @override
  String get blockedNodes_infoKept => '不会删除任何内容。它们仍保留在你的配套电台上，其消息也会保留';

  @override
  String get blockedNodes_infoRelay => '已屏蔽的中继器仍可在网络中转发你的消息';

  @override
  String get blockedNodes_infoChannels => '其在频道中的消息仍会显示';

  @override
  String get blockedNodes_emptyTitle => '暂无已屏蔽节点';

  @override
  String get blockedNodes_emptyHint => '在联系人或地图上长按节点，然后选择“屏蔽节点”。';

  @override
  String get blockedNodes_unblock => '取消屏蔽';

  @override
  String get blockedNodes_unblockAll => '全部取消屏蔽';

  @override
  String blockedNodes_unblockAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '取消屏蔽全部 $count 个节点？它们将重新显示在你的地图和联系人中。',
      one: '取消屏蔽 1 个节点？它将重新显示在你的地图和联系人中。',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_unknownNode => '未知节点';

  @override
  String blockedNodes_blockedOn(String date) {
    return '屏蔽于 $date';
  }

  @override
  String get blockedNodes_blockAction => '屏蔽节点';

  @override
  String blockedNodes_blockConfirmTitle(String name) {
    return '屏蔽 $name？';
  }

  @override
  String get blockedNodes_blockConfirmBody =>
      '它将在你的地图、联系人和聊天中隐藏，你也不会再收到它的提醒或消息通知。你的电台上不会删除任何内容。你可以随时在“应用设置 > 实验性 > 已屏蔽节点”中取消屏蔽。';

  @override
  String get blockedNodes_blockConfirmButton => '屏蔽';

  @override
  String blockedNodes_blocked(String name) {
    return '已屏蔽 $name';
  }

  @override
  String blockedNodes_unblocked(String name) {
    return '已取消屏蔽 $name';
  }

  @override
  String get blockedNodes_undo => '撤销';
}
