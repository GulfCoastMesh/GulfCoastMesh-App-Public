import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/helpers/frame_redaction.dart';

void main() {
  group('redactSensitiveCliText', () {
    test('redacts admin password commands', () {
      expect(redactSensitiveCliText('password secret123'), 'password ***');
      expect(redactSensitiveCliText('Password SuperSecret'), 'Password ***');
    });

    test('redacts guest password commands', () {
      expect(
        redactSensitiveCliText('set guest.password abc'),
        'set guest.password ***',
      );
    });

    test('redacts private key commands', () {
      expect(
        redactSensitiveCliText('set prv.key ${'ab' * 64}'),
        'set prv.key ***',
      );
      expect(
        redactSensitiveCliText('SET PRV.KEY ${'cd' * 64}'),
        'SET PRV.KEY ***',
      );
    });

    test('redacts bridge secret commands', () {
      expect(
        redactSensitiveCliText('set bridge.secret hunter2'),
        'set bridge.secret ***',
      );
    });

    test('leaves unrelated CLI commands alone', () {
      expect(redactSensitiveCliText('reboot'), 'reboot');
      expect(redactSensitiveCliText('get battery'), 'get battery');
    });

    test('redacts XX|-prefixed repeater CLI password commands', () {
      expect(
        redactSensitiveCliText('AB|password secret123'),
        'AB|password ***',
      );
      expect(
        redactSensitiveCliText('0f|set guest.password abc'),
        '0f|set guest.password ***',
      );
      expect(isSensitiveCliCommand('CD|set prv.key ${'ab' * 64}'), isTrue);
    });
  });

  group('redactSensitiveFrame', () {
    test('zeros login password bytes after pubkey', () {
      final frame = buildSendLoginFrame(
        Uint8List.fromList(List<int>.generate(32, (i) => i + 1)),
        'hunter2',
      );
      final redacted = redactSensitiveFrame(frame);
      expect(redacted[0], cmdSendLogin);
      expect(redacted.sublist(1, 33), frame.sublist(1, 33));
      expect(redacted.sublist(33), everyElement(0));
      expect(utf8Contains(frame, 'hunter2'), isTrue);
      expect(utf8Contains(redacted, 'hunter2'), isFalse);
    });

    test('zeros channel PSK bytes', () {
      final psk = Uint8List.fromList(List<int>.generate(16, (i) => 0xA0 + i));
      final frame = buildSetChannelFrame(2, 'public', psk);
      final redacted = redactSensitiveFrame(frame);
      expect(redacted.sublist(0, 34), frame.sublist(0, 34));
      expect(redacted.sublist(34, 50), everyElement(0));
    });

    test('zeros inbound CHANNEL_INFO PSK bytes', () {
      // [code][idx][name x32][psk x16]
      final frame = Uint8List(50);
      frame[0] = respCodeChannelInfo;
      frame[1] = 3;
      final nameBytes = utf8.encode('secret-chan');
      frame.setRange(2, 2 + nameBytes.length, nameBytes);
      for (int i = 34; i < 50; i++) {
        frame[i] = 0xB0 + (i - 34);
      }
      final redacted = redactSensitiveFrame(frame);
      // Header + name preserved, PSK zeroed.
      expect(redacted.sublist(0, 34), frame.sublist(0, 34));
      expect(redacted.sublist(34, 50), everyElement(0));
    });

    test('redacts CLI password payload text', () {
      final pubKey = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
      final frame = buildSendCliCommandFrame(
        pubKey,
        'password hunter2',
        timestampSeconds: 1_700_000_000,
      );
      final redacted = redactSensitiveFrame(frame);
      expect(utf8Contains(frame, 'hunter2'), isTrue);
      expect(utf8Contains(redacted, 'hunter2'), isFalse);
      expect(utf8Contains(redacted, 'password ***'), isTrue);
    });

    test('redacts XX|-prefixed CLI password payload text', () {
      final pubKey = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
      final frame = buildSendCliCommandFrame(
        pubKey,
        'AB|password hunter2',
        timestampSeconds: 1_700_000_000,
      );
      final redacted = redactSensitiveFrame(frame);
      expect(utf8Contains(frame, 'hunter2'), isTrue);
      expect(utf8Contains(redacted, 'hunter2'), isFalse);
      expect(utf8Contains(redacted, 'AB|password ***'), isTrue);
    });

    test('zeros flood-scope key bytes on set and response frames', () {
      final scopeKey = Uint8List.fromList(
        List<int>.generate(16, (i) => 0xC0 + i),
      );
      final setFrame = buildSetDefaultFloodScopeFrame(
        name: 'gulfcoast',
        scopeKey: scopeKey,
      );
      final setRedacted = redactSensitiveFrame(setFrame);
      final keyStart = 1 + defaultFloodScopeNameField;
      expect(setRedacted.sublist(0, keyStart), setFrame.sublist(0, keyStart));
      expect(
        setRedacted.sublist(keyStart, keyStart + defaultFloodScopeKeyBytes),
        everyElement(0),
      );

      final respFrame = Uint8List.fromList([
        respCodeDefaultFloodScope,
        ...setFrame.sublist(1),
      ]);
      final respRedacted = redactSensitiveFrame(respFrame);
      expect(
        respRedacted.sublist(keyStart, keyStart + defaultFloodScopeKeyBytes),
        everyElement(0),
      );
    });

    test('zeros session flood-scope key override bytes', () {
      final scopeKey = Uint8List.fromList(
        List<int>.generate(16, (i) => 0xD0 + i),
      );
      final setFrame = buildSetFloodScopeKeyFrame(scopeKey);
      final redacted = redactSensitiveFrame(setFrame);
      expect(redacted.sublist(0, 2), setFrame.sublist(0, 2));
      expect(redacted.sublist(2, 18), everyElement(0));

      // Clear and unscoped frames carry no key and must pass through.
      expect(
        redactSensitiveFrame(buildClearFloodScopeKeyFrame()),
        buildClearFloodScopeKeyFrame(),
      );
      expect(
        redactSensitiveFrame(buildUnscopedFloodScopeFrame()),
        buildUnscopedFloodScopeFrame(),
      );
    });

    test('does not alter plain text messages', () {
      final pubKey = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
      final frame = buildSendTextMsgFrame(
        pubKey,
        'hello password is fine in chat',
        timestampSeconds: 1_700_000_000,
      );
      final redacted = redactSensitiveFrame(frame);
      expect(redacted, frame);
    });
  });

  group('local companion CLI frames', () {
    Uint8List cli(String command) =>
        Uint8List.fromList([cmdAppStart, ...utf8.encode(command), 0]);

    String textOf(Uint8List frame) {
      final body = frame.sublist(1);
      final nul = body.indexOf(0);
      return utf8.decode(body.sublist(0, nul >= 0 ? nul : body.length));
    }

    test('a password argument is redacted', () {
      expect(
        textOf(redactSensitiveFrame(cli('password hunter2'))),
        'password ***',
      );
    });

    test('a private key is redacted rather than logged verbatim', () {
      final key = 'ab' * 64;
      final out = textOf(redactSensitiveFrame(cli('set prv.key $key')));
      expect(out, 'set prv.key ***');
      expect(out.contains(key), isFalse);
    });

    test('guest password and bridge secret are redacted', () {
      expect(
        textOf(redactSensitiveFrame(cli('set guest.password abc'))),
        'set guest.password ***',
      );
      expect(
        textOf(redactSensitiveFrame(cli('set bridge.secret xyz'))),
        'set bridge.secret ***',
      );
    });

    test('a harmless CLI command is left alone', () {
      expect(
        textOf(redactSensitiveFrame(cli('set privacy on'))),
        'set privacy on',
      );
    });

    test('CMD_APP_START is not mistaken for CLI text', () {
      // [cmd][version][6 reserved][name][0] - version 1 is below printable
      // ASCII, which is what separates it from a CLI frame.
      final appStart = buildAppStartFrame();
      expect(redactSensitiveFrame(appStart), appStart);
    });
  });
}

bool utf8Contains(Uint8List bytes, String needle) {
  return String.fromCharCodes(bytes).contains(needle);
}
