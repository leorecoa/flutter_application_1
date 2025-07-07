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
    if (value == null || value.isEmpty) return null;
    final phoneRegex = RegExp(r'^\(\d{2}\)\s\d{4,5}-\d{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Formato: (11) 99999-9999';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Preço é obrigatório';
    }
    final price = double.tryParse(value);
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
    return null;
  }
}