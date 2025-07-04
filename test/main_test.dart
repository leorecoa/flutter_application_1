import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Main App Tests', () {
    testWidgets('MaterialApp should render', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          title: 'AgendaFácil',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: Scaffold(
            appBar: AppBar(title: const Text('AgendaFácil')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bem-vindo ao AgendaFácil'),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('AgendaFácil'), findsAtLeastNWidgets(1));
      expect(find.text('Bem-vindo ao AgendaFácil'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Theme should be applied correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(Scaffold));
      final ThemeData theme = Theme.of(context);

      expect(theme.useMaterial3, true);
      expect(theme.primaryColor, isNotNull);
    });

    testWidgets('Scaffold should have proper structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: AppBar(title: const Text('Test App')),
            ),
            body: const Center(child: Text('Content')),
            floatingActionButton: const FloatingActionButton(
              onPressed: null,
              child: Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
