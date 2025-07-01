import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pix_payment_model.dart';

class PixService {
  static const String baseUrl = 'https://oovjqmref8.execute-api.us-east-1.amazonaws.com/dev';

  static Future<PixPayment> createPixPayment({
    required double amount,
    required String description,
    required String email,
    required String name,
    required String tenantId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pix/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'valor': amount,
        'nome': name,
        'email': email,
        'tenantId': tenantId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PixPayment(
        paymentId: data['paymentId'],
        amount: amount,
        description: description,
        status: data['status'],
        pixCode: data['pixCode'],
        pixQrCodeBase64: data['pixQrCodeBase64'],
        createdAt: DateTime.now(),
      );
    } else {
      throw Exception('Erro ao criar pagamento PIX');
    }
  }

  static Future<String> checkPaymentStatus(String paymentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pix/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'paymentId': paymentId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'];
    } else {
      throw Exception('Erro ao verificar status do pagamento');
    }
  }
}