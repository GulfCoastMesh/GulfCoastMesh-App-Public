import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/services/firmware_release_service.dart';

Map<String, dynamic> assetJson(String name, {int size = 1000}) => {
  'name': name,
  'browser_download_url': 'https://example.com/$name',
  'size': size,
};

FirmwareAsset asset(String boardId, OtaChipFamily chip) => FirmwareAsset(
  boardId: boardId,
  chip: chip,
  fileName: '$boardId-firmware',
  downloadUrl: 'https://example.com/$boardId',
  sizeBytes: 1000,
);

void main() {
  group('parseAssets', () {
    const tag = 'repeater-v1.16.0';
    final assetsJson = [
      assetJson('Heltec_v3_repeater-v1.16.0-07a3ca9.bin', size: 111),
      assetJson('Heltec_v3_repeater-v1.16.0-07a3ca9-merged.bin'),
      assetJson('RAK_4631_repeater-v1.16.0-07a3ca9.uf2'),
      assetJson('RAK_4631_repeater-v1.16.0-07a3ca9.zip', size: 222),
      assetJson('PicoW_repeater-v1.16.0-07a3ca9.bin'),
      assetJson('PicoW_repeater-v1.16.0-07a3ca9.uf2'),
      assetJson('wio-e5_repeater-v1.16.0-07a3ca9.bin'),
      assetJson('wio-e5_repeater-v1.16.0-07a3ca9.hex'),
      assetJson('wio_wm1110_repeater-v1.16.0-07a3ca9.uf2'),
      assetJson('Ebyte_EoRa-S3_Repeater-v1.16.0-07a3ca9.bin', size: 333),
      assetJson('Ebyte_EoRa-S3_Repeater-v1.16.0-07a3ca9-merged.bin'),
      assetJson('Xiao_nrf52_room_server-v1.16.0-07a3ca9.uf2'),
      assetJson('Xiao_nrf52_room_server-v1.16.0-07a3ca9.zip', size: 444),
      assetJson('ThinkNode_M2_Repeater-v1.16.0-07a3ca9.bin'),
      assetJson('ThinkNode_M2_Repeater-v1.16.0-07a3ca9-merged.bin'),
    ];

    test('classifies chips, picks OTA files, excludes the rest', () {
      final assets = FirmwareReleaseService.parseAssets(tag, assetsJson);
      final byBoard = {for (final a in assets) a.boardId: a};

      expect(byBoard.keys, [
        'Ebyte_EoRa-S3',
        'Heltec_v3',
        'RAK_4631',
        'ThinkNode_M2',
        'Xiao_nrf52',
      ]);

      final heltec = byBoard['Heltec_v3']!;
      expect(heltec.chip, OtaChipFamily.esp32);
      expect(heltec.fileName, 'Heltec_v3_repeater-v1.16.0-07a3ca9.bin');
      expect(heltec.sizeBytes, 111);

      final rak = byBoard['RAK_4631']!;
      expect(rak.chip, OtaChipFamily.nrf52);
      expect(rak.fileName, 'RAK_4631_repeater-v1.16.0-07a3ca9.zip');
      expect(rak.sizeBytes, 222);

      final ebyte = byBoard['Ebyte_EoRa-S3']!;
      expect(ebyte.chip, OtaChipFamily.esp32);
      expect(ebyte.fileName, 'Ebyte_EoRa-S3_Repeater-v1.16.0-07a3ca9.bin');

      final xiao = byBoard['Xiao_nrf52']!;
      expect(xiao.chip, OtaChipFamily.nrf52);
      expect(xiao.fileName, 'Xiao_nrf52_room_server-v1.16.0-07a3ca9.zip');

      expect(byBoard['ThinkNode_M2']!.chip, OtaChipFamily.esp32);
    });

    test('never includes merged.bin, uf2, or hex assets', () {
      final assets = FirmwareReleaseService.parseAssets(tag, assetsJson);
      for (final a in assets) {
        expect(a.fileName.endsWith('-merged.bin'), isFalse);
        expect(a.fileName.endsWith('.uf2'), isFalse);
        expect(a.fileName.endsWith('.hex'), isFalse);
      }
    });

    test('returns assets sorted by boardId', () {
      final assets = FirmwareReleaseService.parseAssets(tag, assetsJson);
      final ids = [for (final a in assets) a.boardId];
      final sorted = [...ids]..sort();
      expect(ids, sorted);
    });
  });

  group('matchBoardName', () {
    final assets = [
      asset('RAK_4631', OtaChipFamily.nrf52),
      asset('Heltec_v3', OtaChipFamily.esp32),
      asset('Xiao_nrf52', OtaChipFamily.nrf52),
      asset('ProMicro', OtaChipFamily.nrf52),
      asset('Ebyte_EoRa-S3', OtaChipFamily.esp32),
    ];

    test('resolves known board replies via the lookup table', () {
      expect(
        FirmwareReleaseService.matchBoardName('RAK 4631', assets),
        'RAK_4631',
      );
      expect(
        FirmwareReleaseService.matchBoardName('Heltec V3', assets),
        'Heltec_v3',
      );
      expect(
        FirmwareReleaseService.matchBoardName('Seeed Xiao-nrf52', assets),
        'Xiao_nrf52',
      );
      expect(
        FirmwareReleaseService.matchBoardName('ProMicro DIY', assets),
        'ProMicro',
      );
    });

    test('falls back to fuzzy matching for unseen names', () {
      expect(
        FirmwareReleaseService.matchBoardName('Ebyte EoRa S3', assets),
        'Ebyte_EoRa-S3',
      );
    });

    test('returns null for unknown boards', () {
      expect(
        FirmwareReleaseService.matchBoardName('Unknown Board XYZ', assets),
        isNull,
      );
    });
  });

  group('selectMatchingTags', () {
    final tags = [
      'repeater-v1.15.0',
      'repeater-v1.16.0',
      'repeater-v1.9.2',
      'room-server-v1.14.0',
      'companion-v1.16.0',
      'repeater-vNaN',
    ];

    test('returns repeater tags sorted newest first', () {
      expect(
        FirmwareReleaseService.selectMatchingTags(tags, roomServer: false),
        ['repeater-v1.16.0', 'repeater-v1.15.0', 'repeater-v1.9.2'],
      );
    });

    test('returns room-server tags sorted newest first', () {
      expect(
        FirmwareReleaseService.selectMatchingTags(tags, roomServer: true),
        ['room-server-v1.14.0'],
      );
    });
  });

  group('selectLatestTag', () {
    final tags = [
      'repeater-v1.15.0',
      'repeater-v1.16.0',
      'repeater-v1.9.2',
      'room-server-v1.14.0',
      'room-server-v1.13.1',
      'companion-v1.16.0',
      'repeater-vNaN',
    ];

    test('picks highest repeater semver', () {
      expect(
        FirmwareReleaseService.selectLatestTag(tags, roomServer: false),
        'repeater-v1.16.0',
      );
    });

    test('picks highest room-server semver when roomServer is true', () {
      expect(
        FirmwareReleaseService.selectLatestTag(tags, roomServer: true),
        'room-server-v1.14.0',
      );
    });

    test('returns null when nothing matches', () {
      expect(
        FirmwareReleaseService.selectLatestTag([
          'companion-v1.0.0',
        ], roomServer: false),
        isNull,
      );
    });
  });

  group('safeFirmwareFileName', () {
    test('accepts a simple basename', () {
      expect(
        FirmwareReleaseService.safeFirmwareFileName(
          'Heltec_v3_repeater-v1.bin',
        ),
        'Heltec_v3_repeater-v1.bin',
      );
    });

    test('strips directory components', () {
      expect(
        FirmwareReleaseService.safeFirmwareFileName('../../etc/passwd'),
        'passwd',
      );
    });

    test('rejects empty and dot-segment names', () {
      expect(
        () => FirmwareReleaseService.safeFirmwareFileName(''),
        throwsArgumentError,
      );
      expect(
        () => FirmwareReleaseService.safeFirmwareFileName('..'),
        throwsArgumentError,
      );
      expect(
        () => FirmwareReleaseService.safeFirmwareFileName('foo..bar.bin'),
        throwsArgumentError,
      );
    });
  });

  group('md5OfFile', () {
    test('computes hex md5 of file contents', () async {
      final dir = await Directory.systemTemp.createTemp('fw_md5_test');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/sample.bin');
      await file.writeAsString('hello world');
      expect(
        await FirmwareReleaseService.md5OfFile(file),
        '5eb63bbbe01eeed093cb22bb8f5acdc3',
      );
    });
  });
}
