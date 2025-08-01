# Guia de Configuração do AWS Amplify

Este guia descreve os passos necessários para inicializar e configurar o AWS Amplify no projeto AGENDEMAIS.

## Pré-requisitos

1. Instale o Amplify CLI:
   ```bash
   npm install -g @aws-amplify/cli
   ```

2. Configure suas credenciais AWS:
   ```bash
   amplify configure
   ```

## Inicialização do Amplify

### 1. Inicializar o Amplify no projeto

```bash
# Na raiz do projeto
amplify init
```

Quando solicitado, forneça as seguintes informações:
- **Nome do projeto**: agendemais
- **Ambiente**: dev (ou prod para produção)
- **Editor padrão**: Visual Studio Code (ou sua preferência)
- **Tipo de app**: javascript
- **Framework**: none
- **Diretório de origem**: lib
- **Diretório de distribuição**: build
- **Comando de build**: flutter build web
- **Usar um perfil AWS existente**: Sim (selecione o perfil configurado anteriormente)

### 2. Adicionar autenticação (Cognito)

```bash
amplify add auth
```

Selecione as opções conforme configurado no arquivo `amplify/backend/auth/agendemais/cli-inputs.json`.

### 3. Adicionar API (AppSync GraphQL)

```bash
amplify add api
```

Selecione:
- **Serviço**: GraphQL
- **Nome da API**: agendemais
- **Tipo de autorização**: Amazon Cognito User Pool
- **Configurar modelo de dados adicional**: Sim
- **Importar schema**: Sim
- **Caminho do schema**: amplify/backend/api/agendemais/schema.graphql

### 4. Adicionar armazenamento (S3)

```bash
amplify add storage
```

Selecione:
- **Serviço**: Content (S3)
- **Recurso**: agendemais-storage
- **Acesso de bucket**: Auth users only
- **Quem deve ter acesso**: Auth and guest users
- **Permissões para usuários autenticados**: create/update, read, delete
- **Permissões para usuários convidados**: read

### 5. Adicionar analytics (Pinpoint)

```bash
amplify add analytics
```

Selecione:
- **Serviço**: Amazon Pinpoint
- **Nome do recurso**: agendemaisanalytics
- **Permissões para usuários convidados**: No

### 6. Adicionar funções Lambda

Para cada função definida no schema GraphQL:

```bash
amplify add function
```

Selecione:
- **Serviço**: Lambda
- **Nome da função**: getAppointmentsByDateRange (e outras)
- **Runtime**: NodeJS
- **Template**: Hello World
- **Acesso avançado**: Yes
- **Recursos para acessar**: API (GraphQL)

Repita para todas as funções necessárias.

### 7. Publicar as alterações

```bash
amplify push
```

Quando solicitado:
- **Gerar código para as operações da API**: Yes
- **Linguagem**: typescript
- **Arquivo de saída**: lib/API.ts
- **Gerar declarações**: Yes
- **Nível de declarações**: all
- **Gerar operações para todo o schema**: Yes

## Configuração no Flutter

### 1. Atualizar o arquivo amplifyconfiguration.dart

Após executar `amplify push`, o Amplify CLI gerará um arquivo `amplifyconfiguration.json`. Copie o conteúdo desse arquivo para o arquivo `lib/amplifyconfiguration.dart`:

```dart
const amplifyconfig = '''
  // Cole aqui o conteúdo do arquivo amplifyconfiguration.json
''';
```

### 2. Inicializar o Amplify no app

No arquivo `main.dart`, adicione o código para inicializar o Amplify:

```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:flutter_application_1/amplifyconfiguration.dart';

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

## Configuração Multi-tenant

### 1. Configurar grupos de usuários no Cognito

Após o deploy, acesse o console do AWS Cognito e configure os grupos de usuários:
- Admin: Acesso total
- Staff: Acesso limitado
- Clients: Acesso apenas aos próprios dados

### 2. Configurar domínios personalizados

Para cada tenant, execute o script de deploy:

```bash
./scripts/deploy_tenant.sh tenant1 "Empresa ABC" empresa-abc.agendemais.com
```

## Testes

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

## Monitoramento de Custos

Após configurar o Amplify, ative o monitoramento de custos:

```dart
final costMonitor = AwsCostMonitor();
costMonitor.startMonitoring();
```

## Próximos Passos

1. Configurar CI/CD com GitHub Actions
2. Implementar testes automatizados
3. Configurar monitoramento e alertas
4. Otimizar consultas GraphQL para performance