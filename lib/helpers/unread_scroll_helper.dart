/// Finds the index, in a newest-first message list, of the oldest message
/// among the most recent [unreadCount] messages that actually count toward
/// the unread badge (per [isQualifying]) — i.e. the message a user should
/// resume reading from.
///
/// A naive `unreadCount - 1` offset breaks whenever a non-qualifying message
/// (e.g. one the user sent themselves) is interleaved among the unread ones,
/// since the connector's unread counter only increments for qualifying
/// messages and skips those. This walks the list counting only qualifying
/// messages so the result lines up with what actually incremented the count.
///
/// Returns null if [unreadCount] is not positive, or if fewer than
/// [unreadCount] qualifying messages are present in [newestFirst] (the
/// target isn't loaded, e.g. it needs older-message pagination first).
int? findFirstUnreadIndex<T>(
  List<T> newestFirst,
  int unreadCount,
  bool Function(T message) isQualifying,
) {
  if (unreadCount <= 0) return null;
  var seen = 0;
  for (var i = 0; i < newestFirst.length; i++) {
    if (isQualifying(newestFirst[i])) {
      seen++;
      if (seen == unreadCount) return i;
    }
  }
  return null;
}
