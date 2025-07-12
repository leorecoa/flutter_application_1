import '../../../core/services/api_service.dart';

class PixService {
  final _apiService = ApiService();

  Future<Map<String, dynamic>> generatePixCode({
    required double amount,
    required String description,
    String? clientName,
    String? clientEmail,
  }) async {
    return await _apiService.post('/payments/pix/generate', {
      'amount': amount,
      'description': description,
      'clientName': clientName,
      'clientEmail': clientEmail,
    });
  }

  Future<Map<String, dynamic>> checkPixStatus(String pixId) async {
    return await _apiService.get('/payments/pix/$pixId/status');
  }

  Future<Map<String, dynamic>> getPixHistory() async {
    return await _apiService.get('/payments/pix/history');
  }

  Future<Map<String, dynamic>> cancelPix(String pixId) async {
    return await _apiService.post('/payments/pix/$pixId/cancel', {});
  }
}