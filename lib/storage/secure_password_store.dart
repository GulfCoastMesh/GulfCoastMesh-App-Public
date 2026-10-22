import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin abstraction over the platform secure key/value store so
/// [StorageService] stays unit-testable without spinning up the
/// flutter_secure_storage platform channel.
abstract class SecurePasswordStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<Map<String, String>> readAll();
}

/// Production implementation backed by `flutter_secure_storage`, which uses
/// the Android Keystore / iOS Keychain / DPAPI / libsecret depending on
/// platform.
class FlutterSecurePasswordStore implements SecurePasswordStore {
  FlutterSecurePasswordStore({FlutterSecureStorage? store})
    : _store = store ?? const FlutterSecureStorage();

  final FlutterSecureStorage _store;

  @override
  Future<String?> read(String key) => _store.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _store.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _store.delete(key: key);

  @override
  Future<Map<String, String>> readAll() => _store.readAll();
}

/// Test-only in-memory implementation. Persistence is per-instance.
class InMemorySecurePasswordStore implements SecurePasswordStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<Map<String, String>> readAll() async =>
      Map<String, String>.from(_data);
}
