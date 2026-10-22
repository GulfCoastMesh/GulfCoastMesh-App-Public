import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/edit_helper.dart';
import 'package:gulf_coast_mesh_app/helpers/reaction_helper.dart';

void main() {
  group('EditHelper', () {
    group('DM edits', () {
      test('builds and parses a round trip', () {
        final text = EditHelper.buildEditText(
          newText: 'hiya everyone',
          targetText: 'hiyaa',
          targetTimestamp: 1700000000,
        );

        expect(text, startsWith('ed:'));

        final info = EditHelper.parseEditText(text);
        expect(info, isNotNull);
        expect(info!.newText, 'hiya everyone');
        expect(info.targetSender, isNull);
        expect(
          info.targetHash,
          ReactionHelper.generateMessageHash('hiyaa', 1700000000),
        );
      });

      test('new text may contain colons', () {
        final text = EditHelper.buildEditText(
          newText: 'time is 10:30, see you then',
          targetText: 'hiyaa',
          targetTimestamp: 1700000000,
        );

        final info = EditHelper.parseEditText(text);
        expect(info!.newText, 'time is 10:30, see you then');
      });

      test('is case/confusable tolerant on the hash like reactions', () {
        final text = EditHelper.buildEditText(
          newText: 'edited',
          targetText: 'original',
          targetTimestamp: 1700000000,
        );
        final info = EditHelper.parseEditText(text);
        final upper = text.replaceRange(
          3,
          11,
          text.substring(3, 11).toUpperCase(),
        );
        final infoUpper = EditHelper.parseEditText(upper);
        expect(infoUpper!.targetHash, info!.targetHash);
      });
    });

    group('channel edits', () {
      test('builds and parses a round trip with sender', () {
        final text = EditHelper.buildChannelEditText(
          newText: 'updated message',
          targetSender: 'Alice',
          targetText: 'original message',
          targetTimestamp: 1700000000,
        );

        final info = EditHelper.parseEditText(text);
        expect(info, isNotNull);
        expect(info!.newText, 'updated message');
        expect(info.targetSender, 'Alice');
        expect(
          info.targetHash,
          ReactionHelper.generateMessageHash('original message', 1700000000),
        );
      });

      test('rejects sender names with brackets', () {
        expect(
          () => EditHelper.buildChannelEditText(
            newText: 'x',
            targetSender: 'Bad]Name',
            targetText: 'y',
            targetTimestamp: 1700000000,
          ),
          throwsArgumentError,
        );
      });
    });

    group('parseEditText', () {
      test('rejects non-edit text', () {
        expect(EditHelper.parseEditText('hello world'), isNull);
        expect(EditHelper.parseEditText('r:abcd:12'), isNull);
        expect(EditHelper.parseEditText('👍\nabcdefgh'), isNull);
      });

      test('rejects malformed edit prefixes', () {
        expect(EditHelper.parseEditText('ed:short:text'), isNull);
        expect(EditHelper.parseEditText('ed:abcdefghnotext'), isNull);
      });

      test('isEditText matches parseEditText', () {
        final text = EditHelper.buildEditText(
          newText: 'edited',
          targetText: 'original',
          targetTimestamp: 1700000000,
        );
        expect(EditHelper.isEditText(text), isTrue);
        expect(EditHelper.isEditText('not an edit'), isFalse);
      });
    });
  });
}
