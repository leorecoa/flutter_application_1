import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/trinks_theme.dart';
import '../models/finance_data.dart';

class GraficoServico extends StatelessWidget {
  final List<ReceitaServico> dados;

  const GraficoServico({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TrinksTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Receita por Serviço',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TrinksTheme.darkGray,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final servico = dados[groupIndex];
                      return BarTooltipItem(
                        '${servico.nome}\n',
                        const TextStyle(
                          color: TrinksTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'R\$ ${servico.valor.toStringAsFixed(0)}\n',
                            style: const TextStyle(
                              color: TrinksTheme.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '${servico.quantidade} atendimentos',
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
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < dados.length) {
                          final nome = dados[value.toInt()].nome;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                nome.length > 8 ? '${nome.substring(0, 8)}...' : nome,
                                style: const TextStyle(
                                  color: TrinksTheme.darkGray,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
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
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'R\$ ${(value / 1000).toStringAsFixed(1)}k',
                          style: const TextStyle(
                            color: TrinksTheme.darkGray,
                            fontSize: 10,
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
                        color: _getColor(entry.key),
                        width: 30,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxValue() / 4,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: TrinksTheme.lightGray,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegenda(),
        ],
      ),
    );
  }

  Widget _buildLegenda() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: dados.asMap().entries.map((entry) {
        final servico = entry.value;
        final color = _getColor(entry.key);
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${servico.nome} (${servico.quantidade})',
              style: const TextStyle(
                fontSize: 11,
                color: TrinksTheme.darkGray,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  double _getMaxValue() {
    if (dados.isEmpty) return 1000;
    return dados.map((e) => e.valor).reduce((a, b) => a > b ? a : b);
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