import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';

void main() {
  test('BufferReader rejects negative reads and skips without moving', () {
    final reader = BufferReader(Uint8List.fromList([1, 2, 3]));

    expect(() => reader.readBytes(-1), throwsRangeError);
    expect(() => reader.skipBytes(-1), throwsRangeError);
    expect(reader.readRemainingBytes(), Uint8List.fromList([1, 2, 3]));
  });

  test('channel names are truncated without splitting UTF-8 code points', () {
    final prefix = List.filled(29, 'a').join();
    final frame = buildSetChannelFrame(
      1,
      '$prefix😀',
      Uint8List.fromList(List<int>.filled(16, 1)),
    );
    final nameBytes = frame.sublist(2, 34);
    final terminator = nameBytes.indexOf(0);

    expect(terminator, 29);
    expect(utf8.decode(nameBytes.sublist(0, terminator)), prefix);
  });

  test('channel names retain multibyte code points that fully fit', () {
    final prefix = List.filled(27, 'a').join();
    final frame = buildSetChannelFrame(
      1,
      '$prefix😀',
      Uint8List.fromList(List<int>.filled(16, 1)),
    );
    final nameBytes = frame.sublist(2, 34);
    final terminator = nameBytes.indexOf(0);

    expect(terminator, 31);
    expect(utf8.decode(nameBytes.sublist(0, terminator)), '$prefix😀');
  });

  test('advert names are truncated without invalid UTF-8', () {
    final prefix = List.filled(29, 'a').join();
    final frame = buildSetAdvertNameFrame('$prefix😀');

    expect(frame.first, cmdSetAdvertName);
    expect(utf8.decode(frame.sublist(1)), prefix);
  });
}
