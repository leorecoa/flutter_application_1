# 🚀 AGENDEMAIS BACKEND - AWS SERVERLESS

Backend completo com **AWS Lambda + DynamoDB** para o sistema AGENDEMAIS.

## 📋 **ARQUITETURA**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter Web  │────│   API Gateway    │────│   AWS Lambda    │
│   (Frontend)    │    │   (REST API)     │    │   (Functions)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
                                               ┌─────────────────┐
                                               │   DynamoDB      │
                                               │   (Database)    │
                                               └─────────────────┘
```

## 🛠️ **RECURSOS IMPLEMENTADOS**

### **📊 DynamoDB Tables**
- **Users Table**: Usuários com autenticação
- **Appointments Table**: Agendamentos por usuário

### **⚡ Lambda Functions**
- **Auth Function**: Login/Register com JWT + bcrypt
- **Appointments Function**: CRUD completo de agendamentos
- **Dashboard Function**: Métricas e estatísticas em tempo real

### **🔐 Segurança**
- JWT Authentication com refresh
- Bcrypt para hash de senhas
- CORS configurado
- Validação de dados

## 🚀 **DEPLOY**

### **Pré-requisitos**
```bash
# Instalar AWS CLI
aws configure

# Instalar SAM CLI
pip install aws-sam-cli
```

### **Deploy Automático**
```bash
# Executar script de deploy
chmod +x deploy.sh
./deploy.sh
```

### **Deploy Manual**
```bash
# Build
sam build

# Deploy
sam deploy --guided --stack-name agendemais-backend
```

## 📡 **ENDPOINTS**

### **🔐 Autenticação**
- `POST /auth/login` - Login de usuário
- `POST /auth/register` - Registro de usuário

### **📅 Agendamentos**
- `GET /appointments` - Listar agendamentos
- `POST /appointments` - Criar agendamento
- `PUT /appointments/{id}` - Atualizar agendamento

### **📊 Dashboard**
- `GET /dashboard/stats` - Estatísticas do dashboard

## 🔧 **CONFIGURAÇÃO FRONTEND**

Para usar a API real no Flutter:

```bash
# Build com API real
flutter build web --dart-define=USE_REAL_API=true --dart-define=API_BASE_URL=https://your-api-url.com/prod
```

## 💰 **CUSTOS AWS**

- **DynamoDB**: Pay-per-request (muito baixo para início)
- **Lambda**: 1M requests gratuitas/mês
- **API Gateway**: 1M requests gratuitas/mês
- **Estimativa**: < $5/mês para até 10k usuários

## 🎯 **PRÓXIMOS PASSOS**

- [ ] Implementar refresh tokens
- [ ] Adicionar rate limiting
- [ ] Implementar cache com ElastiCache
- [ ] Monitoramento com CloudWatch
- [ ] Backup automático DynamoDB