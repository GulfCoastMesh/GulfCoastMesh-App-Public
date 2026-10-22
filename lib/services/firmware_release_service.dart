import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

enum OtaChipFamily { esp32, nrf52 }

class FirmwareAsset {
  final String boardId;
  final OtaChipFamily chip;
  final String fileName;
  final String downloadUrl;
  final int sizeBytes;

  const FirmwareAsset({
    required this.boardId,
    required this.chip,
    required this.fileName,
    required this.downloadUrl,
    required this.sizeBytes,
  });
}

class FirmwareRelease {
  final String tag;
  final String version;
  final List<FirmwareAsset> assets;

  const FirmwareRelease({
    required this.tag,
    required this.version,
    required this.assets,
  });
}

class FirmwareReleaseService {
  FirmwareReleaseService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _releasesUrl =
      'https://api.github.com/repos/meshcore-dev/MeshCore/releases?per_page=30';
  static const _releasesCacheTtl = Duration(minutes: 5);
  static const _metadataRequestTimeout = Duration(seconds: 15);
  static const _downloadIdleTimeout = Duration(seconds: 30);

  List<Map<String, dynamic>>? _releasesJsonCache;
  DateTime? _releasesJsonFetchedAt;

  /// Firmware getManufacturerName() reply → release asset filename prefix.
  static const Map<String, String> boardNameTable = {
    'RAK 4631': 'RAK_4631',
    'RAK 3401': 'RAK_3401',
    'RAK 3112': 'RAK_3112',
    'RAK 3x72': 'RAK_3x72',
    'RAK 11310': 'RAK_11310',
    'RAK WisMesh Tag': 'RAK_WisMesh_Tag',
    'Heltec V2': 'Heltec_v2',
    'Heltec V3': 'Heltec_v3',
    'Heltec V4': 'heltec_v4',
    'Heltec V4 TFT': 'heltec_v4_tft',
    'Heltec V4.3 TFT': 'heltec_v4_tft',
    'Heltec CT62': 'Heltec_ct62',
    'Heltec E213': 'Heltec_E213',
    'Heltec E290': 'Heltec_E290',
    'Heltec Mesh Solar': 'Heltec_mesh_solar',
    'Heltec T096': 'Heltec_t096',
    'Heltec T1': 'Heltec_t1',
    'Heltec T114': 'Heltec_t114',
    'Heltec Tracker V2': 'heltec_tracker_v2',
    'Heltec Wireless Paper': 'Heltec_Wireless_Paper',
    'Heltec MeshPocket': 'Mesh_pocket',
    'Seeed Xiao-nrf52': 'Xiao_nrf52',
    'Xiao S3': 'Xiao_S3',
    'Xiao S3 WIO': 'Xiao_S3_WIO',
    'Xiao C3': 'Xiao_C3',
    'Xiao RP2040': 'Xiao_rp2040',
    'Seeed Wio WM1110': 'wio_wm1110',
    'Seeed Wio Tracker L1': 'WioTrackerL1',
    'Seeed Wio E5 mini': 'wio-e5-mini',
    'Seeed Wio E5 Dev Board': 'wio-e5',
    'Seeed Tracker T1000-E': 't1000e',
    'Seeed SenseCap Solar': 'SenseCap_Solar',
    'Elecrow ThinkNode-M1': 'ThinkNode_M1',
    'Elecrow ThinkNode M2': 'ThinkNode_M2',
    'Elecrow ThinkNode M3': 'ThinkNode_M3',
    'Elecrow ThinkNode M5': 'ThinkNode_M5',
    'Elecrow ThinkNode M6': 'ThinkNode_M6',
    'ProMicro DIY': 'ProMicro',
    'Pico W': 'PicoW',
    'Waveshare RP2040-LoRa': 'waveshare_rp2040_lora',
    'Tiny Relay': 'Tiny_Relay',
    'Station G2': 'Station_G2',
    'Station G3 ESP32': 'Station_G3_ESP32',
    'Nano G2 Ultra': 'Nano_G2_Ultra',
    'muzi works R1 Neo': 'R1Neo',
    'Minewsemi': 'Minewsemi_me25ls01',
    'Keepteen LT1': 'KeepteenLT1',
    'LILYGO T-LoRa V2.1-1.6': 'LilyGo_TLora_V2_1_1_6',
    'LilyGO T-ETH Elite': 'LilyGo_TETH_Elite_sx1262',
    'LilyGo T-Echo': 'LilyGo_T-Echo',
    'LilyGo T-Echo Lite': 'LilyGo_T-Echo-Lite',
    'LilyGo T-Echo Card': 'LilyGo_T-Echo_Card',
    'LilyGo T-Deck': 'LilyGo_TDeck',
    'LilyGo T-Beam 1W': 'LilyGo_TBeam_1W',
    'LilyGo T-Impulse-Plus': 'LilyGo_T_Impulse_Plus',
    'GAT562 Mesh Tracker Pro': 'GAT562_Mesh_Tracker_Pro',
    'GAT562 EVB Pro': 'GAT562_Mesh_EVB_Pro',
    'GAT562 30S Mesh Kit': 'GAT562_30S_Mesh_Kit',
    'Unit C6L': 'M5Stack_Unit_C6L',
    'Ikoka Handheld E22 30dBm (Xiao_nrf52)': 'ikoka_handheld_nrf_e22_30dbm',
  };

  Future<List<FirmwareRelease>> fetchReleases({
    required bool roomServer,
  }) async {
    final releasesJson = await _fetchReleasesJson();
    final prefix = roomServer ? 'room-server-v' : 'repeater-';
    final tags = selectMatchingTags([
      for (final release in releasesJson)
        if (release['tag_name'] is String) release['tag_name'] as String,
    ], roomServer: roomServer);
    if (tags.isEmpty) {
      throw const HttpException('No matching firmware release found');
    }
    return [
      for (final tag in tags)
        _releaseFromJson(
          releasesJson.firstWhere((r) => r['tag_name'] == tag),
          prefix: prefix,
        ),
    ];
  }

  Future<FirmwareRelease> fetchLatestRelease({required bool roomServer}) async {
    final releases = await fetchReleases(roomServer: roomServer);
    return releases.first;
  }

  Future<List<Map<String, dynamic>>> _fetchReleasesJson() async {
    final now = DateTime.now();
    final cachedAt = _releasesJsonFetchedAt;
    final cached = _releasesJsonCache;
    if (cached != null &&
        cachedAt != null &&
        now.difference(cachedAt) < _releasesCacheTtl) {
      return cached;
    }

    final uri = Uri.parse(_releasesUrl);
    final response = await _client
        .get(uri, headers: {'Accept': 'application/vnd.github+json'})
        .timeout(_metadataRequestTimeout);
    if (response.statusCode != 200) {
      throw HttpException(
        'GitHub releases request failed (HTTP ${response.statusCode})',
        uri: uri,
      );
    }
    final releases = (jsonDecode(response.body) as List)
        .cast<Map<String, dynamic>>();
    _releasesJsonCache = releases;
    _releasesJsonFetchedAt = now;
    return releases;
  }

  @visibleForTesting
  void clearReleasesCache() {
    _releasesJsonCache = null;
    _releasesJsonFetchedAt = null;
  }

  static String safeFirmwareFileName(String fileName) {
    final baseName = fileName.split(RegExp(r'[/\\]')).last;
    if (baseName.isEmpty ||
        baseName == '.' ||
        baseName == '..' ||
        baseName.contains('..')) {
      throw ArgumentError('Invalid firmware file name: $fileName');
    }
    return baseName;
  }

  FirmwareRelease _releaseFromJson(
    Map<String, dynamic> release, {
    required String prefix,
  }) {
    final tag = release['tag_name'] as String;
    final assetsJson = ((release['assets'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    return FirmwareRelease(
      tag: tag,
      version: tag.substring(prefix.length),
      assets: parseAssets(tag, assetsJson),
    );
  }

  @visibleForTesting
  static List<String> selectMatchingTags(
    List<String> tags, {
    required bool roomServer,
  }) {
    final prefix = roomServer ? 'room-server-v' : 'repeater-v';
    final matching = [
      for (final tag in tags)
        if (tag.startsWith(prefix) &&
            _parseSemver(tag.substring(prefix.length)) != null)
          tag,
    ];
    matching.sort((a, b) {
      final va = _parseSemver(a.substring(prefix.length))!;
      final vb = _parseSemver(b.substring(prefix.length))!;
      return -_compareSemver(va, vb);
    });
    return matching;
  }

  @visibleForTesting
  static String? selectLatestTag(
    List<String> tags, {
    required bool roomServer,
  }) {
    final matching = selectMatchingTags(tags, roomServer: roomServer);
    return matching.isEmpty ? null : matching.first;
  }

  static List<int>? _parseSemver(String version) {
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(version);
    if (match == null) return null;
    return [for (var i = 1; i <= 3; i++) int.parse(match.group(i)!)];
  }

  static int _compareSemver(List<int> a, List<int> b) {
    for (var i = 0; i < 3; i++) {
      if (a[i] != b[i]) return a[i].compareTo(b[i]);
    }
    return 0;
  }

  static List<FirmwareAsset> parseAssets(
    String tag,
    List<Map<String, dynamic>> assetsJson,
  ) {
    final roleRe = RegExp(
      r'^(.+?)_(repeater|room_server)-v',
      caseSensitive: false,
    );
    final byBoard = <String, List<Map<String, dynamic>>>{};
    for (final json in assetsJson) {
      final name = json['name'] as String? ?? '';
      final match = roleRe.firstMatch(name);
      if (match == null) continue;
      byBoard.putIfAbsent(match.group(1)!, () => []).add(json);
    }

    final result = <FirmwareAsset>[];
    for (final entry in byBoard.entries) {
      Map<String, dynamic>? zip;
      Map<String, dynamic>? plainBin;
      var hasMergedBin = false;
      for (final json in entry.value) {
        final name = json['name'] as String;
        if (name.endsWith('.zip')) {
          zip = json;
        } else if (name.endsWith('-merged.bin')) {
          hasMergedBin = true;
        } else if (name.endsWith('.bin')) {
          plainBin = json;
        }
      }
      Map<String, dynamic>? otaJson;
      OtaChipFamily? chip;
      if (zip != null) {
        otaJson = zip;
        chip = OtaChipFamily.nrf52;
      } else if (plainBin != null && hasMergedBin) {
        otaJson = plainBin;
        chip = OtaChipFamily.esp32;
      }
      if (otaJson == null || chip == null) continue;
      result.add(
        FirmwareAsset(
          boardId: entry.key,
          chip: chip,
          fileName: otaJson['name'] as String,
          downloadUrl: otaJson['browser_download_url'] as String,
          sizeBytes: (otaJson['size'] as num?)?.toInt() ?? 0,
        ),
      );
    }
    result.sort((a, b) => a.boardId.compareTo(b.boardId));
    return result;
  }

  static String? matchBoardName(String boardReply, List<FirmwareAsset> assets) {
    final normalizedReply = _normalize(boardReply);
    if (normalizedReply.isEmpty) return null;

    for (final entry in boardNameTable.entries) {
      if (_normalize(entry.key) != normalizedReply) continue;
      for (final asset in assets) {
        if (asset.boardId == entry.value) return asset.boardId;
      }
      return null;
    }

    final candidates = <FirmwareAsset>[];
    for (final asset in assets) {
      final normalizedBoard = _normalize(asset.boardId);
      if (normalizedBoard.isEmpty) continue;
      if (normalizedBoard == normalizedReply) return asset.boardId;
      if (normalizedBoard.contains(normalizedReply) ||
          normalizedReply.contains(normalizedBoard)) {
        candidates.add(asset);
      }
    }
    if (candidates.isEmpty) return null;
    candidates.sort(
      (a, b) =>
          _normalize(b.boardId).length.compareTo(_normalize(a.boardId).length),
    );
    if (candidates.length > 1 &&
        _normalize(candidates[0].boardId).length ==
            _normalize(candidates[1].boardId).length) {
      return null;
    }
    return candidates.first.boardId;
  }

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  Future<File> downloadAsset(
    FirmwareAsset asset, {
    required void Function(int received, int total) onProgress,
    File? target,
  }) async {
    final safeName = safeFirmwareFileName(asset.fileName);
    final file =
        target ?? File('${(await getTemporaryDirectory()).path}/$safeName');
    final request = http.Request('GET', Uri.parse(asset.downloadUrl));
    final response = await _client
        .send(request)
        .timeout(_metadataRequestTimeout);
    if (response.statusCode != 200) {
      throw HttpException(
        'Firmware download failed (HTTP ${response.statusCode})',
        uri: request.url,
      );
    }
    final total = response.contentLength ?? asset.sizeBytes;
    final sink = file.openWrite();
    var received = 0;
    try {
      // Use an idle timeout on the chunk stream so a stalled CDN does not
      // hang the OTA wizard indefinitely.
      final stream = response.stream.timeout(_downloadIdleTimeout);
      await for (final chunk in stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress(received, total);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
    return file;
  }

  void dispose() {
    _client.close();
  }

  static Future<String> md5OfFile(File file) async {
    final digest = await md5.bind(file.openRead()).first;
    return digest.toString();
  }
}
