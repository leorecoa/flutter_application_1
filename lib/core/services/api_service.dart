import 'package:dio/dio.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'amplify_service.dart';

class ApiService {
  static final Dio _dio = Dio();
  static const String baseUrl = 'https://hk5bp3m596.execute-api.us-east-1.amazonaws.com/Prod';

  static Future<void> _addAuthHeader() async {
    final token = await AmplifyService.getAccessToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Appointments
  static Future<List<dynamic>> getAppointments() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('$baseUrl/appointments');
      return response.data['appointments'] ?? [];
    } catch (e) {
      safePrint('Error getting appointments: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createAppointment(Map<String, dynamic> appointment) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('$baseUrl/appointments', data: appointment);
      return response.data;
    } catch (e) {
      safePrint('Error creating appointment: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateAppointment(String id, Map<String, dynamic> appointment) async {
    try {
      await _addAuthHeader();
      final response = await _dio.put('$baseUrl/appointments/$id', data: appointment);
      return response.data;
    } catch (e) {
      safePrint('Error updating appointment: $e');
      return null;
    }
  }

  static Future<bool> deleteAppointment(String id) async {
    try {
      await _addAuthHeader();
      await _dio.delete('$baseUrl/appointments/$id');
      return true;
    } catch (e) {
      safePrint('Error deleting appointment: $e');
      return false;
    }
  }

  // Clients
  static Future<List<dynamic>> getClients() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('$baseUrl/clients');
      return response.data['clients'] ?? [];
    } catch (e) {
      safePrint('Error getting clients: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createClient(Map<String, dynamic> client) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('$baseUrl/clients', data: client);
      return response.data;
    } catch (e) {
      safePrint('Error creating client: $e');
      return null;
    }
  }

  // Services
  static Future<List<dynamic>> getServices() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('$baseUrl/services');
      return response.data['services'] ?? [];
    } catch (e) {
      safePrint('Error getting services: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createService(Map<String, dynamic> service) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('$baseUrl/services', data: service);
      return response.data;
    } catch (e) {
      safePrint('Error creating service: $e');
      return null;
    }
  }

  // Dashboard Stats
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('$baseUrl/dashboard/stats');
      return response.data ?? {};
    } catch (e) {
      safePrint('Error getting dashboard stats: $e');
      return {
        'totalAppointments': 0,
        'totalClients': 0,
        'totalRevenue': 0,
        'satisfaction': 0,
      };
    }
  }
}