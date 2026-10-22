import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/reaction_helper.dart';

void main() {
  group('MeshCore One reaction protocol', () {
    test('uses the documented SHA-256 little-endian/Crockford hash', () {
      expect(
        ReactionHelper.generateMessageHash('Hello', 1700000000),
        equals('ba6ma8jy'),
      );
      expect(
        ReactionHelper.buildDMReactionText(
          emoji: '👍',
          targetText: 'Hello',
          targetTimestamp: 1700000000,
        ),
        equals('👍\nba6ma8jy'),
      );
    });

    test('builds and parses canonical DM reactions', () {
      final wire = ReactionHelper.buildDMReactionText(
        emoji: '❤️',
        targetText: 'Hello world',
        targetTimestamp: 1234567890,
      );
      final parsed = ReactionHelper.parseDMReaction(wire);

      expect(parsed, isNotNull);
      expect(parsed!.format, ReactionWireFormat.meshCoreOneDm);
      expect(parsed.targetHash, 'wm6wyqv4');
      expect(parsed.emoji, '❤️');
    });

    test('parses canonical Crockford case and substitutions', () {
      final parsed = ReactionHelper.parseDMReaction('👍\nWM6WYQV4');
      expect(parsed, isNotNull);
      expect(parsed!.targetHash, 'wm6wyqv4');

      // O/I/L are accepted as Crockford's conventional aliases.
      final alias = ReactionHelper.parseDMReaction('👍\n0000o1il');
      expect(alias, isNotNull);
      expect(alias!.targetHash, '00000111');
    });

    test('builds and parses canonical channel reactions', () {
      final wire = ReactionHelper.buildReactionText(
        emoji: '🎉',
        targetSender: 'AlphaNode',
        targetText: 'Hello',
        targetTimestamp: 1700000000,
      );
      final parsed = ReactionHelper.parseChannelReaction(wire);

      expect(parsed, isNotNull);
      expect(parsed!.format, ReactionWireFormat.meshCoreOneChannel);
      expect(parsed.targetSender, 'AlphaNode');
      expect(parsed.targetHash, 'ba6ma8jy');
    });

    test('retains v3 parsing and rejects uppercase v3 wire fields', () {
      final parsed = ReactionHelper.parseV3Reaction('r:a1b2:00');
      expect(parsed, isNotNull);
      expect(parsed!.format, ReactionWireFormat.gulfCoastMeshAppV3);
      expect(parsed.targetHash, 'a1b2');
      expect(parsed.emoji, '👍');
      expect(ReactionHelper.parseV3Reaction('r:A1B2:00'), isNull);
      expect(ReactionHelper.parseV3Reaction('r:a1b2:0A'), isNull);
    });

    test('parses legacy v1 millisecond and Dart hash fields', () {
      final wire = 'r:1700000000500_12345_67890:👍';
      final parsed = ReactionHelper.parseV1Reaction(wire);

      expect(parsed, isNotNull);
      expect(parsed!.format, ReactionWireFormat.gulfCoastMeshAppV1);
      expect(parsed.timestampSeconds, 1700000000);
      expect(parsed.senderNameHash, 12345);
      expect(parsed.textHash, 67890);
      expect(parsed.targetHash, '1700000000500_12345_67890');
    });

    test('Dart compatibility hashes UTF-16 code units, not code points', () {
      expect(ReactionHelper.dartStringHashCodeUnits(const []), 1);
      final one = ReactionHelper.computeReactionHash(1700000000, null, '😀a');
      final two = ReactionHelper.computeReactionHash(1700000000, null, '😀b');
      expect(one, isNot(two));
      expect(
        ReactionHelper.dartStringHash('😀'),
        equals(ReactionHelper.dartStringHashCodeUnits('😀'.codeUnits)),
      );
    });

    test('parseReaction recognizes every supported receive format', () {
      expect(
        ReactionHelper.parseReaction('r:a1b2:00')!.format,
        ReactionWireFormat.gulfCoastMeshAppV3,
      );
      expect(
        ReactionHelper.parseReaction('👍\nba6ma8jy')!.format,
        ReactionWireFormat.meshCoreOneDm,
      );
      expect(
        ReactionHelper.parseReaction('r:1700000000000_1_2:👍')!.format,
        ReactionWireFormat.gulfCoastMeshAppV1,
      );
    });
  });
}
