import 'package:gulf_coast_mesh_app/services/notification_service.dart';

/// Records the notifications a dispatcher asks the platform to show.
class RecordingNotificationService implements NotificationService {
  final adverts = <String>[];
  final messages = <String>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showAdvertNotification({
    required String contactName,
    required String contactType,
    String? contactId,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool bannerEnabled = true,
  }) async => adverts.add(contactId ?? contactName);

  @override
  Future<void> showMessageNotification({
    required String contactName,
    required String message,
    String? contactId,
    int? badgeCount,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    bool bannerEnabled = true,
  }) async => messages.add(contactId ?? contactName);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
