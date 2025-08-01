import 'package:flutter_application_1/core/services/amplify_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AmplifyService amplifyService;

  // Inicializa uma nova instância do serviço antes de cada teste
  setUp(() {
    amplifyService = AmplifyService();
  });

  group('AmplifyService Mock Tests', () {
    test('configure() deve completar sem erros', () async {
      // O método `completes` verifica se o Future é concluído com sucesso.
      await expectLater(amplifyService.configure(), completes);
    });

    test('isConfigured deve retornar false para a implementação mock', () {
      // Assert
      expect(amplifyService.isConfigured, isFalse);
    });

    test('getCurrentUserId() deve retornar um ID de usuário mock', () async {
      // Act
      final userId = await amplifyService.getCurrentUserId();

      // Assert
      expect(userId, 'mock-user-id');
    });

    group('query()', () {
      test(
        'deve retornar dados de usuário mock para a query "GetUser"',
        () async {
          // Arrange
          const getUserQuery = 'query GetUser { id, name, email }';

          // Act
          final result = await amplifyService.query(getUserQuery);

          // Assert
          expect(result, isA<Map<String, dynamic>>());
          expect(result.containsKey('getUser'), isTrue);
          expect(result['getUser']['id'], 'mock-user-id');
          expect(result['getUser']['email'], 'mock@example.com');
        },
      );

      test(
        'deve retornar dados de tenant mock para a query "GetTenant"',
        () async {
          // Arrange
          const getTenantQuery = 'query GetTenant { id, name, domain }';

          // Act
          final result = await amplifyService.query(getTenantQuery);

          // Assert
          expect(result, isA<Map<String, dynamic>>());
          expect(result.containsKey('getTenant'), isTrue);
          expect(result['getTenant']['id'], 'mock-tenant-id');
          expect(result['getTenant']['name'], 'Mock Tenant');
        },
      );

      test('deve retornar um mapa vazio para uma query desconhecida', () async {
        // Arrange
        const unknownQuery = 'query GetSomethingElse { field }';

        // Act
        final result = await amplifyService.query(unknownQuery);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.isEmpty, isTrue);
      });
    });

    group('mutate()', () {
      test('deve completar e retornar um mapa vazio', () async {
        // Arrange
        const mutation = 'mutation CreateSomething { id }';

        // Act
        final result = await amplifyService.mutate(mutation);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.isEmpty, isTrue);
      });
    });
  });
}
