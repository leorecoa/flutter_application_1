import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class AuthGuard {
  static Future<String?> redirectLogic(BuildContext context, GoRouterState state) async {
    // Desabilitado temporariamente para desenvolvimento
    return null;
  }
}