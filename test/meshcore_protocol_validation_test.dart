import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';

void main() {
  group('hexToPubKey', () {
    test('parses 64-char hex into 32-byte key', () {
      final key = hexToPubKey('ab' * 32);
      expect(key.length, 32);
      expect(key.first, 0xab);
      expect(key.last, 0xab);
    });

    test('throws on odd length', () {
      expect(() => hexToPubKey('abc'), throwsArgumentError);
    });

    test('throws on non-hex chars', () {
      expect(() => hexToPubKey('zz${'ab' * 31}'), throwsArgumentError);
    });

    test('zero-pads shorter inputs', () {
      final key = hexToPubKey('1234');
      expect(key.length, 32);
      expect(key[0], 0x12);
      expect(key[1], 0x34);
      expect(key[2], 0x00);
    });
  });

  group('buildSendTextMsgFrame validation', () {
    test('throws when recipient pubkey is shorter than 6 bytes', () {
      expect(
        () => buildSendTextMsgFrame(
          Uint8List.fromList([1, 2, 3]),
          'hi',
          timestampSeconds: 0,
        ),
        throwsArgumentError,
      );
    });

    test('accepts a 6-byte pubkey prefix', () {
      final frame = buildSendTextMsgFrame(
        Uint8List.fromList([1, 2, 3, 4, 5, 6]),
        'hi',
        timestampSeconds: 0,
      );
      expect(frame, isNotEmpty);
      expect(frame.first, cmdSendTxtMsg);
    });
  });

  group('_parseContactMessage bounds', () {
    test('drops a truncated contact-message frame without throwing', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final connector = MeshCoreConnector();
      addTearDown(connector.dispose);

      // Layout: [code][prefix x6][path_len][txt_type][timestamp x4] then text.
      // baseTextOffset = 1 + 6 + 1 + 1 + 4 = 13; a valid frame needs >= 17
      // bytes (baseTextOffset + 4). Feed 15 bytes: previously this threw a
      // RangeError inside sublist(13, 17); now it must return null.
      final shortFrame = Uint8List(15);
      shortFrame[0] = respCodeContactMsgRecv;

      expect(connector.parseContactMessageForTest(shortFrame), isNull);
    });
  });

  group('buildImportContactFrame size limit', () {
    test('accepts an advert that fits a companion frame', () {
      final hex = 'ab' * (maxFrameSize - 1);
      expect(buildImportContactFrame(hex).length, maxFrameSize);
    });

    test('rejects a QR payload one byte over the limit', () {
      expect(
        () => buildImportContactFrame('ab' * maxFrameSize),
        throwsArgumentError,
      );
    });
  });
}
