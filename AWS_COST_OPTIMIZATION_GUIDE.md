# Guia de Otimização de Custos AWS para AGENDEMAIS

## Confirmando que Nenhum Recurso AWS Pago Está Sendo Chamado

Para garantir que nenhum recurso AWS pago esteja sendo chamado indevidamente, implementamos as seguintes soluções:

### 1. AWS Call Detector

O `AwsCallDetector` (em `lib/core/aws/aws_call_detector.dart`) monitora todas as tentativas de chamadas AWS:

- Registra cada tentativa de chamada AWS com serviço, operação e parâmetros
- Lança exceções em modo de desenvolvimento quando AWS está desabilitado
- Gera relatórios detalhados de chamadas AWS para auditoria

**Como usar:**
```dart
final detector = ref.read(awsCallDetectorProvider);
detector.startMonitoring();

// Em qualquer serviço que faz chamadas AWS
detector.logAwsCallAttempt('S3', 'uploadFile', parameters: {'key': key});
```

### 2. AWS Cost Monitor

O `AwsCostMonitor` (em `lib/core/aws/aws_cost_monitor.dart`) estima e monitora custos AWS:

- Registra uso de serviços AWS com estimativas de custo
- Detecta uso não autorizado em modo de desenvolvimento
- Gera relatórios de custos estimados

**Como usar:**
```dart
final costMonitor = ref.read(awsCostMonitorProvider);
costMonitor.startMonitoring();

// Verificar custos estimados
final costs = costMonitor.getEstimatedCosts();
```

### 3. AWS Config Checker

O `AwsConfigChecker` (em `lib/core/aws/aws_config_checker.dart`) verifica a configuração AWS:

- Detecta arquivos de configuração AWS
- Verifica variáveis de ambiente AWS
- Confirma se credenciais AWS estão presentes
- Valida se a configuração do ambiente está correta

**Como usar:**
```dart
final configChecker = ref.read(awsConfigCheckerProvider);
final hasCredentials = await configChecker.checkAwsCredentials();
```

## Serviços AWS Gratuitos para Simulação em Produção

### 1. AWS Free Tier

Estes serviços têm camadas gratuitas generosas:

| Serviço | Limite Gratuito | Duração |
|---------|----------------|---------|
| Lambda | 1 milhão de solicitações/mês | Permanente |
| DynamoDB | 25 unidades de capacidade de leitura/escrita | Permanente |
| API Gateway | 1 milhão de chamadas/mês | 12 meses |
| CloudWatch | 10 métricas personalizadas | Permanente |
| S3 | 5GB de armazenamento | 12 meses |
| Cognito | 50.000 usuários ativos mensais | Permanente |

### 2. Configuração para Uso Gratuito

#### Lambda
```yaml
# serverless.yml
functions:
  myFunction:
    memorySize: 128 # Mínimo para reduzir custos
    timeout: 3 # Segundos
```

#### DynamoDB
```yaml
resources:
  Resources:
    UsersTable:
      Type: AWS::DynamoDB::Table
      Properties:
        BillingMode: PROVISIONED
        ProvisionedThroughput:
          ReadCapacityUnits: 5 # Dentro do limite gratuito
          WriteCapacityUnits: 5 # Dentro do limite gratuito
```

#### API Gateway
```yaml
provider:
  apiGateway:
    minimumCompressionSize: 1024 # Reduz transferência de dados
```

## Configuração de CloudWatch, Lambda e API Gateway com Alertas de Limite

### 1. CloudWatch Alarms para Custos

```yaml
resources:
  Resources:
    CostAlarm:
      Type: AWS::CloudWatch::Alarm
      Properties:
        AlarmName: BillingAlarm
        AlarmDescription: Alerta quando o custo estimado exceder $1
        ActionsEnabled: true
        AlarmActions:
          - !Ref SNSTopic
        MetricName: EstimatedCharges
        Namespace: AWS/Billing
        Statistic: Maximum
        Period: 21600 # 6 horas
        Threshold: 1.0 # $1
        ComparisonOperator: GreaterThanThreshold
        Dimensions:
          - Name: Currency
            Value: USD
```

### 2. Lambda com Limites de Execução

```yaml
functions:
  myFunction:
    reservedConcurrency: 5 # Limita execuções simultâneas
    events:
      - http:
          throttling:
            burstLimit: 10 # Limita picos de requisições
            rateLimit: 5 # Requisições por segundo
```

### 3. API Gateway com Throttling

```yaml
provider:
  apiGateway:
    throttling:
      burstLimit: 10
      rateLimit: 5
```

### 4. Monitoramento de Uso com CloudWatch Metrics

```yaml
resources:
  Resources:
    ApiUsageAlarm:
      Type: AWS::CloudWatch::Alarm
      Properties:
        AlarmName: ApiUsageAlarm
        MetricName: Count
        Namespace: AWS/ApiGateway
        Statistic: Sum
        Period: 86400 # 24 horas
        Threshold: 900000 # 90% do limite gratuito
        ComparisonOperator: GreaterThanThreshold
```

## Alternância Rápida entre Ambiente Local e Produção

Implementamos o `EnvironmentSwitcher` (em `lib/core/aws/environment_switcher.dart`) para alternar entre ambientes:

### 1. Alternância via Código

```dart
final switcher = ref.read(environmentSwitcherProvider);

// Alternar para desenvolvimento
await switcher.switchToDevelopment();

// Alternar para produção
await switcher.switchToProduction();
```

### 2. Verificação de Configuração

```dart
final config = await switcher.checkEnvironmentConfiguration();
if (!config['configuration_consistent']) {
  // Configuração inconsistente
}
```

### 3. Boas Práticas para Alternância Segura

- **Variáveis de Ambiente**: Use `.env.dev` e `.env.prod`
- **Configuração Centralizada**: Todas as flags em `environment_config.dart`
- **Verificação Automática**: Execute `AwsConfigChecker` ao iniciar o app
- **CI/CD**: Configure pipelines separados para dev e prod

## Ferramentas AWS para Monitoramento de Custos

### 1. AWS Budgets

Configure orçamentos e alertas:

```yaml
resources:
  Resources:
    DevelopmentBudget:
      Type: AWS::Budgets::Budget
      Properties:
        Budget:
          BudgetName: DevelopmentBudget
          BudgetLimit:
            Amount: 10
            Unit: USD
          TimeUnit: MONTHLY
          BudgetType: COST
        NotificationsWithSubscribers:
          - Notification:
              NotificationType: ACTUAL
              ComparisonOperator: GREATER_THAN
              Threshold: 80
            Subscribers:
              - SubscriptionType: EMAIL
                Address: seu-email@exemplo.com
```

### 2. AWS Cost Explorer

- Analise custos por serviço, região e tag
- Configure relatórios diários ou mensais
- Identifique tendências e anomalias

### 3. AWS Cost Anomaly Detection

Detecta automaticamente gastos anormais:

```yaml
resources:
  Resources:
    CostAnomalyDetection:
      Type: AWS::CE::AnomalyMonitor
      Properties:
        MonitorName: AppAnomalyMonitor
        MonitorType: DIMENSIONAL
        MonitorDimension: SERVICE
```

### 4. AWS Trusted Advisor

- Verifica otimizações de custo
- Identifica recursos subutilizados
- Recomenda melhorias de segurança e performance

## Implementação Prática

Para implementar todas estas soluções, adicionamos:

1. **Detector de Chamadas AWS**: Monitora e registra todas as tentativas de chamadas AWS
2. **Monitor de Custos AWS**: Estima e monitora custos AWS
3. **Verificador de Configuração AWS**: Verifica se há credenciais ou configurações AWS ativas
4. **Alternador de Ambiente**: Alterna facilmente entre desenvolvimento e produção

Estas ferramentas trabalham juntas para garantir que você não tenha custos inesperados durante o desenvolvimento e possa alternar com segurança para produção quando necessário.