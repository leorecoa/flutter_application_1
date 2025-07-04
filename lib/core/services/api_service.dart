import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl => 'https://dy2yuasirk.execute-api.us-east-1.amazonaws.com/dev';
  
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
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }
  
  static Future<Map<String, dynamic>> generatePix({
    required String empresaId,
    required double valor,
    required String descricao,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pix/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'empresa_id': empresaId,
          'valor': valor,
          'descricao': descricao,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao gerar PIX: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
  
  static Future<List<Map<String, dynamic>>> getClients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clientes/ativos'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['clientes'] ?? []);
      } else {
        throw Exception('Erro ao buscar clientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
  
  static Future<bool> updatePaymentStatus({
    required String empresaId,
    required String transactionId,
    required String status,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/payment/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'empresa_id': empresaId,
          'transaction_id': transactionId,
          'status': status,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}