import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/services/amplify_service.dart';
import 'package:flutter_application_1/core/services/amplify_service_mock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late AmplifyService amplifyService;

  setUp(() {
    // Forçamos o provider a usar a implementação Mock para este teste.
    container = ProviderContainer(
      overrides: [
        amplifyServiceProvider.overrideWithValue(AmplifyServiceMock()),
      ],
    );
    amplifyService = container.read(amplifyServiceProvider);
  });

  tearDown(() {
    container.dispose();
  });

  group('AmplifyServiceMock', () {
    test('configure() deve completar sem erros', () async {
      await expectLater(amplifyService.configure(), completes);
    });

    test('signIn() deve retornar true para um login simulado', () async {
      final isSignedIn = await amplifyService.signIn('test@test.com', '123');
      expect(isSignedIn, isTrue);
    });

    test('signOut() deve completar sem erros', () async {
      await expectLater(amplifyService.signOut(), completes);
    });

    test(
      'getAppointments() deve retornar uma lista de agendamentos mock',
      () async {
        final appointments = await amplifyService.getAppointments(
          'mock-tenant',
        );
        expect(appointments, isNotEmpty);
        expect(appointments.first.id, 'mock-appt-1');
        expect(appointments.first.clientName, 'Cliente Simulado');
      },
    );
  });
}
