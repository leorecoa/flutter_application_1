# Estrutura do Banco de Dados - SaaS Agendamento

## DynamoDB Tables

### 1. Users (Autônomos)
```json
{
  "PK": "USER#uuid",
  "SK": "PROFILE",
  "userId": "uuid",
  "email": "email@example.com",
  "name": "Nome do Profissional",
  "phone": "+5511999999999",
  "businessName": "Barbearia do João",
  "businessType": "barbeiro|manicure|personal|diarista",
  "customLink": "joao-barbeiro",
  "planId": "basic|professional|premium",
  "planExpiry": "2024-12-31T23:59:59Z",
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "settings": {
    "whatsappEnabled": true,
    "whatsappNumber": "+5511999999999",
    "paymentMethods": ["pix", "card", "cash"],
    "workingHours": {
      "monday": {"start": "08:00", "end": "18:00", "enabled": true},
      "tuesday": {"start": "08:00", "end": "18:00", "enabled": true}
    }
  }
}
```

### 2. Services
```json
{
  "PK": "USER#uuid",
  "SK": "SERVICE#serviceId",
  "serviceId": "uuid",
  "userId": "uuid",
  "name": "Corte Masculino",
  "description": "Corte tradicional masculino",
  "duration": 30,
  "price": 25.00,
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### 3. Appointments
```json
{
  "PK": "USER#uuid",
  "SK": "APPOINTMENT#appointmentId",
  "appointmentId": "uuid",
  "userId": "uuid",
  "clientName": "Nome do Cliente",
  "clientPhone": "+5511888888888",
  "clientEmail": "cliente@email.com",
  "serviceId": "uuid",
  "serviceName": "Corte Masculino",
  "servicePrice": 25.00,
  "appointmentDate": "2024-02-15",
  "appointmentTime": "14:30",
  "status": "scheduled|confirmed|completed|cancelled",
  "paymentStatus": "pending|paid|failed",
  "paymentMethod": "pix|card|cash",
  "paymentId": "payment_uuid",
  "notes": "Observações do cliente",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### 4. Plans
```json
{
  "PK": "PLAN#planId",
  "SK": "CONFIG",
  "planId": "basic|professional|premium",
  "name": "Plano Básico",
  "price": 19.90,
  "features": {
    "maxAppointments": 50,
    "whatsappIntegration": false,
    "customBranding": false,
    "analytics": false
  },
  "isActive": true
}
```

## GSI (Global Secondary Indexes)

### GSI1: Busca por Link Personalizado
- PK: customLink
- SK: userId

### GSI2: Agendamentos por Data
- PK: userId
- SK: appointmentDate#appointmentTime