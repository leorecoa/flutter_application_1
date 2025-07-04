import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/settings/screens/settings_screen.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('should display settings screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}