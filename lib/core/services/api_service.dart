import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl => 'https://dy2yuasirk.execute-api.us-east-1.amazonaws.com/dev';
  
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