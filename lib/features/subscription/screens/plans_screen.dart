import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/subscription_model.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  bool _isYearly = false;
  final _plans = SubscriptionPlan.getDefaultPlans();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu Plano'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Escolha o plano ideal para seu negócio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton('Mensal', !_isYearly),
                  _buildToggleButton('Anual (2 meses grátis)', _isYearly),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 768 ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _plans.length,
              itemBuilder: (context, index) => _buildPlanCard(_plans[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isYearly = text.contains('Anual')),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final price = _isYearly ? plan.yearlyPrice : plan.monthlyPrice;
    
    return Card(
      elevation: plan.isPopular ? 8 : 2,
      child: Container(
        decoration: plan.isPopular
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 2),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MAIS POPULAR',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              Text(plan.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}/${_isYearly ? 'ano' : 'mês'}',
                   style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...plan.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              )),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _selectPlan(plan),
                  child: Text('Escolher ${plan.name}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectPlan(SubscriptionPlan plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plano ${plan.name} selecionado! Redirecionando para pagamento...')),
    );
    Future.delayed(const Duration(seconds: 1), () => context.go('/dashboard'));
  }
}