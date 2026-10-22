/// A durable wardriving capture that can be uploaded after reconnecting.
class OfflineWardriveSession {
  final String id;
  final DateTime createdAt;
  final List<Map<String, dynamic>> samples;
  final String? devicePublicKey;
  final String? contactUri;
  final String? deviceName;
  final String? radioConfig;
  final double? powerWatts;
  final String? appVersion;
  final bool uploaded;

  const OfflineWardriveSession({
    required this.id,
    required this.createdAt,
    required this.samples,
    this.devicePublicKey,
    this.contactUri,
    this.deviceName,
    this.radioConfig,
    this.powerWatts,
    this.appVersion,
    this.uploaded = false,
  });

  factory OfflineWardriveSession.fromJson(Map<String, dynamic> json) =>
      OfflineWardriveSession(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        samples: (json['samples'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
        devicePublicKey: json['device_public_key'] as String?,
        contactUri: json['contact_uri'] as String?,
        deviceName: json['device_name'] as String?,
        radioConfig: json['radio_config'] as String?,
        powerWatts: (json['power_watts'] as num?)?.toDouble(),
        appVersion: json['app_version'] as String?,
        uploaded: json['uploaded'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'samples': samples,
    'device_public_key': devicePublicKey,
    'contact_uri': contactUri,
    'device_name': deviceName,
    'radio_config': radioConfig,
    'power_watts': powerWatts,
    'app_version': appVersion,
    'uploaded': uploaded,
  };

  OfflineWardriveSession copyWith({
    List<Map<String, dynamic>>? samples,
    bool? uploaded,
  }) => OfflineWardriveSession(
    id: id,
    createdAt: createdAt,
    samples: samples ?? this.samples,
    devicePublicKey: devicePublicKey,
    contactUri: contactUri,
    deviceName: deviceName,
    radioConfig: radioConfig,
    powerWatts: powerWatts,
    appVersion: appVersion,
    uploaded: uploaded ?? this.uploaded,
  );
}
