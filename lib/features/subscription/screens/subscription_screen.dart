import 'package:flutter/material.dart';
import '../../../core/theme/luxury_theme.dart';
import '../../../shared/widgets/luxury_card.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionModel? _currentSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSubscription();
  }

  Future<void> _loadCurrentSubscription() async {
    try {
      final subscription = await SubscriptionService.getCurrentSubscription();
      setState(() {
        _currentSubscription = subscription;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinatura'),
        backgroundColor: LuxuryTheme.deepBlue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [LuxuryTheme.pearl, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_currentSubscription != null) _buildCurrentPlan(),
                    const SizedBox(height: 24),
                    _buildAvailablePlans(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCurrentPlan() {
    final subscription = _currentSubscription!;
    
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: LuxuryTheme.primaryGold, size: 28),
              const SizedBox(width: 12),
              Text(
                'Plano Atual: ${subscription.plan}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: LuxuryTheme.deepBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLimitCard(
                  'Clientes',
                  subscription.limits.hasUnlimitedClients 
                    ? 'Ilimitado' 
                    : '${subscription.limits.clients}',
                  Icons.people,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLimitCard(
                  'Profissionais',
                  subscription.limits.hasUnlimitedBarbers 
                    ? 'Ilimitado' 
                    : '${subscription.limits.barbers}',
                  Icons.person,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLimitCard(
                  'Agendamentos',
                  subscription.limits.hasUnlimitedAppointments 
                    ? 'Ilimitado' 
                    : '${subscription.limits.appointments}',
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (subscription.plan != 'FREE')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: subscription.isExpired 
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    subscription.isExpired ? Icons.warning : Icons.check_circle,
                    color: subscription.isExpired ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    subscription.isExpired
                        ? 'Plano expirado'
                        : 'Expira em ${subscription.daysUntilExpiration} dias',
                    style: TextStyle(
                      color: subscription.isExpired ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLimitCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LuxuryTheme.primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: LuxuryTheme.primaryGold),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: LuxuryTheme.deepBlue,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePlans() {
    final plans = PlanModel.getAvailablePlans();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Planos Disponíveis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: LuxuryTheme.deepBlue,
          ),
        ),
        const SizedBox(height: 16),
        ...plans.map((plan) => _buildPlanCard(plan)),
      ],
    );
  }

  Widget _buildPlanCard(PlanModel plan) {
    final isCurrentPlan = _currentSubscription?.plan == plan.name;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: LuxuryCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: LuxuryTheme.deepBlue,
                  ),
                ),
                if (plan.isPopular)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: LuxuryTheme.primaryGold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  plan.price == 0 ? 'GRÁTIS' : 'R\$ ${plan.price.toStringAsFixed(2)}/mês',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: LuxuryTheme.primaryGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...plan.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(feature),
                ],
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrentPlan ? null : () => _upgradePlan(plan.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrentPlan 
                    ? Colors.grey 
                    : (plan.isPopular ? LuxuryTheme.primaryGold : LuxuryTheme.deepBlue),
                ),
                child: Text(
                  isCurrentPlan 
                    ? 'Plano Atual' 
                    : (plan.name == 'FREE' ? 'Downgrade' : 'Upgrade'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _upgradePlan(String planName) async {
    try {
      setState(() => _isLoading = true);
      
      // TODO: Show payment dialog for paid plans
      if (planName != 'FREE') {
        final shouldProceed = await _showPaymentDialog(planName);
        if (!shouldProceed) {
          setState(() => _isLoading = false);
          return;
        }
      }
      
      await SubscriptionService.upgradePlan(planName);
      await _loadCurrentSubscription();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plano alterado para $planName com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar plano: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showPaymentDialog(String planName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade para $planName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escolha a forma de pagamento:'),
            const SizedBox(height: 16),
            // TODO: Implement payment method selection
            const Text('⚠️ Integração de pagamento será configurada em breve'),
            const SizedBox(height: 8),
            const Text('Por enquanto, o upgrade será feito gratuitamente para testes.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    ) ?? false;
  }
}