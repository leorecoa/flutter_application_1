import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_guard.dart';
import '../../../core/constants/app_constants.dart';
import '../services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  final _apiService = ApiService();
  final _dashboardService = DashboardService();
  Map<String, dynamic>? _stats;
  List<dynamic> _nextAppointments = [];
  bool _isLoading = true;
  bool _isLoadingAppointments = false;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndLoadData() async {
    await AuthGuard.requireAuth(context);
    if (mounted) {
      _loadDashboard();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreAppointments();
    }
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    
    try {
      // Load stats and initial appointments in parallel
      final futures = await Future.wait([
        _dashboardService.getDashboardStats(),
        _dashboardService.getNextAppointments(page: 0, limit: AppConstants.pageSize),
      ]);
      
      if (mounted) {
        setState(() {
          _stats = futures[0] as Map<String, dynamic>;
          _nextAppointments = (futures[1] as Map<String, dynamic>)['appointments'] as List<dynamic>;
          _currentPage = 0;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _loadMoreAppointments() async {
    if (_isLoadingAppointments || _hasError) return;
    
    setState(() => _isLoadingAppointments = true);
    
    try {
      final response = await _dashboardService.getNextAppointments(
        page: _currentPage + 1, 
        limit: AppConstants.pageSize,
      );
      
      final newAppointments = response['appointments'] as List<dynamic>;
      
      if (mounted && newAppointments.isNotEmpty) {
        setState(() {
          _nextAppointments.addAll(newAppointments);
          _currentPage++;
          _isLoadingAppointments = false;
        });
      } else {
        setState(() => _isLoadingAppointments = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAppointments = false);
        _showErrorSnackbar('Erro ao carregar mais agendamentos');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Tentar novamente',
          onPressed: _loadDashboard,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    AuthGuard.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: MediaQuery.of(context).size.width > 768 ? null : AppBar(
        title: Text('Olá, ${_apiService.currentUser?.name ?? 'Usuário'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showNewAppointmentDialog(),
            tooltip: 'Novo Agendamento',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Configurações',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando dashboard...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Verifique sua conexão e tente novamente',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visão Geral',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  const Text(
                    'Próximos Agendamentos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildAppointmentsList(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Ações Rápidas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 768 ? 3 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _StatCard(
              title: 'Agendamentos Hoje',
              value: _stats?['appointmentsToday']?.toString() ?? '0',
              icon: Icons.calendar_today,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Total de Clientes',
              value: _stats?['totalClients']?.toString() ?? '0',
              icon: Icons.people,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Receita do Mês',
              value: 'R\$ ${(_stats?['monthlyRevenue'] ?? 0.0).toStringAsFixed(2).replaceAll('.', ',')}',
              icon: Icons.attach_money,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Serviços Ativos',
              value: _stats?['activeServices']?.toString() ?? '0',
              icon: Icons.build,
              color: Colors.purple,
            ),
            _StatCard(
              title: 'Crescimento Semanal',
              value: '+${_stats?['weeklyGrowth']?.toString() ?? '0'}%',
              icon: Icons.trending_up,
              color: Colors.teal,
            ),
            _StatCard(
              title: 'Satisfação',
              value: '${_stats?['satisfactionRate']?.toString() ?? '0'}/5 ⭐',
              icon: Icons.star,
              color: Colors.amber,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentsList() {
    if (_nextAppointments.isEmpty && !_isLoadingAppointments) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.calendar_today, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum agendamento encontrado',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < _nextAppointments.length) {
            final appointment = _nextAppointments[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _AppointmentCard(appointment: appointment),
            );
          } else if (_isLoadingAppointments) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return null;
        },
        childCount: _nextAppointments.length + (_isLoadingAppointments ? 1 : 0),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _ActionButton(
          title: 'Agendamentos',
          icon: Icons.calendar_today,
          onTap: () => context.push('/appointments'),
        ),
        _ActionButton(
          title: 'Relatórios',
          icon: Icons.analytics,
          onTap: () => context.push('/reports'),
        ),
        _ActionButton(
          title: 'PIX Pagamentos',
          icon: Icons.pix,
          onTap: () => context.push('/pix'),
        ),
        _ActionButton(
          title: 'Configurações',
          icon: Icons.settings,
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }

  void _showNewAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Agendamento'),
        content: const Text('Redirecionando para a tela de agendamentos...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/appointments');
            },
            child: const Text('Ir para Agendamentos'),
          ),
        ],
      ),
    );
  }
}

// Extracted widgets for better performance
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final Map<String, dynamic> appointment;

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.tryParse(appointment['dateTime'] ?? '') ?? DateTime.now();
    
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: appointment['status'] == 'confirmed' 
              ? Colors.green : Colors.orange,
          child: const Icon(Icons.schedule, color: Colors.white),
        ),
        title: Text(appointment['clientName'] ?? 'Cliente'),
        subtitle: Text('${appointment['service'] ?? 'Serviço'} - R\$ ${(appointment['price'] ?? 0.0).toStringAsFixed(2)}'),
        trailing: Text(
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
