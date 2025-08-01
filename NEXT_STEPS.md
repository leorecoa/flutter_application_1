# Próximos Passos - AGENDEMAIS

Este documento descreve os próximos passos para finalizar a implementação do backend AWS Amplify no projeto AGENDEMAIS.

## O que já foi implementado

1. **Estrutura do Projeto**
   - Arquitetura Clean Architecture com separação de camadas
   - Modelo de dados para Appointment
   - Interface do repositório e implementação
   - Casos de uso para operações de agendamento
   - Providers Riverpod para injeção de dependência

2. **Configuração do Amplify**
   - Arquivo de configuração base (amplifyconfiguration.dart)
   - Schema GraphQL para AppSync
   - Configuração de autenticação com Cognito
   - Configuração de storage com S3
   - Configuração de analytics com Pinpoint
   - Função Lambda para consulta personalizada

3. **Suporte Multi-tenant**
   - Modelo de dados com suporte a múltiplos tenants
   - Regras de autorização baseadas em grupos
   - Script para deploy de novos tenants
   - Configuração de domínios personalizados

4. **Otimização de Custos**
   - Ambiente de desenvolvimento local sem custos AWS
   - Monitoramento de custos em tempo real
   - Detecção e prevenção de chamadas AWS indesejadas
   - Documentação de estratégias de otimização de custos

## Próximos Passos

### 1. Executar o Amplify Init

```bash
cd flutter_application_1
amplify init
```

Siga as instruções conforme detalhado no [AMPLIFY_SETUP_GUIDE.md](./AMPLIFY_SETUP_GUIDE.md).

### 2. Adicionar os Serviços AWS

```bash
# Adicionar autenticação
amplify add auth

# Adicionar API GraphQL
amplify add api

# Adicionar storage
amplify add storage

# Adicionar analytics
amplify add analytics
```

### 3. Implementar as Funções Lambda

Para cada função personalizada definida no schema GraphQL:

```bash
amplify add function
```

Implemente a lógica para:
- getAppointmentsByDateRange
- getAvailableTimeSlots
- getDashboardStats
- createRecurringAppointments
- processPayment
- sendAppointmentReminder

### 4. Publicar as Alterações

```bash
amplify push
```

### 5. Atualizar o Arquivo de Configuração

Após o push, copie o conteúdo do arquivo `amplifyconfiguration.json` gerado para o arquivo `lib/amplifyconfiguration.dart`:

```dart
const amplifyconfig = '''
  // Cole aqui o conteúdo do arquivo amplifyconfiguration.json
''';
```

### 6. Implementar os Casos de Uso Restantes

Implemente os casos de uso que estão apenas com stubs:
- ExportAppointmentsUseCase
- CreateRecurringAppointmentsUseCase
- DeleteAppointmentUseCase
- GetAppointmentsUseCase

### 7. Configurar Grupos de Usuários no Cognito

Após o deploy, acesse o console do AWS Cognito e crie os grupos:
- Admin
- Staff
- Clients

### 8. Configurar Domínios Personalizados

Para cada tenant, execute o script de deploy:

```bash
./scripts/deploy_tenant.sh tenant1 "Empresa ABC" empresa-abc.agendemais.com
```

### 9. Configurar Monitoramento de Custos

No console da AWS:
1. Acesse AWS Budgets
2. Crie orçamentos para cada serviço (Cognito, AppSync, S3, etc.)
3. Configure alertas para notificar quando os custos atingirem limites específicos

### 10. Implementar Testes

Crie testes para validar a integração com AWS Amplify:
- Testes de autenticação
- Testes de API GraphQL
- Testes de storage
- Testes de analytics

### 11. Configurar CI/CD

Implemente um pipeline de CI/CD com GitHub Actions para automatizar o deploy:
- Testes automatizados
- Build para web
- Deploy para AWS Amplify

### 12. Documentação Final

Atualize a documentação com:
- Guia de uso para desenvolvedores
- Guia de administração para tenants
- Guia de monitoramento e otimização de custos

## Recursos Úteis

- [Documentação do AWS Amplify](https://docs.amplify.aws)
- [Documentação do Flutter](https://flutter.dev/docs)
- [Documentação do Riverpod](https://riverpod.dev/docs)
- [Guia de Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Cronograma Estimado

1. **Configuração inicial do Amplify**: 1 dia
2. **Implementação das funções Lambda**: 2-3 dias
3. **Implementação dos casos de uso restantes**: 2 dias
4. **Configuração de grupos e domínios**: 1 dia
5. **Testes e validação**: 2-3 dias
6. **CI/CD e documentação**: 1-2 dias

**Tempo total estimado**: 9-12 dias úteis