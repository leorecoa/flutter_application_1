import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_application_1/amplifyconfiguration.dart';
import 'package:flutter_application_1/core/errors/auth_exceptions.dart'
    as custom_exceptions;
import 'package:flutter_application_1/core/models/appointment.dart';
import 'package:flutter_application_1/core/repositories/repository_exception.dart';
import 'package:flutter_application_1/core/services/amplify_service.dart';

/// Implementação real do [AmplifyService] que interage com os serviços da AWS.
class AmplifyServiceReal implements AmplifyService {
  @override
  Future<void> configure() async {
    if (Amplify.isConfigured) {
      return;
    }
    try {
      // O arquivo amplifyconfiguration.dart é gerado pelo Amplify CLI
      await Amplify.configure(amplifyconfig);
      safePrint('Amplify configurado com sucesso.');
    } on AmplifyAlreadyConfiguredException {
      safePrint('Amplify já estava configurado.');
    } catch (e) {
      throw Exception('Erro ao configurar o Amplify: $e');
    }
  }

  @override
  Future<bool> isUserSignedIn() async {
    final session = await Amplify.Auth.fetchAuthSession();
    return session.isSignedIn;
  }

  @override
  Future<bool> signIn(String email, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      return result.isSignedIn;
    } on UserNotFoundException {
      // Captura a exceção do Amplify e lança a nossa exceção personalizada.
      throw custom_exceptions.UserNotFoundException();
    } on NotAuthorizedException {
      // Captura a exceção do Amplify e lança a nossa exceção personalizada.
      throw custom_exceptions.NotAuthorizedException();
    } catch (e) {
      throw custom_exceptions.AuthException(
        'Ocorreu um erro inesperado durante o login.',
      );
    }
  }

  @override
  Future<void> resetPassword(String username) async {
    try {
      await Amplify.Auth.resetPassword(username: username);
    } on UserNotFoundException {
      // Lançamos a mesma exceção para não revelar se o email existe ou não.
      // A mensagem na UI será genérica.
      throw custom_exceptions.UserNotFoundException();
    } catch (e) {
      throw custom_exceptions.AuthException(
        'Ocorreu um erro ao tentar redefinir a senha.',
      );
    }
  }

  @override
  Future<void> confirmResetPassword({
    required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: username,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
    } on CodeMismatchException {
      throw custom_exceptions.AuthException('Código de confirmação inválido.');
    } catch (e) {
      throw custom_exceptions.AuthException(
        'Ocorreu um erro ao confirmar a nova senha.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }

  @override
  Future<List<Appointment>> getAppointments(
    String tenantId, {
    int limit = 20,
    String? nextToken,
  }) async {
    try {
      const query = '''
        query ListAppointments(\$filter: ModelAppointmentFilterInput, \$limit: Int, \$nextToken: String) {
          listAppointments(filter: \$filter, limit: \$limit, nextToken: \$nextToken) {
            items {
              id
              clientName
              serviceName
              date
              startTime
              status
            }
            nextToken
          }
        }
      ''';

      final request = GraphQLRequest<String>(
        document: query,
        variables: {
          'filter': {
            'tenantId': {'eq': tenantId},
          },
          'limit': limit,
          if (nextToken != null) 'nextToken': nextToken,
        },
      );

      final response = await Amplify.API.query(request: request).response;
      final data = json.decode(response.data!);
      final items = (data['listAppointments']['items'] as List)
          .map((item) => Appointment.fromJson(item))
          .toList();
      return items;
    } catch (e) {
      throw RepositoryException('Erro ao buscar agendamentos na AWS: $e');
    }
  }
}
