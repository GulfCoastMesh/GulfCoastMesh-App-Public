import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/prefix_key_generator.dart';

Uint8List _hexToBytes(String hex) {
  return Uint8List.fromList([
    for (var i = 0; i < hex.length; i += 2)
      int.parse(hex.substring(i, i + 2), radix: 16),
  ]);
}

void main() {
  group('isValidKeyPrefix', () {
    test('accepts hex of expected length', () {
      expect(isValidKeyPrefix('A1B2', expectedLength: 4), isTrue);
      expect(isValidKeyPrefix('a1', expectedLength: 2), isTrue);
    });

    test('rejects non-hex, wrong length, and unusable first byte', () {
      expect(isValidKeyPrefix('ZZZZ', expectedLength: 4), isFalse);
      expect(isValidKeyPrefix('ABC', expectedLength: 4), isFalse);
      expect(isValidKeyPrefix('00AB', expectedLength: 4), isFalse);
      expect(isValidKeyPrefix('FF12', expectedLength: 4), isFalse);
    });
  });

  group('generateMeshCoreKeypairFromSeed', () {
    test('matches MeshBuddy / orlp expanded private key + ed25519 pubkey', () {
      final seed = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
      final mesh = generateMeshCoreKeypairFromSeed(seed);
      final hashed = sha512.convert(seed).bytes;
      final dartPrivate = ed25519.newKeyFromSeed(seed);

      expect(mesh.privateKey.length, 64);
      expect(mesh.publicKey.length, 32);
      expect(mesh.privateKey[0], hashed[0] & 248);
      expect(mesh.privateKey[31], (hashed[31] & 63) | 64);
      expect(mesh.privateKey.sublist(32), hashed.sublist(32));
      // Must not be Dart seed||pubkey format.
      expect(mesh.privateKey.sublist(0, 32), isNot(seed));
      expect(mesh.publicKey, dartPrivate.bytes.sublist(32));
      expect(expandSeedToMeshCorePrivateKey(seed), mesh.privateKey);
    });
  });

  group('findPrefixKeySync', () {
    test('finds a MeshCore-format key for a short prefix', () {
      final pair = findPrefixKeySync('a', maxAttempts: 100000);
      expect(pair, isNotNull);
      expect(pair!.publicKeyHex.startsWith('a'), isTrue);
      expect(pair.publicKeyHex.length, 64);
      expect(pair.privateKeyHex.length, 128);
      expect(pair.attempts, greaterThan(0));

      final meshBytes = _hexToBytes(pair.privateKeyHex);
      final pubBytes = _hexToBytes(pair.publicKeyHex);
      expect(meshBytes[0] & 7, 0);
      expect(meshBytes[31] & 192, 64);
      expect(meshBytes.sublist(32), isNot(pubBytes));
    });
  });

  group('findPrefixKey', () {
    test('finds a MeshCore-format key via capped worker pool', () async {
      final pair = await findPrefixKey('a', workerCount: 2, batchSize: 256);
      expect(pair, isNotNull);
      expect(pair!.publicKeyHex.startsWith('a'), isTrue);
      expect(pair.privateKeyHex.length, 128);

      final meshBytes = _hexToBytes(pair.privateKeyHex);
      final pubBytes = _hexToBytes(pair.publicKeyHex);
      expect(meshBytes[0] & 7, 0);
      expect(meshBytes[31] & 192, 64);
      expect(meshBytes.sublist(32), isNot(pubBytes));
    });
  });

  group('parseNewPubkeyFromSetPrvKeyReply', () {
    test('extracts pubkey hex', () {
      const reply =
          'OK, reboot to apply! New pubkey: '
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      expect(
        parseNewPubkeyFromSetPrvKeyReply(reply),
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );
    });

    test('returns null when missing', () {
      expect(parseNewPubkeyFromSetPrvKeyReply('OK'), isNull);
    });
  });

  group('parseSuccessfulSetPrvKeyReply', () {
    test('accepts firmware success reply', () {
      const pub =
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      expect(
        parseSuccessfulSetPrvKeyReply('OK, reboot to apply! New pubkey: $pub'),
        pub,
      );
    });

    test('rejects missing pubkey and error replies', () {
      expect(parseSuccessfulSetPrvKeyReply('OK'), isNull);
      expect(parseSuccessfulSetPrvKeyReply('Error, bad key'), isNull);
      expect(parseSuccessfulSetPrvKeyReply(''), isNull);
      expect(
        parseSuccessfulSetPrvKeyReply(
          'Error: New pubkey: '
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
        ),
        isNull,
      );
    });
  });

  group('buildSetPrivateKeyCommand', () {
    test('formats command', () {
      final hex = 'ab' * 64;
      expect(buildSetPrivateKeyCommand(hex), 'set prv.key $hex');
    });

    test('rejects bad length', () {
      expect(() => buildSetPrivateKeyCommand('abcd'), throwsArgumentError);
    });
  });

  test('expectedAttemptsForPrefix', () {
    expect(expectedAttemptsForPrefix('A1'), 256);
    expect(expectedAttemptsForPrefix('A1B2'), 65536);
  });
}
