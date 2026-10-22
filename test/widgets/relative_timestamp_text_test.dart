import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/widgets/relative_timestamp_text.dart';

void main() {
  testWidgets('old timestamps include a date instead of only a clock time', (
    tester,
  ) async {
    final timestamp = DateTime.now().subtract(const Duration(days: 8));
    late String expectedDate;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expectedDate = MaterialLocalizations.of(
              context,
            ).formatShortDate(timestamp);
            return Scaffold(body: RelativeTimestampText(timestamp));
          },
        ),
      ),
    );

    expect(find.textContaining(expectedDate), findsOneWidget);
  });
}
