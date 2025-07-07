import 'dart:convert';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final ApiService _apiService = ApiService();
  
  // Cache for frequently accessed data
  Map<String, dynamic>? _cachedStats;
  DateTime? _lastStatsUpdate;

  Future<Map<String, dynamic>> getDashboardStats({bool forceRefresh = false}) async {
    // Return cached data if available and not expired
    if (!forceRefresh && 
        _cachedStats != null && 
        _lastStatsUpdate != null &&
        DateTime.now().difference(_lastStatsUpdate!) < AppConstants.cacheTimeout) {
      return _cachedStats!;
    }

    try {
      final response = await _apiService.get('/dashboard/stats');
      
      if (response['success'] == true) {
        _cachedStats = response['data'];
        _lastStatsUpdate = DateTime.now();
        return _cachedStats!;
      } else {
        // Return mock data if API fails (for resilience)
        return _getMockStats();
      }
    } catch (e) {
      // Return mock data for offline functionality
      return _getMockStats();
    }
  }

  Future<Map<String, dynamic>> getNextAppointments({
    int page = 0, 
    int limit = 20,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final uri = Uri.parse('/dashboard/appointments').replace(
        queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
      );

      final response = await _apiService.get(uri.toString());
      
      if (response['success'] == true) {
        return {
          'appointments': response['data']['appointments'] ?? [],
          'total': response['data']['total'] ?? 0,
          'hasMore': response['data']['hasMore'] ?? false,
        };
      } else {
        return _getMockAppointments(page, limit);
      }
    } catch (e) {
      return _getMockAppointments(page, limit);
    }
  }

  Future<Map<String, dynamic>> getRecentActivity({
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get('/dashboard/activity?limit=$limit');
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        return _getMockActivity();
      }
    } catch (e) {
      return _getMockActivity();
    }
  }

  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    try {
      final response = await _apiService.get('/dashboard/metrics', useCache: true);
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        return _getMockMetrics();
      }
    } catch (e) {
      return _getMockMetrics();
    }
  }

  void clearCache() {
    _cachedStats = null;
    _lastStatsUpdate = null;
  }

  // Mock data for offline functionality and development
  Map<String, dynamic> _getMockStats() {
    return {
      'appointmentsToday': 8,
      'totalClients': 142,
      'monthlyRevenue': 15750.50,
      'activeServices': 12,
      'weeklyGrowth': 15,
      'satisfactionRate': 4.8,
      'completedToday': 5,
      'pendingToday': 3,
      'canceledToday': 0,
    };
  }

  Map<String, dynamic> _getMockAppointments(int page, int limit) {
    final mockAppointments = List.generate(limit, (index) {
      final appointmentIndex = (page * limit) + index;
      return {
        'id': 'apt_${appointmentIndex}',
        'clientName': 'Cliente ${appointmentIndex + 1}',
        'service': 'Corte de Cabelo',
        'price': 45.0 + (index * 5),
        'dateTime': DateTime.now().add(Duration(hours: index + 1)).toIso8601String(),
        'status': index % 3 == 0 ? 'confirmed' : 'pending',
        'duration': 60,
        'notes': 'Observações do agendamento',
      };
    });

    return {
      'appointments': page < 2 ? mockAppointments : [], // Simulate pagination end
      'total': page < 2 ? 50 : 40,
      'hasMore': page < 2,
    };
  }

  Map<String, dynamic> _getMockActivity() {
    return {
      'activities': [
        {
          'id': 'act_1',
          'type': 'appointment_created',
          'description': 'Novo agendamento criado',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
          'client': 'João Silva',
        },
        {
          'id': 'act_2',
          'type': 'payment_received',
          'description': 'Pagamento recebido',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          'amount': 85.0,
        },
        {
          'id': 'act_3',
          'type': 'appointment_completed',
          'description': 'Serviço finalizado',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'client': 'Maria Santos',
        },
      ]
    };
  }

  Map<String, dynamic> _getMockMetrics() {
    return {
      'revenue': {
        'daily': [120, 150, 200, 180, 220, 190, 250],
        'weekly': [1200, 1350, 1500, 1400],
        'monthly': [15000, 16500, 18000, 17500],
      },
      'appointments': {
        'completed': 85,
        'pending': 12,
        'canceled': 3,
      },
      'popularServices': [
        {'name': 'Corte de Cabelo', 'count': 45, 'revenue': 2250},
        {'name': 'Manicure', 'count': 32, 'revenue': 960},
        {'name': 'Massagem', 'count': 28, 'revenue': 2100},
      ],
      'busyHours': [
        {'hour': 9, 'appointments': 8},
        {'hour': 14, 'appointments': 12},
        {'hour': 16, 'appointments': 15},
        {'hour': 18, 'appointments': 10},
      ],
    };
  }
}