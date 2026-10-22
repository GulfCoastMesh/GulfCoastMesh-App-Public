import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gulf_coast_mesh_app/services/rich_link_preview_service.dart';

void main() {
  test('fetches and caches safe HTML metadata', () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response(
        '<html><head><title>Fallback</title>'
        '<meta property="og:title" content="Rescue &amp; Ops">'
        '<meta name="description" content="A field update"></head></html>',
        200,
        headers: const {'content-type': 'text/html; charset=utf-8'},
      );
    });
    final service = RichLinkPreviewService(client: client);
    final uri = Uri.parse('https://example.com/update');

    final first = await service.fetch(uri);
    final second = await service.fetch(uri);

    expect(first?.title, 'Rescue & Ops');
    expect(first?.description, 'A field update');
    expect(first?.contentKind, RichRemoteContentKind.webpage);
    expect(second?.title, first?.title);
    expect(requests, 1);
    service.close();
  });

  test(
    'classifies image responses and relative preview images safely',
    () async {
      final imageClient = MockClient((request) async {
        return http.Response.bytes(
          <int>[1, 2, 3],
          200,
          headers: const {'content-type': 'image/avif'},
        );
      });
      final imageService = RichLinkPreviewService(client: imageClient);
      final imageUri = Uri.parse('https://example.com/photo');
      final image = await imageService.fetch(imageUri);
      expect(image?.isInlineImage, isTrue);
      expect(image?.imageUri, imageUri);
      imageService.close();

      expect(
        RichLinkPreviewService.classifyRemoteContent(
          Uri.parse('https://example.com/photo.png'),
        ),
        RichRemoteContentKind.image,
      );
    },
  );

  test('does not request disabled, offline, or private links', () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response('unexpected', 200);
    });
    final service = RichLinkPreviewService(client: client);

    expect(
      await service.fetch(
        Uri.parse('https://example.com/disabled'),
        enabledOverride: false,
      ),
      isNull,
    );
    expect(
      await service.fetch(
        Uri.parse('https://example.com/offline'),
        onlineOverride: false,
      ),
      isNull,
    );
    expect(await service.fetch(Uri.parse('http://127.0.0.1/secret')), isNull);
    expect(requests, 0);
    service.close();
  });

  test('returns cached metadata while offline without fetching', () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response('<title>Cached</title>', 200);
    });
    final store = InMemoryRichPreviewStore();
    final service = RichLinkPreviewService(client: client, store: store);
    final uri = Uri.parse('https://example.com/cached');
    await service.fetch(uri);
    final cached = await service.fetch(uri, onlineOverride: false);

    expect(cached?.title, 'Cached');
    expect(requests, 1);
    service.close();
  });
}
