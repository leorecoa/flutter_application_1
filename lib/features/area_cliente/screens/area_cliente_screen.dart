import 'package:flutter/material.dart';
import '../../../core/theme/trinks_theme.dart';
import '../../appointments/models/agendamento_model.dart';
import '../../payments/models/payment_model.dart';
import '../services/cliente_service.dart';
import '../widgets/lista_agendamentos.dart';
import '../widgets/lista_pagamentos.dart';

class AreaClienteScreen extends StatefulWidget {
  const AreaClienteScreen({super.key});

  @override
  State<AreaClienteScreen> createState() => _AreaClienteScreenState();
}

class _AreaClienteScreenState extends State<AreaClienteScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<Agendamento> _agendamentos = [];
  List<Payment> _pagamentos = [];
  bool _isLoadingAgendamentos = false;
  bool _isLoadingPagamentos = false;

  String? _clienteId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    _clienteId = await ClienteService.getCurrentClienteId();
    _carregarAgendamentos();
    _carregarPagamentos();
  }

  Future<void> _carregarAgendamentos() async {
    if (_clienteId == null) return;

    setState(() => _isLoadingAgendamentos = true);

    final agendamentos =
        await ClienteService.getAgendamentosCliente(_clienteId!);

    setState(() {
      _agendamentos = agendamentos;
      _isLoadingAgendamentos = false;
    });
  }

  Future<void> _carregarPagamentos() async {
    if (_clienteId == null) return;

    setState(() => _isLoadingPagamentos = true);

    final pagamentos = await ClienteService.getPagamentosCliente(_clienteId!);

    setState(() {
      _pagamentos = pagamentos;
      _isLoadingPagamentos = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrinksTheme.lightGray,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TrinksTheme.navyBlue, TrinksTheme.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: TrinksTheme.darkGray.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TrinksTheme.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.content_cut,
                  color: TrinksTheme.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AgendaFácil',
                    style: TextStyle(
                      color: TrinksTheme.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Área do Cliente',
                    style: TextStyle(
                      color: TrinksTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: TrinksTheme.white),
              tooltip: 'Sair',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: TrinksTheme.white,
      child: TabBar(
        controller: _tabController,
        labelColor: TrinksTheme.navyBlue,
        unselectedLabelColor: TrinksTheme.darkGray.withValues(alpha: 0.6),
        indicatorColor: TrinksTheme.navyBlue,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.calendar_today_outlined),
            text: 'Agendamentos',
          ),
          Tab(
            icon: Icon(Icons.payment_outlined),
            text: 'Pagamentos',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        ListaAgendamentos(
          agendamentos: _agendamentos,
          isLoading: _isLoadingAgendamentos,
        ),
        ListaPagamentos(
          pagamentos: _pagamentos,
          isLoading: _isLoadingPagamentos,
        ),
      ],
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar logout com Cognito
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: TrinksTheme.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
