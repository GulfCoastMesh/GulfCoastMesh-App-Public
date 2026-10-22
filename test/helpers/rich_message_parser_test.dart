import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/rich_link_safety.dart';
import 'package:gulf_coast_mesh_app/helpers/rich_message_parser.dart';
import 'package:gulf_coast_mesh_app/models/rich_message.dart';

void main() {
  group('RichMessageParser', () {
    test('tokenizes MeshCore One decorations while preserving source text', () {
      const key =
          '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
      const text =
          'Hi @[Alice] #rescue <$key:1:Field Base> at 37.7749, -122.4194 '
          'https://example.com/x#tag meshcore://channel/add?name=Ops.';
      final parsed = RichMessageParser.parse(text);

      expect(parsed.plainText, text);
      expect(parsed.tokens.map((token) => token.raw).join(), text);
      expect(
        parsed.whereKind(RichMessageTokenKind.mention).single,
        isA<RichMentionToken>(),
      );
      expect(
        parsed.whereKind(RichMessageTokenKind.contactShare).single,
        isA<RichContactShareToken>(),
      );
      expect(
        parsed.whereKind(RichMessageTokenKind.hashtag).single,
        isA<RichHashtagToken>(),
      );
      expect(
        parsed.whereKind(RichMessageTokenKind.coordinate).single,
        isA<RichCoordinateToken>(),
      );
      expect(
        parsed.whereKind(RichMessageTokenKind.url).single,
        isA<RichUrlToken>(),
      );
      expect(
        parsed.whereKind(RichMessageTokenKind.meshcoreUrl).single,
        isA<RichMeshcoreUrlToken>(),
      );
    });

    test('recognizes the reply-with-quote convention before a mention', () {
      final parsed = RichMessageParser.parse('@[Alice]\n>hello worl..\nThanks');
      final quote = parsed.tokens.first as RichReplyQuoteToken;

      expect(quote.mentionName, 'Alice');
      expect(quote.quotedText, 'hello worl..');
      expect(quote.raw, '@[Alice]\n>hello worl..\n');
      expect(parsed.tokens.last.raw, 'Thanks');
    });

    test('builds MeshCore One-compatible reply preview', () {
      expect(
        RichMessageParser.buildReplyText(
          mentionName: 'Alice',
          messageText: '@[Bob] A longer message here',
        ),
        '@[Alice]\n>A longer m..\n',
      );
    });

    test('rejects coordinate lists, versions, and invalid ranges', () {
      expect(
        RichMessageParser.parse('1.0, 2.0, 3.0').containsInteractiveContent,
        isFalse,
      );
      expect(
        RichMessageParser.parse('v1.2, 3.4').containsInteractiveContent,
        isFalse,
      );
      expect(
        RichMessageParser.parse('200.0, 400.0').containsInteractiveContent,
        isFalse,
      );
    });

    test('does not treat hashtags inside links as hashtags', () {
      final parsed = RichMessageParser.parse('https://example.com/#ops #real');
      expect(parsed.whereKind(RichMessageTokenKind.hashtag).length, 1);
      expect(
        (parsed.whereKind(RichMessageTokenKind.hashtag).single
                as RichHashtagToken)
            .hashtag,
        '#real',
      );
    });

    test('contact shares preserve colons in the display name', () {
      const key =
          '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
      final token =
          RichMessageParser.parse('<$key:2:Base:Camp>').tokens.single
              as RichContactShareToken;
      expect(token.publicKeyHex, key);
      expect(token.type, 2);
      expect(token.name, 'Base:Camp');
    });
  });

  group('schemeless URLs', () {
    List<RichUrlToken> urls(String text) => RichMessageParser.parse(
      text,
    ).tokens.whereType<RichUrlToken>().toList(growable: false);

    test('linkifies a bare domain and targets it over https', () {
      final token = urls('check gulfcoastmesh.com for info').single;
      expect(token.raw, 'gulfcoastmesh.com');
      expect(token.uri, Uri.parse('https://gulfcoastmesh.com'));
    });

    test('marks a bare-domain link as inferred, unlike an explicit URL', () {
      expect(urls('check gulfcoastmesh.com for info').single.isInferred, true);
      expect(
        urls('check https://example.com for info').single.isInferred,
        false,
      );
    });

    test('keeps host, port and path of a schemeless link', () {
      final token = urls('port host.io:8080/x').single;
      expect(token.raw, 'host.io:8080/x');
      expect(token.uri, Uri.parse('https://host.io:8080/x'));
    });

    test('drops trailing sentence punctuation', () {
      expect(urls('visit gulfcoastmesh.com.').single.raw, 'gulfcoastmesh.com');
    });

    test('preserves the source text around the link', () {
      const text = 'go to www.example.com now';
      final parsed = RichMessageParser.parse(text);
      expect(parsed.tokens.map((token) => token.raw).join(), text);
    });

    test('does not linkify an email address', () {
      expect(urls('mail me at bob@example.com'), isEmpty);
    });

    test('does not linkify prose that runs a period into a word', () {
      expect(urls('Rcvd.Copy that'), isEmpty);
    });

    test('does not match a known TLD inside a longer label', () {
      expect(urls('ends in example.community okay'), isEmpty);
    });

    test('leaves decimal readings and coordinates alone', () {
      expect(urls('R1: 3.86V (5 nbrs)'), isEmpty);
      expect(urls('coords 29.95, -90.07 here'), isEmpty);
    });

    test('does not double-match the host of a scheme URL', () {
      final token = urls('https://example.com works').single;
      expect(token.raw, 'https://example.com');
    });
  });

  group('RichLinkSafety', () {
    test('allows public HTTP(S) URLs and preserves offline-safe behavior', () {
      expect(
        RichLinkSafety.previewEligibility(
          'https://example.com/a',
          online: true,
        ),
        RichPreviewEligibility.eligible,
      );
      expect(
        RichLinkSafety.previewEligibility(
          'https://example.com/a',
          online: false,
        ),
        RichPreviewEligibility.offline,
      );
    });

    test('rejects credentials, unsupported schemes, and malformed URLs', () {
      expect(
        RichLinkSafety.previewEligibility('https://user:pass@example.com'),
        RichPreviewEligibility.unsafe,
      );
      expect(
        RichLinkSafety.previewEligibility('javascript:alert(1)'),
        RichPreviewEligibility.unsupportedScheme,
      );
      expect(
        RichLinkSafety.previewEligibility('https://'),
        anyOf(RichPreviewEligibility.malformed, RichPreviewEligibility.unsafe),
      );
    });

    test('rejects local, private, loopback, and link-local hosts', () {
      for (final host in [
        'localhost',
        '127.0.0.1',
        '10.0.0.5',
        '172.16.1.1',
        '192.168.1.1',
        '169.254.169.254',
        '::1',
        'fe80::1',
        'fd00::1',
      ]) {
        expect(
          RichLinkSafety.isPrivateOrReservedHost(host),
          isTrue,
          reason: host,
        );
      }
    });
  });
}
