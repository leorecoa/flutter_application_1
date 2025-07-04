import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/services/api_service.dart';
import 'package:flutter_application_1/core/config/multi_region_config.dart';
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

    test('should get current region', () {
      expect(apiService.currentRegion, MultiRegionConfig.defaultRegion);
    });

    test('should change region', () async {
      await apiService.changeRegion('us-west-2');
      expect(apiService.currentRegion, 'us-west-2');
    });

    test('should initialize service', () async {
      await apiService.init();
      expect(apiService.currentRegion, isNotNull);
    });

    test('ApiException should have correct properties', () {
      const exception = ApiException(statusCode: 404, message: 'Not found');
      expect(exception.statusCode, 404);
      expect(exception.message, 'Not found');
      expect(exception.toString(), contains('404'));
      expect(exception.toString(), contains('Not found'));
    });
  });
}