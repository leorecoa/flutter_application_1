import 'package:flutter_application_1/core/models/appointment.dart';
import 'package:flutter_application_1/core/services/amplify_service.dart';

/// Implementação simulada (mock) do [AmplifyService] para desenvolvimento local.
class AmplifyServiceMock implements AmplifyService {
  @override
  Future<void> configure() async {
    print('AmplifyServiceMock: Configurado (simulado).');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<bool> isUserSignedIn() async {
    print('AmplifyServiceMock: Verificando se usuário está logado (simulado).');
    await Future.delayed(const Duration(milliseconds: 50));
    return false; // Por padrão, o mock não está logado para forçar a tela de login.
  }

  @override
  Future<bool> signIn(String email, String password) async {
    print('AmplifyServiceMock: Login com $email (simulado).');
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<void> signOut() async {
    print('AmplifyServiceMock: Logout (simulado).');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<List<Appointment>> getAppointments(String tenantId) async {
    print(
      'AmplifyServiceMock: Buscando agendamentos para $tenantId (simulado).',
    );
    await Future.delayed(const Duration(milliseconds: 300));
    // Retorna uma lista de agendamentos de exemplo
    return [
      Appointment(
        id: 'mock-appt-1',
        clientName: 'Cliente Simulado',
        serviceName: 'Serviço Mock',
        date: DateTime.now(),
        startTime: '10:00',
        status: 'confirmed',
      ),
    ];
  }

  @override
  Future<void> resetPassword(String username) async {
    print(
      'AmplifyServiceMock: Enviando código de reset para $username (simulado).',
    );
    await Future.delayed(const Duration(milliseconds: 500));
    // No mock, apenas completamos a ação com sucesso.
  }

  @override
  Future<void> confirmResetPassword({
    required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {
    print(
      'AmplifyServiceMock: Confirmando reset de senha para $username (simulado).',
    );
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
