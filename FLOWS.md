# Fluxos Principais - AGENDEMAIS

Este documento descreve os principais fluxos de usuário no sistema AGENDEMAIS, detalhando as interações entre as camadas da aplicação.

## 1. Fluxo de Autenticação e Seleção de Tenant

```mermaid
sequenceDiagram
    actor User
    participant UI as UI (LoginScreen)
    participant Controller as AuthController
    participant UseCase as AuthUseCase
    participant Repository as AuthRepository
    participant API as API Service
    participant Amplify as AWS Cognito

    User->>UI: Insere credenciais
    UI->>Controller: login(username, password)
    Controller->>UseCase: execute(username, password)
    UseCase->>Repository: login(username, password)
    Repository->>Amplify: signIn(username, password)
    Amplify-->>Repository: AuthResult
    Repository-->>UseCase: User
    UseCase-->>Controller: User
    Controller-->>UI: Atualiza estado (sucesso)
    UI->>UI: Navega para SelectTenantScreen
    
    User->>UI: Seleciona tenant
    UI->>Controller: selectTenant(tenant)
    Controller->>TenantContext: setTenant(tenant)
    TenantContext-->>Controller: Sucesso
    Controller-->>UI: Atualiza estado
    UI->>UI: Navega para Dashboard
```

## 2. Fluxo de Listagem e Filtro de Agendamentos

```mermaid
sequenceDiagram
    actor User
    participant UI as UI (AppointmentsScreen)
    participant Controller as AppointmentController
    participant UseCase as GetAppointmentsUseCase
    participant Repository as AppointmentRepository
    participant API as API Service

    User->>UI: Acessa tela de agendamentos
    UI->>Controller: fetchAppointments()
    Controller->>UseCase: execute(page: 1, pageSize: 20)
    UseCase->>Repository: getPaginatedAppointments()
    Repository->>API: GET /appointments/paginated
    API-->>Repository: Appointments JSON
    Repository-->>UseCase: List<Appointment>
    UseCase-->>Controller: List<Appointment>
    Controller-->>UI: Atualiza estado
    UI->>UI: Exibe agendamentos
    
    User->>UI: Aplica filtro (status, data)
    UI->>Controller: filterAppointments(filters)
    Controller->>UseCase: execute(filters: filters)
    UseCase->>Repository: getPaginatedAppointments(filters: filters)
    Repository->>API: GET /appointments/paginated?status=...
    API-->>Repository: Filtered Appointments JSON
    Repository-->>UseCase: List<Appointment>
    UseCase-->>Controller: List<Appointment>
    Controller-->>UI: Atualiza estado
    UI->>UI: Exibe agendamentos filtrados
```

## 3. Fluxo de Criação de Agendamento

```mermaid
sequenceDiagram
    actor User
    participant UI as UI (CreateAppointmentScreen)
    participant Controller as AppointmentController
    participant Validator as ValueObjects
    participant UseCase as CreateAppointmentUseCase
    participant Repository as AppointmentRepository
    participant API as API Service
    participant Notification as NotificationService

    User->>UI: Preenche formulário
    UI->>Controller: createAppointment(data)
    Controller->>Validator: Valida dados (ClientName, etc.)
    Validator-->>Controller: Dados validados
    Controller->>UseCase: execute(appointment)
    UseCase->>Repository: createAppointment(appointment)
    Repository->>API: POST /appointments
    API-->>Repository: Created Appointment JSON
    Repository-->>UseCase: Appointment
    UseCase->>Notification: scheduleReminders(appointment)
    Notification-->>UseCase: Sucesso
    UseCase-->>Controller: Appointment
    Controller-->>UI: Atualiza estado (sucesso)
    UI->>UI: Exibe confirmação e volta
```

## 4. Fluxo de Agendamentos Recorrentes

```mermaid
sequenceDiagram
    actor User
    participant UI as UI (RecurringAppointmentDialog)
    participant Controller as AppointmentController
    participant UseCase as CreateRecurringAppointmentsUseCase
    participant Repository as AppointmentRepository
    participant API as API Service

    User->>UI: Configura agendamento recorrente
    UI->>Controller: createRecurringAppointments(template, dates)
    Controller->>UseCase: execute(appointments)
    UseCase->>Repository: createBatchAppointments(appointments)
    Repository->>API: POST /appointments/batch
    API-->>Repository: Created Appointments JSON
    Repository-->>UseCase: List<Appointment>
    UseCase-->>Controller: List<Appointment>
    Controller-->>UI: Atualiza estado (sucesso)
    UI->>UI: Exibe confirmação
```

## 5. Fluxo de Atualização de Status

```mermaid
sequenceDiagram
    actor User
    participant UI as UI (AppointmentCard)
    participant Controller as AppointmentController
    participant UseCase as UpdateAppointmentStatusUseCase
    participant Repository as AppointmentRepository
    participant API as API Service
    participant Notification as NotificationService

    User->>UI: Confirma/Cancela agendamento
    UI->>Controller: updateStatus(id, status)
    Controller->>UseCase: execute(id, status)
    UseCase->>Repository: updateAppointmentStatus(id, status)
    Repository->>API: PUT /appointments/{id}/status
    API-->>Repository: Updated Appointment JSON
    Repository-->>UseCase: Appointment
    UseCase->>Notification: sendStatusUpdateNotification(appointment)
    Notification-->>UseCase: Sucesso
    UseCase-->>Controller: Appointment
    Controller-->>UI: Atualiza estado
    UI->>UI: Atualiza visualização
```

## 6. Fluxo de Exportação

```mermaid
sequenceDiagram
    actor User
    participant UI as UI (AppointmentsScreen)
    participant Controller as AppointmentController
    participant UseCase as ExportAppointmentsUseCase
    participant Repository as AppointmentRepository
    participant API as API Service
    participant Storage as StorageService

    User->>UI: Solicita exportação
    UI->>Controller: exportAppointments(format: 'csv')
    Controller->>UseCase: execute(format: 'csv')
    UseCase->>Repository: getAllAppointments()
    Repository->>API: GET /appointments
    API-->>Repository: Appointments JSON
    Repository-->>UseCase: List<Appointment>
    UseCase-->>UseCase: Formata dados para CSV
    UseCase-->>Controller: CSV String
    Controller->>Storage: saveFile(csv)
    Storage-->>Controller: File path
    Controller-->>UI: Atualiza estado (sucesso)
    UI->>UI: Oferece download/compartilhamento
```

## 7. Fluxo de Operações em Lote

```mermaid
sequenceDiagram
    actor User
    participant UI as UI (BatchOperationsWidget)
    participant Controller as BatchOperationsController
    participant UseCase as UpdateBatchStatusUseCase
    participant Repository as AppointmentRepository
    participant API as API Service
    participant Progress as BatchProgressController

    User->>UI: Seleciona múltiplos agendamentos
    User->>UI: Escolhe operação (confirmar)
    UI->>Controller: updateBatchStatus(ids, status)
    Controller->>Progress: startOperation(ids.length)
    Controller->>UseCase: execute(ids, status)
    
    loop For each appointment
        UseCase->>Repository: updateAppointmentStatus(id, status)
        Repository->>API: PUT /appointments/{id}/status
        API-->>Repository: Updated Appointment
        Repository-->>UseCase: Appointment
        UseCase->>Progress: incrementProgress()
        Progress-->>UI: Atualiza barra de progresso
    end
    
    UseCase-->>Controller: List<Appointment>
    Controller->>Progress: completeOperation()
    Controller-->>UI: Atualiza estado (sucesso)
    UI->>UI: Exibe confirmação
```

## 8. Fluxo de Multi-tenancy

```mermaid
sequenceDiagram
    actor User
    participant Router as GoRouter
    participant Context as TenantContext
    participant UI as UI (Screen)
    participant Repository as Repository
    participant API as API Service

    User->>Router: Acessa rota protegida
    Router->>Context: hasTenant?
    Context-->>Router: false
    Router->>Router: Redireciona para SelectTenantScreen
    
    User->>UI: Seleciona tenant
    UI->>Context: setTenant(tenant)
    Context-->>UI: Sucesso
    UI->>Router: Navega para rota original
    
    User->>UI: Realiza operação
    UI->>Repository: operação()
    Repository->>Context: getTenantId()
    Context-->>Repository: tenantId
    Repository->>API: Request com tenantId
    API-->>Repository: Response
    Repository-->>UI: Resultado
    UI->>UI: Atualiza visualização
```

## 9. Fluxo de Tratamento de Erros

```mermaid
sequenceDiagram
    actor User
    participant UI as UI (Screen)
    participant Controller as Controller
    participant UseCase as UseCase
    participant Repository as Repository
    participant API as API Service
    participant ErrorHandler as ErrorHandler
    participant Logger as Logger

    User->>UI: Realiza ação
    UI->>Controller: ação()
    Controller->>UseCase: execute()
    UseCase->>Repository: operação()
    Repository->>API: Request
    API-->>Repository: Erro 400
    Repository-->>UseCase: Lança RepositoryException
    UseCase-->>Controller: Lança UseCaseException
    Controller->>ErrorHandler: handleError(exception)
    ErrorHandler->>Logger: logError(exception)
    ErrorHandler-->>Controller: Mensagem amigável
    Controller-->>UI: Atualiza estado (erro)
    UI->>UI: Exibe mensagem de erro
```

## 10. Fluxo de Analytics

```mermaid
sequenceDiagram
    actor User
    participant UI as UI (Screen)
    participant Analytics as AnalyticsService
    participant Amplify as AWS Pinpoint

    User->>UI: Realiza ação importante
    UI->>Analytics: trackEvent("appointment_created", properties)
    Analytics->>Amplify: recordEvent(event)
    Amplify-->>Analytics: Sucesso
    
    User->>UI: Navega entre telas
    UI->>Analytics: trackScreen("AppointmentsScreen")
    Analytics->>Amplify: recordEvent(screenView)
    Amplify-->>Analytics: Sucesso
```

Estes fluxos representam as principais interações no sistema AGENDEMAIS, demonstrando como os dados fluem entre as diferentes camadas da aplicação seguindo os princípios da Clean Architecture.