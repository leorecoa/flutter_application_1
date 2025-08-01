import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application_1/main.dart' as app;
import 'package:flutter_application_1/features/appointments/screens/appointments_screen.dart';
import 'package:flutter_application_1/features/appointments/widgets/appointment_card_widget.dart';
import 'package:flutter_application_1/features/appointments/widgets/empty_appointments_view.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo completo de agendamentos', () {
    testWidgets('Navegação e criação de agendamento', (tester) async {
      // Inicializa o app
      app.main();
      await tester.pumpAndSettle();

      // Verifica se está na tela inicial
      expect(find.text('AGENDEMAIS'), findsOneWidget);

      // Navega para a tela de agendamentos
      await _navigateToAppointments(tester);
      await tester.pumpAndSettle();

      // Verifica se está na tela de agendamentos
      expect(find.byType(AppointmentsScreen), findsOneWidget);

      // Tenta criar um novo agendamento
      await _createNewAppointment(tester);
      await tester.pumpAndSettle();

      // Verifica se o agendamento foi criado
      expect(find.byType(AppointmentCard), findsAtLeastNWidgets(1));
    });

    testWidgets('Filtrar e buscar agendamentos', (tester) async {
      // Inicializa o app
      app.main();
      await tester.pumpAndSettle();

      // Navega para a tela de agendamentos
      await _navigateToAppointments(tester);
      await tester.pumpAndSettle();

      // Testa a busca
      await _searchAppointment(tester, 'João');
      await tester.pumpAndSettle();

      // Verifica se os resultados da busca são exibidos
      expect(find.byType(AppointmentCard), findsAtLeastNWidgets(1));
      
      // Limpa a busca
      await _clearSearch(tester);
      await tester.pumpAndSettle();
      
      // Testa os filtros
      await _filterByStatus(tester, 'Confirmado');
      await tester.pumpAndSettle();
      
      // Verifica se os resultados filtrados são exibidos
      expect(find.byType(AppointmentCard), findsAtLeastNWidgets(1));
    });
    
    testWidgets('Operações em lote', (tester) async {
      // Inicializa o app
      app.main();
      await tester.pumpAndSettle();

      // Navega para a tela de agendamentos
      await _navigateToAppointments(tester);
      await tester.pumpAndSettle();

      // Ativa o modo de seleção
      await _activateSelectionMode(tester);
      await tester.pumpAndSettle();
      
      // Seleciona alguns agendamentos
      await _selectAppointments(tester, 2);
      await tester.pumpAndSettle();
      
      // Confirma os agendamentos selecionados
      await _confirmSelectedAppointments(tester);
      await tester.pumpAndSettle();
      
      // Verifica se a operação foi concluída
      expect(find.text('Operação concluída com sucesso'), findsOneWidget);
    });
  });
}

Future<void> _navigateToAppointments(WidgetTester tester) async {
  // Encontra e toca no botão de navegação para agendamentos
  final appointmentsButton = find.byIcon(Icons.calendar_today);
  await tester.tap(appointmentsButton);
}

Future<void> _createNewAppointment(WidgetTester tester) async {
  // Toca no botão de adicionar
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  
  // Preenche o formulário
  await tester.enterText(find.byKey(const ValueKey('clientNameField')), 'Cliente Teste');
  await tester.enterText(find.byKey(const ValueKey('serviceField')), 'Serviço Teste');
  await tester.enterText(find.byKey(const ValueKey('priceField')), '100,00');
  
  // Seleciona a data
  await tester.tap(find.byKey(const ValueKey('dateField')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  
  // Seleciona a hora
  await tester.tap(find.byKey(const ValueKey('timeField')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  
  // Salva o agendamento
  await tester.tap(find.text('SALVAR'));
  await tester.pumpAndSettle();
}

Future<void> _searchAppointment(WidgetTester tester, String query) async {
  // Encontra o campo de busca
  final searchField = find.byType(TextField).first;
  
  // Insere o texto de busca
  await tester.enterText(searchField, query);
  await tester.pumpAndSettle(const Duration(milliseconds: 600)); // Aguarda o debounce
}

Future<void> _clearSearch(WidgetTester tester) async {
  // Encontra o botão de limpar busca
  final clearButton = find.byIcon(Icons.clear).first;
  
  // Toca no botão
  await tester.tap(clearButton);
}

Future<void> _filterByStatus(WidgetTester tester, String status) async {
  // Encontra o botão de filtro
  final filterButton = find.byIcon(Icons.filter_list).first;
  
  // Toca no botão
  await tester.tap(filterButton);
  await tester.pumpAndSettle();
  
  // Seleciona o status
  await tester.tap(find.text(status).last);
  await tester.pumpAndSettle();
}

Future<void> _activateSelectionMode(WidgetTester tester) async {
  // Encontra o botão de seleção
  final selectionButton = find.byIcon(Icons.select_all).first;
  
  // Toca no botão
  await tester.tap(selectionButton);
}

Future<void> _selectAppointments(WidgetTester tester, int count) async {
  // Encontra os checkboxes
  final checkboxes = find.byType(Checkbox);
  
  // Seleciona a quantidade especificada
  for (int i = 0; i < count && i < checkboxes.evaluate().length; i++) {
    await tester.tap(checkboxes.at(i));
    await tester.pumpAndSettle();
  }
}

Future<void> _confirmSelectedAppointments(WidgetTester tester) async {
  // Encontra o botão de confirmar
  final confirmButton = find.text('CONFIRMAR').first;
  
  // Toca no botão
  await tester.tap(confirmButton);
}