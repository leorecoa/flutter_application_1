import '../../../core/errors/app_exceptions.dart';

/// Value Object para nome do cliente
class ClientName {
  final String value;
  
  ClientName._(this.value);
  
  factory ClientName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ValidationException('Nome do cliente não pode estar vazio');
    }
    if (trimmed.length < 3) {
      throw ValidationException('Nome do cliente deve ter pelo menos 3 caracteres');
    }
    if (trimmed.length > 100) {
      throw ValidationException('Nome do cliente não pode exceder 100 caracteres');
    }
    return ClientName._(trimmed);
  }
  
  @override
  String toString() => value;
}

/// Value Object para telefone do cliente
class ClientPhone {
  final String value;
  
  ClientPhone._(this.value);
  
  factory ClientPhone(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      throw ValidationException('Telefone do cliente não pode estar vazio');
    }
    if (digits.length < 8) {
      throw ValidationException('Telefone do cliente deve ter pelo menos 8 dígitos');
    }
    if (digits.length > 15) {
      throw ValidationException('Telefone do cliente não pode exceder 15 dígitos');
    }
    return ClientPhone._(digits);
  }
  
  @override
  String toString() => value;
}

/// Value Object para nome do serviço
class ServiceName {
  final String value;
  
  ServiceName._(this.value);
  
  factory ServiceName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ValidationException('Nome do serviço não pode estar vazio');
    }
    if (trimmed.length < 2) {
      throw ValidationException('Nome do serviço deve ter pelo menos 2 caracteres');
    }
    if (trimmed.length > 100) {
      throw ValidationException('Nome do serviço não pode exceder 100 caracteres');
    }
    return ServiceName._(trimmed);
  }
  
  @override
  String toString() => value;
}

/// Value Object para preço
class Price {
  final double value;
  
  Price._(this.value);
  
  factory Price(double input) {
    if (input < 0) {
      throw ValidationException('Preço não pode ser negativo');
    }
    if (input > 1000000) {
      throw ValidationException('Preço excede o valor máximo permitido');
    }
    return Price._(input);
  }
  
  @override
  String toString() => value.toString();
}

/// Value Object para ID de tenant
class TenantId {
  final String value;
  
  TenantId._(this.value);
  
  factory TenantId(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ValidationException('ID do tenant não pode estar vazio');
    }
    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(trimmed)) {
      throw ValidationException('ID do tenant contém caracteres inválidos');
    }
    return TenantId._(trimmed);
  }
  
  @override
  String toString() => value;
}