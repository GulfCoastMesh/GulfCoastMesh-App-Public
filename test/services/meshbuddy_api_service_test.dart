import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gulf_coast_mesh_app/services/meshbuddy_api_service.dart';

void main() {
  group('formatMeshBuddyError', () {
    test('prefers server message', () {
      expect(
        formatMeshBuddyError({
          'success': false,
          'reason': 'reserved',
          'message': 'Prefix taken',
        }),
        'Prefix taken',
      );
    });

    test('prefers OpenAPI error field', () {
      expect(
        formatMeshBuddyError({'error': 'prefix not available'}),
        'prefix not available',
      );
    });

    test('maps known reasons', () {
      expect(
        formatMeshBuddyError({'success': false, 'reason': 'unusable'}),
        'That prefix cannot be used (reserved by the system)',
      );
      expect(
        formatMeshBuddyError({'success': false, 'reason': 'invalid_prefix'}),
        'Invalid prefix format',
      );
    });
  });

  group('MeshBuddyApiService', () {
    test('parses status with ok field', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/status');
        return http.Response(
          json.encode({
            'ok': true,
            'service': 'meshbuddy',
            'prefix_length': 4,
            'timestamp': '2026-01-01T00:00:00Z',
          }),
          200,
        );
      });
      final api = MeshBuddyApiService(client: client);
      final status = await api.getStatus();
      expect(status.ok, isTrue);
      expect(status.prefixLength, 4);
      api.close();
    });

    test('parses production status shape', () async {
      final client = MockClient((request) async {
        return http.Response(
          json.encode({
            'status': 'ok',
            'service': 'meshbuddy',
            'prefix_length': 4,
            'timestamp': '2026-01-01T00:00:00Z',
          }),
          200,
        );
      });
      final api = MeshBuddyApiService(client: client);
      final status = await api.getStatus();
      expect(status.ok, isTrue);
      api.close();
    });

    test('parses prefix availability', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/prefix/A1B2');
        return http.Response(
          json.encode({
            'success': true,
            'prefix': 'A1B2',
            'available': false,
            'reason': 'reserved',
          }),
          200,
        );
      });
      final api = MeshBuddyApiService(client: client);
      final result = await api.checkPrefix('a1b2');
      expect(result.available, isFalse);
      expect(result.reason, 'reserved');
      api.close();
    });

    test('parses my-reservations list without success flag', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/my-reservations');
        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'ops@example.com');
        return http.Response(
          json.encode({
            'email': 'ops@example.com',
            'count': 1,
            'reservations': [
              {
                'prefix': 'C0DE',
                'name': 'Tower',
                'lat': 30.1,
                'lon': -90.2,
                'altitude': 12,
                'status': 'reserved',
              },
            ],
            'timestamp': '2026-01-01T00:00:00Z',
          }),
          200,
        );
      });
      final api = MeshBuddyApiService(client: client);
      final list = await api.myReservations('ops@example.com');
      expect(list, hasLength(1));
      expect(list.first.prefix, 'C0DE');
      expect(list.first.isReserved, isTrue);
      api.close();
    });

    test('reserve success returns reservation on 201', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/reserve');
        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['prefix'], 'AB12');
        expect(body['source'], 'gulfcoastmesh-app');
        return http.Response(
          json.encode({
            'message': 'Prefix reserved successfully',
            'reservation': {
              'prefix': 'AB12',
              'name': 'Node',
              'lat': 1,
              'lon': 2,
              'altitude': 0,
              'status': 'reserved',
              'email': 'a@b.co',
            },
          }),
          201,
        );
      });
      final api = MeshBuddyApiService(client: client);
      final reservation = await api.reserve(
        prefix: 'ab12',
        name: 'Node',
        lat: 1,
        lon: 2,
        altitude: 0,
        email: 'a@b.co',
      );
      expect(reservation.prefix, 'AB12');
      api.close();
    });

    test('reserve failure throws with mapped reason', () async {
      final client = MockClient((request) async {
        return http.Response(
          json.encode({'success': false, 'reason': 'reserved'}),
          200,
        );
      });
      final api = MeshBuddyApiService(client: client);
      expect(
        () => api.reserve(
          prefix: 'AAAA',
          name: 'Node',
          lat: 1,
          lon: 2,
          altitude: 0,
          email: 'a@b.co',
        ),
        throwsA(
          isA<MeshBuddyApiException>().having(
            (e) => e.reason,
            'reason',
            'reserved',
          ),
        ),
      );
      api.close();
    });

    test('reserve HTTP error uses error field', () async {
      final client = MockClient((request) async {
        return http.Response(
          json.encode({'error': 'prefix not available'}),
          409,
        );
      });
      final api = MeshBuddyApiService(client: client);
      expect(
        () => api.reserve(
          prefix: 'AAAA',
          name: 'Node',
          lat: 1,
          lon: 2,
          altitude: 0,
          email: 'a@b.co',
        ),
        throwsA(
          isA<MeshBuddyApiException>()
              .having((e) => e.message, 'message', 'prefix not available')
              .having((e) => e.reason, 'reason', 'prefix not available'),
        ),
      );
      api.close();
    });

    test('keygen success parses MeshCore keypair', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/keygen');
        expect(request.method, 'POST');
        final body = json.decode(request.body) as Map<String, dynamic>;
        expect(body['prefix'], 'A1B2');
        expect(body['email'], 'ops@example.com');
        return http.Response(
          json.encode({
            'prefix': 'A1B2',
            'public_key': 'A1B2${'CD' * 30}',
            'private_key': 'AB' * 64,
            'attempts': 1234,
            'elapsed_secs': 1.5,
          }),
          200,
        );
      });
      final api = MeshBuddyApiService(client: client);
      final result = await api.keygen(prefix: 'a1b2', email: 'ops@example.com');
      expect(result.prefix, 'A1B2');
      expect(result.publicKey.startsWith('A1B2'), isTrue);
      expect(result.privateKey.length, 128);
      expect(result.attempts, 1234);
      expect(result.isValid, isTrue);
      api.close();
    });

    test('keygen not found throws', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode({'error': 'Not found'}), 404);
      });
      final api = MeshBuddyApiService(client: client);
      expect(
        () => api.keygen(prefix: 'A1B2', email: 'ops@example.com'),
        throwsA(
          isA<MeshBuddyApiException>().having(
            (e) => e.message,
            'message',
            'No reservation found for that prefix/email',
          ),
        ),
      );
      api.close();
    });

    test('shouldFallbackToLocalKeygen for unavailable/network', () {
      expect(
        shouldFallbackToLocalKeygen(
          const MeshBuddyApiException('network_error'),
        ),
        isTrue,
      );
      expect(
        shouldFallbackToLocalKeygen(
          const MeshBuddyApiException('http_503', reason: 'unavailable'),
        ),
        isTrue,
      );
      expect(
        shouldFallbackToLocalKeygen(
          const MeshBuddyApiException('Not found', reason: 'Not found'),
        ),
        isFalse,
      );
    });
  });
}
