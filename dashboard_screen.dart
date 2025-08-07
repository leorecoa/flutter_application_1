import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/providers/firebase_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Ao pressionar, faz o logout e o GoRouter redirecionará para /login
              ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: const Center(child: Text('Bem-vindo! Você está logado.')),
    );
  }
}
