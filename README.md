# 🏢 AgendaFácil SaaS - Sistema de Agendamento Multi-Tenant

[![Deploy Status](https://github.com/user/agenda-facil/workflows/Deploy/badge.svg)](https://github.com/user/agenda-facil/actions)
[![Coverage](https://codecov.io/gh/user/agenda-facil/branch/main/graph/badge.svg)](https://codecov.io/gh/user/agenda-facil)

Sistema completo de agendamento profissional com arquitetura serverless, multi-tenant e escalabilidade global.

## 🏗️ **ARQUITETURA**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter Web  │────│   API Gateway    │────│   Lambda Funcs  │
│   (CloudFront)  │    │   (Cognito Auth) │    │   (Multi-Tenant)│
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                       ┌────────▼────────┐    ┌─────────▼─────────┐
                       │   DynamoDB      │    │      S3 Bucket    │
                       │ (Single Table)  │    │   (Files/Reports) │
                       └─────────────────┘    └───────────────────┘
```

### **Componentes**
- **Frontend**: Flutter Web + CloudFront + S3
- **API**: API Gateway + Cognito Authorizer
- **Backend**: Lambda Functions (Node.js 18)
- **Database**: DynamoDB Single Table Pattern
- **Storage**: S3 para arquivos e relatórios
- **Auth**: Cognito User Pool com custom attributes
- **Monitoring**: CloudWatch + X-Ray

## 🚀 **QUICK START**

### **Deploy Backend**
```bash
cd backend
sam build
sam deploy --guided
```

### **Deploy Frontend**
```bash
cd frontend
flutter build web
aws s3 sync build/web/ s3://your-bucket --delete
```

### **Desenvolvimento Local**
```bash
# Backend
cd backend && npm install && npm test

# Frontend  
cd frontend && flutter run -d chrome
```

## 🔗 **ENDPOINTS API**

### **Base URL**: `https://api.agendafacil.com/dev`

### **Autenticação**
```bash
# Login
POST /auth/login
{
  "email": "user@example.com",
  "password": "password123"
}

# Registro
POST /auth/register  
{
  "name": "João Silva",
  "email": "joao@example.com", 
  "password": "password123",
  "businessName": "Barbearia do João",
  "businessType": "salon"
}
```

### **Tenant Management**
```bash
# Criar tenant (após login)
POST /tenants/create
Authorization: Bearer <jwt-token>
{
  "name": "Minha Empresa",
  "businessType": "salon"
}

# Configurações
GET /tenants/config
PUT /tenants/config
{
  "name": "Nome Atualizado",
  "theme": {
    "primaryColor": "#ff0000"
  }
}
```

### **Serviços**
```bash
# Listar serviços
GET /services
Authorization: Bearer <jwt-token>

# Criar serviço
POST /services
{
  "name": "Corte de Cabelo",
  "price": 25.00,
  "duration": 30,
  "description": "Corte masculino"
}
```

### **Relatórios**
```bash
# Relatório financeiro
GET /relatorios/financeiro?startDate=2024-01-01&endDate=2024-01-31&groupBy=day

# Exportar relatório
POST /relatorios/export
{
  "reportType": "financeiro",
  "format": "csv",
  "params": {
    "startDate": "2024-01-01",
    "endDate": "2024-01-31"
  }
}
```

### **Admin (Super Admin Only)**
```bash
# Listar todos os tenants
GET /admin/tenants
Authorization: Bearer <super-admin-jwt>

# Estatísticas globais
GET /admin/stats

# Desabilitar tenant
PATCH /admin/tenants/disable
{
  "tenantId": "uuid",
  "reason": "Violação de política"
}
```

## 🧪 **TESTES**

### **Executar Testes**
```bash
cd backend

# Todos os testes
npm test

# Com coverage
npm run test:coverage

# Testes específicos
npm test -- auth.test.js
npm test -- tenant.test.js
npm test -- admin.test.js
```

### **Exemplo de JWT para Testes**
```javascript
// Mock JWT payload
{
  "sub": "user-123",
  "email": "test@example.com",
  "custom:tenantId": "tenant-456", 
  "custom:plan": "pro",
  "cognito:groups": ["admin"]
}
```

## 🔧 **SCRIPTS ÚTEIS**

### **Deploy**
```bash
# Deploy dev
./scripts/deploy.sh dev

# Deploy prod  
./scripts/deploy.sh prod

# Deploy via CI/CD
git push origin develop  # → dev
git push origin main     # → prod
```

### **Monitoramento**
```bash
# Análise de custos
node scripts/cost-monitor.js

# Logs em tempo real
aws logs tail /aws/lambda/agenda-facil-dev-AuthFunction --follow

# Métricas
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=agenda-facil-dev-AuthFunction \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

## 🏢 **MULTI-TENANT**

### **Isolamento de Dados**
```
TENANT#uuid#SERVICES → SERVICE#id
TENANT#uuid#APPOINTMENTS → APPOINTMENT#id  
TENANT#uuid → CONFIG
TENANT#uuid → USER#userId
```

### **Planos e Quotas**
- **Free**: 50 agendamentos/mês
- **Pro**: Ilimitado
- **Enterprise**: Recursos customizados

### **Custom Attributes Cognito**
```json
{
  "custom:tenantId": "uuid-do-tenant",
  "custom:plan": "free|pro|enterprise"
}
```

## 📊 **MONITORAMENTO**

### **CloudWatch Dashboard**
- Invocações por função
- Erros 4xx/5xx
- Duração média
- Uso por tenant

### **Alarmes Configurados**
- Erros > 5 em 1 minuto
- Duração > 5 segundos  
- Falhas de invocação

### **Métricas Customizadas**
```javascript
logger.metric('appointment_created', 1, 'Count', {
  tenantId: 'uuid',
  plan: 'pro'
});
```

## 🔐 **SEGURANÇA**

### **Autenticação**
- Cognito User Pool com MFA opcional
- JWT com custom claims
- Política de senha: 8+ chars, símbolos, números

### **Autorização**  
- API Gateway Authorizer
- Validação JWT manual com JWKS
- Middleware multi-tenant

### **IAM Least Privilege**
```yaml
AuthFunction:
  - dynamodb:PutItem (UsersTable only)
  - cognito-idp:AdminCreateUser

ServicesFunction:  
  - dynamodb:* (ServicesTable only)
```

## 🌍 **ESCALABILIDADE**

### **DynamoDB Auto Scaling**
- Read: 5-100 RCU
- Write: 5-100 WCU
- GSI scaling automático

### **Lambda Provisioned Concurrency**
- AuthFunction: 10 instâncias
- Endpoints críticos otimizados

### **CloudFront**
- Cache global para frontend
- Certificado SSL automático

## 📁 **ESTRUTURA DO PROJETO**

```
agenda-facil/
├── backend/
│   ├── template.yaml
│   ├── samconfig.toml
│   ├── lambda/
│   │   ├── auth/
│   │   ├── tenant/
│   │   ├── admin/
│   │   ├── services/
│   │   ├── appointments/
│   │   ├── booking/
│   │   ├── relatorio/
│   │   └── shared/
│   ├── tests/
│   └── scripts/
├── frontend/
│   ├── lib/
│   │   ├── features/
│   │   ├── core/
│   │   └── shared/
│   └── web/
├── .github/workflows/
└── docs/
```

## 🚀 **DEPLOY PRODUÇÃO**

### **Pré-requisitos**
- AWS CLI configurado
- SAM CLI instalado
- Node.js 18+
- Flutter SDK

### **Variáveis de Ambiente**
```bash
# GitHub Secrets
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY  
AWS_ACCESS_KEY_ID_PROD
AWS_SECRET_ACCESS_KEY_PROD
SNYK_TOKEN
```

### **Domínio Customizado**
```bash
# Certificado SSL
aws acm request-certificate \
  --domain-name api.agendafacil.com \
  --validation-method DNS

# API Gateway Custom Domain
aws apigateway create-domain-name \
  --domain-name api.agendafacil.com \
  --certificate-arn arn:aws:acm:...
```

## 📞 **SUPORTE**

- **Documentação**: [docs.agendafacil.com](https://docs.agendafacil.com)
- **Issues**: [GitHub Issues](https://github.com/user/agenda-facil/issues)
- **Email**: suporte@agendafacil.com

## 📄 **LICENÇA**

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

**AgendaFácil SaaS** - Sistema profissional de agendamento multi-tenant com arquitetura serverless escalável.