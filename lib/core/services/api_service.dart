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
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (path == '/auth/login') {
      final password = data['password']?.toString() ?? '';
      if (data['email']?.toString().contains('@') == true && 
          password.length >= 6) {
        return {
          'success': true,
          'token': 'user-token-${DateTime.now().millisecondsSinceEpoch}',
          'message': 'Login realizado com sucesso'
        };
      } else {
        return {
          'success': false,
          'message': 'Email ou senha inválidos'
        };
      }
    }
    
    if (path == '/auth/register') {
      final password = data['password']?.toString() ?? '';
      if (data['email']?.toString().contains('@') == true && 
          password.length >= 6 &&
          data['name']?.toString().isNotEmpty == true) {
        return {
          'success': true,
          'message': 'Conta criada com sucesso'
        };
      } else {
        return {
          'success': false,
          'message': 'Dados inválidos'
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