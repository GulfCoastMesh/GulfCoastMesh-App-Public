import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/ota_reply_parser.dart';

void main() {
  group('parseVerReply', () {
    test('parses version with build date', () {
      final info = parseVerReply('v1.16.0-07a3ca9 (Build: Apr 1 2026)');
      expect(info, isNotNull);
      expect(info!.version, 'v1.16.0');
      expect(info.raw, 'v1.16.0-07a3ca9 (Build: Apr 1 2026)');
    });

    test('parses bare version', () {
      expect(parseVerReply('v1.9.2')!.version, 'v1.9.2');
    });

    test('returns null for garbage', () {
      expect(parseVerReply('Error'), isNull);
    });
  });

  group('compareVersions', () {
    test('orders semvers numerically', () {
      expect(compareVersions('v1.16.0', 'v1.15.0'), greaterThan(0));
      expect(compareVersions('v1.9.0', 'v1.16.0'), lessThan(0));
      expect(compareVersions('v1.16.0', '1.16.0'), 0);
      expect(compareVersions('v2.0.0', 'v1.99.99'), greaterThan(0));
    });
  });

  group('parseStartOtaReply', () {
    test('parses ESP32 update URL', () {
      final result = parseStartOtaReply('Started: http://192.168.4.1/update');
      expect(result, isNotNull);
      expect(result!.isEsp32, isTrue);
      expect(result.isNrf, isFalse);
      expect(result.updateUrl.toString(), 'http://192.168.4.1/update');
    });

    test('parses nRF DFU MAC', () {
      final result = parseStartOtaReply('OK - mac: c3:9a:11:22:33:44');
      expect(result, isNotNull);
      expect(result!.isNrf, isTrue);
      expect(result.isEsp32, isFalse);
      expect(result.dfuMac, 'C3:9A:11:22:33:44');
    });

    test('returns null for error reply', () {
      expect(parseStartOtaReply('Error'), isNull);
    });
  });

  group('bootloaderHasOtaFix', () {
    test('detects OTAFIX bootloaders', () {
      expect(bootloaderHasOtaFix('> 0.9.2 OTAFIX 2.0'), isTrue);
      expect(bootloaderHasOtaFix('> s140 6.1.1, 0.6.0 otafix'), isTrue);
    });

    test('rejects stock bootloaders', () {
      expect(bootloaderHasOtaFix('> s140 6.1.1, 0.6.0'), isFalse);
      expect(bootloaderHasOtaFix('Error'), isFalse);
    });
  });
}
