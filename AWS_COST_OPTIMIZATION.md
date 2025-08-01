# Estratégias de Otimização de Custos AWS

Este documento descreve as estratégias implementadas para otimizar os custos da AWS durante o desenvolvimento e em produção do AGENDEMAIS.

## Sumário

- [Desenvolvimento Local](#desenvolvimento-local)
- [Serviços Simulados](#serviços-simulados)
- [Monitoramento de Custos](#monitoramento-de-custos)
- [Detecção de Chamadas](#detecção-de-chamadas)
- [Boas Práticas em Produção](#boas-práticas-em-produção)
- [Configuração de Ambiente](#configuração-de-ambiente)

## Desenvolvimento Local

Para evitar custos desnecessários durante o desenvolvimento, implementamos um sistema que permite trabalhar completamente offline, sem realizar chamadas aos serviços AWS:

- **EnvironmentConfig**: Controla quando usar serviços AWS reais vs. simulados
- **AmplifyServiceFactory**: Cria a implementação correta do serviço baseado no ambiente
- **MockAmplifyService**: Implementação local que simula o comportamento do Amplify

### Como usar

```dart
// Em main.dart, configure o ambiente
void main() async {
  // Para desenvolvimento local sem custos AWS:
  EnvironmentConfig.printConfig(); // Verifica configuração atual
  
  // Inicializa serviços
  final amplifyService = AmplifyServiceFactory.create();
  await amplifyService.initialize();
  
  runApp(MyApp());
}
```

## Serviços Simulados

Implementamos versões simuladas dos seguintes serviços AWS:

- **Amplify Auth (Cognito)**: Autenticação simulada localmente
- **Amplify API (AppSync/GraphQL)**: Dados mockados para queries e mutations
- **Amplify Storage (S3)**: Armazenamento local de arquivos
- **Amplify Analytics (Pinpoint)**: Logging local de eventos

Cada serviço simulado mantém o mesmo contrato de interface que a versão real, permitindo alternar facilmente entre desenvolvimento e produção.

## Monitoramento de Custos

O `AwsCostMonitor` fornece estimativas de custos em tempo real:

- Rastreia chamadas a serviços AWS
- Calcula custos estimados baseados em preços atuais da AWS
- Gera relatórios periódicos de uso
- Emite alertas quando limites são atingidos

### Como usar

```dart
// Em qualquer serviço que use AWS
final costMonitor = AwsCostMonitor();

// Antes de fazer uma chamada AWS
costMonitor.trackApiCall('getAppointments');

// Para gerar um relatório
print(costMonitor.estimatedTotalCost);
```

## Detecção de Chamadas

O `AwsCallDetector` previne chamadas acidentais à AWS durante o desenvolvimento:

- Intercepta chamadas de rede para domínios AWS
- Bloqueia chamadas não autorizadas
- Registra tentativas para depuração
- Permite configurar exceções

### Como usar

```dart
// Em main.dart
final detector = AwsCallDetector();
detector.initialize();

// Para permitir um host específico
detector.allowHost('api.exemplo.com');
```

## Boas Práticas em Produção

Mesmo em produção, implementamos estratégias para minimizar custos:

### AppSync/API

- Paginação eficiente para reduzir transferência de dados
- Seleção de campos específicos em queries GraphQL
- Cache de dados no cliente para reduzir chamadas repetidas

### S3/Storage

- Compressão de arquivos antes do upload
- Política de expiração para arquivos temporários
- Uso de URLs pré-assinados para acesso direto

### Cognito/Auth

- Sessões de longa duração para reduzir refreshes de token
- Autenticação em camadas (JWT local + verificação remota)

### DynamoDB

- Uso eficiente de índices secundários
- Operações em lote para múltiplas leituras/escritas
- TTL para dados temporários

## Configuração de Ambiente

O arquivo `environment_config.dart` centraliza todas as configurações relacionadas ao ambiente:

```dart
// Exemplos de configuração
// Para desenvolvimento local sem custos:
flutter run --dart-define=ENVIRONMENT=dev --dart-define=USE_REAL_AWS=false

// Para testes com AWS:
flutter run --dart-define=ENVIRONMENT=dev --dart-define=USE_REAL_AWS=true

// Para produção:
flutter run --dart-define=ENVIRONMENT=prod
```

## Monitoramento em Produção

Em produção, utilizamos:

- **AWS Budgets**: Alertas de orçamento por serviço
- **AWS Cost Explorer**: Análise detalhada de custos
- **CloudWatch Metrics**: Monitoramento de uso de recursos
- **Relatórios personalizados**: Análise de custos por tenant

---

## Próximos Passos

- [ ] Implementar sistema de quotas por tenant
- [ ] Adicionar dashboard de custos no painel administrativo
- [ ] Otimizar consultas GraphQL com análise de performance
- [ ] Implementar cache distribuído para reduzir chamadas à API