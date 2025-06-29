import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/cognito_service.dart';

class AuthGuard {
  static Future<String?> redirectLogic(BuildContext context, GoRouterState state) async {
    final isSignedIn = await CognitoService.isSignedIn();
    final isLoginRoute = state.matchedLocation == '/login';
    
    if (!isSignedIn && !isLoginRoute) {
      return '/login';
    }
    
    if (isSignedIn && isLoginRoute) {
      return '/dashboard';
    }
    
    return null;
  }
}