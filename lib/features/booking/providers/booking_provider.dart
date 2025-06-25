import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';

class BookingProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/booking', bookingData);
      
      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Erro ao criar agendamento';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<String>> getAvailableTimes(String professionalId, String date) async {
    try {
      final response = await _apiService.get('/booking/available-times', {
        'professionalId': professionalId,
        'date': date,
      });
      
      if (response['success'] == true) {
        return List<String>.from(response['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}