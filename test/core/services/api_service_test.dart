import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importação corrigida para o nome do pacote "agendafacil" e o novo arquivo
import 'package:agendafacil/src/core/services/api_service.dart';

// Importação para o arquivo de mock que será gerado
import 'api_service_test.mocks.dart';

// Anotação para gerar um MockClient a partir da classe Client do http
@GenerateMocks([http.Client])
void main() {
  late ApiService apiService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService(client: mockClient);
  });

  group('ApiService - GET', () {
    test('retorna um Map se a chamada http for bem-sucedida (status 200)',
        () async {
      // Arrange
      final responsePayload = '{"data": "test_ok"}';
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(responsePayload, 200));

      // Act
      final result = await apiService.get('test-endpoint');

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['data'], 'test_ok');
    });

    test('lança uma Exception se a chamada http retornar um erro', () {
      // Arrange
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // Act & Assert
      expect(apiService.get('test-endpoint'), throwsException);
    });
  });
}
