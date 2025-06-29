class GanhoMensal {
  final String mes;
  final double valor;
  final int quantidadeServicos;

  const GanhoMensal({
    required this.mes,
    required this.valor,
    required this.quantidadeServicos,
  });
}

class ReceitaBarbeiro {
  final String nome;
  final double valor;
  final int quantidadeServicos;

  const ReceitaBarbeiro({
    required this.nome,
    required this.valor,
    required this.quantidadeServicos,
  });
}

class ReceitaServico {
  final String nome;
  final double valor;
  final int quantidade;

  const ReceitaServico({
    required this.nome,
    required this.valor,
    required this.quantidade,
  });
}

class DashboardFinanceiroData {
  final List<GanhoMensal> ganhosMensais;
  final List<ReceitaBarbeiro> receitaPorBarbeiro;
  final List<ReceitaServico> receitaPorServico;
  final double totalReceita;
  final int totalServicos;

  const DashboardFinanceiroData({
    required this.ganhosMensais,
    required this.receitaPorBarbeiro,
    required this.receitaPorServico,
    required this.totalReceita,
    required this.totalServicos,
  });
}

enum PeriodoFiltro {
  mesAtual,
  ultimos3Meses,
  anoAtual,
  personalizado,
}