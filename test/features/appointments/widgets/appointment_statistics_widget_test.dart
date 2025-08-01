import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_application_1/core/models/appointment_model.dart';
import 'package:flutter_application_1/features/appointments/application/appointment_providers.dart';
import 'package:flutter_application_1/features/appointments/widgets/appointment_statistics_widget.dart';

import 'appointment_statistics_widget_test.mocks.dart';

@GenerateMocks([AsyncValue])
void main() {
  late List<Appointment> testAppointments;

  setUp(() {
    // Criar agendamentos de teste para o mês atual
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    testAppointments = [
      // Agendamento confirmado
      Appointment(
        id: 'test-1',
        professionalId: 'prof-1',
        serviceId: 'service-1',
        clientId: 'client-1',
        clientName: 'Cliente 1',
        clientPhone: '123456789',
        service: 'Corte de Cabelo',
        price: 50.0,
        dateTime: currentMonth.add(const Duration(days: 1)),
        duration: 30,
        status: AppointmentStatus.confirmed,
        notes: 'Nota 1',
      ),
      // Agendamento cancelado
      Appointment(
        id: 'test-2',
        professionalId: 'prof-1',
        serviceId: 'service-2',
        clientId: 'client-2',
        clientName: 'Cliente 2',
        clientPhone: '987654321',
        service: 'Barba',
        price: 30.0,
        dateTime: currentMonth.add(const Duration(days: 2)),
        duration: 20,
        status: AppointmentStatus.cancelled,
        notes: 'Nota 2',
      ),
      // Agendamento agendado
      Appointment(
        id: 'test-3',
        professionalId: 'prof-1',
        serviceId: 'service-3',
        clientId: 'client-3',
        clientName: 'Cliente 3',
        clientPhone: '555555555',
        service: 'Corte e Barba',
        price: 70.0,
        dateTime: currentMonth.add(const Duration(days: 3)),
        duration: 50,
        status: AppointmentStatus.scheduled,
        notes: 'Nota 3',
      ),
      // Agendamento concluído
      Appointment(
        id: 'test-4',
        professionalId: 'prof-1',
        serviceId: 'service-1',
        clientId: 'client-4',
        clientName: 'Cliente 4',
        clientPhone: '444444444',
        service: 'Corte de Cabelo',
        price: 50.0,
        dateTime: currentMonth.add(const Duration(days: 4)),
        duration: 30,
        status: AppointmentStatus.completed,
        notes: 'Nota 4',
      ),
    ];
  });

  testWidgets('AppointmentStatisticsWidget displays correct statistics', (
    WidgetTester tester,
  ) async {
    // Arrange
    final mockAsyncValue = MockAsyncValue<List<Appointment>>();
    when(
      mockAsyncValue.when<Widget>(
        data: anyNamed('data'),
        loading: anyNamed('loading'),
        error: anyNamed('error'),
      ),
    ).thenAnswer((invocation) {
      final data = invocation.namedArguments[const Symbol('data')] as Function;
      return data(testAppointments);
    });

    // Build our widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [allAppointmentsProvider.overrideWithValue(mockAsyncValue)],
        child: const MaterialApp(
          home: Scaffold(body: AppointmentStatisticsWidget()),
        ),
      ),
    );

    // Assert
    expect(find.text('Estatísticas do Mês'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('4'), findsOneWidget); // Total de agendamentos
    expect(find.text('Confirmados'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // Confirmados + Concluídos
    expect(find.text('Cancelados'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // Cancelados
    expect(find.text('Receita'), findsOneWidget);
    expect(find.text('Taxa de Confirmação'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget); // Taxa de confirmação (2/3)
  });

  testWidgets('AppointmentStatisticsWidget handles empty appointments', (
    WidgetTester tester,
  ) async {
    // Arrange
    final mockAsyncValue = MockAsyncValue<List<Appointment>>();
    when(
      mockAsyncValue.when<Widget>(
        data: anyNamed('data'),
        loading: anyNamed('loading'),
        error: anyNamed('error'),
      ),
    ).thenAnswer((invocation) {
      final data = invocation.namedArguments[const Symbol('data')] as Function;
      return data(<Appointment>[]);
    });

    // Build our widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [allAppointmentsProvider.overrideWithValue(mockAsyncValue)],
        child: const MaterialApp(
          home: Scaffold(body: AppointmentStatisticsWidget()),
        ),
      ),
    );

    // Assert
    expect(find.text('Estatísticas do Mês'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // Total de agendamentos
    expect(find.text('R\$0,00'), findsAtLeastNWidgets(1)); // Receita zero
    expect(find.text('0%'), findsOneWidget); // Taxa de confirmação zero
  });

  testWidgets('AppointmentStatisticsWidget shows loading indicator', (
    WidgetTester tester,
  ) async {
    // Arrange
    final mockAsyncValue = MockAsyncValue<List<Appointment>>();
    when(
      mockAsyncValue.when<Widget>(
        data: anyNamed('data'),
        loading: anyNamed('loading'),
        error: anyNamed('error'),
      ),
    ).thenAnswer((invocation) {
      final loading =
          invocation.namedArguments[const Symbol('loading')] as Function;
      return loading();
    });

    // Build our widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [allAppointmentsProvider.overrideWithValue(mockAsyncValue)],
        child: const MaterialApp(
          home: Scaffold(body: AppointmentStatisticsWidget()),
        ),
      ),
    );

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppointmentStatisticsWidget shows error message', (
    WidgetTester tester,
  ) async {
    // Arrange
    final mockAsyncValue = MockAsyncValue<List<Appointment>>();
    when(
      mockAsyncValue.when<Widget>(
        data: anyNamed('data'),
        loading: anyNamed('loading'),
        error: anyNamed('error'),
      ),
    ).thenAnswer((invocation) {
      final error =
          invocation.namedArguments[const Symbol('error')] as Function;
      return error('Erro de teste', StackTrace.empty);
    });

    // Build our widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [allAppointmentsProvider.overrideWithValue(mockAsyncValue)],
        child: const MaterialApp(
          home: Scaffold(body: AppointmentStatisticsWidget()),
        ),
      ),
    );

    // Assert
    expect(
      find.text('Erro ao carregar estatísticas: Erro de teste'),
      findsOneWidget,
    );
  });
}
