import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/tcp_meshcore_transport.dart';

void main() {
  group('parseTcpEndpoint', () {
    test('bare host uses the default companion port', () {
      final endpoint = parseTcpEndpoint('meshcore.local');
      expect(endpoint?.host, 'meshcore.local');
      expect(endpoint?.port, defaultMeshCoreTcpPort);
    });

    test('host:port is split', () {
      final endpoint = parseTcpEndpoint('192.168.1.50:4403');
      expect(endpoint?.host, '192.168.1.50');
      expect(endpoint?.port, 4403);
    });

    test('surrounding whitespace is tolerated', () {
      final endpoint = parseTcpEndpoint('  192.168.1.50:4403  ');
      expect(endpoint?.host, '192.168.1.50');
      expect(endpoint?.port, 4403);
    });

    test(
      'bare IPv6 literal keeps all its colons and uses the default port',
      () {
        final endpoint = parseTcpEndpoint('fe80::1234:5678:9abc');
        expect(endpoint?.host, 'fe80::1234:5678:9abc');
        expect(endpoint?.port, defaultMeshCoreTcpPort);
      },
    );

    test('bracketed IPv6 with a port is split', () {
      final endpoint = parseTcpEndpoint('[fe80::1]:4403');
      expect(endpoint?.host, 'fe80::1');
      expect(endpoint?.port, 4403);
    });

    test('bracketed IPv6 without a port uses the default', () {
      final endpoint = parseTcpEndpoint('[fe80::1]');
      expect(endpoint?.host, 'fe80::1');
      expect(endpoint?.port, defaultMeshCoreTcpPort);
    });

    test('rejects empty, portless-colon, and out-of-range input', () {
      expect(parseTcpEndpoint(''), isNull);
      expect(parseTcpEndpoint('   '), isNull);
      expect(parseTcpEndpoint(':4403'), isNull);
      expect(parseTcpEndpoint('host:'), isNull);
      expect(parseTcpEndpoint('host:notaport'), isNull);
      expect(parseTcpEndpoint('host:0'), isNull);
      expect(parseTcpEndpoint('host:65536'), isNull);
      expect(parseTcpEndpoint('[fe80::1]junk'), isNull);
      expect(parseTcpEndpoint('[]:4403'), isNull);
    });
  });
}
