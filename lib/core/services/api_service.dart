class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  String? _authToken;
  
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null;
  String get currentRegion => 'us-east-1';
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  void clearAuthToken() {
    _authToken = null;
  }
  
  Future<void> init() async {
    // Initialize service
  }
  
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    print('🚀 API Call: $path with data: $data');
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (path == '/auth/login') {
      final email = data['email']?.toString() ?? '';
      final password = data['password']?.toString() ?? '';
      
      print('🔑 Login attempt: $email');
      
      if (email.contains('@') && password.length >= 6) {
        final token = 'token_${DateTime.now().millisecondsSinceEpoch}';
        print('✅ Login success: $token');
        return {
          'success': true,
          'token': token,
          'user': {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'email': email,
            'name': email.split('@')[0],
          },
          'message': 'Login realizado com sucesso'
        };
      } else {
        print('❌ Login failed: invalid credentials');
        return {
          'success': false,
          'message': 'Email deve conter @ e senha ter 6+ caracteres'
        };
      }
    }
    
    if (path == '/auth/register') {
      final email = data['email']?.toString() ?? '';
      final password = data['password']?.toString() ?? '';
      final name = data['name']?.toString() ?? '';
      final businessName = data['businessName']?.toString() ?? '';
      
      print('📝 Register attempt: $email, $name, $businessName');
      
      if (email.contains('@') && password.length >= 6 && name.isNotEmpty) {
        print('✅ Registration success');
        return {
          'success': true,
          'user': {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'email': email,
            'name': name,
            'businessName': businessName,
          },
          'message': 'Conta criada com sucesso! Faça login para continuar.'
        };
      } else {
        print('❌ Registration failed: invalid data');
        return {
          'success': false,
          'message': 'Preencha todos os campos corretamente'
        };
      }
    }
    
    return {'success': true, 'message': 'Operação realizada'};
  }
  
  Future<Map<String, dynamic>> get(String path) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (path == '/dashboard/stats') {
      return {
        'success': true,
        'data': {
          'appointmentsToday': DateTime.now().day,
          'totalClients': DateTime.now().month * 10 + 50,
          'monthlyRevenue': (DateTime.now().month * 1000.0) + 500.0,
          'activeServices': 8,
          'weeklyGrowth': (DateTime.now().day % 20) + 5.0,
          'satisfactionRate': 4.5 + (DateTime.now().millisecond % 5) / 10,
        }
      };
    }
    
    return {'success': true, 'data': {}};
  }
  
  static Future<Map<String, dynamic>> generatePix({
    required String empresaId,
    required double valor,
    required String descricao,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'pixCode': '00020126580014br.gov.bcb.pix013636c4c14e-1234-4321-abcd-123456789012520400005303986540${valor.toStringAsFixed(2)}5802BR5925AGENDEMAIS LTDA6009SAO PAULO62070503***6304ABCD',
      'qrCode': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='
    };
  }
  
  static Future<List<Map<String, dynamic>>> getClients() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': '1', 'nome': 'Cliente Exemplo 1', 'telefone': '(11) 99999-9999'},
      {'id': '2', 'nome': 'Cliente Exemplo 2', 'telefone': '(11) 88888-8888'},
    ];
  }
  
  static Future<bool> updatePaymentStatus({
    required String empresaId,
    required String transactionId,
    required String status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}