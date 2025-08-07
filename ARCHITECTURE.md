# Documentação de Arquitetura - AGENDEMAIS

## Visão Geral

O AGENDEMAIS é um sistema SaaS de agendamento desenvolvido com Flutter, Riverpod e GoRouter, seguindo os princípios da Clean Architecture. Este documento descreve a arquitetura do sistema, seus componentes principais e como eles interagem entre si.

## Princípios Arquiteturais

### Clean Architecture

O sistema segue os princípios da Clean Architecture, com as seguintes camadas:

1. **Domain** - Contém as regras de negócio e entidades do sistema
   - Value Objects
   - Interfaces de repositórios
   - Use Cases

2. **Data** - Implementa as interfaces definidas no Domain
   - Implementações de repositórios
   - Fontes de dados (API, cache local)

3. **Application** - Gerencia o estado e coordena os Use Cases
   - Controllers
   - Providers
   - State Notifiers

4. **Presentation** - Interface do usuário
   - Screens
   - Widgets
   - View Models

### Injeção de Dependência

Utilizamos o Riverpod para injeção de dependência, permitindo:

- Substituição fácil de implementações para testes
- Gerenciamento de estado reativo
- Acesso a dependências em qualquer parte do aplicativo

### Tratamento de Erros

Implementamos um sistema robusto de tratamento de erros com:

- Hierarquia de exceções específicas para cada camada
- Tratamento centralizado de erros
- Feedback visual para o usuário

### Multi-tenancy

O sistema suporta múltiplos tenants (empresas/organizações) com:

- Isolamento de dados por tenant
- Middleware para verificação de acesso
- Contexto de tenant para toda a aplicação

## Estrutura de Diretórios

```
lib/
├── core/
│   ├── errors/
│   │   ├── app_exceptions.dart
│   │   ├── error_handler.dart
│   │   └── error_handling_mixin.dart
│   ├── models/
│   │   ├── appointment_model.dart
│   │   ├── tenant_model.dart
│   │   └── user_model.dart
│   ├── multi_tenant/
│   │   ├── tenant_context.dart
│   │   └── tenant_repository.dart
│   ├── services/
│   │   ├── api_service.dart      # (Ex: Firebase Functions, REST)
│   │   ├── auth_service.dart     # (Ex: Firebase Auth)
│   │   └── storage_service.dart  # (Ex: Firebase Storage)
│   └── utils/
│       ├── debouncer.dart
│       └── validators.dart
├── features/
│   ├── appointments/
│   │   ├── domain/
│   │   │   ├── usecases/
│   │   │   │   └── appointment_usecases.dart
│   │   │   ├── value_objects/
│   │   │   │   └── appointment_value_objects.dart
│   │   │   └── appointment_repository.dart
│   │   ├── data/
│   │   │   └── appointment_repository_impl.dart
│   │   ├── application/
│   │   │   ├── appointment_screen_controller.dart
│   │   │   ├── repository_providers.dart
│   │   │   └── service_providers.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── appointments_screen.dart
│   │   │   └── widgets/
│   │   │       └── appointment_card.dart
│   │   └── services/
│   │       └── appointments_service_v2.dart
│   └── multi_tenant/
│       └── screens/
│           └── select_tenant_screen.dart
└── main.dart
```

## Fluxos Principais

### Fluxo de Agendamento

1. Usuário acessa a tela de agendamentos
2. Controller solicita dados ao Use Case
3. Use Case valida os dados usando Value Objects
4. Use Case chama o Repository
5. Repository acessa a API
6. Dados retornam pelo mesmo caminho
7. Controller atualiza o estado
8. UI reage às mudanças de estado

### Fluxo de Multi-tenancy

1. Usuário faz login
2. Sistema verifica se há um tenant selecionado
3. Se não houver, redireciona para tela de seleção
4. Usuário seleciona um tenant
5. Sistema armazena o tenant no contexto
6. Todas as operações subsequentes são filtradas pelo tenant

## Padrões Utilizados

- **Repository Pattern** - Para acesso a dados
- **Use Case Pattern** - Para regras de negócio
- **Value Objects** - Para validação de domínio
- **Provider Pattern** - Para injeção de dependência
- **State Notifier Pattern** - Para gerenciamento de estado
- **Middleware Pattern** - Para verificação de acesso

## Considerações de Segurança

- Validação de inputs em todas as camadas
- Verificação de acesso por tenant
- Sanitização de dados
- Autenticação JWT com refresh tokens
- Criptografia de dados sensíveis

## Escalabilidade

- Operações em lote para processamento eficiente
- Cache distribuído para dados frequentemente acessados
- Processamento assíncrono para operações pesadas
- Paginação para grandes volumes de dados

## Monitoramento

- Logging estruturado para todas as operações
- Métricas de performance
- Rastreamento de erros
- Alertas para situações críticas

---

**Autor:** Equipe AGENDEMAIS  
**Data:** 2023-07-15  
**Versão:** 1.0