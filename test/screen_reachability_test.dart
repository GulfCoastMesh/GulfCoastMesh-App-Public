import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every screen must be referenced from somewhere outside its own file.
///
/// The Community QR join/create feature sat fully built but unreachable for
/// weeks because its entry point was removed in an unrelated refactor: the
/// screen, its model, its store and its tests all still passed, and nothing
/// pointed at it. Compilation cannot catch that, so this does.
void main() {
  test('no screen is orphaned', () {
    final screens = Directory('lib/screens')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
    expect(screens, isNotEmpty, reason: 'expected to find screen sources');

    final sources = <String, String>{};
    for (final dir in ['lib', 'test']) {
      for (final file in Directory(dir).listSync(recursive: true)) {
        if (file is File && file.path.endsWith('.dart')) {
          sources[file.path] = file.readAsStringSync();
        }
      }
    }

    final classPattern = RegExp(
      r'^class (\w+) extends (?:StatelessWidget|StatefulWidget)',
      multiLine: true,
    );

    final orphans = <String>[];
    for (final screen in screens) {
      final path = screen.path;
      final text = sources[path] ?? screen.readAsStringSync();
      final names = classPattern
          .allMatches(text)
          .map((m) => m.group(1)!)
          .where((n) => n.endsWith('Screen'))
          .toList();
      if (names.isEmpty) continue;

      final reachable = names.any((name) {
        final use = RegExp(r'\b' + name + r'\b');
        return sources.entries.any(
          (e) => e.key != path && use.hasMatch(e.value),
        );
      });
      if (!reachable) {
        orphans.add('$path (${names.join(", ")})');
      }
    }

    expect(
      orphans,
      isEmpty,
      reason:
          'These screens are built but nothing references them. Either wire '
          'up an entry point or delete the feature:\n  ${orphans.join("\n  ")}',
    );
  });
}
