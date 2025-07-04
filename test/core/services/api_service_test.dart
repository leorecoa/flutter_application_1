import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      apiService = ApiService();
    });

    test('should be singleton', () {
      final instance1 = ApiService();
      final instance2 = ApiService();
      expect(identical(instance1, instance2), true);
    });

    test('should set and get auth token', () {
      const token = 'test-token';
      apiService.setAuthToken(token);
      expect(apiService.authToken, token);
      expect(apiService.isAuthenticated, true);
    });

    test('should clear auth token', () {
      apiService.setAuthToken('test-token');
      apiService.clearAuthToken();
      expect(apiService.authToken, null);
      expect(apiService.isAuthenticated, false);
    });

    test('should initialize service', () async {
      await apiService.init();
      expect(apiService, isNotNull);
    });


  });
}