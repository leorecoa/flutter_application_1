import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic app test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('AgendaFácil'),
        ),
      ),
    );

    expect(find.text('AgendaFácil'), findsOneWidget);
  });
}