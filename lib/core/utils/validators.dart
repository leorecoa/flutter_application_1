class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Campo'} é obrigatório';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    
    final phoneRegex = RegExp(r'^\(\d{2}\)\s\d{4,5}-\d{4}$|^\d{10,11}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'Telefone inválido';
    }
    
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Preço é obrigatório';
    }
    
    final price = double.tryParse(value.replaceAll(',', '.'));
    if (price == null || price <= 0) {
      return 'Preço deve ser maior que zero';
    }
    
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Nome deve conter apenas letras';
    }
    
    return null;
  }

  static String? dateTime(DateTime? value) {
    if (value == null) {
      return 'Data e hora são obrigatórias';
    }
    
    if (value.isBefore(DateTime.now())) {
      return 'Data deve ser futura';
    }
    
    return null;
  }

  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) return result;
    }
    return null;
  }
}

class InputFormatters {
  static String formatPhone(String value) {
    final numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numbers.length <= 10) {
      return numbers.replaceAllMapped(
        RegExp(r'^(\d{2})(\d{4})(\d{4})$'),
        (match) => '(${match[1]}) ${match[2]}-${match[3]}',
      );
    } else {
      return numbers.replaceAllMapped(
        RegExp(r'^(\d{2})(\d{5})(\d{4})$'),
        (match) => '(${match[1]}) ${match[2]}-${match[3]}',
      );
    }
  }

  static String formatPrice(String value) {
    final numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.isEmpty) return '';
    
    final price = double.parse(numbers) / 100;
    return price.toStringAsFixed(2).replaceAll('.', ',');
  }

  static String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}