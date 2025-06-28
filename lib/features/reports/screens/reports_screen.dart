import 'package:flutter/material.dart';
import '../../../core/theme/luxury_theme.dart';
import '../../../shared/widgets/luxury_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [LuxuryTheme.pearl, Colors.white]),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LuxuryCard(
              child: Column(
                children: [
                  const Text('Receita Mensal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Text('R\$ 15.420', style: TextStyle(fontSize: 32, color: Colors.green[600], fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}