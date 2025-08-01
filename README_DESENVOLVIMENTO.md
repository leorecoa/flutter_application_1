# Guia de Desenvolvimento - AGENDEMAIS

Este guia contém instruções para desenvolvedores trabalharem no projeto AGENDEMAIS, um sistema SaaS de agendamentos com suporte multi-tenant.

## Índice

1. [Configuração do Ambiente](#configuração-do-ambiente)
2. [Estrutura do Projeto](#estrutura-do-projeto)
3. [Desenvolvimento Local](#desenvolvimento-local)
4. [Integração com AWS](#integração-com-aws)
5. [Multi-tenant](#multi-tenant)
6. [Testes](#testes)
7. [Deploy](#deploy)
8. [Boas Práticas](#boas-práticas)

## Configuração do Ambiente

### Pré-requisitos

- Flutter SDK 3.16.9 ou superior
- Dart 3.2.0 ou superior
- VS Code ou Android Studio
- Git
- Node.js e npm (para AWS Amplify CLI)

### Instalação

1. Clone o repositório:
   ```bash
   git clone https://github.com/agendemais/app.git
   cd app
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Instale o Amplify CLI (opcional, apenas para desenvolvimento com AWS):
   ```bash
   npm install -g @aws-amplify/cli
   amplify configure
   ```

4. Configure o ambiente:
   ```bash
   # Para desenvolvimento local sem AWS:
   flutter run --dart-define=ENVIRONMENT=dev --dart-define=USE_REAL_AWS=false
   
   # Para desenvolvimento com AWS:
   flutter run --dart-define=ENVIRONMENT=dev --dart-define=USE_REAL_AWS=true
   ```

## Estrutura do Projeto

O projeto segue a arquitetura Clean Architecture com as seguintes camadas:

```
lib/
├── core/                  # Código central e utilitários
│   ├── analytics/         # Serviço de analytics
│   ├── config/            # Configurações de ambiente
│   ├── errors/            # Exceções e tratamento de erros
│   ├── logging/           # Sistema de logging
│   ├── models/            # Modelos de dados
│   ├── services/          # Serviços de infraestrutura
│   └── tenant/            # Lógica multi-tenant
├── data/                  # Camada de dados
│   ├── datasources/       # Fontes de dados (API, local)
│   └── repositories/      # Implementações de repositórios
├── domain/                # Regras de negócio
│   ├── entities/          # Entidades de domínio
│   ├── repositories/      # Interfaces de repositórios
│   └── usecases/          # Casos de uso
└── presentation/          # Interface do usuário
    ├── pages/             # Telas
    ├── providers/         # Providers Riverpod
    └── widgets/           # Componentes reutilizáveis
```

## Desenvolvimento Local

Para desenvolver sem custos AWS:

1. Certifique-se de que `USE_REAL_AWS=false` está definido
2. Use os serviços simulados em `core/services/`
3. Os dados serão armazenados localmente

### Serviços Simulados

- **AmplifyService**: Simula autenticação, API, storage e analytics
- **StorageService**: Armazena arquivos localmente
- **AnalyticsService**: Registra eventos apenas em log

## Integração com AWS

Para desenvolver com AWS real:

1. Configure `USE_REAL_AWS=true`
2. Certifique-se de ter as credenciais AWS configuradas
3. Use o `AwsCostMonitor` para monitorar custos

### Configuração do Amplify

Se precisar configurar o Amplify do zero:

```bash
amplify init
amplify add auth
amplify add api
amplify add storage
amplify add analytics
amplify push
```

## Multi-tenant

O sistema suporta múltiplos tenants (clientes) na mesma base de código:

- Cada tenant tem seu próprio domínio, configurações e dados
- O contexto do tenant é gerenciado por `TenantContext`
- Os dados são isolados por tenant no backend

### Adicionando um Novo Tenant

Use o script de deploy:

```bash
./scripts/deploy_tenant.sh tenant1 "Empresa ABC" empresa-abc.agendemais.com
```

## Testes

Execute os testes com:

```bash
# Testes unitários
flutter test

# Testes de widget
flutter test --tags=widget

# Testes de integração
flutter test integration_test
```

## Deploy

O deploy é automatizado via AWS Amplify:

1. Faça push para a branch `main` para deploy em produção
2. Cada tenant tem sua própria branch e ambiente

### Deploy Manual

```bash
# Build para web
flutter build web --release --dart-define=ENVIRONMENT=prod

# Deploy via Amplify CLI
amplify publish
```

## Boas Práticas

- Sempre use os casos de uso para lógica de negócio
- Mantenha a separação de camadas (presentation, domain, data)
- Use o `EnvironmentConfig` para configurações específicas de ambiente
- Evite chamadas AWS desnecessárias em desenvolvimento
- Documente novas funcionalidades
- Escreva testes para novas features

---

Para mais informações, consulte:
- [AWS_COST_OPTIMIZATION.md](./AWS_COST_OPTIMIZATION.md) - Estratégias de otimização de custos
- [DESENVOLVIMENTO_LOCAL.md](./DESENVOLVIMENTO_LOCAL.md) - Detalhes sobre desenvolvimento local
- [RESUMO_ALTERACOES.md](./RESUMO_ALTERACOES.md) - Histórico de alterações importantes