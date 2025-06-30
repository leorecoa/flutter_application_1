import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../models/subscription_model.dart';

class SubscriptionService {
  static const String _baseUrl = '${AppConfig.apiGatewayUrl}/subscription';

  static Future<SubscriptionModel> getCurrentSubscription() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add Authorization header with Cognito token
          // 'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SubscriptionModel.fromJson(data);
      } else {
        throw Exception('Failed to load subscription');
      }
    } catch (e) {
      // Return default FREE subscription for now
      return SubscriptionModel(
        plan: 'FREE',
        status: 'ACTIVE',
        limits: SubscriptionLimits(clients: 5, barbers: 1, appointments: 50),
        price: 0,
        startDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 30)),
        paymentStatus: 'ACTIVE',
      );
    }
  }

  static Future<SubscriptionModel> createSubscription(String plan) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add Authorization header
        },
        body: json.encode({'plan': plan}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return SubscriptionModel.fromJson(data);
      } else {
        throw Exception('Failed to create subscription');
      }
    } catch (e) {
      throw Exception('Error creating subscription: $e');
    }
  }

  static Future<SubscriptionModel> upgradePlan(String newPlan) async {
    try {
      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add Authorization header
        },
        body: json.encode({'plan': newPlan}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SubscriptionModel.fromJson(data);
      } else {
        throw Exception('Failed to upgrade plan');
      }
    } catch (e) {
      throw Exception('Error upgrading plan: $e');
    }
  }

  static Future<bool> checkLimit(String limitType, int currentCount) async {
    try {
      final subscription = await getCurrentSubscription();
      
      switch (limitType) {
        case 'clients':
          return subscription.limits.hasUnlimitedClients || 
                 currentCount < subscription.limits.clients;
        case 'barbers':
          return subscription.limits.hasUnlimitedBarbers || 
                 currentCount < subscription.limits.barbers;
        case 'appointments':
          return subscription.limits.hasUnlimitedAppointments || 
                 currentCount < subscription.limits.appointments;
        default:
          return true;
      }
    } catch (e) {
      return false;
    }
  }

  // TODO: Implement payment processing
  // static Future<String> processPayment(String plan, String paymentMethod) async {
  //   // Stripe integration
  //   if (paymentMethod == 'STRIPE') {
  //     return await _processStripePayment(plan);
  //   }
  //   
  //   // PIX integration
  //   if (paymentMethod == 'PIX') {
  //     return await _processPixPayment(plan);
  //   }
  //   
  //   throw Exception('Unsupported payment method');
  // }
}