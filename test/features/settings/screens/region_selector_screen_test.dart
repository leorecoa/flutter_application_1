import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/settings/screens/region_selector_screen.dart';

void main() {
  group('RegionSelectorScreen', () {
    testWidgets('should display title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegionSelectorScreen(),
        ),
      );

      expect(find.text('Selecionar Região'), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegionSelectorScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have refresh button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegionSelectorScreen(),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}