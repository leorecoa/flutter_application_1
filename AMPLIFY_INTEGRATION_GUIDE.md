# Guia de Integração AWS Amplify - AGENDEMAIS

Este guia detalha os passos para implementar a integração completa do AWS Amplify no projeto AGENDEMAIS, focando na criação do backend GraphQL e na configuração dos serviços AWS.

## Índice

1. [Visão Geral](#visão-geral)
2. [Pré-requisitos](#pré-requisitos)
3. [Inicialização do Amplify](#inicialização-do-amplify)
4. [Configuração do GraphQL Schema](#configuração-do-graphql-schema)
5. [Implementação das Funções Lambda](#implementação-das-funções-lambda)
6. [Configuração de Autenticação](#configuração-de-autenticação)
7. [Configuração de Storage](#configuração-de-storage)
8. [Configuração de Analytics](#configuração-de-analytics)
9. [Integração no Flutter](#integração-no-flutter)
10. [Testes e Validação](#testes-e-validação)
11. [Deploy Multi-tenant](#deploy-multi-tenant)
12. [Monitoramento e Otimização](#monitoramento-e-otimização)

## Visão Geral

A integração do AWS Amplify no AGENDEMAIS permite:

- **Autenticação segura** com Cognito
- **API GraphQL** com AppSync
- **Armazenamento** com S3
- **Analytics** com Pinpoint
- **Suporte multi-tenant**
- **Desenvolvimento local** sem custos AWS

## Pré-requisitos

1. **AWS CLI** instalado e configurado
2. **Amplify CLI** instalado:
   ```bash
   npm install -g @aws-amplify/cli
   amplify configure
   ```
3. **Flutter SDK** 3.16.9 ou superior
4. **Dependências Flutter** adicionadas ao `pubspec.yaml`:
   ```yaml
   dependencies:
     amplify_flutter: ^1.0.0
     amplify_auth_cognito: ^1.0.0
     amplify_api: ^1.0.0
     amplify_storage_s3: ^1.0.0
     amplify_analytics_pinpoint: ^1.0.0
   ```

## Inicialização do Amplify

### 1. Inicializar o projeto Amplify

```bash
cd flutter_application_1
amplify init
```

Siga as instruções conforme detalhado no [AMPLIFY_SETUP_GUIDE.md](./AMPLIFY_SETUP_GUIDE.md).

### 2. Verificar a estrutura de diretórios

Após a inicialização, você terá a seguinte estrutura:

```
amplify/
├── backend/
│   ├── api/
│   ├── auth/
│   ├── function/
│   ├── storage/
│   └── analytics/
└── .config/
```

## Configuração do GraphQL Schema

### 1. Adicionar API GraphQL

```bash
amplify add api
```

Selecione:
- **Serviço**: GraphQL
- **Nome da API**: agendemais
- **Tipo de autorização**: Amazon Cognito User Pool
- **Configurar modelo de dados adicional**: Sim

### 2. Definir o Schema GraphQL

Copie o schema definido em `amplify/backend/api/agendemais/schema.graphql`:

```graphql
type Tenant @model
@auth(rules: [
  { allow: groups, groups: ["Admin"], operations: [create, read, update, delete] },
  { allow: owner, ownerField: "owner", operations: [read, update] },
  { allow: private, operations: [read] }
]) {
  id: ID!
  name: String!
  # ... outros campos
}

# ... outros tipos
```

O schema completo inclui:
- Tenant (multi-tenant)
- User (usuários)
- Client (clientes)
- Service (serviços)
- Appointment (agendamentos)
- Payment (pagamentos)
- Queries e mutations personalizadas

### 3. Gerar os modelos

```bash
amplify codegen models
```

## Implementação das Funções Lambda

### 1. Criar funções para resolvers personalizados

Para cada função definida no schema (ex: `getAppointmentsByDateRange`):

```bash
amplify add function
```

Selecione:
- **Nome**: getAppointmentsByDateRange
- **Runtime**: NodeJS
- **Template**: Hello World
- **Acesso avançado**: Yes
- **Recursos para acessar**: API (GraphQL)

### 2. Implementar a lógica da função

Edite o arquivo `amplify/backend/function/getAppointmentsByDateRange/src/index.js`:

```javascript
/* Amplify Params - DO NOT EDIT
  API_AGENDEMAIS_GRAPHQLAPIENDPOINTOUTPUT
  API_AGENDEMAIS_GRAPHQLAPIIDOUTPUT
  ENV
  REGION
Amplify Params - DO NOT EDIT */

const AWS = require('aws-sdk');
const https = require('https');
const urlParse = require('url').URL;

exports.handler = async (event) => {
  // Implementação da função
  // ...
};
```

### 3. Conectar as funções ao schema GraphQL

Após implementar todas as funções, execute:

```bash
amplify update api
```

Selecione a opção para configurar resolvers adicionais e conecte cada função ao campo correspondente no schema.

## Configuração de Autenticação

### 1. Adicionar autenticação

```bash
amplify add auth
```

Selecione:
- **Tipo de autenticação**: Default configuration with social provider
- **Atributos obrigatórios**: Email, Name
- **Atributos de login**: Email
- **Provedores sociais**: Google, Facebook (opcional)

### 2. Configurar grupos de usuários

Após o deploy, acesse o console do AWS Cognito e crie os grupos:
- Admin
- Staff
- Clients

### 3. Configurar políticas de acesso

Edite as regras de autorização no schema GraphQL para controlar o acesso baseado em grupos.

## Configuração de Storage

### 1. Adicionar storage

```bash
amplify add storage
```

Selecione:
- **Serviço**: Content (S3)
- **Recurso**: agendemais-storage
- **Acesso de bucket**: Auth users only
- **Permissões para usuários autenticados**: create/update, read, delete

### 2. Configurar políticas de acesso por tenant

Implemente lógica para isolar os arquivos por tenant usando prefixos de caminho:

```
s3://bucket/tenant1/...
s3://bucket/tenant2/...
```

## Configuração de Analytics

### 1. Adicionar analytics

```bash
amplify add analytics
```

Selecione:
- **Serviço**: Amazon Pinpoint
- **Nome do recurso**: agendemaisanalytics

### 2. Configurar eventos personalizados

Defina eventos personalizados para rastrear:
- Agendamentos criados
- Agendamentos cancelados
- Logins de usuários
- Uso de recursos por tenant

## Integração no Flutter

### 1. Configurar o Amplify no Flutter

No arquivo `main.dart`:

```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'amplifyconfiguration.dart';

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final api = AmplifyAPI();
    final storage = AmplifyStorageS3();
    final analytics = AmplifyAnalyticsPinpoint();
    
    await Amplify.addPlugins([auth, api, storage, analytics]);
    await Amplify.configure(amplifyconfig);
    
    print('Amplify configurado com sucesso');
  } catch (e) {
    print('Erro ao configurar Amplify: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(MyApp());
}
```

### 2. Implementar o repositório

Utilize a implementação do `AppointmentRepositoryImpl` para interagir com a API GraphQL:

```dart
class AppointmentRepositoryImpl implements AppointmentRepository {
  final AmplifyService _amplifyService;
  
  AppointmentRepositoryImpl(this._amplifyService);
  
  // Implementação dos métodos
}
```

### 3. Implementar os casos de uso

Utilize os casos de uso para encapsular a lógica de negócio:

```dart
class UpdateAppointmentUseCase {
  final AppointmentRepository _repository;
  
  UpdateAppointmentUseCase(this._repository);
  
  Future<Appointment> execute(Appointment appointment) async {
    // Validação e lógica de negócio
    return await _repository.updateAppointment(appointment);
  }
}
```

## Testes e Validação

### 1. Testar autenticação

```dart
try {
  final result = await Amplify.Auth.signIn(
    username: 'email@exemplo.com',
    password: 'senha123'
  );
  print('Login bem-sucedido: ${result.isSignedIn}');
} catch (e) {
  print('Erro no login: $e');
}
```

### 2. Testar API GraphQL

```dart
const String listAppointments = '''
query ListAppointments {
  listAppointments {
    items {
      id
      clientName
      date
      startTime
      status
    }
  }
}
''';

try {
  final request = GraphQLRequest<String>(
    document: listAppointments,
    variables: {}
  );
  final response = await Amplify.API.query(request: request).response;
  print('Resultado: ${response.data}');
} catch (e) {
  print('Erro na query: $e');
}
```

### 3. Testar Storage

```dart
try {
  final result = await Amplify.Storage.uploadFile(
    local: File('arquivo.pdf'),
    key: 'documentos/arquivo.pdf',
    options: StorageUploadFileOptions(
      accessLevel: StorageAccessLevel.private
    )
  );
  print('Upload concluído: ${result.key}');
} catch (e) {
  print('Erro no upload: $e');
}
```

## Deploy Multi-tenant

### 1. Configurar ambiente para cada tenant

Utilize o script `deploy_tenant.sh` para criar ambientes para cada tenant:

```bash
./scripts/deploy_tenant.sh tenant1 "Empresa ABC" empresa-abc.agendemais.com
```

### 2. Configurar domínios personalizados

Para cada tenant, configure um domínio personalizado no AWS Amplify Console:

1. Acesse o console do Amplify
2. Selecione o app
3. Vá para "Domain management"
4. Adicione o domínio personalizado
5. Configure os registros DNS conforme instruções

### 3. Configurar variáveis de ambiente por tenant

No console do Amplify, configure variáveis de ambiente específicas para cada tenant:

- `TENANT_ID`
- `TENANT_NAME`
- `TENANT_FEATURES`

## Monitoramento e Otimização

### 1. Configurar monitoramento de custos

Utilize o `AwsCostMonitor` para rastrear e estimar custos:

```dart
final costMonitor = AwsCostMonitor();
costMonitor.startMonitoring();
```

### 2. Configurar alertas de orçamento

No console da AWS:
1. Acesse AWS Budgets
2. Crie orçamentos para cada serviço (Cognito, AppSync, S3, etc.)
3. Configure alertas para notificar quando os custos atingirem limites específicos

### 3. Otimizar consultas GraphQL

- Use paginação para limitar o tamanho das respostas
- Selecione apenas os campos necessários
- Use caching no cliente para reduzir chamadas repetidas

### 4. Implementar TTL para dados temporários

Configure TTL (Time to Live) para dados temporários no DynamoDB para reduzir custos de armazenamento.

---

## Próximos Passos

1. Implementar testes automatizados para a integração com Amplify
2. Configurar CI/CD com GitHub Actions
3. Implementar sistema de notificações com Amazon SNS
4. Adicionar suporte a múltiplos idiomas
5. Implementar dashboard de monitoramento de custos

Para mais detalhes sobre cada etapa, consulte a documentação oficial do AWS Amplify: https://docs.amplify.aws