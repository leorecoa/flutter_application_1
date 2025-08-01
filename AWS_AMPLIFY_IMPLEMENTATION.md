# AWS Amplify Implementation - AGENDEMAIS

Este documento detalha a implementação completa do AWS Amplify no projeto AGENDEMAIS, incluindo todos os componentes, serviços e configurações.

## Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Componentes Implementados](#componentes-implementados)
4. [Configuração do Amplify](#configuração-do-amplify)
5. [Modelo de Dados](#modelo-de-dados)
6. [Autenticação](#autenticação)
7. [API GraphQL](#api-graphql)
8. [Funções Lambda](#funções-lambda)
9. [Storage](#storage)
10. [Analytics](#analytics)
11. [Multi-tenant](#multi-tenant)
12. [CI/CD](#cicd)
13. [Otimização de Custos](#otimização-de-custos)
14. [Próximos Passos](#próximos-passos)

## Visão Geral

O AGENDEMAIS é um sistema SaaS de agendamentos com suporte multi-tenant, implementado com Flutter e AWS Amplify. A aplicação permite que múltiplos negócios (tenants) gerenciem seus agendamentos, clientes e serviços de forma independente.

## Arquitetura

A arquitetura do sistema segue o padrão Clean Architecture, com as seguintes camadas:

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                     │
│  (UI, Controllers, Providers, State Management - Riverpod)  │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                       Domain Layer                          │
│         (Use Cases, Repository Interfaces, Models)          │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                        Data Layer                           │
│        (Repository Implementations, Data Sources)           │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                    Infrastructure Layer                     │
│               (AWS Amplify, External Services)              │
└─────────────────────────────────────────────────────────────┘
```

## Componentes Implementados

### Core

- **Models**: Appointment, Tenant, User, Client, Service, Payment
- **Repositories**: AppointmentRepository, TenantRepository
- **Use Cases**: UpdateAppointment, DeleteAppointment, GetAppointments, etc.
- **Services**: AmplifyService, AnalyticsService, StorageService, Logger

### AWS Amplify

- **Auth**: Cognito para autenticação e autorização
- **API**: AppSync GraphQL para operações de dados
- **Storage**: S3 para armazenamento de arquivos
- **Analytics**: Pinpoint para analytics e notificações
- **Functions**: Lambda para lógica de negócio personalizada

### Multi-tenant

- **TenantContext**: Gerenciamento do contexto do tenant atual
- **TenantRepository**: Operações relacionadas a tenants
- **Deploy Multi-tenant**: Scripts e configurações para deploy de múltiplos tenants

## Configuração do Amplify

### Arquivo de Configuração

O arquivo `amplifyconfiguration.dart` contém a configuração do Amplify:

```dart
const amplifyconfig = '''
{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": { ... },
  "api": { ... },
  "storage": { ... },
  "analytics": { ... }
}
''';
```

### Inicialização

A inicialização do Amplify é feita no arquivo `main.dart`:

```dart
Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final api = AmplifyAPI();
    final storage = AmplifyStorageS3();
    final analytics = AmplifyAnalyticsPinpoint();
    
    await Amplify.addPlugins([auth, api, storage, analytics]);
    await Amplify.configure(amplifyconfig);
    
    Logger.info('Amplify configurado com sucesso');
  } catch (e) {
    Logger.error('Erro ao configurar Amplify', error: e);
  }
}
```

## Modelo de Dados

### Schema GraphQL

O schema GraphQL define os tipos de dados e suas relações:

```graphql
type Tenant @model {
  id: ID!
  name: String!
  domain: String
  plan: String!
  status: String!
  # ...
}

type User @model {
  id: ID!
  username: String!
  email: String!
  # ...
}

type Appointment @model {
  id: ID!
  clientId: ID!
  client: Client @belongsTo
  serviceId: ID!
  service: Service @belongsTo
  # ...
}

# ...
```

### Modelos Dart

Os modelos Dart correspondem aos tipos GraphQL:

```dart
class Appointment {
  final String id;
  final String clientId;
  final String clientName;
  final String serviceId;
  final String serviceName;
  // ...
}

class Tenant {
  final String id;
  final String name;
  final String? domain;
  final String plan;
  final String status;
  // ...
}

// ...
```

## Autenticação

### Configuração do Cognito

A autenticação é gerenciada pelo Amazon Cognito:

- **User Pool**: Para autenticação de usuários
- **Identity Pool**: Para acesso a outros serviços AWS
- **Grupos de Usuários**: Admin, Staff, Clients
- **Atributos Obrigatórios**: Email, Name
- **Provedores Sociais**: Google, Facebook (opcional)

### Implementação no Flutter

```dart
// Login
Future<void> signIn(String email, String password) async {
  try {
    final result = await Amplify.Auth.signIn(
      username: email,
      password: password
    );
    return result.isSignedIn;
  } catch (e) {
    throw AuthException('Erro ao fazer login: $e');
  }
}

// Registro
Future<void> signUp(String email, String password, String name) async {
  try {
    final userAttributes = {
      'email': email,
      'name': name,
    };
    
    final result = await Amplify.Auth.signUp(
      username: email,
      password: password,
      options: SignUpOptions(
        userAttributes: userAttributes
      )
    );
    return result.isSignUpComplete;
  } catch (e) {
    throw AuthException('Erro ao registrar: $e');
  }
}
```

## API GraphQL

### Configuração do AppSync

A API GraphQL é implementada com AWS AppSync:

- **Schema**: Define os tipos de dados e operações
- **Resolvers**: Conectam as operações GraphQL aos dados
- **Data Sources**: DynamoDB, Lambda, etc.

### Implementação no Flutter

```dart
// Buscar agendamentos
Future<List<Appointment>> getAppointments({
  required String tenantId,
  int page = 1,
  int pageSize = 20,
  Map<String, dynamic>? filters,
}) async {
  try {
    const query = '''
      query ListAppointments($filter: ModelAppointmentFilterInput, $limit: Int, $nextToken: String) {
        listAppointments(filter: $filter, limit: $limit, nextToken: $nextToken) {
          items {
            id
            clientName
            # ...
          }
          nextToken
        }
      }
    ''';
    
    final baseFilter = {
      'tenantId': {'eq': tenantId},
      // ...
    };
    
    final request = GraphQLRequest<String>(
      document: query,
      variables: {
        'filter': baseFilter,
        'limit': pageSize,
        // ...
      }
    );
    
    final response = await Amplify.API.query(request: request).response;
    final data = json.decode(response.data);
    final items = data['listAppointments']['items'] as List<dynamic>;
    
    return items.map((item) => Appointment.fromJson(item)).toList();
  } catch (e) {
    throw RepositoryException('Erro ao buscar agendamentos: $e');
  }
}
```

## Funções Lambda

### Funções Implementadas

1. **getAppointmentsByDateRange**: Busca agendamentos em um intervalo de datas
2. **getAvailableTimeSlots**: Calcula horários disponíveis para agendamento
3. **getDashboardStats**: Calcula estatísticas para o dashboard
4. **createRecurringAppointments**: Cria múltiplos agendamentos recorrentes
5. **processPayment**: Processa pagamentos para agendamentos
6. **sendAppointmentReminder**: Envia lembretes de agendamento

### Exemplo de Implementação

```javascript
// getAvailableTimeSlots
exports.handler = async (event) => {
  const tenantId = event.arguments.tenantId;
  const serviceId = event.arguments.serviceId;
  const date = event.arguments.date;
  
  // 1. Get the service to determine duration
  const service = await getService(serviceId);
  
  // 2. Get tenant settings to determine working hours
  const tenantSettings = await getTenantSettings(tenantId);
  
  // 3. Get existing appointments for this date
  const appointments = await getAppointmentsForDate(tenantId, date);
  
  // 4. Calculate available time slots
  const availableSlots = calculateAvailableSlots(
    startTime,
    endTime,
    serviceDuration,
    appointments
  );
  
  return {
    slots: availableSlots,
    serviceDuration: serviceDuration,
    workingHours: {
      start: startTime,
      end: endTime
    }
  };
};
```

## Storage

### Configuração do S3

O armazenamento de arquivos é gerenciado pelo Amazon S3:

- **Bucket**: Para armazenamento de arquivos
- **Políticas de Acesso**: Controle de acesso por tenant
- **Prefixos de Caminho**: Isolamento de arquivos por tenant

### Implementação no Flutter

```dart
// Upload de arquivo
Future<String> uploadFile(String path, List<int> bytes) async {
  try {
    final result = await Amplify.Storage.uploadData(
      data: bytes,
      key: path,
      options: StorageUploadDataOptions(
        accessLevel: StorageAccessLevel.private
      )
    ).result;
    
    return result.key;
  } catch (e) {
    throw StorageException('Erro ao fazer upload de arquivo: $e');
  }
}

// Download de arquivo
Future<List<int>> downloadFile(String path) async {
  try {
    final result = await Amplify.Storage.downloadData(
      key: path,
      options: StorageDownloadDataOptions(
        accessLevel: StorageAccessLevel.private
      )
    ).result;
    
    return result.data.toList();
  } catch (e) {
    throw StorageException('Erro ao fazer download de arquivo: $e');
  }
}
```

## Analytics

### Configuração do Pinpoint

O analytics é gerenciado pelo Amazon Pinpoint:

- **Eventos Personalizados**: Para rastrear ações do usuário
- **Funis de Conversão**: Para análise de fluxos
- **Segmentação de Usuários**: Para marketing direcionado

### Implementação no Flutter

```dart
// Registrar evento
Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
  try {
    final event = AnalyticsEvent(eventName);
    
    if (parameters != null) {
      parameters.forEach((key, value) {
        if (value is String) {
          event.properties.addStringProperty(key, value);
        } else if (value is int) {
          event.properties.addIntProperty(key, value);
        } else if (value is double) {
          event.properties.addDoubleProperty(key, value);
        } else if (value is bool) {
          event.properties.addBoolProperty(key, value);
        }
      });
    }
    
    await Amplify.Analytics.recordEvent(event: event);
  } catch (e) {
    Logger.error('Erro ao registrar evento de analytics', error: e);
  }
}
```

## Multi-tenant

### Modelo de Tenant

```dart
class Tenant {
  final String id;
  final String name;
  final String? domain;
  final String plan;
  final String status;
  final String? logo;
  final String? primaryColor;
  final String? accentColor;
  final int? maxUsers;
  final int? maxClients;
  final List<String>? features;
  
  // ...
}
```

### Contexto do Tenant

```dart
class TenantContext {
  Tenant? _currentTenant;
  
  Tenant? get currentTenant => _currentTenant;
  
  Future<void> initialize() async {
    // Busca o tenant do usuário atual
    // ...
  }
  
  Future<void> switchTenant(String tenantId) async {
    // Altera o tenant atual
    // ...
  }
}
```

### Isolamento de Dados

- **Filtros de Tenant**: Todas as queries incluem filtro por tenantId
- **Regras de Autorização**: Controle de acesso baseado em grupos e tenant
- **Prefixos de Storage**: Arquivos isolados por tenant

## CI/CD

### GitHub Actions

O pipeline de CI/CD é implementado com GitHub Actions:

```yaml
name: Amplify Deploy

on:
  push:
    branches:
      - main
      - develop
      - 'tenant/**'

jobs:
  test:
    # ...
  
  build:
    # ...
  
  deploy:
    # ...
```

### Deploy Multi-tenant

O script `deploy_tenant.sh` automatiza o deploy de novos tenants:

```bash
./scripts/deploy_tenant.sh tenant1 "Empresa ABC" empresa-abc.agendemais.com
```

## Otimização de Custos

### Desenvolvimento Local

- **AmplifyServiceFactory**: Cria implementação real ou mock baseado no ambiente
- **EnvironmentConfig**: Controla quando usar serviços AWS reais
- **AwsCostMonitor**: Monitora e estima custos em tempo real
- **AwsCallDetector**: Previne chamadas acidentais à AWS

### Produção

- **Paginação**: Reduz transferência de dados
- **Cache**: Reduz chamadas repetidas
- **TTL**: Expiração automática de dados temporários
- **Compressão**: Reduz tamanho de arquivos

## Próximos Passos

1. **Executar o Amplify Init**: Inicializar o Amplify no projeto
2. **Adicionar os Serviços AWS**: Auth, API, Storage e Analytics
3. **Implementar as Funções Lambda**: Para queries e mutations personalizadas
4. **Configurar Grupos de Usuários**: No Cognito para controle de acesso
5. **Configurar Domínios Personalizados**: Para cada tenant
6. **Implementar Testes**: Para validar a integração

---

## Conclusão

A implementação do AWS Amplify no projeto AGENDEMAIS fornece uma base sólida para um sistema SaaS de agendamentos escalável, seguro e com suporte multi-tenant. A arquitetura limpa e modular facilita a manutenção e evolução do sistema, enquanto as estratégias de otimização de custos garantem eficiência tanto em desenvolvimento quanto em produção.