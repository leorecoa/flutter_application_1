# Desenvolvimento Local - AGENDEMAIS

Este documento detalha como desenvolver o AGENDEMAIS localmente sem depender de serviços AWS, evitando custos desnecessários durante o desenvolvimento.

## Índice

1. [Visão Geral](#visão-geral)
2. [Configuração](#configuração)
3. [Serviços Simulados](#serviços-simulados)
4. [Dados de Teste](#dados-de-teste)
5. [Alternando entre Local e AWS](#alternando-entre-local-e-aws)
6. [Limitações](#limitações)
7. [Troubleshooting](#troubleshooting)

## Visão Geral

O AGENDEMAIS foi projetado para funcionar em dois modos:

1. **Modo AWS**: Conectado aos serviços AWS reais (produção/staging)
2. **Modo Local**: Usando implementações simuladas dos serviços AWS (desenvolvimento)

O modo local permite desenvolver e testar sem custos AWS, usando dados simulados e armazenamento local.

## Configuração

### Configuração Básica

Para executar em modo local:

```bash
flutter run --dart-define=ENVIRONMENT=dev --dart-define=USE_REAL_AWS=false
```

### Arquivo de Configuração

Você também pode criar um arquivo `.env.local` na raiz do projeto:

```
ENVIRONMENT=dev
USE_REAL_AWS=false
ENABLE_ANALYTICS=false
ENABLE_VERBOSE_LOGGING=true
```

E então executar:

```bash
flutter run --dart-define-from-file=.env.local
```

## Serviços Simulados

### AmplifyService

O `MockAmplifyService` simula:

- **Autenticação**: Usuário sempre autenticado com ID "local-dev-user-id"
- **API**: Retorna dados mock para queries e mutations
- **Storage**: Armazena arquivos na memória
- **Analytics**: Registra eventos apenas em log

### Exemplo de Uso

```dart
// O código é o mesmo para ambos os modos
final amplifyService = AmplifyServiceFactory.create();
await amplifyService.initialize();

// Em modo local, isso retorna dados simulados
final result = await amplifyService.query('getAppointments', variables: {
  'limit': 10,
});
```

### StorageService

O `LocalStorageService` simula:

- Armazenamento de arquivos no sistema de arquivos local
- Download de arquivos
- Geração de URLs para arquivos

### AnalyticsService

O `LocalAnalyticsService` simula:

- Registro de eventos apenas em log
- Sem envio real para AWS Pinpoint

## Dados de Teste

### Agendamentos

O sistema gera automaticamente dados de teste para:

- Agendamentos (próximos 30 dias)
- Clientes
- Serviços
- Pagamentos

### Personalização

Você pode personalizar os dados de teste em `test_data_generator.dart`:

```dart
// Gerar novos dados de teste
final generator = TestDataGenerator();
await generator.generateAppointments(count: 20);
```

## Alternando entre Local e AWS

### Durante o Desenvolvimento

Para alternar entre modos:

```bash
# Modo local
flutter run --dart-define=USE_REAL_AWS=false

# Modo AWS
flutter run --dart-define=USE_REAL_AWS=true
```

### No Código

Você pode verificar o modo atual:

```dart
if (EnvironmentConfig.useRealAws) {
  // Código específico para AWS real
} else {
  // Código específico para desenvolvimento local
}
```

### Detecção de Chamadas AWS

O sistema inclui um detector de chamadas AWS para evitar chamadas acidentais:

```dart
// Em main.dart
final detector = AwsCallDetector();
detector.initialize();
```

Se uma chamada AWS for detectada em modo local, um aviso será registrado.

## Limitações

O modo local tem algumas limitações:

1. **Funcionalidades Offline**: Algumas funcionalidades podem não estar disponíveis offline
2. **Dados Limitados**: Apenas dados de teste estão disponíveis
3. **Notificações**: Notificações push não funcionam em modo local
4. **Pagamentos**: Integração com gateway de pagamento não funciona localmente

## Troubleshooting

### Problemas Comuns

#### Erro "Amplify not configured"

Solução: Verifique se `amplifyService.initialize()` foi chamado antes de usar outros métodos.

#### Dados de Teste Não Aparecem

Solução: Execute `TestDataGenerator().reset()` e reinicie o app.

#### Erro ao Alternar Modos

Solução: Limpe o cache e reinstale o app:

```bash
flutter clean
flutter pub get
```

### Logs de Depuração

Para ver logs detalhados:

```bash
flutter run --dart-define=ENABLE_VERBOSE_LOGGING=true
```

Os logs incluem:
- Chamadas de serviço simuladas
- Dados mock gerados
- Tentativas de chamadas AWS bloqueadas

---

Para mais informações, consulte:
- [README_DESENVOLVIMENTO.md](./README_DESENVOLVIMENTO.md) - Guia geral de desenvolvimento
- [AWS_COST_OPTIMIZATION.md](./AWS_COST_OPTIMIZATION.md) - Estratégias de otimização de custos