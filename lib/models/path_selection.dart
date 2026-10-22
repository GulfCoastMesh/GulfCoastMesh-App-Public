class PathSelection {
  final List<int> pathBytes;
  final int hopCount;
  final bool useFlood;

  const PathSelection({
    required this.pathBytes,
    required this.hopCount,
    required this.useFlood,
  });
}
