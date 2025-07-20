# AGENDEMAIS - Guia de Desenvolvimento

## Visão Geral

Este guia fornece diretrizes, padrões e melhores práticas para o desenvolvimento do AGENDEMAIS. Ele serve como referência para todos os desenvolvedores que trabalham no projeto.

## Arquitetura

O AGENDEMAIS segue uma arquitetura em camadas com separação clara de responsabilidades:

```
lib/
├── core/               # Componentes centrais reutilizáveis
│   ├── models/         # Modelos de dados
│   ├── services/       # Serviços de infraestrutura
│   ├── repositories/   # Interfaces e implementações de repositórios
│   ├── utils/          # Utilitários
│   └── widgets/        # Widgets reutilizáveis
│
├── features/           # Módulos funcionais
│   ├── appointments/   # Funcionalidade de agendamentos
│   ├── auth/           # Autenticação
│   ├── dashboard/      # Dashboard
│   ├── notifications/  # Sistema de notificações
│   ├── payments/       # Processamento de pagamentos
│   └── settings/       # Configurações
│
└── main.dart           # Ponto de entrada da aplicação
```

### Padrões de Design

1. **Repository Pattern**: Para acesso a dados
2. **Provider Pattern**: Para injeção de dependências
3. **Controller Pattern**: Para lógica de negócios
4. **Observer Pattern**: Para reatividade

## Gerenciamento de Estado

Utilizamos o Riverpod como solução principal de gerenciamento de estado:

### Tipos de Providers

- **StateProvider**: Para estados simples
- **StateNotifierProvider**: Para estados complexos
- **FutureProvider**: Para dados assíncronos
- **StreamProvider**: Para streams de dados

### Exemplo de Implementação

```dart
// Definição do estado
class AppointmentsState {
  final List<Appointment> appointments;
  final bool isLoading;
  final String? error;
  
  AppointmentsState({
    this.appointments = const [],
    this.isLoading = false,
    this.error,
  });
  
  AppointmentsState copyWith({...}) {...}
}

// Notifier
class AppointmentsNotifier extends StateNotifier<AppointmentsState> {
  final AppointmentsRepository _repository;
  
  AppointmentsNotifier(this._repository) : super(AppointmentsState());
  
  Future<void> loadAppointments() async {...}
}

// Provider
final appointmentsProvider = StateNotifierProvider<AppointmentsNotifier, AppointmentsState>((ref) {
  final repository = ref.watch(appointmentsRepositoryProvider);
  return AppointmentsNotifier(repository);
});
```

## Navegação

Utilizamos o GoRouter para navegação:

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/appointments',
      builder: (context, state) => const AppointmentsScreen(),
    ),
    // Outras rotas...
  ],
);
```

## Testes

### Tipos de Testes

1. **Testes Unitários**: Para lógica de negócios e utilitários
2. **Testes de Widget**: Para componentes de UI
3. **Testes de Integração**: Para fluxos completos

### Exemplo de Teste Unitário

```dart
test('AppointmentScreenController updates appointment status correctly', () async {
  // Arrange
  final mockService = MockAppointmentsService();
  final controller = AppointmentScreenController(mockService, mockRead);
  
  // Act
  await controller.updateAppointmentStatus('test-id', true);
  
  // Assert
  verify(mockService.updateAppointmentStatus('test-id', AppointmentStatus.confirmed)).called(1);
});
```

## Convenções de Código

### Nomenclatura

- **Classes**: PascalCase (ex: `AppointmentCard`)
- **Variáveis e métodos**: camelCase (ex: `fetchAppointments()`)
- **Constantes**: SNAKE_CASE (ex: `MAX_APPOINTMENTS`)
- **Arquivos**: snake_case (ex: `appointment_card.dart`)

### Organização de Arquivos

- Um widget por arquivo para widgets complexos
- Agrupar widgets pequenos relacionados
- Separar modelos, serviços e widgets em diretórios distintos

### Documentação

- Documentar todas as classes públicas
- Documentar métodos complexos
- Usar comentários para explicar lógica não óbvia

```dart
/// Widget para exibir um cartão de agendamento
///
/// Exibe informações do agendamento e permite ações como
/// confirmar, cancelar ou editar.
class AppointmentCard extends StatelessWidget {
  // ...
}
```

## Fluxo de Trabalho Git

### Branches

- `main`: Código em produção
- `develop`: Branch de desenvolvimento
- `feature/nome-da-feature`: Para novas funcionalidades
- `bugfix/nome-do-bug`: Para correções de bugs

### Commits

Seguimos o padrão Conventional Commits:

- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `refactor:` Refatoração de código
- `docs:` Documentação
- `test:` Adição ou modificação de testes
- `chore:` Alterações de build, dependências, etc.

### Pull Requests

- Descrever claramente o que foi implementado
- Referenciar issues relacionadas
- Incluir testes para novas funcionalidades
- Garantir que todos os testes passem

## Dependências Principais

- **flutter_riverpod**: Gerenciamento de estado
- **go_router**: Navegação
- **intl**: Internacionalização
- **http**: Requisições HTTP
- **shared_preferences**: Armazenamento local
- **flutter_local_notifications**: Notificações push
- **table_calendar**: Visualização de calendário
- **mockito**: Mocks para testes

## Processo de Revisão de Código

### Critérios de Aceitação

1. Código segue as convenções estabelecidas
2. Testes unitários e de widget foram implementados
3. Não há problemas de performance óbvios
4. Documentação foi atualizada
5. Não há código duplicado

### Checklist de Revisão

- [ ] O código segue os padrões de design estabelecidos?
- [ ] Os testes cobrem os casos principais?
- [ ] A documentação foi atualizada?
- [ ] O código é eficiente e legível?
- [ ] As dependências são gerenciadas corretamente?

## Recursos Adicionais

- [Documentação do Flutter](https://flutter.dev/docs)
- [Documentação do Riverpod](https://riverpod.dev/docs/getting_started)
- [Guia de Estilo Dart](https://dart.dev/guides/language/effective-dart/style)
- [Melhores Práticas de Testes Flutter](https://flutter.dev/docs/testing)

## Contato

Para dúvidas ou sugestões sobre este guia, entre em contato com a equipe de desenvolvimento.