import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/appointments/domain/value_objects/appointment_value_objects.dart';
import 'package:flutter_application_1/core/errors/app_exceptions.dart';

void main() {
  group('ClientName', () {
    test('should create valid ClientName', () {
      // Act
      final clientName = ClientName('John Doe');
      
      // Assert
      expect(clientName.value, equals('John Doe'));
    });
    
    test('should trim whitespace', () {
      // Act
      final clientName = ClientName('  John Doe  ');
      
      // Assert
      expect(clientName.value, equals('John Doe'));
    });
    
    test('should throw ValidationException when empty', () {
      // Act & Assert
      expect(() => ClientName(''), throwsA(isA<ValidationException>()));
    });
    
    test('should throw ValidationException when too short', () {
      // Act & Assert
      expect(() => ClientName('Jo'), throwsA(isA<ValidationException>()));
    });
    
    test('should throw ValidationException when too long', () {
      // Act & Assert
      final longName = 'A' * 101;
      expect(() => ClientName(longName), throwsA(isA<ValidationException>()));
    });
  });
  
  group('ClientPhone', () {
    test('should create valid ClientPhone', () {
      // Act
      final clientPhone = ClientPhone('123456789');
      
      // Assert
      expect(clientPhone.value, equals('123456789'));
    });
    
    test('should remove non-digit characters', () {
      // Act
      final clientPhone = ClientPhone('(123) 456-789');
      
      // Assert
      expect(clientPhone.value, equals('123456789'));
    });
    
    test('should throw ValidationException when empty', () {
      // Act & Assert
      expect(() => ClientPhone(''), throwsA(isA<ValidationException>()));
    });
    
    test('should throw ValidationException when too short', () {
      // Act & Assert
      expect(() => ClientPhone('123'), throwsA(isA<ValidationException>()));
    });
    
    test('should throw ValidationException when too long', () {
      // Act & Assert
      final longPhone = '1' * 16;
      expect(() => ClientPhone(longPhone), throwsA(isA<ValidationException>()));
    });
  });
  
  group('ServiceName', () {
    test('should create valid ServiceName', () {
      // Act
      final serviceName = ServiceName('Haircut');
      
      // Assert
      expect(serviceName.value, equals('Haircut'));
    });
    
    test('should trim whitespace', () {
      // Act
      final serviceName = ServiceName('  Haircut  ');
      
      // Assert
      expect(serviceName.value, equals('Haircut'));
    });
    
    test('should throw ValidationException when empty', () {
      // Act & Assert
      expect(() => ServiceName(''), throwsA(isA<ValidationException>()));
    });
    
    test('should throw ValidationException when too short', () {
      // Act & Assert
      expect(() => ServiceName('H'), throwsA(isA<ValidationException>()));
    });
    
    test('should throw ValidationException when too long', () {
      // Act & Assert
      final longName = 'A' * 101;
      expect(() => ServiceName(longName), throwsA(isA<ValidationException>()));
    });
  });
  
  group('Price', () {
    test('should create valid Price', () {
      // Act
      final price = Price(100.0);
      
      // Assert
      expect(price.value, equals(100.0));
    });
    
    test('should throw ValidationException when negative', () {
      // Act & Assert
      expect(() => Price(-10.0), throwsA(isA<ValidationException>()));
    });
    
    test('should throw ValidationException when too large', () {
      // Act & Assert
      expect(() => Price(1000001.0), throwsA(isA<ValidationException>()));
    });
  });
  
  group('TenantId', () {
    test('should create valid TenantId', () {
      // Act
      final tenantId = TenantId('tenant-123');
      
      // Assert
      expect(tenantId.value, equals('tenant-123'));
    });
    
    test('should trim whitespace', () {
      // Act
      final tenantId = TenantId('  tenant-123  ');
      
      // Assert
      expect(tenantId.value, equals('tenant-123'));
    });
    
    test('should throw ValidationException when empty', () {
      // Act & Assert
      expect(() => TenantId(''), throwsA(isA<ValidationException>()));
    });
    
    test('should throw ValidationException when contains invalid characters', () {
      // Act & Assert
      expect(() => TenantId('tenant@123'), throwsA(isA<ValidationException>()));
    });
  });
}