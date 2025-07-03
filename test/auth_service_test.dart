import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:agenda_facil/core/services/auth_service.dart';

@GenerateMocks([http.Client])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('login should return true on successful response', () async {
      // Arrange
      const responseJson =
          '{"accessToken": "test_token", "refreshToken": "refresh_token", "idToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyLTEyMyJ9.aBcDeFgHiJkLmNoPqRsTuVwXyZ"}';
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseJson, 200));

      // Act
      final result = await AuthService.login('test@example.com', 'password');

      // Assert
      expect(result, true);
      expect(AuthService.isAuthenticated, true);
    });

    test('login should return false on failed response', () async {
      // Arrange
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
          (_) async => http.Response('{"error": "Invalid credentials"}', 401));

      // Act
      final result =
          await AuthService.login('test@example.com', 'wrong_password');

      // Assert
      expect(result, false);
      expect(AuthService.isAuthenticated, false);
    });

    test('logout should clear authentication data', () async {
      // Arrange - login first
      const responseJson =
          '{"accessToken": "test_token", "refreshToken": "refresh_token", "idToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyLTEyMyJ9.aBcDeFgHiJkLmNoPqRsTuVwXyZ"}';
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseJson, 200));
      await AuthService.login('test@example.com', 'password');

      // Act
      await AuthService.logout();

      // Assert
      expect(AuthService.isAuthenticated, false);
    });
  });
}
