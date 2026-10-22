import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/atak_channel_helper.dart';
import 'package:gulf_coast_mesh_app/helpers/channel_slot_helper.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';

Channel _channel(int index, String name, {String? pskHex}) {
  return Channel(
    index: index,
    name: name,
    psk: pskHex != null
        ? Channel.parsePskHex(pskHex)
        : Uint8List.fromList(List<int>.filled(16, 1)),
  );
}

Channel _publicChannel(int index) {
  return _channel(index, 'Public', pskHex: Channel.publicChannelPsk);
}

void main() {
  group('normalizeHashtagChannelName', () {
    test('normalizes case and leading hash', () {
      expect(normalizeHashtagChannelName('#MyTeam'), '#myteam');
      expect(normalizeHashtagChannelName('myteam'), '#myteam');
      expect(normalizeHashtagChannelName('  #ATAK  '), '#atak');
    });

    test('returns empty for blank input', () {
      expect(normalizeHashtagChannelName(''), '');
      expect(normalizeHashtagChannelName('   '), '');
      expect(normalizeHashtagChannelName('#'), '');
    });
  });

  group('isAtakChannelName', () {
    test('matches atak and #atak case-insensitively', () {
      expect(isAtakChannelName('atak'), isTrue);
      expect(isAtakChannelName('#atak'), isTrue);
      expect(isAtakChannelName('ATAK'), isTrue);
      expect(isAtakChannelName('#ATAK'), isTrue);
    });

    test('rejects other names', () {
      expect(isAtakChannelName('Public'), isFalse);
      expect(isAtakChannelName('#mesh'), isFalse);
      expect(isAtakChannelName(''), isFalse);
    });
  });

  group('isAtakEligibleChannel', () {
    test('accepts non-empty hashtag channels', () {
      expect(isAtakEligibleChannel(_channel(1, '#atak')), isTrue);
    });

    test('rejects empty and public channels', () {
      expect(isAtakEligibleChannel(Channel.empty(0)), isFalse);
      expect(isAtakEligibleChannel(_publicChannel(1)), isFalse);
    });
  });

  group('findHashtagChannel', () {
    test('matches by normalized hashtag name', () {
      final channels = [
        _channel(0, 'Public'),
        _channel(1, '#MyTeam'),
        _channel(2, '#atak'),
      ];
      expect(findHashtagChannel(channels, 'myteam')?.index, 1);
      expect(findHashtagChannel(channels, '#ATAK')?.index, 2);
    });

    test('returns null when no match exists', () {
      expect(findHashtagChannel([_channel(0, '#atak')], 'missing'), isNull);
    });
  });

  group('findAtakChannel', () {
    test('returns first matching non-empty channel', () {
      final channels = [
        Channel.empty(0),
        _channel(1, 'Public'),
        _channel(2, '#atak'),
      ];
      expect(findAtakChannel(channels)?.index, 2);
    });

    test('returns null when no ATAK channel exists', () {
      final channels = [_channel(0, 'Public')];
      expect(findAtakChannel(channels), isNull);
    });
  });

  group('resolveSelectedChannel', () {
    final channels = [_channel(0, 'Public'), _channel(1, '#atak')];

    test('resolves by index when name matches', () {
      final resolved = resolveSelectedChannel(
        channels,
        index: 1,
        name: '#atak',
      );
      expect(resolved?.index, 1);
    });

    test('falls back to name when index mismatches', () {
      final resolved = resolveSelectedChannel(
        channels,
        index: 0,
        name: '#atak',
      );
      expect(resolved?.index, 1);
    });

    test('returns null when nothing matches', () {
      expect(
        resolveSelectedChannel(channels, index: 5, name: 'missing'),
        isNull,
      );
    });
  });

  group('resolveAtakChannel', () {
    final channels = [
      _publicChannel(0),
      _channel(1, '#atak'),
      _channel(2, '#myteam'),
    ];

    test('returns eligible selected channel', () {
      final resolved = resolveAtakChannel(channels, index: 2, name: '#myteam');
      expect(resolved?.index, 2);
    });

    test('returns null for public channel selection', () {
      final resolved = resolveAtakChannel(channels, index: 0, name: 'Public');
      expect(resolved, isNull);
    });
  });

  group('firstAvailableChannelIndex', () {
    test('returns first unused slot', () {
      final channels = [_channel(0, 'A'), _channel(2, 'C')];
      expect(firstAvailableChannelIndex(channels, 4), 1);
    });

    test('returns null when all slots are used', () {
      final channels = [_channel(0, 'A'), _channel(1, 'B')];
      expect(firstAvailableChannelIndex(channels, 2), isNull);
    });
  });

  group('isStoredPublicAtakSelection', () {
    test('detects saved Public channel selection', () {
      expect(isStoredPublicAtakSelection('Public'), isTrue);
      expect(isStoredPublicAtakSelection('#atak'), isFalse);
    });
  });
}
