import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agendemais/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AgendeMaisApp());
    
    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}