import 'dart:convert';
import 'dart:typed_data';

import 'package:gulf_coast_mesh_app/helpers/weather_api2_codec.dart';

// API_V2.md and Python reference encoder, response_id=010203.
const weatherVector = '~W2IQECA7vJ0nDq0QU2-w5GlpRDzCKzGHntGYBsIFPEvoKJAQiwUmoA';
const forecastRadarVector = '~W2KAECA2NUYGbQK5f7X3KHK0tiKUOWRMeDjmO_RhEJiA0A';
// Python random.Random(42), 812 randrange(8) cells; uncompressible.
const observedRadarVectors = [
  '~W2SAECAwAEACAAAC53Hv903ApqGKUAAAAAAAE3JQayYd4JudSaOC3xOOyCMYv5qh2j6eaKoWbW3Rc12p0eRHLsE2FD66DCqUKPlMOSR7roje6fLcWGYEEzfvruJa59BG62XRa_PEAm',
  '~W2SAECAwEE_zNkmKevcUCBC1EyZ4jLdbT4Bk9GNSt1ghETket4IiZQUTcSobLAoltqTTJUj4rx7eWGuQzrIhQRt45HGKvThnRNzRYNcu7_XWEzbgL23PM9IZ6O5Xrv6-f48eHYRpq1',
  '~W2SAECAwIE2L0xGz5Kex99uNYFI9YFuntrmjnQBdig6dlZRQxoLwuDuin8uJfF3-zC7y5efWVJLPP3H-E89nV7kssabSczriJEgHrA_xX4xA8kZvH800Q2RlME_8TIZ5wzUYHI5zT_',
  '~W2SAECAwMEwCUyEPopP6_bqD6Np2yMG-uPUfyDiXCWRyf97_IUugR5_a0P',
];

String armor(List<int> bytes) =>
    '~W2${base64Url.encode(bytes).replaceAll('=', '')}';
String positional(int type, List<Object?> slots) =>
    armor([type, 1, 2, 3, ...utf8.encode(jsonEncode(slots))]);
String withResponseId(String text, int id) {
  final bytes = base64Url.decode(base64Url.normalize(text.substring(3)));
  bytes[3] = id;
  return armor(bytes);
}

Map<String, dynamic> decodeFrames(List<String> frames) {
  final group = WeatherApi2Group(WeatherApi2Frame(frames.first));
  Map<String, dynamic>? result;
  for (final frame in frames) {
    result = group.add(WeatherApi2Frame(frame));
  }
  return result!;
}

Uint8List radarPayload(int width) {
  final count = width == 28 ? 616 : 812;
  final bytes = Uint8List(19 + (count * 3 + 7) ~/ 8);
  bytes[1] = width;
  final view = ByteData.sublistView(bytes);
  view.setInt32(3, 3045150);
  view.setInt32(7, -9118710);
  view.setUint32(11, 1780000000);
  return bytes;
}
