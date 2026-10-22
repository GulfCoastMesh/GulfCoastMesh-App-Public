import 'reaction_helper.dart';

/// An edit after parsing its wire representation.
class EditInfo {
  final String targetHash;
  final String newText;
  final String? targetSender;

  EditInfo({
    required this.targetHash,
    required this.newText,
    this.targetSender,
  });
}

/// Wire-format helpers for message edits.
///
/// Edits ride the plain text-message frame, the same way [ReactionHelper]
/// reactions do: there is no stable per-message packet id on the wire, so
/// the target is identified by the MeshCore One message hash (SHA-256 of
/// the original text + timestamp). Any client that recognizes the `ed:`
/// prefix can recompute the same hash and apply the edit, without needing
/// a new command code.
class EditHelper {
  EditHelper._();

  static const String _prefix = 'ed:';

  /// Build a DM edit: `ed:{hash}:{newText}`.
  static String buildEditText({
    required String newText,
    required String targetText,
    required int targetTimestamp,
  }) {
    final hash = ReactionHelper.generateMessageHash(
      targetText,
      targetTimestamp,
    );
    return '$_prefix$hash:$newText';
  }

  /// Build a channel edit: `ed:{hash}@[{targetSender}]:{newText}`.
  ///
  /// The sender is included the same way channel reactions include it,
  /// since a channel can have multiple authors sharing the same text hash.
  static String buildChannelEditText({
    required String newText,
    required String targetSender,
    required String targetText,
    required int targetTimestamp,
  }) {
    if (targetSender.isEmpty || targetSender.contains(RegExp(r'[\r\n\[\]]'))) {
      throw ArgumentError.value(targetSender, 'targetSender');
    }
    final hash = ReactionHelper.generateMessageHash(
      targetText,
      targetTimestamp,
    );
    return '$_prefix$hash@[$targetSender]:$newText';
  }

  /// Parse either edit representation.
  static EditInfo? parseEditText(String text) {
    if (!text.startsWith(_prefix)) return null;
    final rest = text.substring(_prefix.length);
    if (rest.length < 9) return null;

    final hash = ReactionHelper.normalizeHash(rest.substring(0, 8));
    if (hash == null) return null;
    final tail = rest.substring(8);

    if (tail.startsWith('@[')) {
      final closeBracket = tail.indexOf(']');
      if (closeBracket < 3) return null;
      final sender = tail.substring(2, closeBracket);
      if (sender.isEmpty) return null;
      if (tail.length <= closeBracket + 1 || tail[closeBracket + 1] != ':') {
        return null;
      }
      return EditInfo(
        targetHash: hash,
        newText: tail.substring(closeBracket + 2),
        targetSender: sender,
      );
    }

    if (!tail.startsWith(':')) return null;
    return EditInfo(targetHash: hash, newText: tail.substring(1));
  }

  /// Returns true when [text] is a supported edit representation.
  static bool isEditText(String text) => parseEditText(text) != null;
}
