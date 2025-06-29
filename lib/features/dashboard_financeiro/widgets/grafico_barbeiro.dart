import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/finance_data.dart';

class GraficoBarbeiro extends StatelessWidget {
  final List<ReceitaBarbeiro> dados;

  const GraficoBarbeiro({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Receita por Barbeiro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TrinksTheme.darkGray,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: _buildPieChartSections(),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dados.asMap().entries.map((entry) {
                      final barbeiro = entry.value;
                      final color = _getColor(entry.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    barbeiro.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${barbeiro.valor.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: TrinksTheme.darkGray.withValues(alpha: 0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = dados.fold(0.0, (sum, item) => sum + item.valor);
    
    return dados.asMap().entries.map((entry) {
      final barbeiro = entry.value;
      final percentage = (barbeiro.valor / total) * 100;
      
      return PieChartSectionData(
        color: _getColor(entry.key),
        value: barbeiro.valor,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: TrinksTheme.white,
        ),
      );
    }).toList();
  }

  Color _getColor(int index) {
    const colors = [
      TrinksTheme.navyBlue,
      TrinksTheme.lightBlue,
      TrinksTheme.purple,
      TrinksTheme.success,
      TrinksTheme.warning,
    ];
    return colors[index % colors.length];
  }
}