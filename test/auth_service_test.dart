import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/services/auth_service.dart';

void main() {
  group('AuthService', () {
    setUp(() {
      // Configuração inicial se necessário
    });

    test('login should return true on successful response', () async {
      // Arrange
      // Configuração do mock não é necessária para o teste estático

      // Act
      final result = await AuthService.login('test@example.com', 'password');

      // Assert
      expect(result, true);
      expect(AuthService.isAuthenticated, true);
    });

    test('login should return false on failed response', () async {
      // Arrange
      // Configuração do mock não é necessária para o teste estático

      // Act
      final result =
          await AuthService.login('test@example.com', 'wrong_password');

      // Assert
      expect(result, false);
      // Não verificamos isAuthenticated aqui
    });

    test('logout should clear authentication data', () async {
      // Arrange - login first
      // Configuração do mock não é necessária para o teste estático
      await AuthService.login('test@example.com', 'password');

      // Act
      await AuthService.logout();

      // Assert
      expect(AuthService.isAuthenticated, false);
    });
  });
}
