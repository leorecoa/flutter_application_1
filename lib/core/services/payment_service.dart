import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../utils/storage_utils.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  
  factory PaymentService() => _instance;
  
  PaymentService._internal();
  
  final String _pixKey = '05359566493'; // CPF configurado
  
  String get apiUrl => dotenv.env['API_URL'] ?? 'https://api.agendafacil.com';
  
  /// Gera um pagamento PIX rastreável por cliente
  Future<Map<String, dynamic>> generatePixPayment({
    required String clientId,
    required double amount,
    required String description,
  }) async {
    final businessId = await StorageUtils.getCurrentBusinessId();
    
    final response = await http.post(
      Uri.parse('$apiUrl/payments/pix/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pixKey': _pixKey,
        'amount': amount,
        'description': description,
        'clientId': clientId, // ID do cliente para rastreamento
        'metadata': {
          'businessId': businessId,
          'transactionType': 'subscription',
          'timestamp': DateTime.now().toIso8601String(),
        }
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao gerar PIX: ${response.body}');
    }
  }
  
  /// Verifica o status de um pagamento PIX
  Future<Map<String, dynamic>> checkPixStatus(String transactionId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/payments/pix/status/$transactionId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao verificar status do PIX: ${response.body}');
    }
  }
  
  /// Obtém histórico de pagamentos
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final businessId = await StorageUtils.getCurrentBusinessId();
    
    final response = await http.get(
      Uri.parse('$apiUrl/payments/history?businessId=$businessId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Falha ao obter histórico de pagamentos: ${response.body}');
    }
  }
}