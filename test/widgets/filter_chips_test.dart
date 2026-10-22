import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/widgets/filter_chips.dart';

void main() {
  testWidgets('filter chips remain usable with large accessibility text', (
    tester,
  ) async {
    String selected = 'all';
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3)),
          child: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: FilterChipRow<String>(
                selected: selected,
                onSelected: (value) => setState(() => selected = value),
                items: const [
                  FilterChipItem(value: 'all', label: 'All'),
                  FilterChipItem(value: 'unread', label: 'Unread', count: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Unread'));
    await tester.pump();
    expect(selected, 'unread');
    expect(tester.takeException(), isNull);
  });
}
