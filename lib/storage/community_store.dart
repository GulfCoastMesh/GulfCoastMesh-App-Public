import 'dart:convert';

import '../models/community.dart';
import 'prefs_manager.dart';
import 'secure_password_store.dart';

/// Persists communities (including secret K) in platform secure storage.
class CommunityStore {
  CommunityStore({SecurePasswordStore? secretStore})
    : _secrets = secretStore ?? FlutterSecurePasswordStore();

  final SecurePasswordStore _secrets;
  Future<void> _mutationChain = Future.value();

  static const String _communitiesKey = 'communities_v1';
  static const String _communitiesSecureKey = 'communities_secure_v1';

  Future<T> _serializeMutation<T>(Future<T> Function() operation) {
    final result = _mutationChain.catchError((_) {}).then((_) => operation());
    _mutationChain = result.then<void>((_) {}, onError: (_, _) {});
    return result;
  }

  Future<List<Community>> loadCommunities() async {
    final jsonString = await _loadJsonWithMigration();
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(jsonString) as List<dynamic>;
    } catch (_) {
      return [];
    }

    final communities = <Community>[];
    for (final entry in jsonList) {
      try {
        communities.add(Community.fromJson(entry as Map<String, dynamic>));
      } catch (_) {
        continue;
      }
    }
    return communities;
  }

  Future<void> saveCommunities(List<Community> communities) async {
    final snapshot = List<Community>.from(communities);
    await _serializeMutation(() => _saveCommunities(snapshot));
  }

  Future<void> _saveCommunities(List<Community> communities) async {
    final jsonList = communities.map((c) => c.toJson()).toList();
    await _secrets.write(_communitiesSecureKey, jsonEncode(jsonList));
    await PrefsManager.instance.remove(_communitiesKey);
  }

  Future<void> addCommunity(Community community) async {
    await _serializeMutation(() async {
      final communities = await loadCommunities();
      final existingIndex = communities.indexWhere((c) => c.id == community.id);
      if (existingIndex >= 0) {
        communities[existingIndex] = community;
      } else {
        communities.add(community);
      }
      await _saveCommunities(communities);
    });
  }

  Future<void> updateCommunity(Community community) async {
    await _serializeMutation(() async {
      final communities = await loadCommunities();
      final index = communities.indexWhere((c) => c.id == community.id);
      if (index >= 0) {
        communities[index] = community;
        await _saveCommunities(communities);
      }
    });
  }

  Future<void> removeCommunity(String communityId) async {
    await _serializeMutation(() async {
      final communities = await loadCommunities();
      communities.removeWhere((c) => c.id == communityId);
      await _saveCommunities(communities);
    });
  }

  Future<Community?> getCommunity(String communityId) async {
    final communities = await loadCommunities();
    try {
      return communities.firstWhere((c) => c.id == communityId);
    } catch (_) {
      return null;
    }
  }

  Future<Community?> findByCommunityId(String cid) async {
    final communities = await loadCommunities();
    try {
      return communities.firstWhere((c) => c.communityId == cid);
    } catch (_) {
      return null;
    }
  }

  Future<void> addHashtagChannel(String communityId, String hashtag) async {
    await _serializeMutation(() async {
      final communities = await loadCommunities();
      final index = communities.indexWhere((c) => c.id == communityId);
      if (index < 0) return;
      communities[index] = communities[index].addHashtagChannel(hashtag);
      await _saveCommunities(communities);
    });
  }

  Future<void> removeHashtagChannel(String communityId, String hashtag) async {
    await _serializeMutation(() async {
      final communities = await loadCommunities();
      final index = communities.indexWhere((c) => c.id == communityId);
      if (index < 0) return;
      communities[index] = communities[index].removeHashtagChannel(hashtag);
      await _saveCommunities(communities);
    });
  }

  Future<String?> _loadJsonWithMigration() async {
    final existing = await _secrets.read(_communitiesSecureKey);
    if (existing != null && existing.isNotEmpty && _isValidJson(existing)) {
      // Secure copy is authoritative and parseable; drop any legacy plaintext.
      // Only delete the legacy backup once we know the secure copy is valid, so
      // a corrupt secure blob can still be recovered from legacy below.
      if (PrefsManager.instance.getString(_communitiesKey) != null) {
        await PrefsManager.instance.remove(_communitiesKey);
      }
      return existing;
    }

    final legacy = PrefsManager.instance.getString(_communitiesKey);
    if (legacy != null && legacy.isNotEmpty) {
      // Only migrate valid JSON. Copying a corrupt blob into secure storage and
      // then deleting the legacy copy would silently lose all communities on
      // the next decode. If it doesn't parse, leave the legacy blob untouched.
      if (!_isValidJson(legacy)) return legacy;

      await _secrets.write(_communitiesSecureKey, legacy);
      await PrefsManager.instance.remove(_communitiesKey);
      return legacy;
    }
    return null;
  }

  bool _isValidJson(String source) {
    try {
      jsonDecode(source);
      return true;
    } catch (_) {
      return false;
    }
  }
}
