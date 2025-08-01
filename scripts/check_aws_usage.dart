import 'package:flutter_application_1/core/aws/aws_config_checker.dart';
import 'package:flutter_application_1/core/aws/aws_cost_monitor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Script para verificar se há chamadas AWS indevidas
void main() async {
  print('🔍 Verificando uso de AWS...');

  // Cria um container para os providers
  final container = ProviderContainer();

  try {
    // Verifica configuração AWS
    final configChecker = container.read(awsConfigCheckerProvider);
    print('\n📋 Verificando arquivos de configuração AWS...');
    final configFiles = await configChecker.checkAwsConfigFiles();
    _printMap(configFiles);

    print('\n📋 Verificando variáveis de ambiente AWS...');
    final envVars = configChecker.checkAwsEnvironmentVariables();
    _printMap(envVars);

    print('\n📋 Verificando credenciais AWS...');
    final hasCredentials = await configChecker.checkAwsCredentials();
    print(
      'Credenciais AWS encontradas: ${hasCredentials ? '⚠️ SIM' : '✅ NÃO'}',
    );

    print('\n📋 Verificando configuração do ambiente...');
    final isConfigCorrect = configChecker.isEnvironmentConfigCorrect();
    print(
      'Configuração do ambiente correta: ${isConfigCorrect ? '✅ SIM' : '⚠️ NÃO'}',
    );

    print('\n📋 Recomendações de configuração:');
    final recommendations = configChecker.getConfigurationRecommendations();
    if (recommendations.isEmpty) {
      print('✅ Nenhuma recomendação, configuração está correta.');
    } else {
      for (final recommendation in recommendations) {
        print('⚠️ $recommendation');
      }
    }

    // Verifica custos estimados
    final costMonitor = container.read(awsCostMonitorProvider);
    costMonitor.startMonitoring();

    print('\n💰 Custos estimados:');
    final costs = costMonitor.getEstimatedCosts();
    if (costs.isEmpty) {
      print('✅ Nenhum custo registrado.');
    } else {
      _printMap(costs);
    }

    print('\n🚨 Verificando uso não autorizado:');
    final unauthorizedUsage = await costMonitor.checkForUnauthorizedUsage();
    if (unauthorizedUsage.isEmpty) {
      print('✅ Nenhum uso não autorizado detectado.');
    } else {
      print('⚠️ Uso não autorizado detectado:');
      for (final usage in unauthorizedUsage) {
        print('  - Serviço: ${usage['service']}');
        print('    Contagem: ${usage['count']}');
        print('    Custo estimado: \$${usage['estimatedCost']}');
      }
    }

    print('\n✅ Verificação concluída.');
  } catch (e) {
    print('\n❌ Erro durante a verificação: $e');
  } finally {
    container.dispose();
  }
}

/// Imprime um mapa de forma formatada
void _printMap(Map<String, dynamic> map) {
  map.forEach((key, value) {
    String valueStr;

    if (value == null) {
      valueStr = 'não definido';
    } else if (value is bool) {
      valueStr = value ? '✅ sim' : '❌ não';
    } else if (value is double) {
      valueStr = '\$${value.toStringAsFixed(4)}';
    } else {
      valueStr = value.toString();
    }

    print('  - $key: $valueStr');
  });
}
