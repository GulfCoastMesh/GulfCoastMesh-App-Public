// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

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
  String get nav_contacts => 'Contacts';

  @override
  String get nav_channels => 'Canaux';

  @override
  String get nav_map => 'Carte';

  @override
  String get nav_chats => 'Discussions';

  @override
  String get nav_nodes => 'Nœuds';

  @override
  String get nav_settings => 'Paramètres';

  @override
  String get common_cancel => 'Annuler';

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
  String get common_connect => 'Connecter';

  @override
  String get common_unknownDevice => 'Appareil inconnu';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_delete => 'Supprimer';

  @override
  String get common_close => 'Fermer';

  @override
  String get common_edit => 'Modifier';

  @override
  String get common_add => 'Ajouter';

  @override
  String get common_settings => 'Paramètres';

  @override
  String get common_disconnect => 'Déconnecter';

  @override
  String get common_connected => 'Connecté';

  @override
  String get common_disconnected => 'Déconnecté';

  @override
  String get common_reconnecting => 'Reconnecting';

  @override
  String get common_create => 'Créer';

  @override
  String get common_continue => 'Continuer';

  @override
  String get common_share => 'Partager';

  @override
  String get common_copy => 'Copier';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get common_hide => 'Masquer';

  @override
  String get common_remove => 'Supprimer';

  @override
  String get common_enable => 'Activer';

  @override
  String get common_disable => 'Désactiver';

  @override
  String get common_reboot => 'Redémarrer';

  @override
  String get common_loading => 'Chargement...';

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
  String get scanner_scanning => 'Recherche de périphériques...';

  @override
  String get scanner_connecting => 'Connexion en cours...';

  @override
  String get scanner_disconnecting => 'Déconnexion...';

  @override
  String get scanner_notConnected => 'Non connecté';

  @override
  String scanner_connectedTo(String deviceName) {
    return 'Connecté à $deviceName';
  }

  @override
  String get scanner_searchingDevices => 'Recherche des appareils MeshCore...';

  @override
  String get scanner_tapToScan =>
      'Appuyez sur Scanner pour trouver les appareils MeshCore';

  @override
  String scanner_connectionFailed(String error) {
    return 'Échec de la connexion : $error';
  }

  @override
  String get scanner_backgroundBleMayDrop =>
      'Background BLE may drop without notification permission.';

  @override
  String get scanner_stop => 'Arrêter';

  @override
  String get scanner_scan => 'Scanner';

  @override
  String get scanner_bluetoothOff => 'Le Bluetooth est désactivé.';

  @override
  String get scanner_bluetoothOffMessage =>
      'Veuillez activer le Bluetooth pour rechercher des appareils.';

  @override
  String get scanner_enableBluetooth => 'Activer le Bluetooth';

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
  String get device_quickSwitch => 'Basculement rapide';

  @override
  String get device_meshcore => 'MeshCore';

  @override
  String get settings_title => 'Paramètres';

  @override
  String get settings_deviceInfo => 'Informations du périphérique';

  @override
  String get settings_appSettings => 'Paramètres de l\'application';

  @override
  String get settings_appSettingsSubtitle =>
      'Notifications, messagerie et préférences de carte';

  @override
  String get settings_nodeSettings => 'Paramètres du nœud';

  @override
  String get settings_nodeName => 'Nom du nœud';

  @override
  String get settings_nodeNameNotSet => 'Non défini';

  @override
  String get settings_nodeNameHint => 'Entrer le nom du nœud';

  @override
  String get settings_nodeNameUpdated => 'Nom mis à jour';

  @override
  String get settings_radioSettings => 'Paramètres Radio';

  @override
  String get settings_radioSettingsSubtitle =>
      'Fréquence, puissance, facteur d\'espacement';

  @override
  String get settings_radioSettingsUpdated => 'Paramètres radio mis à jour';

  @override
  String get settings_location => 'Emplacement';

  @override
  String get settings_locationSubtitle => 'Coordonnées GPS';

  @override
  String get settings_locationUpdated => 'Emplacement mis à jour';

  @override
  String get settings_locationBothRequired =>
      'Entrez la latitude et la longitude.';

  @override
  String get settings_locationInvalid => 'Latitude ou longitude invalide.';

  @override
  String get settings_locationGPSEnable => 'Activer le GPS';

  @override
  String get settings_locationGPSEnableSubtitle =>
      'Activer la mise à jour automatique de la position via GPS';

  @override
  String get settings_locationIntervalSec =>
      'Intervalle de mise-à-jour du GPS (Secondes)';

  @override
  String get settings_usePhoneGps => 'Use phone GPS';

  @override
  String get settings_locationIntervalInvalid =>
      'L\'intervalle doit être compris entre 60 et 86400 secondes.';

  @override
  String get settings_latitude => 'Latitude';

  @override
  String get settings_longitude => 'Longitude';

  @override
  String get settings_privacyMode => 'Mode de confidentialité';

  @override
  String get settings_privacyModeSubtitle =>
      'Cacher le nom/l\'emplacement dans les annonces';

  @override
  String get settings_privacyModeToggle =>
      'Activer le mode confidentialité pour masquer votre nom et votre localisation dans les annonces.';

  @override
  String get settings_privacyModeEnabled => 'Mode de confidentialité activé';

  @override
  String get settings_privacyModeDisabled =>
      'Mode de confidentialité désactivé';

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
  String get settings_actions => 'Actions';

  @override
  String get settings_sendAdvertisement => 'S\'annoncer';

  @override
  String get settings_sendAdvertisementSubtitle =>
      'Présence diffusée maintenant';

  @override
  String get settings_advertisementSent => 'Annonce envoyée';

  @override
  String get settings_syncTime => 'Temps de synchronisation';

  @override
  String get settings_syncTimeSubtitle =>
      'Définir l\'heure de l\'appareil sur l\'heure du téléphone.';

  @override
  String get settings_timeSynchronized => 'Synchronisation temporelle';

  @override
  String get settings_refreshContacts => 'Rafraîchir les Contacts';

  @override
  String get settings_refreshContactsSubtitle =>
      'Recharger la liste des contacts depuis l\'appareil';

  @override
  String get settings_rebootDevice => 'Redémarrer l\'appareil';

  @override
  String get settings_rebootDeviceSubtitle => 'Redémarrer l\'appareil MeshCore';

  @override
  String get settings_rebootDeviceConfirm =>
      'Êtes-vous sûr de vouloir redémarrer l\'appareil ? Vous serez déconnecté.';

  @override
  String get settings_debug => 'Déboguer';

  @override
  String get settings_bleDebugLog => 'Journal de débogage BLE';

  @override
  String get settings_bleDebugLogSubtitle =>
      'Commandes BLE, réponses et données brutes';

  @override
  String get settings_appDebugLog => 'Journal de débogage de l\'application';

  @override
  String get settings_appDebugLogSubtitle =>
      'Messages de débogage de l\'application';

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
  String get settings_about => 'À propos';

  @override
  String settings_aboutVersion(String version) {
    return 'Gulf Coast Mesh App v$version';
  }

  @override
  String get settings_aboutLegalese => 'Gulf Coast Mesh App 2026';

  @override
  String get settings_aboutDescription =>
      'Un client Flutter open source pour les appareils de réseau mesh MeshCore LoRa.';

  @override
  String get settings_aboutOpenMeteoAttribution =>
      'Données d\'élévation LOS : Open-Meteo (CC BY 4.0)';

  @override
  String get settings_infoName => 'Nom';

  @override
  String get settings_infoId => 'ID';

  @override
  String get settings_infoStatus => 'État';

  @override
  String get settings_infoBattery => 'Batterie';

  @override
  String get settings_infoPublicKey => 'Clé Publique';

  @override
  String get settings_infoContactsCount => 'Nombre de contacts';

  @override
  String get settings_infoChannelCount => 'Nombre de canaux';

  @override
  String get settings_presets => 'Préréglages';

  @override
  String get settings_frequency => 'Fréquence (MHz)';

  @override
  String get settings_frequencyHelper => '300,0 - 2 500,0';

  @override
  String get settings_frequencyInvalid => 'Fréquence invalide (300-2500 MHz)';

  @override
  String get settings_bandwidth => 'Bande passante';

  @override
  String get settings_spreadingFactor => 'Facteur de répartition';

  @override
  String get settings_codingRate => 'Taux de codage';

  @override
  String get settings_txPower => 'TX Puissance (dBm)';

  @override
  String get settings_txPowerHelper => '0 - 22';

  @override
  String get settings_txPowerInvalid => 'Puissance TX invalide (0-22 dBm)';

  @override
  String get settings_clientRepeat => 'Répétition hors réseau';

  @override
  String get settings_clientRepeatSubtitle =>
      'Permettez à cet appareil de répéter les paquets de données pour les autres.';

  @override
  String get settings_clientRepeatFreqWarning =>
      'Pour les transmissions hors réseau, il est nécessaire d\'utiliser les fréquences de 433, 869 ou 918 MHz.';

  @override
  String settings_error(String message) {
    return 'Erreur : $message';
  }

  @override
  String get appSettings_title => 'Paramètres de l\'application';

  @override
  String get appSettings_appearance => 'Apparence';

  @override
  String get appSettings_theme => 'Thème';

  @override
  String get appSettings_themeSystem => 'Défaut système';

  @override
  String get appSettings_themeLight => 'Lumière';

  @override
  String get appSettings_themeDark => 'Sombre';

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
  String get appSettings_language => 'Langue';

  @override
  String get appSettings_languageSystem => 'Par défaut du système';

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
  String get appSettings_languageRu => 'Russe';

  @override
  String get appSettings_languageUk => 'Ukrainien';

  @override
  String get appSettings_enableMessageTracing =>
      'Activer le traçage des messages';

  @override
  String get appSettings_enableMessageTracingSubtitle =>
      'Afficher les métadonnées détaillées de routage et de synchronisation des messages';

  @override
  String get appSettings_notifications => 'Notifications';

  @override
  String get appSettings_enableNotifications => 'Activer les Notifications';

  @override
  String get appSettings_enableNotificationsSubtitle =>
      'Recevoir des notifications pour les messages et les annonces';

  @override
  String get appSettings_notificationPermissionDenied =>
      'Permission de notification refusée';

  @override
  String get appSettings_notificationsEnabled => 'Notifications activées';

  @override
  String get appSettings_notificationsDisabled => 'Notifications désactivées';

  @override
  String get appSettings_messageNotifications => 'Notifications de Messages';

  @override
  String get appSettings_messageNotificationsSubtitle =>
      'Afficher une notification lors de la réception de nouveaux messages';

  @override
  String get appSettings_channelMessageNotifications =>
      'Notifications des Messages de Canal';

  @override
  String get appSettings_channelMessageNotificationsSubtitle =>
      'Afficher une notification lors de la réception des messages de canal';

  @override
  String get appSettings_advertisementNotifications =>
      'Notifications d\'annonces';

  @override
  String get appSettings_advertisementNotificationsSubtitle =>
      'Afficher une notification lors de la découverte de nouveaux nœuds';

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
  String get appSettings_messaging => 'Messagerie';

  @override
  String get appSettings_clearPathOnMaxRetry =>
      'Effacer le chemin sur Max Retry';

  @override
  String get appSettings_clearPathOnMaxRetrySubtitle =>
      'Réinitialiser le chemin de contact après 5 tentatives d\'envoi infructueuses';

  @override
  String get appSettings_pathsWillBeCleared =>
      'Les chemins seront effacés après 5 tentatives infructueuses.';

  @override
  String get appSettings_pathsWillNotBeCleared =>
      'Les chemins ne seront pas effacés automatiquement.';

  @override
  String get appSettings_autoRouteRotation =>
      'Rotation de l\'itinéraire automatique';

  @override
  String get appSettings_autoRouteRotationSubtitle =>
      'Alterner entre les meilleurs chemins et le mode d\'envoi sur tout le réseau (flood)';

  @override
  String get appSettings_autoRouteRotationEnabled =>
      'Rotation du routage automatique activée';

  @override
  String get appSettings_autoRouteRotationDisabled =>
      'Rotation de l\'itinéraire automatique désactivée';

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
  String get appSettings_battery => 'Batterie';

  @override
  String get appSettings_batteryChemistry => 'Chimie de la batterie';

  @override
  String appSettings_batteryChemistryPerDevice(String deviceName) {
    return 'Définir par appareil ($deviceName)';
  }

  @override
  String get appSettings_batteryChemistryConnectFirst =>
      'Connectez un appareil pour choisir';

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
  String get appSettings_mapDisplay => 'Affichage de la carte';

  @override
  String get appSettings_showRepeaters => 'Afficher les répéteurs';

  @override
  String get appSettings_showRepeatersSubtitle =>
      'Afficher les nœuds répéteurs sur la carte';

  @override
  String get appSettings_showChatNodes => 'Afficher les nœuds de discussion';

  @override
  String get appSettings_showChatNodesSubtitle =>
      'Afficher les nœuds de chat sur la carte';

  @override
  String get appSettings_showOtherNodes => 'Afficher d\'autres nœuds';

  @override
  String get appSettings_showOtherNodesSubtitle =>
      'Afficher d\'autres types de nœuds sur la carte';

  @override
  String get appSettings_timeFilter => 'Filtre du temps';

  @override
  String get appSettings_timeFilterShowAll => 'Afficher tous les nœuds';

  @override
  String appSettings_timeFilterShowLast(int hours) {
    return 'Afficher les nœuds des $hours dernières heures';
  }

  @override
  String get appSettings_mapTimeFilter => 'Filtre du Temps de la Carte';

  @override
  String get appSettings_showNodesDiscoveredWithin =>
      'Afficher les nœuds découverts dans :';

  @override
  String get appSettings_allTime => 'Tout le temps';

  @override
  String get appSettings_lastHour => 'Dernière heure';

  @override
  String get appSettings_last6Hours => 'Dernières 6 heures';

  @override
  String get appSettings_last24Hours => 'Dernières 24 heures';

  @override
  String get appSettings_lastWeek => 'La semaine dernière';

  @override
  String get appSettings_offlineMapCache => 'Cache de Carte Hors Ligne';

  @override
  String get appSettings_unitsTitle => 'Unités';

  @override
  String get appSettings_unitsMetric => 'Métrique (m/km)';

  @override
  String get appSettings_unitsImperial => 'Impérial (ft / mi)';

  @override
  String get appSettings_noAreaSelected => 'Aucune zone sélectionnée';

  @override
  String appSettings_areaSelectedZoom(int minZoom, int maxZoom) {
    return 'Zone sélectionnée (zoom $minZoom-$maxZoom)';
  }

  @override
  String get appSettings_debugCard => 'Déboguer';

  @override
  String get appSettings_appDebugLogging =>
      'Journalisation de débogage de l\'application';

  @override
  String get appSettings_appDebugLoggingSubtitle =>
      'Enregistrez les messages de débogage de l\'application Log pour le dépannage.';

  @override
  String get appSettings_appDebugLoggingEnabled =>
      'Journalisation de débogage de l\'application activée';

  @override
  String get appSettings_appDebugLoggingDisabled =>
      'Le débogage de l\'application est désactivé.';

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
  String get contacts_title => 'Contacts';

  @override
  String get contacts_noContacts => 'Aucun contact trouvé.';

  @override
  String get contacts_contactsWillAppear =>
      'Les contacts apparaîtront lorsque les appareils font leur annonce.';

  @override
  String get contacts_searchContacts => 'Rechercher des contacts...';

  @override
  String get contacts_noUnreadContacts => 'Aucun contact non lu';

  @override
  String get contacts_noContactsFound => 'Aucun contact ou groupe trouvé.';

  @override
  String get contacts_deleteContact => 'Supprimer le contact';

  @override
  String contacts_removeConfirm(String contactName) {
    return 'Supprimer $contactName des contacts ?';
  }

  @override
  String get contacts_manageRepeater => 'Gérer le répéteur';

  @override
  String get contacts_manageRoom => 'Gérer le Room Server';

  @override
  String get contacts_roomLogin => 'Connexion Room Server';

  @override
  String get contacts_openChat => 'Ouverture du Chat';

  @override
  String get contacts_editGroup => 'Modifier le groupe';

  @override
  String get contacts_deleteGroup => 'Supprimer le groupe';

  @override
  String contacts_deleteGroupConfirm(String groupName) {
    return 'Supprimer $groupName?';
  }

  @override
  String get contacts_newGroup => 'Nouveau Groupe';

  @override
  String get contacts_groupName => 'Nom du groupe';

  @override
  String get contacts_groupNameRequired => 'Le nom du groupe est obligatoire.';

  @override
  String contacts_groupAlreadyExists(String name) {
    return 'Le groupe \"$name\" existe déjà.';
  }

  @override
  String get contacts_filterContacts => 'Filtrer les contacts...';

  @override
  String get contacts_noContactsMatchFilter =>
      'Aucun contact ne correspond à votre filtre.';

  @override
  String get contacts_noMembers => 'Aucun membre';

  @override
  String get contacts_lastSeenNow => 'Vu maintenant';

  @override
  String contacts_lastSeenMinsAgo(int minutes) {
    return 'Vu il y a $minutes minutes';
  }

  @override
  String get contacts_lastSeenHourAgo => 'Vu il y a 1 heure';

  @override
  String contacts_lastSeenHoursAgo(int hours) {
    return 'Vu il y a $hours heures';
  }

  @override
  String get contacts_lastSeenDayAgo => 'Vu il y a 1 jour';

  @override
  String contacts_lastSeenDaysAgo(int days) {
    return 'Vu il y a $days jours';
  }

  @override
  String get channels_title => 'Canaux';

  @override
  String get channels_noChannelsConfigured => 'Aucun canal configuré';

  @override
  String get channels_addPublicChannel => 'Ajouter un canal public';

  @override
  String get channels_searchChannels => 'Rechercher des canaux...';

  @override
  String get channels_noChannelsFound => 'Aucun canal trouvé';

  @override
  String get channels_channelSlotsFull =>
      'All device channel slots are in use. Delete a channel before adding another.';

  @override
  String channels_channelAddFailed(String error) {
    return 'Could not add channel: $error';
  }

  @override
  String channels_channelIndex(int index) {
    return 'Canal $index';
  }

  @override
  String get channels_hashtagChannel => 'Canal avec hashtag';

  @override
  String get channels_public => 'Public';

  @override
  String get channels_private => 'Privé';

  @override
  String get channels_publicChannel => 'Canal public';

  @override
  String get channels_privateChannel => 'Canal privé';

  @override
  String get channels_editChannel => 'Modifier le canal';

  @override
  String get channels_deleteChannel => 'Supprimer le canal';

  @override
  String channels_deleteChannelConfirm(String name) {
    return 'Supprimer $name? Cela ne peut pas être annulé.';
  }

  @override
  String get channels_deleteChannelRequiresConnection =>
      'Connect to a device to delete a channel';

  @override
  String channels_channelDeleted(String name) {
    return 'Le canal \"$name\" a été supprimé';
  }

  @override
  String get channels_addChannel => 'Ajouter un Canal';

  @override
  String get channels_channelIndexLabel => 'Index de canal';

  @override
  String get channels_channelName => 'Nom du canal';

  @override
  String get channels_usePublicChannel => 'Utiliser le canal public';

  @override
  String get channels_standardPublicPsk => 'PSK public standard';

  @override
  String get channels_pskHex => 'PSK (Hex)';

  @override
  String get channels_generateRandomPsk =>
      'Générer une clé de modulation PSK aléatoire';

  @override
  String get channels_enterChannelName => 'Veuillez entrer un nom de canal';

  @override
  String get channels_pskMustBe32Hex =>
      'Le PKS doit être composé de 32 caractères hexadécimaux.';

  @override
  String channels_channelAdded(String name) {
    return 'Le canal \"$name\" a été ajouté';
  }

  @override
  String channels_editChannelTitle(int index) {
    return 'Modifier le Canal $index';
  }

  @override
  String get channels_smazCompression => 'Compression SMAZ';

  @override
  String channels_channelUpdated(String name) {
    return 'Le canal \"$name\" a été mis à jour';
  }

  @override
  String get channels_publicChannelAdded => 'Le canal public a été ajouté';

  @override
  String get channels_sortBy => 'Trier par';

  @override
  String get channels_sortManual => 'Manuel';

  @override
  String get channels_sortAZ => 'A à Z';

  @override
  String get channels_sortLatestMessages => 'Derniers messages';

  @override
  String get channels_sortUnread => 'Non lu';

  @override
  String get channels_createPrivateChannel => 'Créer un Canal Privé';

  @override
  String get channels_createPrivateChannelDesc =>
      'Sécurisé avec une clé secrète.';

  @override
  String get channels_joinPrivateChannel => 'Rejoindre un Canal Privé';

  @override
  String get channels_joinPrivateChannelDesc =>
      'Entrer manuellement une clé secrète.';

  @override
  String get channels_joinPublicChannel => 'Rejoindre le canal public';

  @override
  String get channels_joinPublicChannelDesc =>
      'Tout le monde peut rejoindre ce canal.';

  @override
  String get channels_joinHashtagChannel => 'Rejoindre un Canal Hashtag';

  @override
  String get channels_joinHashtagChannelDesc =>
      'N\'importe qui peut rejoindre les canaux #hashtag.';

  @override
  String get channels_scanQrCode => 'Scanner un code QR';

  @override
  String get channels_scanQrCodeDesc =>
      'Import a channel invite with name, key, and optional region.';

  @override
  String get channels_scanQrCodeComingSoon => 'Bientôt disponible';

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
  String get channels_enterHashtag => 'Entrez le hashtag';

  @override
  String get channels_hashtagHint => 'ex. #equipe';

  @override
  String get chat_noMessages => 'Aucun message pour le moment.';

  @override
  String get chat_sendMessageToStart => 'Envoyer un message pour commencer';

  @override
  String get chat_originalMessageNotFound => 'Message d\'origine non trouvé';

  @override
  String chat_replyingTo(String name) {
    return 'Répondre à $name';
  }

  @override
  String chat_replyTo(String name) {
    return 'Répondre à $name';
  }

  @override
  String get chat_location => 'Emplacement';

  @override
  String chat_sendMessageTo(String contactName) {
    return 'Envoyer un message à $contactName';
  }

  @override
  String get chat_typeMessage => 'Saisir un message...';

  @override
  String chat_messageTooLong(int maxBytes) {
    return 'Message trop long (max $maxBytes octets).';
  }

  @override
  String get chat_messageCopied => 'Message copié';

  @override
  String get chat_messageDeleted => 'Message supprimé';

  @override
  String get chat_retryingMessage => 'Tentative de récupération.';

  @override
  String chat_retryCount(int current, int max) {
    return 'Essai $current/$max';
  }

  @override
  String get chat_sendGif => 'Envoyer GIF';

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
  String get chat_reply => 'Répondre';

  @override
  String get chat_addReaction => 'Ajouter une Réaction';

  @override
  String get chat_editMessage => 'Edit message';

  @override
  String get chat_editedLabel => '(edited)';

  @override
  String get chat_messageEdited => 'Message edited';

  @override
  String get chat_me => 'Moi';

  @override
  String get emojiCategorySmileys => 'Émojis';

  @override
  String get emojiCategoryGestures => 'Gestes';

  @override
  String get emojiCategoryHearts => 'Cœurs';

  @override
  String get emojiCategoryObjects => 'Objets';

  @override
  String get gifPicker_title => 'Choisir un GIF';

  @override
  String get gifPicker_searchHint => 'Rechercher des GIF...';

  @override
  String get gifPicker_poweredBy => 'Propulsé par GIPHY';

  @override
  String get gifPicker_noGifsFound => 'Aucun GIF trouvé';

  @override
  String get gifPicker_failedLoad => 'Impossible de charger les GIFs';

  @override
  String get gifPicker_failedSearch => 'Recherche de GIFs échouée';

  @override
  String get gifPicker_noInternet => 'Aucune connexion internet';

  @override
  String get debugLog_appTitle => 'Journal de débogage de l\'application';

  @override
  String get debugLog_bleTitle => 'Journal de débogage BLE';

  @override
  String get debugLog_copyLog => 'Copier le journal';

  @override
  String get debugLog_clearLog => 'Effacer le journal';

  @override
  String get debugLog_copied => 'Journal de débogage copié';

  @override
  String get debugLog_bleCopied => 'Journal BLE copié';

  @override
  String get debugLog_noEntries => 'Aucun journal de débogage pour le moment.';

  @override
  String get debugLog_enableInSettings =>
      'Activer le débogage de l\'application dans les paramètres';

  @override
  String get debugLog_frames => 'Cadres';

  @override
  String get debugLog_rawLogRx => 'Enregistrement brut - RX';

  @override
  String get debugLog_noBleActivity =>
      'Pas d\'activité BLE enregistrée pour le moment.';

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
    return 'Longueur du cadre : $count octets';
  }

  @override
  String debugFrame_command(String value) {
    return 'Commande : 0x$value';
  }

  @override
  String get debugFrame_textMessageHeader => 'Message :';

  @override
  String debugFrame_destinationPubKey(String pubKey) {
    return '- Destination PubKey: $pubKey';
  }

  @override
  String debugFrame_timestamp(int timestamp) {
    return '- Timestamp : $timestamp';
  }

  @override
  String debugFrame_flags(String value) {
    return '- Indicateurs : 0x$value';
  }

  @override
  String debugFrame_textType(int type, String label) {
    return '- Type de texte : $type ($label)';
  }

  @override
  String get debugFrame_textTypeCli => 'CLI';

  @override
  String get debugFrame_textTypePlain => 'Simple';

  @override
  String debugFrame_text(String text) {
    return '- Texte : \"$text\"';
  }

  @override
  String get debugFrame_hexDump => 'Vidéo de Dump Hexadécimal :';

  @override
  String get chat_pathManagement => 'Gestion des chemins';

  @override
  String get chat_ShowAllPaths => 'Afficher tous les chemins';

  @override
  String get chat_routingMode => 'Mode de routage';

  @override
  String get chat_autoUseSavedPath => 'Auto (utiliser le chemin sauvegardé)';

  @override
  String get chat_forceFloodMode => 'Mode tout le réseau forcé';

  @override
  String get chat_recentAckPaths =>
      'Chemins ACK récents (touchez pour utiliser) :';

  @override
  String get chat_pathHistoryFull =>
      'L\'historique du chemin est plein. Supprimez les entrées pour en ajouter de nouvelles.';

  @override
  String get chat_hopSingular => 'saut';

  @override
  String get chat_hopPlural => 'sauts';

  @override
  String chat_hopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sauts',
      one: 'saut',
    );
    return '$count $_temp0';
  }

  @override
  String get chat_successes => 'Succès';

  @override
  String get chat_removePath => 'Supprimer le chemin';

  @override
  String get chat_noPathHistoryYet =>
      'Aucune historique de parcours disponible.\nEnvoyez un message pour découvrir les parcours.';

  @override
  String get chat_pathActions => 'Actions du chemin :';

  @override
  String get chat_setCustomPath => 'Définir un chemin personnalisé';

  @override
  String get chat_setCustomPathSubtitle =>
      'Spécifier manuellement le chemin de routage';

  @override
  String get chat_clearPath => 'Effacer le chemin';

  @override
  String get chat_clearPathSubtitle =>
      'Forcer la redécouverte lors de la prochaine envoi';

  @override
  String get chat_pathCleared =>
      'Le chemin est dégagé. Le prochain message redécouvrira le tracé.';

  @override
  String get chat_floodModeSubtitle =>
      'Utiliser le commutateur de routage dans la barre d\'application';

  @override
  String get chat_floodModeEnabled =>
      'Le mode envoi à tout le réseau est activé. Changer via l\'icône de routage dans la barre d\'outils.';

  @override
  String get chat_fullPath => 'Chemin complet';

  @override
  String get chat_pathDetailsNotAvailable =>
      'Les détails du chemin ne sont pas encore disponibles. Essayez d\'envoyer un message pour rafraîchir.';

  @override
  String chat_pathSetHops(int hopCount, String status) {
    String _temp0 = intl.Intl.pluralLogic(
      hopCount,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Chemin défini : $hopCount $_temp0 - $status';
  }

  @override
  String get chat_pathSavedLocally =>
      'Sauvegardé localement. Connectez-vous pour synchroniser.';

  @override
  String get chat_pathDeviceConfirmed => 'Appareil confirmé.';

  @override
  String get chat_pathDeviceNotConfirmed =>
      'L\'appareil n\'a pas encore été confirmé.';

  @override
  String get chat_type => 'Saisir';

  @override
  String get chat_path => 'Chemin';

  @override
  String get chat_publicKey => 'Clé Publique';

  @override
  String get chat_compressOutgoingMessages =>
      'Compresser les messages sortants';

  @override
  String get chat_floodForced => 'Tout le réseau  (forcée)';

  @override
  String get chat_directForced => 'Direct (forcé)';

  @override
  String chat_hopsForced(int count) {
    return '$count sauts (forcés)';
  }

  @override
  String get chat_floodAuto => 'Tout le réseau (auto)';

  @override
  String get chat_direct => 'Afficher';

  @override
  String get chat_poiShared => 'Point d\'intérêt Partagé';

  @override
  String chat_unread(int count) {
    return 'Non lu : $count';
  }

  @override
  String get chat_openLink => 'Ouvrir le lien ?';

  @override
  String get chat_openLinkConfirmation =>
      'Voulez-vous ouvrir ce lien dans votre navigateur ?';

  @override
  String get chat_open => 'Ouvrir';

  @override
  String chat_couldNotOpenLink(String url) {
    return 'Impossible d\'ouvrir le lien : $url';
  }

  @override
  String get chat_invalidLink => 'Format de lien invalide';

  @override
  String get map_title => 'Carte des nœuds';

  @override
  String get map_lineOfSight => 'Ligne de vue';

  @override
  String get map_losScreenTitle => 'Ligne de vue';

  @override
  String get map_noNodesWithLocation =>
      'Aucun nœud avec des données de localisation';

  @override
  String get map_nodesNeedGps =>
      'Les nœuds doivent partager leurs coordonnées GPS\npour apparaître sur la carte.';

  @override
  String map_nodesCount(int count) {
    return 'Nœuds : $count';
  }

  @override
  String map_pinsCount(int count) {
    return 'Epingles: $count';
  }

  @override
  String get map_chat => 'Chat';

  @override
  String get map_repeater => 'Répéteur';

  @override
  String get map_room => 'Salle';

  @override
  String get map_sensor => 'Capteur';

  @override
  String get map_pinDm => 'Clé (DM)';

  @override
  String get map_pinPrivate => 'Verrouiller (Privé)';

  @override
  String get map_pinPublic => 'Clé (Public)';

  @override
  String get map_lastSeen => 'Dernière fois vu';

  @override
  String get map_disconnectConfirm =>
      'Êtes-vous sûr de vouloir vous déconnecter de cet appareil ?';

  @override
  String get map_from => 'À partir de';

  @override
  String get map_source => 'Source';

  @override
  String get map_flags => 'Drapeaux';

  @override
  String get map_pinLabel => 'Étiquete de repin';

  @override
  String get map_label => 'Étiquette';

  @override
  String get map_publicLocationShare => 'Partager dans un lieu public';

  @override
  String map_publicLocationShareConfirm(String channelLabel) {
    return 'Vous êtes sur le point de partager un emplacement dans $channelLabel. Ce canal est public et toute personne disposant de la clé PSK peut le voir.';
  }

  @override
  String get map_connectToShareMarkers =>
      'Connectez-vous à un appareil pour partager des marqueurs';

  @override
  String get map_filterNodes => 'Filtrer les nœuds';

  @override
  String get map_nodeTypes => 'Types de nœuds';

  @override
  String get map_chatNodes => 'Nœuds de Chat';

  @override
  String get map_repeaters => 'Répéteurs';

  @override
  String get map_otherNodes => 'Autres nœuds';

  @override
  String get map_keyPrefix => 'Préfixe clé';

  @override
  String get map_filterByKeyPrefix => 'Filtrer par préfixe de clé';

  @override
  String get map_publicKeyPrefix => 'Préfixe de clé publique';

  @override
  String get map_markers => 'Marqueurs';

  @override
  String get map_showSharedMarkers => 'Afficher les marqueurs partagés';

  @override
  String get map_lastSeenTime => 'Dernière fois vu';

  @override
  String get map_joinRoom => 'Rejoindre la salle';

  @override
  String get map_manageRepeater => 'Gérer le répéteur';

  @override
  String get map_tapToAdd =>
      'Appuyez sur les nœuds pour les ajouter au chemin.';

  @override
  String get map_runTrace => 'Exécuter la traçage de chemin';

  @override
  String get map_removeLast => 'Supprimer le dernier';

  @override
  String get map_pathTraceCancelled => 'Traçage de chemin annulé';

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
  String get mapCache_title => 'Cache de Carte Hors Ligne';

  @override
  String get mapCache_selectAreaFirst =>
      'Sélectionner une zone pour la mise en cache en premier';

  @override
  String get mapCache_noTilesToDownload =>
      'Aucun tuilage à télécharger pour cette zone.';

  @override
  String get mapCache_downloadTilesTitle => 'Télécharger les tuiles';

  @override
  String mapCache_downloadTilesPrompt(int count) {
    return 'Télécharger $count tuiles pour un usage hors ligne ?';
  }

  @override
  String get mapCache_downloadAction => 'Télécharger';

  @override
  String mapCache_cachedTiles(int count) {
    return 'Cachez $count tuiles';
  }

  @override
  String mapCache_cachedTilesWithFailed(int downloaded, int failed) {
    return 'Tuiles mis en cache ($downloaded) ($failed ratés)';
  }

  @override
  String get mapCache_clearOfflineCacheTitle => 'Vider le cache hors ligne';

  @override
  String get mapCache_clearOfflineCachePrompt =>
      'Supprimer toutes les tuiles de carte mises en cache ?';

  @override
  String get mapCache_offlineCacheCleared =>
      'Le cache hors ligne a été effacé.';

  @override
  String get mapCache_noAreaSelected => 'Aucune zone sélectionnée';

  @override
  String get mapCache_cacheArea => 'Zone de cache';

  @override
  String get mapCache_useCurrentView => 'Utiliser la Vue Actuelle';

  @override
  String get mapCache_zoomRange => 'Plage de zoom';

  @override
  String mapCache_estimatedTiles(int count) {
    return 'Estimation des tuiles : $count';
  }

  @override
  String mapCache_downloadedTiles(int completed, int total) {
    return 'Téléchargé $completed / $total';
  }

  @override
  String get mapCache_downloadTilesButton => 'Télécharger les tuiles';

  @override
  String get mapCache_clearCacheButton => 'Vider le Cache';

  @override
  String mapCache_failedDownloads(int count) {
    return 'Téléchargements échoués : $count';
  }

  @override
  String mapCache_boundsLabel(
    String north,
    String south,
    String east,
    String west,
  ) {
    return 'N $north, S $south, E $east, O $west';
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
  String get time_justNow => 'Maintenant';

  @override
  String time_minutesAgo(int minutes) {
    return '$minutes minutes auparavant';
  }

  @override
  String time_hoursAgo(int hours) {
    return '${hours}h auparavant';
  }

  @override
  String time_daysAgo(int days) {
    return '$days jours avant';
  }

  @override
  String get time_hour => 'heure';

  @override
  String get time_hours => 'heures';

  @override
  String get time_day => 'jour';

  @override
  String get time_days => 'jours';

  @override
  String get time_week => 'semaine';

  @override
  String get time_weeks => 'semaines';

  @override
  String get time_month => 'mois';

  @override
  String get time_months => 'mois';

  @override
  String get time_minutes => 'minutes';

  @override
  String get time_allTime => 'Tout le temps';

  @override
  String get dialog_disconnect => 'Déconnecter';

  @override
  String get dialog_disconnectConfirm =>
      'Êtes-vous sûr de vouloir vous déconnecter de cet appareil ?';

  @override
  String get login_repeaterLogin => 'Connexion au répéteur';

  @override
  String get login_roomLogin => 'Connexion Room Server';

  @override
  String get login_password => 'Mot de passe';

  @override
  String get login_enterPassword => 'Entrez votre mot de passe';

  @override
  String get login_savePassword => 'Sauvegarder le mot de passe';

  @override
  String get login_savePasswordSubtitle =>
      'Le mot de passe sera stocké en toute sécurité sur cet appareil.';

  @override
  String get login_repeaterDescription =>
      'Entrez le mot de passe du répéteur pour accéder aux paramètres et à l\'état.';

  @override
  String get login_roomDescription =>
      'Entrez le mot de passe de la pièce pour accéder aux paramètres et à l\'état.';

  @override
  String get login_routing => 'Redirection';

  @override
  String get login_routingMode => 'Mode de routage';

  @override
  String get login_autoUseSavedPath => 'Auto (utiliser le chemin sauvegardé)';

  @override
  String get login_forceFloodMode => 'Mode tout le réseau forcé';

  @override
  String get login_managePaths => 'Gérer les chemins';

  @override
  String get login_login => 'Connexion';

  @override
  String login_attempt(int current, int max) {
    return 'Essayer $current/$max';
  }

  @override
  String login_failed(String error) {
    return 'Connexion échouée : $error';
  }

  @override
  String get login_failedMessage =>
      'Connexion échouée. Soit le mot de passe est incorrect, soit le relais est injoignable.';

  @override
  String get common_reload => 'Recharger';

  @override
  String get common_clear => 'Effacer';

  @override
  String path_currentPath(String path) {
    return 'Chemin actuel : $path';
  }

  @override
  String path_usingHopsPath(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hops',
      one: 'hop',
    );
    return 'Utiliser $count $_temp0 chemin';
  }

  @override
  String get path_enterCustomPath => 'Entrer un chemin personnalisé';

  @override
  String get path_currentPathLabel => 'Chemin actuel';

  @override
  String get path_hexPrefixInstructions =>
      'Entrez les préfixes hexadécimaux de 2 caractères pour chaque saut, séparés par des virgules.';

  @override
  String get path_hexPrefixExample =>
      'Exemple : A1,F2,3C (chaque nœud utilise le premier octet de sa clé publique).';

  @override
  String get path_labelHexPrefixes => 'Préfixes hexadécimaux';

  @override
  String get path_helperMaxHops =>
      'Max 64 sauts. Chaque préfixe fait 2 caractères hexadécimaux (1 octet)';

  @override
  String get path_selectFromContacts => 'Sélectionner à partir des contacts :';

  @override
  String get path_noRepeatersFound =>
      'Aucun répéteur ou serveur de salle n\'a été trouvé.';

  @override
  String get path_customPathsRequire =>
      'Les chemins personnalisés nécessitent des sauts intermédiaires qui peuvent transmettre des messages.';

  @override
  String path_invalidHexPrefixes(String prefixes) {
    return 'Préfixes hexadécimaux invalides : $prefixes';
  }

  @override
  String get path_tooLong =>
      'Le chemin est trop long. Maximum 64 sauts autorisés.';

  @override
  String get path_setPath => 'Définir le chemin';

  @override
  String get repeater_management => 'Gestion des répéteurs';

  @override
  String get room_management => 'Administrattion Room Server';

  @override
  String get repeater_managementTools => 'Outils de Gestion';

  @override
  String get repeater_status => 'État';

  @override
  String get repeater_statusSubtitle =>
      'Afficher l\'état, les statistiques et les voisins du répéteur';

  @override
  String get repeater_sendAdvert => 'Send Advert';

  @override
  String get repeater_sendAdvertSubtitle =>
      'Broadcast an advertisement packet now';

  @override
  String get repeater_telemetry => 'Télémetrie';

  @override
  String get repeater_telemetrySubtitle =>
      'Afficher la télémétrie des capteurs et les statistiques du système';

  @override
  String get repeater_cli => 'CLI';

  @override
  String get repeater_cliSubtitle => 'Envoyer des commandes au répéteur';

  @override
  String get repeater_neighbors => 'Voisins';

  @override
  String get repeater_neighborsSubtitle => 'Afficher les voisins de saut nuls.';

  @override
  String get repeater_settings => 'Paramètres';

  @override
  String get repeater_settingsSubtitle =>
      'Configurer les paramètres du répéteur';

  @override
  String get repeater_statusTitle => 'État du répéteur';

  @override
  String get repeater_routingMode => 'Mode de routage';

  @override
  String get repeater_autoUseSavedPath =>
      'Auto (utiliser le chemin sauvegardé)';

  @override
  String get repeater_forceFloodMode => 'Mode tout le réseau forcé';

  @override
  String get repeater_pathManagement => 'Gestion des chemins';

  @override
  String get repeater_refresh => 'Rafraîchir';

  @override
  String get repeater_statusRequestTimeout =>
      'Demande de statut délai dépassé.';

  @override
  String repeater_errorLoadingStatus(String error) {
    return 'Erreur lors du chargement du statut : $error';
  }

  @override
  String get repeater_systemInformation => 'Informations Système';

  @override
  String get repeater_firmwareVersion => 'Firmware';

  @override
  String get repeater_battery => 'Batterie';

  @override
  String get repeater_clockAtLogin => 'Horloge (au démarrage)';

  @override
  String get repeater_uptime => 'Disponibilité';

  @override
  String get repeater_queueLength => 'Longueur de la file d\'attente';

  @override
  String get repeater_debugFlags => 'Marqueurs de débogage';

  @override
  String get repeater_radioStatistics => 'Statistiques Radio';

  @override
  String get repeater_lastRssi => 'Dernier RSSI';

  @override
  String get repeater_lastSnr => 'Dernier SNR';

  @override
  String get repeater_noiseFloor => 'Niveau de Bruit';

  @override
  String get repeater_txAirtime => 'TX Airtime';

  @override
  String get repeater_rxAirtime => 'RX Airtime';

  @override
  String get repeater_packetStatistics => 'Statistiques des paquets';

  @override
  String get repeater_sent => 'Envoyé';

  @override
  String get repeater_received => 'Reçu';

  @override
  String get repeater_duplicates => 'Doublons';

  @override
  String repeater_daysHoursMinsSecs(
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return '$days jours ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  String repeater_packetTxTotal(int total, String flood, String direct) {
    return 'Total : $total, Tout le réseau : $flood, Direct : $direct';
  }

  @override
  String repeater_packetRxTotal(int total, String flood, String direct) {
    return 'Total : $total, Tout le réseau : $flood, Direct : $direct';
  }

  @override
  String repeater_duplicatesFloodDirect(String flood, String direct) {
    return 'Tout le réseau : $flood, Direct : $direct';
  }

  @override
  String repeater_duplicatesTotal(int total) {
    return 'Total : $total';
  }

  @override
  String get repeater_settingsTitle => 'Paramètres du répéteur';

  @override
  String get repeater_basicSettings => 'Paramètres de base';

  @override
  String get repeater_repeaterName => 'Nom du répéteur';

  @override
  String get repeater_repeaterNameHelper => 'Afficher le nom de ce répéteur';

  @override
  String get repeater_adminPassword => 'Mot de passe Administrateur';

  @override
  String get repeater_adminPasswordHelper => 'Mot de passe d\'accès complet';

  @override
  String get repeater_guestPassword => 'Mot de passe invité';

  @override
  String get repeater_guestPasswordHelper =>
      'Accès en lecture seule avec mot de passe';

  @override
  String get repeater_radioSettings => 'Paramètres Radio';

  @override
  String get repeater_frequencyMhz => 'Fréquence (MHz)';

  @override
  String get repeater_frequencyHelper => '300-2500 MHz';

  @override
  String get repeater_txPower => 'TX Puissance';

  @override
  String get repeater_txPowerHelper => '1-30 dBm';

  @override
  String get repeater_bandwidth => 'Bande passante';

  @override
  String get repeater_spreadingFactor => 'Facteur de répartition';

  @override
  String get repeater_codingRate => 'Taux de codage';

  @override
  String get repeater_locationSettings => 'Paramètres de localisation';

  @override
  String get repeater_latitude => 'Latitude';

  @override
  String get repeater_latitudeHelper =>
      'Degrés décimaux (par exemple, 37.7749)';

  @override
  String get repeater_longitude => 'Longitude';

  @override
  String get repeater_longitudeHelper =>
      'Degrés décimaux (par exemple, -122,4194)';

  @override
  String get repeater_features => 'Fonctionnalités';

  @override
  String get repeater_packetForwarding => 'Transfert de paquets';

  @override
  String get repeater_packetForwardingSubtitle =>
      'Activer le répéteur pour transmettre des paquets';

  @override
  String get repeater_guestAccess => 'Accès Invité';

  @override
  String get repeater_guestAccessSubtitle =>
      'Autoriser l\'accès invité en lecture seule';

  @override
  String get repeater_privacyMode => 'Mode de confidentialité';

  @override
  String get repeater_privacyModeSubtitle =>
      'Cacher le nom/l\'emplacement dans les annonces';

  @override
  String get repeater_advertisementSettings => 'Paramètres d\'annonces';

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
      'Intervalle des annonces Locale (0 saut)';

  @override
  String repeater_localAdvertIntervalMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get repeater_floodAdvertInterval =>
      'Intervalle des annonces à tout le réseau (flood)';

  @override
  String repeater_floodAdvertIntervalHours(int hours) {
    return '$hours heures';
  }

  @override
  String get repeater_encryptedAdvertInterval =>
      'Intervalle d\'annonces cryptées';

  @override
  String get repeater_dangerZone => 'Zone dangereuse';

  @override
  String get repeater_rebootRepeater => 'Redémarrer Répéteur';

  @override
  String get repeater_rebootRepeaterSubtitle =>
      'Réinitialiser l\'appareil répéteur';

  @override
  String get repeater_rebootRepeaterConfirm =>
      'Êtes-vous sûr de vouloir redémarrer ce répéteur ?';

  @override
  String get repeater_regenerateIdentityKeySubtitle =>
      'Générer une nouvelle paire de clés publique/privée';

  @override
  String get repeater_regenerateIdentityKeyConfirm =>
      'Cela générera une nouvelle identité pour le répéteur. Continuer ?';

  @override
  String get repeater_eraseFileSystem => 'Supprimer le système de fichiers';

  @override
  String get repeater_eraseFileSystemSubtitle =>
      'Formater le système de fichiers du répéteur';

  @override
  String get repeater_eraseFileSystemConfirm =>
      'AVERTISSEMENT : Cela effacera toutes les données du répéteur. Cela ne peut pas être annulé !';

  @override
  String get repeater_eraseSerialOnly =>
      'Erase n\'est disponible que via la console série.';

  @override
  String repeater_commandSent(String command) {
    return 'Commande envoyée : $command';
  }

  @override
  String repeater_errorSendingCommand(String error) {
    return 'Erreur lors de l\'envoi de la commande : $error';
  }

  @override
  String get repeater_confirm => 'Confirmer';

  @override
  String get repeater_settingsSaved =>
      'Les paramètres ont été enregistrés avec succès.';

  @override
  String repeater_errorSavingSettings(String error) {
    return 'Erreur lors de la sauvegarde des paramètres : $error';
  }

  @override
  String get repeater_refreshBasicSettings =>
      'Rafraîchir les paramètres de base';

  @override
  String get repeater_refreshRadioSettings => 'Rafraîchir les paramètres Radio';

  @override
  String get repeater_refreshTxPower => 'Rafraîchir la tension TX';

  @override
  String get repeater_refreshLocationSettings =>
      'Rafraîchir les paramètres de localisation';

  @override
  String get repeater_refreshPacketForwarding =>
      'Rafraîchir le routage des paquets';

  @override
  String get repeater_refreshGuestAccess => 'Rafraîchir l\'accès invité';

  @override
  String get repeater_refreshPrivacyMode =>
      'Rafraîchir le Mode Confidentialité';

  @override
  String get repeater_refreshAdvertisementSettings =>
      'Rafraîchir les Paramètres des annonces';

  @override
  String repeater_refreshed(String label) {
    return '$label rafraîchi';
  }

  @override
  String repeater_errorRefreshing(String label) {
    return 'Erreur lors du rafraîchissement de $label';
  }

  @override
  String get repeater_cliTitle => 'Répéteur CLI';

  @override
  String get repeater_debugNextCommand => 'Déboguer Prochaine Commande';

  @override
  String get repeater_commandHelp => 'Aide';

  @override
  String get repeater_clearHistory => 'Effacer l\'historique';

  @override
  String get repeater_noCommandsSent =>
      'Aucune commande n\'a encore été envoyée.';

  @override
  String get repeater_typeCommandOrUseQuick =>
      'Saisissez une commande ci-dessous ou utilisez les commandes rapides';

  @override
  String get repeater_enterCommandHint => 'Entrer la commande...';

  @override
  String get repeater_previousCommand => 'Commande précédente';

  @override
  String get repeater_nextCommand => 'Prochaine commande';

  @override
  String get repeater_enterCommandFirst => 'Entrez d\'abord une commande';

  @override
  String get repeater_cliCommandFrameTitle => 'Frame de commande CLI';

  @override
  String repeater_cliCommandError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get repeater_cliQuickGetName => 'Obtenir le nom';

  @override
  String get repeater_cliQuickGetRadio => 'Obtenir la Radio';

  @override
  String get repeater_cliQuickGetTx => 'Obtenir TX';

  @override
  String get repeater_cliQuickNeighbors => 'Voisins';

  @override
  String get repeater_cliQuickVersion => 'Version';

  @override
  String get repeater_cliQuickAdvertise => 'Publier';

  @override
  String get repeater_cliQuickClock => 'Horloge';

  @override
  String get repeater_cliHelpAdvert => 'Envoie un paquet d\'annonce';

  @override
  String get repeater_cliHelpReboot =>
      'Redémarre l\'appareil. (Note, vous risquez d\'obtenir \'Timeout\' ce qui est normal)';

  @override
  String get repeater_cliHelpClock =>
      'Affiche l\'heure actuelle par l\'horloge de chaque appareil.';

  @override
  String get repeater_cliHelpPassword =>
      'Définit un nouveau mot de passe administrateur pour l\'appareil.';

  @override
  String get repeater_cliHelpVersion =>
      'Affiche la version du périphérique et la date de construction du micrologiciel.';

  @override
  String get repeater_cliHelpClearStats =>
      'Réinitialise divers compteurs de statistiques à zéro.';

  @override
  String get repeater_cliHelpSetAf => 'Définit le facteur de temps d\'air.';

  @override
  String get repeater_cliHelpSetTx =>
      'Définit la puissance de transmission LoRa en dBm (réinitialisation requise pour appliquer).';

  @override
  String get repeater_cliHelpSetRepeat =>
      'Active ou désactive le rôle du répéteur pour ce nœud.';

  @override
  String get repeater_cliHelpSetAllowReadOnly =>
      '(Room server) Si \"activé\", alors un mot de passe vide permettra la connexion, mais ne permettra pas de publier dans la pièce. (lecture seule uniquement)';

  @override
  String get repeater_cliHelpSetFloodMax =>
      'Définit le nombre maximal de sauts pour les paquets de balayage entrants (si >= max, le paquet n\'est pas acheminé).';

  @override
  String get repeater_cliHelpSetIntThresh =>
      'Définit le seuil d\'interférence (en dB). La valeur par défaut est de 14. Définir sur 0 désactive la détection des interférences de canal.';

  @override
  String get repeater_cliHelpSetAgcResetInterval =>
      'Définit l\'intervalle pour réinitialiser le contrôleur de gain automatique. Mettez à 0 pour désactiver.';

  @override
  String get repeater_cliHelpSetMultiAcks =>
      'Active ou désactive la fonctionnalité « double ACKs ».';

  @override
  String get repeater_cliHelpSetAdvertInterval =>
      'Définit l\'intervalle entre chaque émission d\'une annonce locale (sans relais). Définir sur 0 pour désactiver.';

  @override
  String get repeater_cliHelpSetFloodAdvertInterval =>
      'Définit l\'intervalle du minuteur en heures pour envoyer un paquet d\'annonce massive. Définir sur 0 pour désactiver.';

  @override
  String get repeater_cliHelpGetPathHashMode =>
      'Returns advert path hash mode (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetPathHashMode =>
      'Sets advert path hash mode for this repeater (0=1-byte, 1=2-byte, 2=3-byte). Requires firmware 1.14+.';

  @override
  String get repeater_cliHelpSetGuestPassword =>
      'Définit/met à jour le mot de passe de l\'invité. (pour les répéteurs, les connexions d\'invités peuvent envoyer la requête \"Get Stats\")';

  @override
  String get repeater_cliHelpSetName => 'Définit le nom de l\'annonce.';

  @override
  String get repeater_cliHelpSetLat =>
      'Définit la latitude de la carte des annonces. (degrés décimaux)';

  @override
  String get repeater_cliHelpSetLon =>
      'Définit la longitude de la carte de l\'annonce. (degrés décimaux)';

  @override
  String get repeater_cliHelpSetRadio =>
      'Définit complètement de nouveaux paramètres de radio et les enregistre dans les préférences. Nécessite une commande \"redémarrage\" pour les appliquer.';

  @override
  String get repeater_cliHelpSetRxDelay =>
      'Paramètres (expérimental) de base pour appliquer un léger délai aux paquets reçus, en fonction de la force du signal/score. Définir sur 0 pour désactiver.';

  @override
  String get repeater_cliHelpSetTxDelay =>
      'Définit un facteur multiplié par le temps de fonctionnement en mode vers tout le réseau (flood) pour un paquet et avec un système de slot aléatoire, afin de retarder son envoi (pour diminuer la probabilité de collisions).';

  @override
  String get repeater_cliHelpSetDirectTxDelay =>
      'Identique à txdelay, mais pour appliquer un délai aléatoire au transfert des paquets en mode direct.';

  @override
  String get repeater_cliHelpSetBridgeEnabled => 'Activer/Désactiver le pont.';

  @override
  String get repeater_cliHelpSetBridgeDelay =>
      'Définir le délai avant de renvoyer les paquets.';

  @override
  String get repeater_cliHelpSetBridgeSource =>
      'Choisissez si le pont retransmettra les paquets reçus ou les paquets transmis.';

  @override
  String get repeater_cliHelpSetBridgeBaud =>
      'Définir la vitesse de communication série pour les ponts Rs232.';

  @override
  String get repeater_cliHelpSetBridgeSecret =>
      'Définir le secret du pont pour les ponts espnow.';

  @override
  String get repeater_cliHelpSetAdcMultiplier =>
      'Définit un facteur personnalisé pour ajuster la tension de la batterie signalée (uniquement pris en charge sur certains cartes).';

  @override
  String get repeater_cliHelpTempRadio =>
      'Définit des paramètres radio temporaires pour le nombre de minutes donné, puis revient aux paramètres radio d\'origine. (ne sauvegarde pas dans les préférences).';

  @override
  String get repeater_cliHelpSetPerm =>
      'Modifie l’ACL. Supprime l’entrée correspondante (par préfixe de clé publique) si \"permissions\" est égal à zéro. Ajoute une nouvelle entrée si la clé publique hexadécimale a une longueur complète et n’est pas actuellement dans l’ACL. Met à jour l’entrée en fonction du préfixe de clé publique. Les bits de permission varient en fonction du rôle du firmware, mais les 2 bits inférieurs sont : 0 (Invité), 1 (Lecture seule), 2 (Lecture/écriture), 3 (Administrateur).';

  @override
  String get repeater_cliHelpGetBridgeType =>
      'Obtenir le type de pont : aucun, rs232, espnow';

  @override
  String get repeater_cliHelpLogStart =>
      'Démarre l\'enregistrement des paquets dans le système de fichiers.';

  @override
  String get repeater_cliHelpLogStop =>
      'Arrêter de journaliser les paquets vers le système de fichiers.';

  @override
  String get repeater_cliHelpLogErase =>
      'Supprime les journaux de paquets du système de fichiers.';

  @override
  String get repeater_cliHelpNeighbors =>
      'Affiche une liste d\'autres nœuds répéteurs entendus via des annonces sans relais. Chaque ligne est id-préfixe-hexadécimal:timestamp:snr-fois-4';

  @override
  String get repeater_cliHelpNeighborRemove =>
      'Supprime la première entrée correspondante (par préfixe de clé publique (hexadécimal)) de la liste des voisins.';

  @override
  String get repeater_cliHelpRegion =>
      '(série uniquement) Liste toutes les régions définies et les autorisations actuelles d\'annonces sur tout le réseau (flood).';

  @override
  String get repeater_cliHelpRegionLoad =>
      'REMARQUE : il s\'agit d\'une invocation multi-commande spéciale. Chaque commande subséquente est un nom de région (indenté avec des espaces pour indiquer la hiérarchie parent, avec un minimum d\'un espace). Terminé par l\'envoi d\'une ligne vide/commande.';

  @override
  String get repeater_cliHelpRegionGet =>
      'Recherche la région avec le préfixe de nom donné (ou \"\" pour l\'étendue globale). Répond avec \"-> nom-de-région (nom-parent) \'F\'\"';

  @override
  String get repeater_cliHelpRegionPut =>
      'Ajoute ou met à jour une définition de région avec le nom donné.';

  @override
  String get repeater_cliHelpRegionRemove =>
      'Supprime une définition de région avec le nom donné.';

  @override
  String get repeater_cliHelpRegionAllowf =>
      'Définit les autorisations de \"Flot\" pour la région donnée. (\'\' pour la portée globale/héritée)';

  @override
  String get repeater_cliHelpRegionDenyf =>
      'Supprime l\'autorisation \'F\'lood\' pour la région donnée. (NOTE : à ce stade, il n\'est pas conseillé de l\'utiliser sur l\'étendue globale/héritée !! )';

  @override
  String get repeater_cliHelpRegionHome =>
      'Répond avec la région \'maison\' actuelle. (Note appliquée nulle part pour l\'instant, réservée à une utilisation future)';

  @override
  String get repeater_cliHelpRegionHomeSet => 'Définit la région \'maison\'.';

  @override
  String get repeater_cliHelpRegionSave =>
      'Conserve la liste/la carte des régions dans le stockage.';

  @override
  String get repeater_cliHelpGps =>
      'Affiche l’état du GPS. Lorsque le GPS est éteint, il répond uniquement « éteint », si allumé, il répond avec « allumé », l’état, la correction, le nombre de satellites.';

  @override
  String get repeater_cliHelpGpsOnOff => 'Activer/désactiver le GPS.';

  @override
  String get repeater_cliHelpGpsSync =>
      'Synchronise l\'heure du nœud avec l\'horloge GPS.';

  @override
  String get repeater_cliHelpGpsSetLoc =>
      'Définit la position du nœud aux coordonnées GPS et enregistre les préférences.';

  @override
  String get repeater_cliHelpGpsAdvert =>
      'Donne la configuration de l\'annonce de la localisation du nœud :\n- none : ne pas inclure la localisation dans les annonces\n- share : partager la localisation GPS (du SensorManager)\n- prefs : annoncer la localisation stockée dans les préférences';

  @override
  String get repeater_cliHelpGpsAdvertSet =>
      'Définit la configuration de l\'annonce de localisation.';

  @override
  String get repeater_commandsListTitle => 'Liste des commandes';

  @override
  String get repeater_commandsListNote =>
      'NOTE : pour les diverses commandes « set »..., il existe également une commande « get »...';

  @override
  String get repeater_general => 'Général';

  @override
  String get repeater_settingsCategory => 'Paramètres';

  @override
  String get repeater_bridge => 'Pont';

  @override
  String get repeater_logging => 'Journalisation';

  @override
  String get repeater_neighborsRepeaterOnly => 'Voisins (Uniquement répéteur)';

  @override
  String get repeater_regionManagementRepeaterOnly =>
      'Gestion des régions (uniquement pour le répéteur)';

  @override
  String get repeater_regionNote =>
      'Les commandes de région ont été introduites pour gérer les définitions et les autorisations des régions.';

  @override
  String get repeater_gpsManagement => 'Gestion GPS';

  @override
  String get repeater_gpsNote =>
      'La commande GPS a été introduite pour gérer les sujets liés à la localisation.';

  @override
  String get telemetry_receivedData => 'Données de télémétrie reçues';

  @override
  String get telemetry_requestTimeout => 'Demande de télémétrie expirée.';

  @override
  String telemetry_errorLoading(String error) {
    return 'Erreur lors du chargement de la télémétrie : $error';
  }

  @override
  String get telemetry_noData => 'Aucune donnée de télémétrie disponible.';

  @override
  String telemetry_channelTitle(int channel) {
    return 'Canal $channel';
  }

  @override
  String get telemetry_batteryLabel => 'Batterie';

  @override
  String get telemetry_voltageLabel => 'Tension';

  @override
  String get telemetry_mcuTemperatureLabel => 'Température du MCU';

  @override
  String get telemetry_temperatureLabel => 'Température';

  @override
  String get telemetry_currentLabel => 'Actuellement';

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
  String get neighbors_receivedData => 'Données des voisins reçues';

  @override
  String get neighbors_requestTimedOut => 'Les voisins demandent un délai.';

  @override
  String neighbors_errorLoading(String error) {
    return 'Erreur lors du chargement des voisins : $error';
  }

  @override
  String get neighbors_repeatersNeighbors => 'Répéteurs Voisins';

  @override
  String get neighbors_noData =>
      'Aucune donnée concernant les voisins disponible.';

  @override
  String neighbors_unknownContact(String pubkey) {
    return 'Clé publique inconnue $pubkey';
  }

  @override
  String neighbors_heardAgo(String time) {
    return 'Écouté : $time auparavant';
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
  String get channelPath_title => 'Chemin de paquet';

  @override
  String get channelPath_viewMap => 'Afficher la carte';

  @override
  String get channelPath_otherObservedPaths => 'Autres chemins observés';

  @override
  String get channelPath_repeaterHops => 'Sauts du répéteur';

  @override
  String get channelPath_noHopDetails =>
      'Les détails de l\'envoi ne sont pas fournis pour ce paquet.';

  @override
  String get channelPath_messageDetails => 'Détails du message';

  @override
  String get channelPath_senderLabel => 'Expéditeur';

  @override
  String get channelPath_timeLabel => 'Temps';

  @override
  String get channelPath_repeatsLabel => 'Répétitions';

  @override
  String channelPath_pathLabel(int index) {
    return 'Chemin $index';
  }

  @override
  String get channelPath_observedLabel => 'Observé';

  @override
  String channelPath_observedPathTitle(int index, String hops) {
    return 'Chemin observé $index • $hops';
  }

  @override
  String get channelPath_noLocationData => 'Aucune donnée de localisation';

  @override
  String channelPath_timeWithDate(int day, int month, String time) {
    return '$day/$month $time';
  }

  @override
  String channelPath_timeOnly(String time) {
    return '$time';
  }

  @override
  String get channelPath_unknownPath => 'Inconnu';

  @override
  String get channelPath_floodPath => 'Tout le réseau';

  @override
  String get channelPath_directPath => 'Afficher';

  @override
  String channelPath_observedZeroOf(int total) {
    return '0 de $total sauts';
  }

  @override
  String channelPath_observedSomeOf(int observed, int total) {
    return '$observed sur $total sauts';
  }

  @override
  String get channelPath_mapTitle => 'Carte du chemin';

  @override
  String get channelPath_noRepeaterLocations =>
      'Aucune position de répéteur disponible pour ce chemin.';

  @override
  String channelPath_primaryPath(int index) {
    return 'Chemin $index (Principal)';
  }

  @override
  String get channelPath_pathLabelTitle => 'Chemin';

  @override
  String get channelPath_observedPathHeader => 'Chemin observé';

  @override
  String channelPath_selectedPathLabel(String label, String prefixes) {
    return '$label • $prefixes';
  }

  @override
  String get channelPath_noHopDetailsAvailable =>
      'Aucun détail de saut disponible pour ce paquet.';

  @override
  String get channelPath_unknownRepeater => 'Répéteur Inconnu';

  @override
  String get community_title => 'Communauté';

  @override
  String get community_create => 'Créer une Communauté';

  @override
  String get community_createDesc =>
      'Créer une nouvelle communauté et la partager via QR code.';

  @override
  String get community_join => 'Rejoindre';

  @override
  String get community_joinTitle => 'Rejoindre la communauté';

  @override
  String community_joinConfirmation(String name) {
    return 'Souhaitez-vous rejoindre la communauté \"$name\" ?';
  }

  @override
  String get community_scanQr => 'Scanner la communauté QR';

  @override
  String get community_scanInstructions =>
      'Pointez l\'appareil photo vers un code QR communautaire.';

  @override
  String get community_showQr => 'Afficher le QR Code';

  @override
  String get community_publicChannel => 'Communauté Publique';

  @override
  String get community_hashtagChannel => 'Hashtag Communauté';

  @override
  String get community_name => 'Nom de la communauté';

  @override
  String get community_enterName => 'Entrez le nom de la communauté';

  @override
  String community_created(String name) {
    return 'Communauté \"$name\" créée';
  }

  @override
  String community_joined(String name) {
    return 'Rejoint la communauté \"$name\"';
  }

  @override
  String get community_qrTitle => 'Partager Communauté';

  @override
  String community_qrInstructions(String name) {
    return 'Scanner ce QR code pour rejoindre $name';
  }

  @override
  String get community_hashtagPrivacyHint =>
      'Les canaux hashtag de la communauté ne sont accessibles qu\'aux membres de la communauté';

  @override
  String get community_invalidQrCode => 'Code QR de communauté non valide';

  @override
  String get community_alreadyMember => 'Déjà membre';

  @override
  String community_alreadyMemberMessage(String name) {
    return 'Vous êtes déjà membre de \"$name\".';
  }

  @override
  String get community_addPublicChannel =>
      'Ajouter un Canal Public de la Communauté';

  @override
  String get community_addPublicChannelHint =>
      'Ajouter automatiquement le canal public pour cette communauté';

  @override
  String get community_noCommunities =>
      'Aucun groupe n\'a été rejoint pour le moment.';

  @override
  String get community_scanOrCreate =>
      'Scanner un code QR ou créer une communauté pour commencer';

  @override
  String get community_manageCommunities => 'Gérer les Communautés';

  @override
  String get community_delete => 'Quitter la communauté';

  @override
  String community_deleteConfirm(String name) {
    return 'Quitter \"$name\" ?';
  }

  @override
  String community_deleteChannelsWarning(int count) {
    return 'Cela supprimera également $count canal/canaux et leurs messages.';
  }

  @override
  String community_deleted(String name) {
    return 'Communauté \"$name\" quittée';
  }

  @override
  String get community_regenerateSecret => 'Régénérer le secret';

  @override
  String community_regenerateSecretConfirm(String name) {
    return 'Régénérer la clé secrète pour \"$name\" ? Tous les membres devront scanner le nouveau code QR pour continuer à communiquer.';
  }

  @override
  String get community_regenerate => 'Régénérer';

  @override
  String community_secretRegenerated(String name) {
    return 'Mot de passe secret régénéré pour \"$name\"';
  }

  @override
  String get community_updateSecret => 'Mettre à jour le secret';

  @override
  String community_secretUpdated(String name) {
    return 'Modification secrète mise à jour pour \"$name\"';
  }

  @override
  String community_scanToUpdateSecret(String name) {
    return 'Scanner le nouveau code QR pour mettre à jour le mot de passe pour \"$name\"';
  }

  @override
  String get community_addHashtagChannel => 'Ajouter un Hashtag Communauté';

  @override
  String get community_addHashtagChannelDesc =>
      'Ajouter un canal hashtag pour cette communauté';

  @override
  String get community_selectCommunity => 'Sélectionner Communauté';

  @override
  String get community_regularHashtag => 'Hashtag régulier';

  @override
  String get community_regularHashtagDesc =>
      'Hashtag public (tout le monde peut rejoindre)';

  @override
  String get community_communityHashtag => 'Hashtag de la communauté';

  @override
  String get community_communityHashtagDesc =>
      'Exclusif aux membres de la communauté';

  @override
  String community_forCommunity(String name) {
    return 'Pour $name';
  }

  @override
  String get listFilter_tooltip => 'Filtrer et trier';

  @override
  String get listFilter_sortBy => 'Trier par';

  @override
  String get listFilter_latestMessages => 'Derniers messages';

  @override
  String get listFilter_heardRecently => 'Écoute récemment';

  @override
  String get listFilter_az => 'A à Z';

  @override
  String get listFilter_filters => 'Filtres';

  @override
  String get listFilter_all => 'Tout';

  @override
  String get listFilter_users => 'Utilisateurs';

  @override
  String get listFilter_repeaters => 'Répéteurs';

  @override
  String get listFilter_roomServers => 'Room servers';

  @override
  String get listFilter_unreadOnly => 'Messages non lus seulement';

  @override
  String get listFilter_newGroup => 'Nouveau groupe';

  @override
  String get pathTrace_you => 'Vous';

  @override
  String get pathTrace_failed => 'Traçage du chemin échoué.';

  @override
  String get pathTrace_notAvailable => 'Tracé de chemin non disponible.';

  @override
  String get pathTrace_refreshTooltip => 'Actualiser Path Trace';

  @override
  String get pathTrace_someHopsNoLocation =>
      'Un ou plusieurs des sauts manquent d\'une localisation !';

  @override
  String get pathTrace_clearTooltip => 'Effacer le chemin';

  @override
  String get losSelectStartEnd =>
      'Sélectionnez les nœuds de début et de fin pour LOS.';

  @override
  String losRunFailed(String error) {
    return 'Échec de la vérification de la ligne de vue : $error';
  }

  @override
  String get losClearAllPoints => 'Effacer tous les points';

  @override
  String get losRunToViewElevationProfile =>
      'Exécutez LOS pour afficher le profil d\'altitude';

  @override
  String get losMenuTitle => 'Menu LOS';

  @override
  String get losMenuSubtitle =>
      'Appuyez sur les nœuds ou appuyez longuement sur la carte pour des points personnalisés';

  @override
  String get losShowDisplayNodes => 'Afficher les nœuds d\'affichage';

  @override
  String get losCustomPoints => 'Points personnalisés';

  @override
  String losCustomPointLabel(int index) {
    return 'Personnalisé $index';
  }

  @override
  String get losPointA => 'Point A';

  @override
  String get losPointB => 'Point B';

  @override
  String losAntennaA(String value, String unit) {
    return 'Antenne A : $value $unit';
  }

  @override
  String losAntennaB(String value, String unit) {
    return 'Antenne B : $value $unit';
  }

  @override
  String get losRun => 'Exécuter la LOS';

  @override
  String get losNoElevationData => 'Aucune donnée d\'altitude';

  @override
  String losProfileClear(
    String distance,
    String distanceUnit,
    String clearance,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, LOS clair, clairance minimale $clearance $heightUnit';
  }

  @override
  String losProfileBlocked(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, bloqué par $obstruction $heightUnit';
  }

  @override
  String get losStatusChecking => 'LOS : vérification...';

  @override
  String get losStatusNoData => 'LOS : aucune donnée';

  @override
  String losStatusSummary(int clear, int total, int blocked, int unknown) {
    return 'LOS : $clear/$total clair, $blocked bloqué, $unknown inconnu';
  }

  @override
  String get losErrorElevationUnavailable =>
      'Données d\'altitude indisponibles pour un ou plusieurs échantillons.';

  @override
  String get losErrorInvalidInput =>
      'Données de points/d\'altitude non valides pour le calcul de la LOS.';

  @override
  String get losRenameCustomPoint => 'Renommer le point personnalisé';

  @override
  String get losPointName => 'Nom du point';

  @override
  String get losShowPanelTooltip => 'Afficher le panneau LOS';

  @override
  String get losHidePanelTooltip => 'Masquer le panneau LOS';

  @override
  String get losElevationAttribution =>
      'Données d\'altitude : Open-Meteo (CC BY 4.0)';

  @override
  String get contacts_pathTrace => 'Traçage de chemin';

  @override
  String get contacts_ping => 'Ping';

  @override
  String get contacts_repeaterPathTrace => 'Tracer le chemin vers le répéteur';

  @override
  String get contacts_repeaterPing => 'Pinguer le répéteur';

  @override
  String get contacts_roomPathTrace =>
      'Traçage du chemin vers le serveur de la salle';

  @override
  String get contacts_roomPing => 'Pinguer le serveur de la salle';

  @override
  String get contacts_chatTraceRoute => 'Tracer le chemin';

  @override
  String contacts_pathTraceTo(String name) {
    return 'Tracer l\'itinéraire vers $name';
  }

  @override
  String get contacts_clipboardEmpty => 'Le presse-papiers est vide.';

  @override
  String get contacts_invalidAdvertFormat => 'Données de contact non valides';

  @override
  String get contacts_contactImported => 'Le contact a été importé.';

  @override
  String get contacts_contactImportFailed =>
      'Échec de l\'importation du contact.';

  @override
  String get contacts_zeroHopAdvert => 'Annonce Zero saut';

  @override
  String get contacts_floodAdvert => 'Annonce à tout le réseau';

  @override
  String get contacts_copyAdvertToClipboard =>
      'Copier l\'annonce dans le presse-papiers';

  @override
  String get contacts_addContactFromClipboard =>
      'Ajouter un contact depuis le presse-papiers';

  @override
  String get contacts_ShareContact =>
      'Copier le contact dans le presse-papiers';

  @override
  String get contacts_ShareContactZeroHop => 'Partager un contact par annonce';

  @override
  String get contacts_zeroHopContactAdvertSent =>
      'Envoyer un contact par annonce.';

  @override
  String get contacts_zeroHopContactAdvertFailed =>
      'Échec de l\'envoi du contact.';

  @override
  String get contacts_contactAdvertCopied =>
      'Annonce copiée dans le presse-papiers.';

  @override
  String get contacts_contactAdvertCopyFailed =>
      'La copie de l\'annonce vers le presse-papiers a échoué.';

  @override
  String get notification_activityTitle => 'Activité MeshCore';

  @override
  String notification_messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'messages',
      one: 'message',
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
      other: 'messages de canal',
      one: 'message de canal',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nouveaux nœuds',
      one: 'nouveau nœud',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newTypeDiscovered(String contactType) {
    return 'Nouveau $contactType découvert';
  }

  @override
  String get notification_receivedNewMessage => 'Nouveau message reçu';

  @override
  String get settings_gpxExportRepeaters =>
      'Exporter les répéteurs / serveur de salle au format GPX';

  @override
  String get settings_gpxExportRepeatersSubtitle =>
      'Exporte les répéteurs / roomserver avec une localisation vers un fichier GPX.';

  @override
  String get settings_gpxExportContacts =>
      'Exporter les compagnons au format GPX';

  @override
  String get settings_gpxExportContactsSubtitle =>
      'Exporte les compagnons avec un emplacement vers un fichier GPX.';

  @override
  String get settings_gpxExportAll =>
      'Exporter tous les contacts au format GPX';

  @override
  String get settings_gpxExportAllSubtitle =>
      'Exporte tous les contacts avec une localisation vers un fichier GPX.';

  @override
  String get settings_gpxExportSuccess => 'Fichier GPX exporté avec succès.';

  @override
  String get settings_gpxExportNoContacts => 'Aucun contact à exporter.';

  @override
  String get settings_gpxExportNotAvailable =>
      'Non pris en charge sur votre appareil/Système d\'exploitation';

  @override
  String get settings_gpxExportError =>
      'Une erreur s\'est produite lors de l\'exportation.';

  @override
  String get settings_gpxExportRepeatersRoom =>
      'Emplacements des serveurs de répéteur et de salle';

  @override
  String get settings_gpxExportChat => 'Emplacements des compagnons';

  @override
  String get settings_gpxExportAllContacts =>
      'Tous les emplacements des contacts';

  @override
  String get settings_gpxExportShareText =>
      'Données de carte exportées à partir de Gulf Coast Mesh App';

  @override
  String get settings_gpxExportShareSubject =>
      'Gulf Coast Mesh App exporter les données de carte GPX';

  @override
  String get snrIndicator_nearByRepeaters => 'Répéteurs à proximité';

  @override
  String get snrIndicator_lastSeen => 'Dernière fois vu';

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
  String get repeater_regenerateIdentityKey => 'Ré générer la clé d\'identité';

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
  String get appSettings_nodeBlocking => 'Bloquer des nœuds';

  @override
  String get appSettings_nodeBlockingSubtitle =>
      'Masquer les nœuds choisis de votre carte, de vos contacts et de vos discussions, et couper leurs alertes. Application uniquement : rien n\'est supprimé de votre radio.';

  @override
  String get appSettings_blockedNodes => 'Nœuds bloqués';

  @override
  String appSettings_blockedNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nœuds bloqués',
      one: '1 nœud bloqué',
      zero: 'Aucun bloqué pour le moment',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_title => 'Nœuds bloqués';

  @override
  String get blockedNodes_howItWorks => 'Fonctionnement du blocage';

  @override
  String get blockedNodes_infoHidden =>
      'Masqués de votre carte, de vos contacts et de vos discussions';

  @override
  String get blockedNodes_infoMuted =>
      'Aucune alerte de nouveau nœud ni notification de message de leur part';

  @override
  String get blockedNodes_infoKept =>
      'Rien n\'est supprimé. Ils restent sur votre radio compagnon et leurs messages sont conservés';

  @override
  String get blockedNodes_infoRelay =>
      'Les répéteurs bloqués peuvent toujours relayer vos messages sur le maillage';

  @override
  String get blockedNodes_infoChannels =>
      'Leurs messages dans les canaux restent affichés';

  @override
  String get blockedNodes_emptyTitle => 'Aucun nœud bloqué';

  @override
  String get blockedNodes_emptyHint =>
      'Appuyez longuement sur un nœud dans Contacts ou sur la Carte, puis choisissez Bloquer le nœud.';

  @override
  String get blockedNodes_unblock => 'Débloquer';

  @override
  String get blockedNodes_unblockAll => 'Tout débloquer';

  @override
  String blockedNodes_unblockAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Débloquer les $count nœuds ? Ils réapparaîtront sur votre carte et dans vos contacts.',
      one:
          'Débloquer 1 nœud ? Il réapparaîtra sur votre carte et dans vos contacts.',
    );
    return '$_temp0';
  }

  @override
  String get blockedNodes_unknownNode => 'Nœud inconnu';

  @override
  String blockedNodes_blockedOn(String date) {
    return 'Bloqué le $date';
  }

  @override
  String get blockedNodes_blockAction => 'Bloquer le nœud';

  @override
  String blockedNodes_blockConfirmTitle(String name) {
    return 'Bloquer $name ?';
  }

  @override
  String get blockedNodes_blockConfirmBody =>
      'Il sera masqué de votre carte, de vos contacts et de vos discussions, et vous ne recevrez ni alertes ni notifications de messages de sa part. Rien n\'est supprimé de votre radio. Vous pouvez le débloquer à tout moment dans Paramètres de l\'application > Expérimental > Nœuds bloqués.';

  @override
  String get blockedNodes_blockConfirmButton => 'Bloquer';

  @override
  String blockedNodes_blocked(String name) {
    return '$name bloqué';
  }

  @override
  String blockedNodes_unblocked(String name) {
    return '$name débloqué';
  }

  @override
  String get blockedNodes_undo => 'Annuler';
}
