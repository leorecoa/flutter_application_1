import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadUser();
  }

  final _apiService = ApiService();

  Future<void> _loadUser() async {
    if (_apiService.currentUser != null) {
      state = state.copyWith(user: _apiService.currentUser);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        final user = User.fromJson(response['user']);
        await _apiService.setAuthToken(response['token'], user);
        state = state.copyWith(user: user, isLoading: false);
        return true;
      } else {
        state = state.copyWith(error: response['message'], isLoading: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.clearAuthToken();
    state = const AuthState();
  }
}

// Services Provider
final servicesProvider = FutureProvider<List<Service>>((ref) async {
  final cache = CacheService();
  final cached = await cache.get<List>('cache_services');
  
  if (cached != null) {
    return cached.map((json) => Service.fromJson(json)).toList();
  }

  final apiService = ApiService();
  final response = await apiService.get('/services');
  
  if (response['success'] == true) {
    final services = List<Map<String, dynamic>>.from(response['data'] ?? []);
    await cache.set('cache_services', services);
    return services.map((json) => Service.fromJson(json)).toList();
  }
  
  return [];
});

// Dashboard Stats Provider
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final cache = CacheService();
  final cached = await cache.get<Map<String, dynamic>>('cache_dashboard');
  
  if (cached != null) {
    return cached;
  }

  final apiService = ApiService();
  final response = await apiService.get('/dashboard/stats');
  
  if (response['success'] == true) {
    final stats = response['data'] ?? {};
    await cache.set('cache_dashboard', stats, ttl: const Duration(minutes: 5));
    return stats;
  }
  
  return {};
});