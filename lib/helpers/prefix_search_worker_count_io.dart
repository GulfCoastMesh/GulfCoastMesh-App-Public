import 'dart:io';
import 'dart:math';

/// MeshBuddy uses ~75% of cores. Leave at least one core free so Flutter can
/// keep painting the spinner instead of ANRing.
int get parallelPrefixSearchWorkers {
  final n = Platform.numberOfProcessors;
  if (n <= 1) return 1;
  final target = max(1, (n * 0.75).round());
  return min(target, n - 1).clamp(1, 6);
}

bool get supportsParallelPrefixIsolates => true;
