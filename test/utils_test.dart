import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utility Functions', () {
    test('String extensions should work', () {
      const testString = 'hello world';
      expect(testString.isNotEmpty, true);
      expect(testString.length, 11);
      expect(testString.contains('world'), true);
      expect(testString.toUpperCase(), 'HELLO WORLD');
      expect(testString.toLowerCase(), 'hello world');
    });

    test('List operations should work', () {
      final testList = [1, 2, 3, 4, 5];
      expect(testList.length, 5);
      expect(testList.first, 1);
      expect(testList.last, 5);
      expect(testList.contains(3), true);
      expect(testList.where((e) => e > 3).toList(), [4, 5]);
    });

    test('Map operations should work', () {
      final testMap = {'key1': 'value1', 'key2': 'value2'};
      expect(testMap.length, 2);
      expect(testMap.containsKey('key1'), true);
      expect(testMap['key1'], 'value1');
      expect(testMap.keys.toList(), ['key1', 'key2']);
      expect(testMap.values.toList(), ['value1', 'value2']);
    });

    test('DateTime operations should work', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final yesterday = now.subtract(const Duration(days: 1));
      
      expect(tomorrow.isAfter(now), true);
      expect(yesterday.isBefore(now), true);
      expect(now.difference(yesterday).inDays, 1);
    });

    test('Duration operations should work', () {
      const duration = Duration(hours: 2, minutes: 30);
      expect(duration.inMinutes, 150);
      expect(duration.inHours, 2);
      expect(duration.inSeconds, 9000);
    });
  });
}