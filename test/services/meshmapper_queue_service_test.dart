import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/wardriving_queue_item.dart';
import 'package:gulf_coast_mesh_app/services/meshmapper_api_service.dart';
import 'package:gulf_coast_mesh_app/services/meshmapper_queue_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _QueueApi extends MeshMapperApiService {
  String activeSession = 'current';
  final uploads = <List<Map<String, dynamic>>>[];
  @override
  bool get hasSession => true;
  @override
  String get sessionId => activeSession;
  @override
  Future<Map<String, dynamic>?> submitWardriveData(
    List<Map<String, dynamic>> entries,
  ) async {
    uploads.add(entries);
    return {'success': true};
  }
}

WardrivingQueueItem _sample() => WardrivingQueueItem.rx(
  latitude: 30,
  longitude: -90,
  heardRepeats: 'AA(1.0)',
  timestamp: DateTime.utc(2026),
  externalAntenna: false,
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });

  tearDown(PrefsManager.reset);

  test(
    'queue restoration salvages valid items around corrupt entries',
    () async {
      final valid = WardrivingQueueItem.tx(
        latitude: 30,
        longitude: -90,
        heardRepeats: 'AA(1.0)',
        timestamp: DateTime.utc(2026, 1, 1),
        externalAntenna: false,
      );
      final raw = jsonEncode({
        'version': 1,
        'items': [
          valid.toJson(),
          {'type': 'TX', 'latitude': 999},
          'not-an-item',
        ],
      });
      await PrefsManager.instance.setString('wardriving_upload_queue', raw);
      final api = MeshMapperApiService();
      final queue = MeshMapperQueueService(apiService: api);
      addTearDown(queue.dispose);
      addTearDown(api.dispose);

      // Awaiting any public operation also waits for queue initialization.
      await queue.enqueueAll(const []);

      expect(queue.queueCount, 1);
      expect(
        PrefsManager.instance.getString('wardriving_upload_queue_corrupt'),
        raw,
      );
      final persisted =
          jsonDecode(
                PrefsManager.instance.getString('wardriving_upload_queue')!,
              )
              as Map<String, dynamic>;
      expect(persisted['items'], hasLength(1));
    },
  );

  test(
    'drops only session-bound tagged entries when a session changes',
    () async {
      final api = MeshMapperApiService();
      final queue = MeshMapperQueueService(apiService: api);
      addTearDown(queue.dispose);
      addTearDown(api.dispose);
      final tagged = WardrivingQueueItem.tx(
        latitude: 30,
        longitude: -90,
        heardRepeats: 'AA(1.0)',
        timestamp: DateTime.utc(2026, 1, 1),
        externalAntenna: false,
        wireTag: 'MM:tag',
        pingCounter: 1,
      );
      final untagged = WardrivingQueueItem.rx(
        latitude: 30,
        longitude: -90,
        heardRepeats: 'AA(1.0)',
        timestamp: DateTime.utc(2026, 1, 1),
        externalAntenna: false,
      );

      await queue.enqueueAll([tagged, untagged]);
      await queue.dropStaleTaggedItems();

      expect(queue.queueCount, 1);
      expect(queue.droppedCount, 1);
    },
  );

  test(
    'binds wire tags to their session and removes them on replacement',
    () async {
      var calls = 0;
      final api = MeshMapperApiService(
        apiKey: 'test-only',
        client: MockClient((_) async {
          calls++;
          return http.Response(
            jsonEncode({
              'success': true,
              'session_id': calls == 1 ? 'session-old' : 'session-new',
              'tx_allowed': true,
              'rx_allowed': true,
              'expires_at': 9999999999,
            }),
            200,
          );
        }),
      );
      final queue = MeshMapperQueueService(apiService: api);
      addTearDown(queue.dispose);
      addTearDown(api.dispose);
      api.onSessionIdChanged = (_, _) => queue.dropStaleTaggedItems();

      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 30,
        lon: -90,
      );
      final tagged = WardrivingQueueItem.tx(
        latitude: 30,
        longitude: -90,
        heardRepeats: 'AA(1.0)',
        timestamp: DateTime.utc(2026, 1, 1),
        externalAntenna: false,
        wireTag: 'MM:tag',
        pingCounter: 1,
      );
      await queue.enqueue(tagged);
      expect(tagged.wireTagSessionId, 'session-old');

      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 30,
        lon: -90,
      );
      expect(queue.queueCount, 0);
    },
  );

  test('second flush waits for the in-flight upload', () async {
    final uploadStarted = Completer<void>();
    final uploadResponse = Completer<http.Response>();
    var calls = 0;
    final api = MeshMapperApiService(
      apiKey: 'test-only',
      client: MockClient((_) async {
        calls++;
        if (calls == 1) {
          return http.Response(
            jsonEncode({
              'success': true,
              'session_id': 'session-current',
              'tx_allowed': true,
              'rx_allowed': true,
              'expires_at': 9999999999,
            }),
            200,
          );
        }
        uploadStarted.complete();
        return uploadResponse.future;
      }),
    );
    final queue = MeshMapperQueueService(apiService: api);
    addTearDown(queue.dispose);
    addTearDown(api.dispose);
    await api.requestAuth(
      reason: 'connect',
      publicKey: 'deadbeef',
      lat: 30,
      lon: -90,
    );
    await queue.enqueue(
      WardrivingQueueItem.rx(
        latitude: 30,
        longitude: -90,
        heardRepeats: 'AA(1.0)',
        timestamp: DateTime.utc(2026, 1, 1),
        externalAntenna: false,
      ),
    );

    final firstFlush = queue.flush();
    await uploadStarted.future;
    var secondFinished = false;
    final secondFlush = queue.flush().whenComplete(() => secondFinished = true);
    await Future<void>.delayed(Duration.zero);
    expect(secondFinished, isFalse);

    uploadResponse.complete(http.Response(jsonEncode({'success': true}), 200));
    await Future.wait([firstFlush, secondFlush]);
    expect(queue.queueCount, 0);
  });

  test(
    'flush drains more than one batch before releasing the session',
    () async {
      final api = _QueueApi();
      final queue = MeshMapperQueueService(apiService: api);
      addTearDown(queue.dispose);
      addTearDown(api.dispose);
      await queue.enqueueAll(List.generate(101, (_) => _sample()));
      await queue.flush();
      expect(api.uploads.map((batch) => batch.length), [50, 50, 1]);
      expect(queue.queueCount, 0);
      expect(queue.uploadedCount, 101);
    },
  );

  test(
    'a tag minted before session replacement is never rebound at enqueue',
    () async {
      final api = _QueueApi();
      final queue = MeshMapperQueueService(apiService: api);
      addTearDown(queue.dispose);
      addTearDown(api.dispose);
      final tagged = WardrivingQueueItem.tx(
        latitude: 30,
        longitude: -90,
        heardRepeats: 'AA(1.0)',
        timestamp: DateTime.utc(2026),
        externalAntenna: false,
        wireTag: 'MM:old-tag',
        pingCounter: 1,
        wireTagSessionId: 'previous',
      );
      await queue.enqueueAll([tagged, _sample()]);
      expect(tagged.wireTagSessionId, 'previous');
      await queue.flush();
      expect(api.uploads.single.single['type'], 'RX');
      expect(queue.droppedCount, 1);
    },
  );

  test(
    'overlapping persistence cannot let an older queue overwrite the latest',
    () async {
      final firstStarted = Completer<void>();
      final releaseFirst = Completer<void>();
      var activeWrites = 0;
      var maximumWrites = 0;
      var writes = 0;
      String? durable;
      final api = _QueueApi();
      final queue = MeshMapperQueueService(
        apiService: api,
        writeQueue: (value) async {
          activeWrites++;
          if (activeWrites > maximumWrites) maximumWrites = activeWrites;
          if (++writes == 1) {
            firstStarted.complete();
            await releaseFirst.future;
          }
          durable = value;
          activeWrites--;
        },
      );
      addTearDown(queue.dispose);
      addTearDown(api.dispose);
      final first = queue.enqueue(_sample());
      await firstStarted.future;
      final second = queue.enqueue(_sample());
      await pumpEventQueue();
      expect(writes, 1);
      releaseFirst.complete();
      await Future.wait([first, second]);
      expect(maximumWrites, 1);
      expect((jsonDecode(durable!) as Map)['items'], hasLength(2));
    },
  );
}
