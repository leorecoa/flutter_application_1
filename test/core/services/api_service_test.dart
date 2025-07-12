import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:agendemais/core/services/api_service.dart';

@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      apiService = ApiService();
      mockClient = MockClient();
    });

    test('should make successful GET request', () async {
      // Arrange
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{"success": true, "data": []}', 200));

      // Act
      final result = await apiService.get('/test');

      // Assert
      expect(result['success'], true);
      expect(result['data'], isA<List>());
    });

    test('should handle POST request with data', () async {
      // Arrange
      const testData = {'name': 'Test Service', 'price': 50.0};
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"success": true, "data": {"id": "123"}}', 201));

      // Act
      final result = await apiService.post('/services', testData);

      // Assert
      expect(result['success'], true);
      expect(result['data']['id'], '123');
    });

    test('should handle network errors gracefully', () async {
      // Arrange
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await apiService.get('/test');

      // Assert
      expect(result['success'], false);
      expect(result['message'], contains('Erro de conexão'));
    });
  });
}