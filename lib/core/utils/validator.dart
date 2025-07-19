/// Classe utilitária para validação de dados
class Validator {
  /// Valida um endereço de e-mail
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }
  
  /// Valida um número de telefone brasileiro
  static bool isValidPhone(String phone) {
    // Remove caracteres não numéricos
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verifica se o telefone tem entre 10 e 11 dígitos
    if (cleanPhone.length < 10 || cleanPhone.length > 11) {
      return false;
    }
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1+$').hasMatch(cleanPhone)) {
      return false;
    }
    
    return true;
  }
  
  /// Valida um CPF
  static bool isValidCPF(String cpf) {
    // Remove caracteres não numéricos
    final cleanCPF = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verifica se o CPF tem 11 dígitos
    if (cleanCPF.length != 11) {
      return false;
    }
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1+$').hasMatch(cleanCPF)) {
      return false;
    }
    
    // Calcula o primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleanCPF[i]) * (10 - i);
    }
    int digit1 = 11 - (sum % 11);
    if (digit1 > 9) {
      digit1 = 0;
    }
    
    // Calcula o segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleanCPF[i]) * (11 - i);
    }
    int digit2 = 11 - (sum % 11);
    if (digit2 > 9) {
      digit2 = 0;
    }
    
    // Verifica se os dígitos verificadores estão corretos
    return cleanCPF[9] == digit1.toString() && cleanCPF[10] == digit2.toString();
  }
  
  /// Valida um CNPJ
  static bool isValidCNPJ(String cnpj) {
    // Remove caracteres não numéricos
    final cleanCNPJ = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verifica se o CNPJ tem 14 dígitos
    if (cleanCNPJ.length != 14) {
      return false;
    }
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1+$').hasMatch(cleanCNPJ)) {
      return false;
    }
    
    // Calcula o primeiro dígito verificador
    int sum = 0;
    int weight = 5;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cleanCNPJ[i]) * weight;
      weight = weight == 2 ? 9 : weight - 1;
    }
    int digit1 = 11 - (sum % 11);
    if (digit1 > 9) {
      digit1 = 0;
    }
    
    // Calcula o segundo dígito verificador
    sum = 0;
    weight = 6;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cleanCNPJ[i]) * weight;
      weight = weight == 2 ? 9 : weight - 1;
    }
    int digit2 = 11 - (sum % 11);
    if (digit2 > 9) {
      digit2 = 0;
    }
    
    // Verifica se os dígitos verificadores estão corretos
    return cleanCNPJ[12] == digit1.toString() && cleanCNPJ[13] == digit2.toString();
  }
  
  /// Valida uma senha forte
  static bool isStrongPassword(String password) {
    // Verifica se a senha tem pelo menos 8 caracteres
    if (password.length < 8) {
      return false;
    }
    
    // Verifica se a senha contém pelo menos uma letra maiúscula
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return false;
    }
    
    // Verifica se a senha contém pelo menos uma letra minúscula
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return false;
    }
    
    // Verifica se a senha contém pelo menos um número
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return false;
    }
    
    // Verifica se a senha contém pelo menos um caractere especial
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return false;
    }
    
    return true;
  }
  
  /// Valida uma data
  static bool isValidDate(String date) {
    try {
      // Tenta converter a string para um objeto DateTime
      final parts = date.split('/');
      if (parts.length != 3) {
        return false;
      }
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      // Verifica se a data é válida
      if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) {
        return false;
      }
      
      // Verifica meses com 30 dias
      if ([4, 6, 9, 11].contains(month) && day > 30) {
        return false;
      }
      
      // Verifica fevereiro e anos bissextos
      if (month == 2) {
        final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        if (day > (isLeapYear ? 29 : 28)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Valida um CEP
  static bool isValidCEP(String cep) {
    // Remove caracteres não numéricos
    final cleanCEP = cep.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verifica se o CEP tem 8 dígitos
    return cleanCEP.length == 8;
  }
  
  /// Formata um CPF
  static String formatCPF(String cpf) {
    final cleanCPF = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCPF.length != 11) {
      return cpf;
    }
    
    return '${cleanCPF.substring(0, 3)}.${cleanCPF.substring(3, 6)}.${cleanCPF.substring(6, 9)}-${cleanCPF.substring(9)}';
  }
  
  /// Formata um CNPJ
  static String formatCNPJ(String cnpj) {
    final cleanCNPJ = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCNPJ.length != 14) {
      return cnpj;
    }
    
    return '${cleanCNPJ.substring(0, 2)}.${cleanCNPJ.substring(2, 5)}.${cleanCNPJ.substring(5, 8)}/${cleanCNPJ.substring(8, 12)}-${cleanCNPJ.substring(12)}';
  }
  
  /// Formata um telefone
  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length == 11) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 7)}-${cleanPhone.substring(7)}';
    } else if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6)}';
    }
    
    return phone;
  }
  
  /// Formata um CEP
  static String formatCEP(String cep) {
    final cleanCEP = cep.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCEP.length != 8) {
      return cep;
    }
    
    return '${cleanCEP.substring(0, 5)}-${cleanCEP.substring(5)}';
  }
}