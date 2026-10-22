import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/retired_media_message.dart';

void main() {
  test('identifies retired voice, image, PDF, and local-audio messages', () {
    for (final text in ['VE3:abc', 'IE4:abc', 'PE1:abc', '!AUDIO:/tmp/a.m4a']) {
      expect(isRetiredMediaMessage(text), isTrue);
    }
    expect(isRetiredMediaMessage('ordinary text'), isFalse);
    expect(isRetiredMediaMessage('g:gif-id'), isFalse);
  });
}
