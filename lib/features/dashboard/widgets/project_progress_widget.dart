import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget para exibir o progresso do projeto AGENDEMAIS
class ProjectProgressWidget extends ConsumerWidget {
  const ProjectProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progresso do Projeto',
                  style: theme.textTheme.titleLarge,
                ),
                Chip(
                  label: const Text('75% Completo'),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  labelStyle: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Progresso geral
            _buildProgressSection(
              context,
              'Progresso Geral',
              0.75,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            
            // Progresso por área
            Text(
              'Progresso por Área',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildProgressSection(
              context,
              'Autenticação',
              0.9,
              Colors.green,
            ),
            _buildProgressSection(
              context,
              'Agendamentos',
              0.85,
              Colors.green,
            ),
            _buildProgressSection(
              context,
              'Pagamentos',
              0.7,
              Colors.amber,
            ),
            _buildProgressSection(
              context,
              'Notificações',
              0.8,
              Colors.green,
            ),
            _buildProgressSection(
              context,
              'Dashboard',
              0.6,
              Colors.amber,
            ),
            _buildProgressSection(
              context,
              'Configurações',
              0.65,
              Colors.amber,
            ),
            _buildProgressSection(
              context,
              'Relatórios',
              0.5,
              Colors.orange,
            ),
            _buildProgressSection(
              context,
              'Multi-tenancy',
              0.8,
              Colors.green,
            ),
            
            const SizedBox(height: 16),
            
            // Qualidade do código
            Text(
              'Qualidade do Código',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildProgressSection(
              context,
              'Arquitetura',
              0.85,
              Colors.green,
            ),
            _buildProgressSection(
              context,
              'Testes',
              0.6,
              Colors.amber,
            ),
            _buildProgressSection(
              context,
              'Documentação',
              0.7,
              Colors.amber,
            ),
            _buildProgressSection(
              context,
              'Performance',
              0.75,
              Colors.amber,
            ),
            _buildProgressSection(
              context,
              'Acessibilidade',
              0.5,
              Colors.orange,
            ),
            _buildProgressSection(
              context,
              'Internacionalização',
              0.4,
              Colors.orange,
            ),
            
            const SizedBox(height: 24),
            
            // Próximos passos
            Text(
              'Próximos Passos',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildNextStep(
              context,
              'Completar refatoração do módulo de agendamentos',
              true,
            ),
            _buildNextStep(
              context,
              'Implementar testes unitários para controllers restantes',
              false,
            ),
            _buildNextStep(
              context,
              'Melhorar dashboard com gráficos avançados',
              false,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressSection(
    BuildContext context,
    String title,
    double progress,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text('${(progress * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextStep(
    BuildContext context,
    String title,
    bool inProgress,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            inProgress ? Icons.pending : Icons.check_box_outline_blank,
            color: inProgress ? Colors.amber : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: inProgress ? Colors.amber : Colors.black87,
                fontWeight: inProgress ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}