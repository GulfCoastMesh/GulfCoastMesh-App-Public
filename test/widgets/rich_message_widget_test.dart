import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/rich_message_parser.dart';
import 'package:gulf_coast_mesh_app/models/rich_message.dart';
import 'package:gulf_coast_mesh_app/widgets/rich_message_widget.dart';

void main() {
  testWidgets('renders decorated rich tokens and reports callbacks', (
    tester,
  ) async {
    final message = RichMessageParser.parse('https://example.com');
    RichMessageToken? tappedToken;
    Uri? tappedUri;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RichMessageWidget(
            message: message,
            onTokenTap: (token) => tappedToken = token,
            onUrlTap: (uri) => tappedUri = uri,
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
    final urlText = tester.getTopLeft(find.byType(RichText));
    await tester.tapAt(urlText + const Offset(8, 8));
    expect(tappedToken, isA<RichUrlToken>());
    expect(tappedUri, Uri.parse('https://example.com'));
  });

  testWidgets('renders contact and coordinate callbacks without navigation', (
    tester,
  ) async {
    const key =
        '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
    final message = RichMessageParser.parse('<$key:1:Base>');
    RichContactShareToken? contact;
    RichCoordinateToken? coordinate;
    await tester.pumpWidget(
      MaterialApp(
        home: RichMessageWidget(
          message: message,
          onContactShareTap: (value) => contact = value,
          onCoordinateTap: (value) => coordinate = value,
        ),
      ),
    );

    final contactText = tester.getTopLeft(find.byType(RichText));
    await tester.tapAt(contactText + const Offset(8, 8));
    expect(contact?.name, 'Base');

    await tester.pumpWidget(
      MaterialApp(
        home: RichMessageWidget(
          message: RichMessageParser.parse('30.1, -90.2'),
          onCoordinateTap: (value) => coordinate = value,
        ),
      ),
    );
    final coordinateText = tester.getTopLeft(find.byType(RichText));
    await tester.tapAt(coordinateText + const Offset(8, 8));
    expect(coordinate?.latitude, 30.1);
  });
}
