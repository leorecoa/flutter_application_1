import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App should render without crashing',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ProviderScope(child: AgendeMaisApp()));

    // Verify that the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App should have correct title', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ProviderScope(child: AgendeMaisApp()));

    // Get the MaterialApp widget
    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify that the app has the correct title
    expect(app.title, contains('AgendeMais'));
  });
}
