import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/helpers/contact_advert_uri.dart';

void main() {
  group('ContactAdvertUri', () {
    test('accepts a valid contact advert URI', () {
      final hex = 'ab' * 98; // 196 hex chars = 98-byte advert
      expect(ContactAdvertUri.isContactAdvert('meshcore://$hex'), isTrue);
      expect(ContactAdvertUri.contactHexFromUri('meshcore://$hex'), hex);
    });

    test('accepts longer adverts (200+ hex chars)', () {
      final hex = 'cd' * 200;
      expect(ContactAdvertUri.isContactAdvert('meshcore://$hex'), isTrue);
      expect(ContactAdvertUri.contactHexFromUri('meshcore://$hex'), hex);
    });

    test('rejects a missing meshcore:// prefix', () {
      expect(ContactAdvertUri.isContactAdvert('ab' * 98), isFalse);
      expect(ContactAdvertUri.contactHexFromUri('ab' * 98), isNull);
    });

    test('rejects empty hex payload', () {
      expect(ContactAdvertUri.isContactAdvert('meshcore://'), isFalse);
      expect(ContactAdvertUri.contactHexFromUri('meshcore://'), isNull);
    });

    test('rejects odd-length hex payload', () {
      expect(ContactAdvertUri.isContactAdvert('meshcore://abc'), isFalse);
      expect(ContactAdvertUri.contactHexFromUri('meshcore://abc'), isNull);
    });

    test('rejects non-hex characters', () {
      expect(ContactAdvertUri.isContactAdvert('meshcore://zz'), isFalse);
      expect(ContactAdvertUri.contactHexFromUri('meshcore://zz'), isNull);
    });

    test('trims surrounding whitespace', () {
      final hex = 'ab' * 98;
      expect(ContactAdvertUri.contactHexFromUri('  meshcore://$hex  '), hex);
    });

    test('a channel invite URI is not a contact advert', () {
      expect(
        ContactAdvertUri.isContactAdvert(
          'meshcore://channel/add?name=x&secret=${'ab' * 16}',
        ),
        isFalse,
      );
    });

    test('import frame round-trips the parsed hex payload', () {
      final hex = 'ab' * 98;
      final frame = buildImportContactFrame(
        ContactAdvertUri.contactHexFromUri('meshcore://$hex')!,
      );
      expect(frame.first, cmdImportContact);
      expect(frame.length, 1 + 98);
    });
  });
}
