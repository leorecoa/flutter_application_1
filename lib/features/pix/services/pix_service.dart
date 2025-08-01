import '../../../core/services/api_service.dart';

class PixService {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> createPixPayment(
    double amount,
    String description,
  ) async {
    try {
      final response = await _apiService.post(
        '/pix/payment',
        body: {'amount': amount, 'description': description},
      );
      return response;
    } catch (e) {
      throw Exception('Erro ao criar pagamento PIX: $e');
    }
  }

  Future<Map<String, dynamic>> getPixPaymentStatus(String paymentId) async {
    try {
      final response = await _apiService.get('/pix/payment/$paymentId/status');
      return response;
    } catch (e) {
      throw Exception('Erro ao verificar status do pagamento PIX: $e');
    }
  }

  Future<Map<String, dynamic>> getPixHistory() async {
    return await _apiService.get('/payments/pix/history');
  }

  Future<Map<String, dynamic>> cancelPix(String pixId) async {
    return await _apiService.post('/payments/pix/$pixId/cancel', body: {});
  }
}
