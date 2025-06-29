import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/finance_data.dart';

class GraficoMensal extends StatelessWidget {
  final List<GanhoMensal> dados;

  const GraficoMensal({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ganhos Mensais',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TrinksTheme.darkGray,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final ganho = dados[groupIndex];
                      return BarTooltipItem(
                        '${ganho.mes}\n',
                        const TextStyle(
                          color: TrinksTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'R\$ ${ganho.valor.toStringAsFixed(0)}\n',
                            style: const TextStyle(
                              color: TrinksTheme.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '${ganho.quantidadeServicos} serviços',
                            style: const TextStyle(
                              color: TrinksTheme.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < dados.length) {
                          return Text(
                            dados[value.toInt()].mes,
                            style: const TextStyle(
                              color: TrinksTheme.darkGray,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'R\$ ${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(
                            color: TrinksTheme.darkGray,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: dados.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.valor,
                        color: TrinksTheme.navyBlue,
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxValue() / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: TrinksTheme.lightGray,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxValue() {
    if (dados.isEmpty) return 10000;
    return dados.map((e) => e.valor).reduce((a, b) => a > b ? a : b);
  }
}