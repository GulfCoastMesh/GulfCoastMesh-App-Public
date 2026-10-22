import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';

void main() {
  test('builds SAR developer channel datagram in MeshCore wire order', () {
    final frame = buildSendChannelDataFrame(
      channelIndex: 3,
      dataType: dataTypeDev,
      payload: Uint8List.fromList([0x56, 1, 2]),
    );
    expect(frame, [cmdSendChannelData, 3, 0xff, 0xff, 0xff, 0x56, 1, 2]);
  });

  test('parses channel datagrams and clamps malformed declared length', () {
    final parsed = ChannelDataFrame.tryParse(
      Uint8List.fromList([
        respCodeChannelDataReceived,
        8, // SNR = 2.0
        0,
        0,
        3,
        0xff,
        0xff,
        0xff,
        5, // declares five, only two follow
        0x49,
        0x01,
      ]),
    );
    expect(parsed, isNotNull);
    expect(parsed!.snr, 2.0);
    expect(parsed.channelIndex, 3);
    expect(parsed.dataType, dataTypeDev);
    expect(parsed.payload, [0x49, 0x01]);
  });

  test('rejects path bytes supplied for a flood datagram', () {
    expect(
      () => buildSendChannelDataFrame(
        channelIndex: 0,
        dataType: dataTypeDev,
        payload: Uint8List.fromList([1]),
        pathBytes: Uint8List.fromList([1]),
      ),
      throwsArgumentError,
    );
  });
}
