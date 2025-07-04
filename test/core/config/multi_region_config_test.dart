import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/config/multi_region_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MultiRegionConfig', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should have default region', () {
      expect(MultiRegionConfig.defaultRegion, 'us-east-1');
    });

    test('should have regions map', () {
      expect(MultiRegionConfig.regions, isNotEmpty);
      expect(MultiRegionConfig.regions.containsKey('us-east-1'), true);
      expect(MultiRegionConfig.regions.containsKey('us-west-2'), true);
      expect(MultiRegionConfig.regions.containsKey('sa-east-1'), true);
    });

    test('should have api endpoints', () {
      expect(MultiRegionConfig.apiEndpoints, isNotEmpty);
      expect(MultiRegionConfig.apiEndpoints.containsKey('us-east-1'), true);
      expect(MultiRegionConfig.apiEndpoints['us-east-1'], contains('us-east-1'));
    });

    test('should get preferred region', () async {
      final region = await MultiRegionConfig.getPreferredRegion();
      expect(region, isNotNull);
      expect(MultiRegionConfig.regions.containsKey(region), true);
    });

    test('should set preferred region', () async {
      await MultiRegionConfig.setPreferredRegion('us-west-2');
      final region = await MultiRegionConfig.getPreferredRegion();
      expect(region, 'us-west-2');
    });

    test('should throw error for invalid region', () async {
      expect(
        () => MultiRegionConfig.setPreferredRegion('invalid-region'),
        throwsArgumentError,
      );
    });

    test('should get api endpoint for region', () async {
      final endpoint = await MultiRegionConfig.getApiEndpoint(region: 'us-east-1');
      expect(endpoint, MultiRegionConfig.apiEndpoints['us-east-1']);
    });

    test('should get api endpoint for preferred region', () async {
      await MultiRegionConfig.setPreferredRegion('us-west-2');
      final endpoint = await MultiRegionConfig.getApiEndpoint();
      expect(endpoint, MultiRegionConfig.apiEndpoints['us-west-2']);
    });
  });
}