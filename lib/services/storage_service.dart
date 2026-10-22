import 'dart:convert';
import '../models/path_history.dart';
import '../storage/prefs_manager.dart';
import '../storage/secure_password_store.dart';

class StorageService {
  StorageService({SecurePasswordStore? passwordStore})
    : _passwordStore = passwordStore ?? FlutterSecurePasswordStore();

  /// Backing store for repeater passwords. Defaults to the platform secure
  /// keystore (Keychain / Keystore / DPAPI / libsecret) via
  /// `flutter_secure_storage`; tests inject an in-memory implementation.
  final SecurePasswordStore _passwordStore;

  static const String _pathHistoryPrefix = 'path_history_';
  static const String _pendingMessagesKey = 'pending_messages';

  /// Legacy plaintext repeater password key in SharedPreferences. Kept so we
  /// can lazy-migrate existing installs into the secure store and then wipe
  /// the legacy entry. Once nothing reads from it, this key is dead.
  static const String _legacyRepeaterPasswordsKey = 'repeater_passwords';

  /// Namespace prefix for individual repeater password entries in the secure
  /// store. Each repeater gets its own entry so we no longer need to do a
  /// read-modify-write on a single JSON blob.
  static const String _securePasswordPrefix = 'repeater_pw_';

  /// Serializes operations that touch the password store + legacy migration
  /// state together, so a concurrent migration can't race a save/remove and
  /// leave the two stores inconsistent.
  Future<void> _repeaterPasswordChain = Future.value();

  Future<T> _serializeRepeaterPasswordOp<T>(Future<T> Function() op) {
    final prior = _repeaterPasswordChain;
    final result = prior.then((_) => op());
    // Keep the chain alive even if `op` throws, otherwise every subsequent
    // op would re-throw the same error forever.
    _repeaterPasswordChain = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<void> savePathHistory(
    String contactPubKeyHex,
    ContactPathHistory history,
  ) async {
    final prefs = PrefsManager.instance;
    final key = '$_pathHistoryPrefix$contactPubKeyHex';
    final jsonStr = jsonEncode(history.toJson());
    await prefs.setString(key, jsonStr);
  }

  Future<ContactPathHistory?> loadPathHistory(String contactPubKeyHex) async {
    final prefs = PrefsManager.instance;
    final key = '$_pathHistoryPrefix$contactPubKeyHex';
    final jsonStr = prefs.getString(key);

    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ContactPathHistory.fromJson(contactPubKeyHex, json);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearPathHistory(String contactPubKeyHex) async {
    final prefs = PrefsManager.instance;
    final key = '$_pathHistoryPrefix$contactPubKeyHex';
    await prefs.remove(key);
  }

  Future<void> clearAllPathHistories() async {
    final prefs = PrefsManager.instance;
    final keys = prefs.getKeys();
    final pathHistoryKeys = keys.where(
      (key) => key.startsWith(_pathHistoryPrefix),
    );

    for (final key in pathHistoryKeys) {
      await prefs.remove(key);
    }
  }

  Future<Map<String, String>> loadPendingMessages() async {
    final prefs = PrefsManager.instance;
    final jsonStr = prefs.getString(_pendingMessagesKey);

    if (jsonStr == null) return {};

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(key, value as String));
    } catch (e) {
      return {};
    }
  }

  Future<void> savePendingMessages(Map<String, String> pending) async {
    final prefs = PrefsManager.instance;
    final jsonStr = jsonEncode(pending);
    await prefs.setString(_pendingMessagesKey, jsonStr);
  }

  Future<void> clearPendingMessages() async {
    final prefs = PrefsManager.instance;
    await prefs.remove(_pendingMessagesKey);
  }

  /// Save a repeater password by public key hex into the platform secure
  /// keystore.
  ///
  /// Serialized via [_serializeRepeaterPasswordOp] so an in-flight legacy
  /// migration cannot interleave with this write and leave the secure
  /// store and legacy plaintext blob inconsistent.
  Future<void> saveRepeaterPassword(String repeaterPubKeyHex, String password) {
    return _serializeRepeaterPasswordOp(() async {
      await _passwordStore.write(
        '$_securePasswordPrefix$repeaterPubKeyHex',
        password,
      );
      // If a legacy plaintext entry exists for this repeater, evict it so a
      // save effectively migrates and wipes the plaintext copy in one step.
      // Otherwise an install that upgraded but only ever re-saves (never
      // reads) could keep the plaintext blob around indefinitely.
      final legacy = await _loadLegacyRepeaterPasswords();
      if (legacy.remove(repeaterPubKeyHex) != null) {
        await _writeLegacyRepeaterPasswords(legacy);
      }
    });
  }

  /// Load all saved repeater passwords (map of pubKeyHex -> password).
  ///
  /// Reads everything in the secure store and folds in any legacy entries
  /// still in the plaintext SharedPreferences blob, opportunistically
  /// migrating them so subsequent reads come from the secure store.
  Future<Map<String, String>> loadRepeaterPasswords() async {
    final all = <String, String>{};

    final secureAll = await _passwordStore.readAll();
    for (final entry in secureAll.entries) {
      if (entry.key.startsWith(_securePasswordPrefix)) {
        all[entry.key.substring(_securePasswordPrefix.length)] = entry.value;
      }
    }

    final legacy = await _loadLegacyRepeaterPasswords();
    if (legacy.isEmpty) return all;

    final toMigrate = <String, String>{};
    for (final entry in legacy.entries) {
      if (!all.containsKey(entry.key)) {
        toMigrate[entry.key] = entry.value;
        all[entry.key] = entry.value;
      }
    }

    // The legacy blob is non-empty; every entry is either already in the
    // secure store or about to be migrated below. Migrate the stragglers and
    // then drop the plaintext blob entirely so we never read plaintext again.
    // (Previously the blob was only removed when something migrated, leaving
    // plaintext behind after a downgrade->upgrade cycle where every key was
    // already present in the secure store.)
    await _serializeRepeaterPasswordOp(() async {
      for (final entry in toMigrate.entries) {
        await _passwordStore.write(
          '$_securePasswordPrefix${entry.key}',
          entry.value,
        );
      }
      await PrefsManager.instance.remove(_legacyRepeaterPasswordsKey);
    });

    return all;
  }

  /// Get a specific repeater's saved password.
  ///
  /// Fast path is a single secure-store read. Falls back to the legacy
  /// plaintext blob and migrates the entry into the secure store if found
  /// (so the plaintext copy is removed on read, not just on next save).
  Future<String?> getRepeaterPassword(String repeaterPubKeyHex) async {
    final key = '$_securePasswordPrefix$repeaterPubKeyHex';
    final fromSecure = await _passwordStore.read(key);
    if (fromSecure != null) {
      // A downgrade->upgrade cycle can leave a plaintext copy behind even when
      // the secure entry exists; evict it so plaintext never lingers.
      final legacy = await _loadLegacyRepeaterPasswords();
      if (legacy.containsKey(repeaterPubKeyHex)) {
        await _serializeRepeaterPasswordOp(() async {
          final current = await _loadLegacyRepeaterPasswords();
          if (current.remove(repeaterPubKeyHex) != null) {
            await _writeLegacyRepeaterPasswords(current);
          }
        });
      }
      return fromSecure;
    }

    return _serializeRepeaterPasswordOp(() async {
      // Re-check under serialization in case another op migrated this entry
      // between the snapshot read above and acquiring the chain.
      final racedSecure = await _passwordStore.read(key);
      if (racedSecure != null) return racedSecure;

      final legacy = await _loadLegacyRepeaterPasswords();
      final value = legacy[repeaterPubKeyHex];
      if (value == null) return null;

      await _passwordStore.write(key, value);
      legacy.remove(repeaterPubKeyHex);
      await _writeLegacyRepeaterPasswords(legacy);
      return value;
    });
  }

  /// Remove a saved repeater password from the secure store and from the
  /// legacy plaintext blob if it lingered there.
  Future<void> removeRepeaterPassword(String repeaterPubKeyHex) {
    return _serializeRepeaterPasswordOp(() async {
      await _passwordStore.delete('$_securePasswordPrefix$repeaterPubKeyHex');
      final legacy = await _loadLegacyRepeaterPasswords();
      if (legacy.remove(repeaterPubKeyHex) != null) {
        await _writeLegacyRepeaterPasswords(legacy);
      }
    });
  }

  /// Clear every saved repeater password from both the secure store and any
  /// remaining legacy entries.
  Future<void> clearAllRepeaterPasswords() {
    return _serializeRepeaterPasswordOp(() async {
      final all = await _passwordStore.readAll();
      for (final key in all.keys) {
        if (key.startsWith(_securePasswordPrefix)) {
          await _passwordStore.delete(key);
        }
      }
      await PrefsManager.instance.remove(_legacyRepeaterPasswordsKey);
    });
  }

  Future<Map<String, String>> _loadLegacyRepeaterPasswords() async {
    final prefs = PrefsManager.instance;
    final jsonStr = prefs.getString(_legacyRepeaterPasswordsKey);
    if (jsonStr == null) return {};
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(key, value as String));
    } catch (_) {
      // Unparseable legacy blob: treat as empty so a fresh write isn't
      // blocked by an unreadable record.
      return {};
    }
  }

  Future<void> _writeLegacyRepeaterPasswords(
    Map<String, String> passwords,
  ) async {
    final prefs = PrefsManager.instance;
    if (passwords.isEmpty) {
      await prefs.remove(_legacyRepeaterPasswordsKey);
    } else {
      await prefs.setString(_legacyRepeaterPasswordsKey, jsonEncode(passwords));
    }
  }
}
