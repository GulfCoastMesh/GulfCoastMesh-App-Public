String initialsFromName(String name) {
  if (name.isEmpty) return '?';
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.length == 1) {
    final runes = words[0].runes.toList();
    if (runes.isEmpty) return '?';
    return String.fromCharCode(runes[0]).toUpperCase();
  }
  final first = words[0].runes.toList();
  final last = words[1].runes.toList();
  if (first.isEmpty || last.isEmpty) return '?';
  return '${String.fromCharCode(first[0])}${String.fromCharCode(last[0])}'
      .toUpperCase();
}
