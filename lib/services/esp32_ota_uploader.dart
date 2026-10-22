import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:plugin_wifi_connect/plugin_wifi_connect.dart';

/// Uploads firmware to an ESP32 repeater running the MeshCore OTA web server
/// (AsyncElegantOTA on the `MeshCore-OTA` access point).
class Esp32OtaUploader {
  static const otaSsid = 'MeshCore-OTA';

  /// Prompts the system WiFi-join dialog for the open MeshCore-OTA network.
  /// Returns true when the phone joined (and on Android the process is bound
  /// to that network so HTTP reaches 192.168.4.1).
  Future<bool> joinOtaWifi() async {
    try {
      final connected = await PluginWifiConnect.connect(
        otaSsid,
        saveNetwork: false,
      );
      return connected ?? false;
    } on Exception {
      return false;
    }
  }

  Future<void> leaveOtaWifi() async {
    try {
      await PluginWifiConnect.disconnect();
    } on Exception {
      // Best effort; the network drops when the device reboots anyway.
    }
  }

  /// Checks that the OTA web server answers at the update URL's host.
  Future<bool> probe(Uri updateUrl, {void Function(String)? onLog}) async {
    final root = updateUrl.replace(path: '/');
    try {
      final response = await http.get(root).timeout(const Duration(seconds: 6));
      onLog?.call('Probe ${root.toString()}: HTTP ${response.statusCode}');
      return response.statusCode == 200;
    } on Exception catch (e) {
      onLog?.call('Probe failed: $e');
      return false;
    }
  }

  /// Uploads the non-merged .bin via multipart POST (fields `MD5` and
  /// `firmware`) with upload progress. Returns the server response body.
  /// The device reboots into the new firmware once it replies OK.
  ///
  /// MD5 is an integrity check only (AsyncElegantOTA convention). It does not
  /// authenticate the firmware over the open MeshCore-OTA Wi-Fi access point.
  Future<String> upload({
    required Uri updateUrl,
    required File firmware,
    required String md5Hex,
    required void Function(int sent, int total) onProgress,
    void Function(String)? onLog,
  }) async {
    final bytes = await firmware.readAsBytes();
    final boundary = '----MeshCoreOta${DateTime.now().millisecondsSinceEpoch}';

    final header = utf8.encode(
      '--$boundary\r\n'
      'Content-Disposition: form-data; name="MD5"\r\n\r\n'
      '$md5Hex\r\n'
      '--$boundary\r\n'
      'Content-Disposition: form-data; name="firmware"; '
      'filename="${firmware.uri.pathSegments.last}"\r\n'
      'Content-Type: application/octet-stream\r\n\r\n',
    );
    final footer = utf8.encode('\r\n--$boundary--\r\n');
    final total = header.length + bytes.length + footer.length;

    final request = http.StreamedRequest('POST', updateUrl)
      ..headers['Content-Type'] = 'multipart/form-data; boundary=$boundary'
      ..headers['Content-Length'] = '$total'
      ..contentLength = total;

    onLog?.call('POST $updateUrl ($total bytes, MD5 $md5Hex)');

    var uploadFinished = false;
    final uploadDone = Completer<void>();
    unawaited(() async {
      try {
        var sent = 0;
        void add(List<int> chunk) {
          request.sink.add(chunk);
          sent += chunk.length;
          onProgress(sent, total);
        }

        add(header);
        const chunkSize = 8192;
        for (var offset = 0; offset < bytes.length; offset += chunkSize) {
          add(bytes.sublist(offset, min(offset + chunkSize, bytes.length)));
          await Future<void>.delayed(Duration.zero);
        }
        add(footer);
        await request.sink.close();
        uploadFinished = true;
      } finally {
        if (!uploadDone.isCompleted) uploadDone.complete();
      }
    }());

    final client = http.Client();
    try {
      try {
        final streamed = await client
            .send(request)
            .timeout(const Duration(minutes: 5));
        await uploadDone.future;
        uploadFinished = true;

        try {
          final response = await http.Response.fromStream(
            streamed,
          ).timeout(const Duration(seconds: 15));
          onLog?.call(
            'Upload response: HTTP ${response.statusCode} ${response.body}',
          );
          if (response.statusCode != 200) {
            onLog?.call(
              'Non-200 response after full upload — device likely rebooting',
            );
          }
          return response.body;
        } on Exception catch (e) {
          if (_isExpectedRebootDisconnect(e)) {
            onLog?.call('Device rebooting after upload (no HTTP response): $e');
            return '';
          }
          rethrow;
        }
      } on Exception catch (e) {
        await uploadDone.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {},
        );
        if (uploadFinished && _isExpectedRebootDisconnect(e)) {
          onLog?.call(
            'Disconnect after upload completed (device rebooting): $e',
          );
          return '';
        }
        rethrow;
      }
    } finally {
      client.close();
    }
  }

  static bool _isExpectedRebootDisconnect(Object error) {
    if (error is SocketException) return true;
    final message = error.toString().toLowerCase();
    return message.contains('connection reset') ||
        message.contains('connection closed') ||
        message.contains('broken pipe') ||
        message.contains('connection abort');
  }
}
