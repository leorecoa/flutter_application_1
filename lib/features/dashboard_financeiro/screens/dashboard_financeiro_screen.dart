import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/admin_layout.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/finance_data.dart';
import '../services/relatorio_service.dart';
import '../widgets/grafico_mensal.dart';
import '../widgets/grafico_barbeiro.dart';
import '../widgets/grafico_servico.dart';

class DashboardFinanceiroScreen extends StatefulWidget {
  const DashboardFinanceiroScreen({super.key});

  @override
  State<DashboardFinanceiroScreen> createState() => _DashboardFinanceiroScreenState();
}

class _DashboardFinanceiroScreenState extends State<DashboardFinanceiroScreen> {
  DashboardFinanceiroData? _dashboardData;
  bool _isLoading = false;
  
  PeriodoFiltro _periodoSelecionado = PeriodoFiltro.mesAtual;
  String? _barbeiroSelecionado;
  DateTime? _dataInicio;
  DateTime? _dataFim;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    setState(() => _isLoading = true);
    
    final data = await RelatorioService.getDashboardData(
      periodo: _periodoSelecionado,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
      barbeiroId: _barbeiroSelecionado,
    );
    
    setState(() {
      _dashboardData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Dashboard Financeiro',
      currentRoute: '/admin/dashboard-financeiro',
      child: Column(
        children: [
          _buildFiltros(),
          const SizedBox(height: 24),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_dashboardData != null)
            Expanded(child: _buildDashboard()),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildPeriodoFilter()),
              const SizedBox(width: 16),
              Expanded(child: _buildBarbeiroFilter()),
              const SizedBox(width: 16),
              if (_periodoSelecionado == PeriodoFiltro.personalizado) ...[
                Expanded(child: _buildDataInicioFilter()),
                const SizedBox(width: 16),
                Expanded(child: _buildDataFimFilter()),
                const SizedBox(width: 16),
              ],
              _buildAtualizarButton(),
            ],
          ),
          if (_dashboardData != null) ...[
            const SizedBox(height: 16),
            _buildResumo(),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodoFilter() {
    return DropdownButtonFormField<PeriodoFiltro>(
      value: _periodoSelecionado,
      decoration: const InputDecoration(
        labelText: 'Período',
        prefixIcon: Icon(Icons.calendar_today_outlined),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: PeriodoFiltro.mesAtual, child: Text('Mês Atual')),
        DropdownMenuItem(value: PeriodoFiltro.ultimos3Meses, child: Text('Últimos 3 Meses')),
        DropdownMenuItem(value: PeriodoFiltro.anoAtual, child: Text('Ano Atual')),
        DropdownMenuItem(value: PeriodoFiltro.personalizado, child: Text('Personalizado')),
      ],
      onChanged: (value) {
        setState(() => _periodoSelecionado = value!);
        if (value != PeriodoFiltro.personalizado) {
          _carregarDados();
        }
      },
    );
  }

  Widget _buildBarbeiroFilter() {
    return DropdownButtonFormField<String>(
      value: _barbeiroSelecionado,
      decoration: const InputDecoration(
        labelText: 'Barbeiro',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Todos os Barbeiros')),
        DropdownMenuItem(value: 'carlos', child: Text('Carlos')),
        DropdownMenuItem(value: 'roberto', child: Text('Roberto')),
        DropdownMenuItem(value: 'ana', child: Text('Ana')),
      ],
      onChanged: (value) {
        setState(() => _barbeiroSelecionado = value);
        _carregarDados();
      },
    );
  }

  Widget _buildDataInicioFilter() {
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Data Início',
        prefixIcon: Icon(Icons.calendar_today_outlined),
        border: OutlineInputBorder(),
      ),
      controller: TextEditingController(
        text: _dataInicio != null ? DateFormat('dd/MM/yyyy').format(_dataInicio!) : '',
      ),
      onTap: () async {
        final data = await showDatePicker(
          context: context,
          initialDate: _dataInicio ?? DateTime.now().subtract(const Duration(days: 30)),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (data != null) {
          setState(() => _dataInicio = data);
        }
      },
    );
  }

  Widget _buildDataFimFilter() {
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Data Fim',
        prefixIcon: Icon(Icons.calendar_today_outlined),
        border: OutlineInputBorder(),
      ),
      controller: TextEditingController(
        text: _dataFim != null ? DateFormat('dd/MM/yyyy').format(_dataFim!) : '',
      ),
      onTap: () async {
        final data = await showDatePicker(
          context: context,
          initialDate: _dataFim ?? DateTime.now(),
          firstDate: _dataInicio ?? DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (data != null) {
          setState(() => _dataFim = data);
        }
      },
    );
  }

  Widget _buildAtualizarButton() {
    return ElevatedButton.icon(
      onPressed: _carregarDados,
      icon: const Icon(Icons.refresh),
      label: const Text('Atualizar'),
    );
  }

  Widget _buildResumo() {
    final data = _dashboardData!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TrinksTheme.lightPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResumoItem('Total Receita', 'R\$ ${data.totalReceita.toStringAsFixed(0)}', Icons.trending_up),
          _buildResumoItem('Total Serviços', '${data.totalServicos}', Icons.content_cut),
          _buildResumoItem('Ticket Médio', 'R\$ ${(data.totalReceita / data.totalServicos).toStringAsFixed(0)}', Icons.receipt_long),
        ],
      ),
    );
  }

  Widget _buildResumoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: TrinksTheme.navyBlue, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: TrinksTheme.navyBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: TrinksTheme.darkGray.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    final data = _dashboardData!;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Gráfico Mensal (full width)
          GraficoMensal(dados: data.ganhosMensais),
          const SizedBox(height: 24),
          // Gráficos lado a lado
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: GraficoBarbeiro(dados: data.receitaPorBarbeiro)),
              const SizedBox(width: 24),
              Expanded(child: GraficoServico(dados: data.receitaPorServico)),
            ],
          ),
        ],
      ),
    );
  }
}