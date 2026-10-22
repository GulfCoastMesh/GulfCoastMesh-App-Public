import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gulf_coast_mesh_app/models/wardriving.dart';
import 'package:gulf_coast_mesh_app/services/meshmapper_api_service.dart';

void main() {
  group('meshMapperZoneCode', () {
    test('normalizes status maps and auth strings', () {
      expect(meshMapperZoneCode({'code': 'hou', 'name': 'Houston'}), 'HOU');
      expect(meshMapperZoneCode('msy'), 'MSY');
      expect(meshMapperZoneCode({'name': 'missing'}), isNull);
    });

    test('parses enabled repeater target hex safely', () {
      final repeater = MeshMapperRepeater.fromJson({
        'id': '4e',
        'hex_id': 'aabbccdd',
        'name': 'Test',
        'lat': 29.7,
        'lon': -95.3,
      });
      expect(repeater.targetId, 'AABBCCDD');
      expect(repeater.longitude, -95.3);
    });
  });

  group('formatMeshMapperAuthError', () {
    test('maps missing zone to an actionable local message', () {
      expect(
        formatMeshMapperAuthError(
          const MeshMapperApiResponse(error: 'missing_zone'),
        ),
        'MeshMapper zone unavailable',
      );
    });

    test('maps invalid_key reason to friendly message', () {
      expect(
        formatMeshMapperAuthError(
          const MeshMapperApiResponse(
            data: {'success': false, 'reason': 'invalid_key'},
          ),
        ),
        'Invalid MeshMapper API key for this build',
      );
    });

    test('prefers server message over reason', () {
      expect(
        formatMeshMapperAuthError(
          const MeshMapperApiResponse(
            data: {
              'success': false,
              'reason': 'unknown_device',
              'message':
                  'Unknown public key. Please advertise yourself on the mesh.',
            },
          ),
        ),
        'Unknown public key. Please advertise yourself on the mesh.',
      );
    });

    test('maps unknown_device reason when message absent', () {
      expect(
        formatMeshMapperAuthError(
          const MeshMapperApiResponse(
            data: {'success': false, 'reason': 'unknown_device'},
          ),
        ),
        'Unknown device public key. Advertise on the mesh first.',
      );
    });

    test('reports network transport errors', () {
      expect(
        formatMeshMapperAuthError(
          const MeshMapperApiResponse(error: 'network_error'),
        ),
        'Network error contacting MeshMapper',
      );
    });

    test('reports HTTP status when body has no message', () {
      expect(
        formatMeshMapperAuthError(const MeshMapperApiResponse(httpStatus: 503)),
        'MeshMapper API HTTP 503',
      );
    });

    test('prefers JSON body over HTTP 403 status', () {
      expect(
        formatMeshMapperAuthError(
          const MeshMapperApiResponse(
            httpStatus: 403,
            data: {
              'success': false,
              'reason': 'unknown_device',
              'message':
                  'Unknown public key. Please advertise yourself on the mesh.',
            },
          ),
        ),
        'Unknown public key. Please advertise yourself on the mesh.',
      );
    });
  });

  group('formatMeshMapperZoneStatusError', () {
    test('describes outside zone with nearest zone', () {
      expect(
        formatMeshMapperZoneStatusError(
          const MeshMapperApiResponse(
            data: {
              'success': true,
              'in_zone': false,
              'nearest_zone': {
                'name': 'Cape Town, ZA',
                'code': 'CPT',
                'distance_km': 3945.72,
              },
            },
          ),
        ),
        'Outside coverage zone (nearest: Cape Town, ZA, 3946 km)',
      );
    });
  });

  group('buildMeshMapperAuthRequestBody', () {
    test('register includes contact_uri and normalized iata', () {
      final body = buildMeshMapperAuthRequestBody(
        apiKey: 'test-key',
        reason: 'register',
        contactUri: 'meshcore://abc123',
        publicKey: 'deadbeef',
        iataCode: ' hou ',
        lat: 45.0,
        lon: -75.0,
      );

      expect(body, isNotNull);
      expect(body!['contact_uri'], 'meshcore://abc123');
      expect(body.containsKey('public_key'), isFalse);
      expect(body['reason'], 'register');
      expect(body['iata'], 'HOU');
    });

    test('connect includes public_key and normalized iata', () {
      final body = buildMeshMapperAuthRequestBody(
        apiKey: 'test-key',
        reason: 'connect',
        publicKey: 'deadbeef',
        iataCode: 'msy',
        lat: 45.0,
        lon: -75.0,
      );

      expect(body, isNotNull);
      expect(body!['public_key'], 'deadbeef');
      expect(body.containsKey('contact_uri'), isFalse);
      expect(body['iata'], 'MSY');
    });

    test('omits unusable iata and never adds it to disconnect', () {
      final connectBody = buildMeshMapperAuthRequestBody(
        apiKey: 'test-key',
        reason: 'connect',
        publicKey: 'deadbeef',
        iataCode: '   ',
        lat: 45.0,
        lon: -75.0,
      );
      final disconnectBody = buildMeshMapperAuthRequestBody(
        apiKey: 'test-key',
        reason: 'disconnect',
        sessionId: 'session-1',
        iataCode: 'HOU',
      );

      expect(connectBody!.containsKey('iata'), isFalse);
      expect(disconnectBody!.containsKey('iata'), isFalse);
    });

    test('offline uploads authenticate with offline_mode', () {
      final body = buildMeshMapperAuthRequestBody(
        apiKey: 'test-key',
        reason: 'connect',
        publicKey: 'deadbeef',
        iataCode: 'hou',
        lat: 45,
        lon: -75,
        offlineMode: true,
      );

      expect(body!['offline_mode'], isTrue);
      expect(body['iata'], 'HOU');
    });
  });

  group('checkZoneStatus', () {
    test('stores normalized map-form and string-form status zones', () async {
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        return http.Response(
          json.encode({
            'success': true,
            'in_zone': true,
            'zone': requestCount == 1 ? {'code': 'hou'} : 'msy',
          }),
          200,
        );
      });
      final api = MeshMapperApiService(apiKey: 'test-only', client: client);

      await api.checkZoneStatus(
        lat: 29.7,
        lon: -95.3,
        accuracyMeters: 5,
        appVersion: 'test',
      );
      expect(api.zone, 'HOU');

      await api.checkZoneStatus(
        lat: 29.9,
        lon: -90.1,
        accuracyMeters: 5,
        appVersion: 'test',
      );
      expect(api.zone, 'MSY');
    });

    test('clears stale zone when successful status has no zone', () async {
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        return http.Response(
          json.encode({
            'success': true,
            'in_zone': true,
            if (requestCount == 1) 'zone': {'code': 'hou'},
          }),
          200,
        );
      });
      final api = MeshMapperApiService(apiKey: 'test-only', client: client);

      await api.checkZoneStatus(
        lat: 29.7,
        lon: -95.3,
        accuracyMeters: 5,
        appVersion: 'test',
      );
      expect(api.zone, 'HOU');

      await api.checkZoneStatus(
        lat: 29.7,
        lon: -95.3,
        accuracyMeters: 5,
        appVersion: 'test',
      );
      expect(api.zone, isNull);
    });
  });

  group('shouldAttemptMeshMapperRegistration', () {
    test('returns false for gps_stale', () {
      expect(
        shouldAttemptMeshMapperRegistration(
          const MeshMapperApiResponse(
            data: {'success': false, 'reason': 'gps_stale'},
          ),
        ),
        isFalse,
      );
    });

    test('returns true for unknown_device', () {
      expect(
        shouldAttemptMeshMapperRegistration(
          const MeshMapperApiResponse(
            httpStatus: 403,
            data: {'success': false, 'reason': 'unknown_device'},
          ),
        ),
        isTrue,
      );
    });
  });

  group('classifyUploadResponse', () {
    test('does not spend retry budget when no response arrived', () {
      expect(classifyUploadResponse(null), MeshMapperUploadResult.unreachable);
    });

    test('honors the server rate-limit hold', () {
      expect(
        classifyUploadResponse({'success': false, 'reason': 'rate_limited'}),
        MeshMapperUploadResult.held,
      );
    });

    test('parses bounded Retry-After values', () {
      expect(
        MeshMapperApiService.parseRetryAfter('12'),
        const Duration(seconds: 12),
      );
      expect(
        MeshMapperApiService.parseRetryAfter(null),
        MeshMapperApiService.defaultWardriveRetryAfter,
      );
      expect(
        MeshMapperApiService.parseRetryAfter('999999'),
        MeshMapperApiService.maxWardriveRetryAfter,
      );
    });
  });

  group('requestAuth', () {
    test('missing API key does not send an auth request', () async {
      var requests = 0;
      final api = MeshMapperApiService(
        apiKey: '',
        client: MockClient((_) async {
          requests++;
          return http.Response('{}', 200);
        }),
      );
      addTearDown(api.dispose);
      final response = await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 30,
        lon: -90,
      );
      expect(api.hasApiKey, isFalse);
      expect(response.error, 'missing_api_key');
      expect(requests, 0);
    });

    test('register stores session from successful response', () async {
      Map<String, dynamic>? capturedBody;
      final client = MockClient((request) async {
        capturedBody = json.decode(request.body) as Map<String, dynamic>;
        return http.Response(
          json.encode({
            'success': true,
            'session_id': 'sess-1',
            'tx_allowed': true,
            'rx_allowed': true,
            'expires_at': 9999999999,
          }),
          200,
        );
      });

      final api = MeshMapperApiService(apiKey: 'test-only', client: client);
      final response = await api.requestAuth(
        reason: 'register',
        contactUri: 'meshcore://signed-contact',
        iataCode: 'hou',
        lat: 45.0,
        lon: -75.0,
      );

      expect(response.isSuccess, isTrue);
      expect(capturedBody?['key'], 'test-only');
      expect(capturedBody?['contact_uri'], 'meshcore://signed-contact');
      expect(capturedBody?['iata'], 'HOU');
      expect(api.hasSession, isTrue);
      expect(api.txAllowed, isTrue);
      expect(api.rxAllowed, isTrue);
    });

    test('connect sends the resolved iata with the public key', () async {
      Map<String, dynamic>? capturedBody;
      final client = MockClient((request) async {
        capturedBody = json.decode(request.body) as Map<String, dynamic>;
        return http.Response(json.encode({'success': false}), 200);
      });
      final api = MeshMapperApiService(apiKey: 'test-only', client: client);

      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        iataCode: 'msy',
        lat: 45.0,
        lon: -75.0,
      );

      expect(capturedBody?['public_key'], 'deadbeef');
      expect(capturedBody?['iata'], 'MSY');
    });

    test('stores enforce_hybrid and min_mode_interval from response', () async {
      final client = MockClient((request) async {
        return http.Response(
          json.encode({
            'success': true,
            'session_id': 'sess-2',
            'tx_allowed': true,
            'rx_allowed': true,
            'expires_at': 9999999999,
            'enforce_hybrid': true,
            'min_mode_interval': 45,
          }),
          200,
        );
      });

      final api = MeshMapperApiService(apiKey: 'test-only', client: client);
      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 45.0,
        lon: -75.0,
      );

      expect(api.enforceHybrid, isTrue);
      expect(api.minModeInterval, 45);
    });

    test('defaults min_mode_interval when absent', () async {
      final client = MockClient((request) async {
        return http.Response(
          json.encode({
            'success': true,
            'session_id': 'sess-3',
            'tx_allowed': true,
            'rx_allowed': true,
            'expires_at': 9999999999,
          }),
          200,
        );
      });

      final api = MeshMapperApiService(apiKey: 'test-only', client: client);
      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 45.0,
        lon: -75.0,
      );

      expect(api.enforceHybrid, isFalse);
      expect(api.minModeInterval, kWardrivingMinIntervalSec);
    });

    test('notifies queue owner before replacing a live session', () async {
      var callCount = 0;
      final api = MeshMapperApiService(
        apiKey: 'test-only',
        client: MockClient((_) async {
          callCount++;
          return http.Response(
            json.encode({
              'success': true,
              'session_id': callCount == 1 ? 'sess-old' : 'sess-new',
              'tx_allowed': true,
              'rx_allowed': true,
              'expires_at': 9999999999,
            }),
            200,
          );
        }),
      );
      addTearDown(api.dispose);
      final changes = <(String, String)>[];
      api.onSessionIdChanged = (oldId, newId) async {
        changes.add((oldId, newId));
      };

      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 45.0,
        lon: -75.0,
      );
      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 45.0,
        lon: -75.0,
      );

      expect(changes, [('sess-old', 'sess-new')]);
      expect(api.sessionId, 'sess-new');
    });
  });

  group('submitWardriveData', () {
    test('processes a session error returned with non-200 JSON', () async {
      var callCount = 0;
      final api = MeshMapperApiService(
        apiKey: 'test-only',
        client: MockClient((_) async {
          callCount++;
          if (callCount == 1) {
            return http.Response(
              json.encode({
                'success': true,
                'session_id': 'sess-expired',
                'tx_allowed': true,
                'rx_allowed': true,
                'expires_at': 9999999999,
              }),
              200,
            );
          }
          return http.Response(
            json.encode({'success': false, 'reason': 'session_expired'}),
            403,
          );
        }),
      );
      addTearDown(api.dispose);
      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 45.0,
        lon: -75.0,
      );

      final response = await api.submitWardriveData(const []);

      expect(response?['reason'], 'session_expired');
      expect(api.hasSession, isFalse);
    });

    test('holds all wardrive senders after a Retry-After response', () async {
      var now = DateTime.utc(2026, 1, 1, 12);
      var calls = 0;
      final api = MeshMapperApiService(
        apiKey: 'test-only',
        now: () => now,
        client: MockClient((_) async {
          calls++;
          if (calls == 1) {
            return http.Response(
              json.encode({
                'success': true,
                'session_id': 'sess-held',
                'tx_allowed': true,
                'rx_allowed': true,
                'expires_at': 9999999999,
              }),
              200,
            );
          }
          if (calls == 2) {
            return http.Response(
              json.encode({'success': false, 'reason': 'rate_limited'}),
              429,
              headers: {'retry-after': '120'},
            );
          }
          return http.Response(json.encode({'success': true}), 200);
        }),
      );
      addTearDown(api.dispose);
      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 45,
        lon: -75,
      );

      final limited = await api.submitWardriveData(const []);
      expect(classifyUploadResponse(limited), MeshMapperUploadResult.held);
      expect(api.wardriveBackoff, const Duration(seconds: 120));
      expect(api.hasSession, isTrue);

      // Queue uploads and session preflights share the hold and must not make
      // another HTTP request that would extend the server's penalty.
      expect(
        classifyUploadResponse(await api.submitWardriveData(const [])),
        MeshMapperUploadResult.held,
      );
      final check = await api.checkSessionValid();
      expect(check.isValid, isTrue);
      expect(calls, 2);

      now = now.add(const Duration(seconds: 121));
      expect(await api.submitWardriveData(const []), {'success': true});
      expect(calls, 3);
    });

    test('stale upload error cannot clear a replacement session', () async {
      final uploadStarted = Completer<void>();
      final delayedUpload = Completer<http.Response>();
      var authCount = 0;
      var sessionErrors = 0;
      final api = MeshMapperApiService(
        apiKey: 'test-only',
        client: MockClient((request) async {
          final body = json.decode(request.body) as Map<String, dynamic>;
          if (request.url.path.endsWith('/auth')) {
            if (body['reason'] == 'disconnect') {
              return http.Response(json.encode({'success': true}), 200);
            }
            authCount++;
            return http.Response(
              json.encode({
                'success': true,
                'session_id': authCount == 1 ? 'sess-old' : 'sess-new',
                'tx_allowed': true,
                'rx_allowed': true,
                'expires_at': 9999999999,
              }),
              200,
            );
          }
          uploadStarted.complete();
          return delayedUpload.future;
        }),
      );
      addTearDown(api.dispose);
      api.onSessionError = (_, _) => sessionErrors++;
      Future<void> connect() => api
          .requestAuth(
            reason: 'connect',
            publicKey: 'deadbeef',
            lat: 45,
            lon: -75,
          )
          .then((_) {});

      await connect();
      final upload = api.submitWardriveData(const []);
      await uploadStarted.future;
      await api.disconnect();
      await connect();
      delayedUpload.complete(
        http.Response(
          json.encode({'success': false, 'reason': 'session_expired'}),
          403,
        ),
      );
      await upload;

      expect(api.sessionId, 'sess-new');
      expect(api.hasSession, isTrue);
      expect(sessionErrors, 0);
    });
  });

  group('checkSessionValid', () {
    test('treats transport errors as transient (keep session)', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          // Initial auth succeeds so we have a session
          return http.Response(
            json.encode({
              'success': true,
              'session_id': 'sess-net',
              'tx_allowed': true,
              'rx_allowed': true,
              'expires_at': 9999999999,
            }),
            200,
          );
        }
        // Heartbeat: simulate a transport error
        throw Exception('network down');
      });

      final api = MeshMapperApiService(apiKey: 'test-only', client: client);
      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 45.0,
        lon: -75.0,
      );
      expect(api.hasSession, isTrue);

      final result = await api.checkSessionValid(lat: 45.0, lon: -75.0);
      expect(result.isValid, isTrue);
      expect(result.reason, 'transient');
      // Session is preserved across a transient blip
      expect(api.hasSession, isTrue);
    });

    test('drops session on explicit session_invalid', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return http.Response(
            json.encode({
              'success': true,
              'session_id': 'sess-bad',
              'tx_allowed': true,
              'rx_allowed': true,
              'expires_at': 9999999999,
            }),
            200,
          );
        }
        return http.Response(
          json.encode({
            'success': false,
            'reason': 'session_invalid',
            'message': 'Session is invalid',
          }),
          200,
        );
      });

      final api = MeshMapperApiService(apiKey: 'test-only', client: client);
      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 45.0,
        lon: -75.0,
      );

      final result = await api.checkSessionValid(lat: 45.0, lon: -75.0);
      expect(result.isValid, isFalse);
      expect(result.reason, 'session_invalid');
      expect(api.hasSession, isFalse);
    });

    test('treats the first preflight 429 as a valid held session', () async {
      var calls = 0;
      final api = MeshMapperApiService(
        apiKey: 'test-only',
        client: MockClient((_) async {
          calls++;
          if (calls == 1) {
            return http.Response(
              json.encode({
                'success': true,
                'session_id': 'sess-preflight-held',
                'tx_allowed': true,
                'rx_allowed': true,
                'expires_at': 9999999999,
              }),
              200,
            );
          }
          return http.Response(
            json.encode({'success': false, 'reason': 'rate_limited'}),
            429,
            headers: {'retry-after': '60'},
          );
        }),
      );
      addTearDown(api.dispose);
      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 45,
        lon: -75,
      );

      expect((await api.checkSessionValid()).isValid, isTrue);
      expect(api.isWardriveHeld, isTrue);
      expect((await api.checkSessionValid()).isValid, isTrue);
      expect(calls, 2);
    });

    test(
      'stale heartbeat verdict cannot clear a replacement session',
      () async {
        final heartbeatStarted = Completer<void>();
        final delayedHeartbeat = Completer<http.Response>();
        var authCount = 0;
        var sessionErrors = 0;
        final api = MeshMapperApiService(
          apiKey: 'test-only',
          client: MockClient((request) async {
            final body = json.decode(request.body) as Map<String, dynamic>;
            if (request.url.path.endsWith('/auth')) {
              if (body['reason'] == 'disconnect') {
                return http.Response(json.encode({'success': true}), 200);
              }
              authCount++;
              return http.Response(
                json.encode({
                  'success': true,
                  'session_id': authCount == 1 ? 'sess-old' : 'sess-new',
                  'tx_allowed': true,
                  'rx_allowed': true,
                  'expires_at': 9999999999,
                }),
                200,
              );
            }
            heartbeatStarted.complete();
            return delayedHeartbeat.future;
          }),
        );
        addTearDown(api.dispose);
        api.onSessionError = (_, _) => sessionErrors++;
        Future<void> connect() => api
            .requestAuth(
              reason: 'connect',
              publicKey: 'deadbeef',
              lat: 45,
              lon: -75,
            )
            .then((_) {});

        await connect();
        final check = api.checkSessionValid();
        await heartbeatStarted.future;
        await api.disconnect();
        await connect();
        delayedHeartbeat.complete(
          http.Response(
            json.encode({'success': false, 'reason': 'session_invalid'}),
            200,
          ),
        );

        expect((await check).isValid, isTrue);
        expect(api.sessionId, 'sess-new');
        expect(sessionErrors, 0);
      },
    );
  });

  group('sendHeartbeat', () {
    test('sends heartbeat coords using wardrive lon field', () async {
      Map<String, dynamic>? capturedBody;
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        capturedBody = json.decode(request.body) as Map<String, dynamic>;
        return http.Response(
          json.encode({
            'success': true,
            if (requestCount == 1) ...{
              'session_id': 'sess-hb',
              'tx_allowed': true,
              'rx_allowed': true,
            },
            'expires_at': 9999999999,
          }),
          200,
        );
      });

      final api = MeshMapperApiService(apiKey: 'test-only', client: client);
      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 45.0,
        lon: -75.0,
      );

      await api.sendHeartbeat(lat: 30.5, lon: -90.25);

      final coords = capturedBody?['coords'] as Map<String, dynamic>?;
      expect(coords, isNotNull);
      expect(coords!['lat'], 30.5);
      expect(coords['lon'], -90.25);
      expect(coords.containsKey('lng'), isFalse);
    });

    test('does not clear a session when heartbeat receives 429', () async {
      var calls = 0;
      final api = MeshMapperApiService(
        apiKey: 'test-only',
        client: MockClient((_) async {
          calls++;
          if (calls == 1) {
            return http.Response(
              json.encode({
                'success': true,
                'session_id': 'sess-heartbeat-held',
                'tx_allowed': true,
                'rx_allowed': true,
                'expires_at': 9999999999,
              }),
              200,
            );
          }
          return http.Response('not-json', 429, headers: {'retry-after': '60'});
        }),
      );
      addTearDown(api.dispose);
      await api.requestAuth(
        reason: 'connect',
        publicKey: 'deadbeef',
        lat: 45,
        lon: -75,
      );

      final result = await api.sendHeartbeatTyped();
      expect(result.data?['reason'], 'held');
      expect(api.hasSession, isTrue);
      expect(api.isWardriveHeld, isTrue);
      expect(calls, 2);
    });
  });
}
