import '../models/finance_data.dart';

class RelatorioService {
  static Future<DashboardFinanceiroData> getDashboardData({
    PeriodoFiltro periodo = PeriodoFiltro.mesAtual,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? barbeiroId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data baseado no período
    final ganhosMensais = _getGanhosMensais(periodo);
    final receitaPorBarbeiro = _getReceitaPorBarbeiro(barbeiroId);
    final receitaPorServico = _getReceitaPorServico();

    final totalReceita = ganhosMensais.fold(0.0, (sum, item) => sum + item.valor);
    final totalServicos = ganhosMensais.fold(0, (sum, item) => sum + item.quantidadeServicos);

    return DashboardFinanceiroData(
      ganhosMensais: ganhosMensais,
      receitaPorBarbeiro: receitaPorBarbeiro,
      receitaPorServico: receitaPorServico,
      totalReceita: totalReceita,
      totalServicos: totalServicos,
    );
  }

  static List<GanhoMensal> _getGanhosMensais(PeriodoFiltro periodo) {
    switch (periodo) {
      case PeriodoFiltro.mesAtual:
        return [
          const GanhoMensal(mes: 'Dez', valor: 8500, quantidadeServicos: 145),
        ];
      case PeriodoFiltro.ultimos3Meses:
        return [
          const GanhoMensal(mes: 'Out', valor: 7200, quantidadeServicos: 128),
          const GanhoMensal(mes: 'Nov', valor: 8100, quantidadeServicos: 142),
          const GanhoMensal(mes: 'Dez', valor: 8500, quantidadeServicos: 145),
        ];
      case PeriodoFiltro.anoAtual:
        return [
          const GanhoMensal(mes: 'Jan', valor: 6800, quantidadeServicos: 115),
          const GanhoMensal(mes: 'Fev', valor: 7200, quantidadeServicos: 125),
          const GanhoMensal(mes: 'Mar', valor: 7800, quantidadeServicos: 135),
          const GanhoMensal(mes: 'Abr', valor: 7500, quantidadeServicos: 130),
          const GanhoMensal(mes: 'Mai', valor: 8200, quantidadeServicos: 140),
          const GanhoMensal(mes: 'Jun', valor: 7900, quantidadeServicos: 138),
          const GanhoMensal(mes: 'Jul', valor: 8400, quantidadeServicos: 148),
          const GanhoMensal(mes: 'Ago', valor: 8100, quantidadeServicos: 142),
          const GanhoMensal(mes: 'Set', valor: 7600, quantidadeServicos: 132),
          const GanhoMensal(mes: 'Out', valor: 7200, quantidadeServicos: 128),
          const GanhoMensal(mes: 'Nov', valor: 8100, quantidadeServicos: 142),
          const GanhoMensal(mes: 'Dez', valor: 8500, quantidadeServicos: 145),
        ];
      case PeriodoFiltro.personalizado:
        return [
          const GanhoMensal(mes: 'Nov', valor: 8100, quantidadeServicos: 142),
          const GanhoMensal(mes: 'Dez', valor: 8500, quantidadeServicos: 145),
        ];
    }
  }

  static List<ReceitaBarbeiro> _getReceitaPorBarbeiro(String? filtroId) {
    final todos = [
      const ReceitaBarbeiro(nome: 'Carlos', valor: 3200, quantidadeServicos: 58),
      const ReceitaBarbeiro(nome: 'Roberto', valor: 2800, quantidadeServicos: 52),
      const ReceitaBarbeiro(nome: 'Ana', valor: 2500, quantidadeServicos: 35),
    ];

    if (filtroId != null) {
      return todos.where((b) => b.nome.toLowerCase().contains(filtroId.toLowerCase())).toList();
    }

    return todos;
  }

  static List<ReceitaServico> _getReceitaPorServico() {
    return [
      const ReceitaServico(nome: 'Corte + Barba', valor: 3850, quantidade: 70),
      const ReceitaServico(nome: 'Corte', valor: 2450, quantidade: 70),
      const ReceitaServico(nome: 'Barba', valor: 1500, quantidade: 60),
      const ReceitaServico(nome: 'Sobrancelha', valor: 525, quantidade: 35),
      const ReceitaServico(nome: 'Lavagem', valor: 200, quantidade: 20),
    ];
  }
}