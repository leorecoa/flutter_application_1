import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AppointmentsChart extends StatelessWidget {
  final Map<String, int> statusData;

  const AppointmentsChart({super.key, required this.statusData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status dos Agendamentos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _generateSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateSections() {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
    final statuses = ['Agendado', 'Confirmado', 'Concluído', 'Cancelado'];
    
    return statusData.entries.map((entry) {
      final index = statuses.indexOf(entry.key);
      final color = colors[index % colors.length];
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
    final statuses = ['Agendado', 'Confirmado', 'Concluído', 'Cancelado'];
    
    return Wrap(
      spacing: 16,
      children: statusData.entries.map((entry) {
        final index = statuses.indexOf(entry.key);
        final color = colors[index % colors.length];
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text('${entry.key}: ${entry.value}'),
          ],
        );
      }).toList(),
    );
  }
}