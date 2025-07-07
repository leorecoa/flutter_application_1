import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';

class PixService {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> generatePixPayment({
    required double amount,
    required String description,
    String? clientId,
    String? appointmentId,
  }) async {
    final response = await _apiService.post('/payments/pix/generate', {
      'amount': amount,
      'description': description,
      if (clientId != null) 'clientId': clientId,
      if (appointmentId != null) 'appointmentId': appointmentId,
    });

    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Erro ao gerar PIX');
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    final response = await _apiService.get('/payments/pix/$transactionId/status');

    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Erro ao verificar status do pagamento');
    }
  }

  Future<Map<String, dynamic>> getPaymentHistory({
    int page = 0,
    int limit = 20,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    };

    final uri = Uri.parse('/payments/pix/history').replace(
      queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
    );

    final response = await _apiService.get(uri.toString());

    if (response['success'] == true) {
      return {
        'payments': response['data']['payments'] ?? [],
        'total': response['data']['total'] ?? 0,
        'hasMore': response['data']['hasMore'] ?? false,
      };
    } else {
      throw Exception(response['message'] ?? 'Erro ao carregar histórico de pagamentos');
    }
  }

  Future<Map<String, dynamic>> cancelPayment(String transactionId) async {
    final response = await _apiService.put('/payments/pix/$transactionId/cancel', {});

    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Erro ao cancelar pagamento');
    }
  }

  Future<Map<String, dynamic>> getPaymentDetails(String transactionId) async {
    final response = await _apiService.get('/payments/pix/$transactionId');

    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Erro ao carregar detalhes do pagamento');
    }
  }

  Future<Map<String, dynamic>> getPixConfiguration() async {
    final response = await _apiService.get('/payments/pix/config');

    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Erro ao carregar configuração PIX');
    }
  }

  Future<Map<String, dynamic>> updatePixSettings({
    String? pixKey,
    String? bankName,
    String? accountType,
  }) async {
    final data = <String, dynamic>{};
    if (pixKey != null) data['pixKey'] = pixKey;
    if (bankName != null) data['bankName'] = bankName;
    if (accountType != null) data['accountType'] = accountType;

    final response = await _apiService.put('/payments/pix/settings', data);

    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Erro ao atualizar configurações PIX');
    }
  }
}