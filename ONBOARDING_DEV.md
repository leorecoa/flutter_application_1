# 👨‍💻 GUIA DE ONBOARDING - AGENDAFÁCIL SAAS

## 🎯 **BEM-VINDO À EQUIPE**

Este guia vai te ajudar a configurar o ambiente de desenvolvimento e entender a arquitetura do AgendaFácil SaaS em **30 minutos**.

---

## 🛠️ **SETUP INICIAL (10 min)**

### **Pré-requisitos**
```bash
# Instalar ferramentas essenciais
- Node.js 18+
- AWS CLI v2
- SAM CLI
- Flutter SDK 3.16+
- Git
- VS Code (recomendado)
```

### **Configuração AWS**
```bash
# Configurar credenciais AWS
aws configure
# AWS Access Key ID: [sua-key]
# AWS Secret Access Key: [sua-secret]
# Default region: us-east-1
# Default output format: json

# Verificar configuração
aws sts get-caller-identity
```

### **Clone e Setup**
```bash
# Clonar repositório
git clone https://github.com/empresa/agenda-facil-saas.git
cd agenda-facil-saas

# Backend setup
cd backend
npm install
cp .env.example .env

# Frontend setup
cd ../frontend
flutter pub get
```

---

## 🏗️ **ARQUITETURA OVERVIEW (10 min)**

### **Estrutura do Projeto**
```
agenda-facil-saas/
├── backend/                 # AWS Serverless
│   ├── lambda/              # 7 Lambda Functions
│   │   ├── auth/           # Autenticação
│   │   ├── tenant/         # Multi-tenant
│   │   ├── services/       # CRUD Serviços
│   │   ├── appointments/   # Agendamentos
│   │   ├── users/          # Usuários
│   │   ├── booking/        # Booking público
│   │   ├── relatorio/      # Relatórios
│   │   ├── admin/          # Super admin
│   │   └── shared/         # Utilitários
│   ├── tests/              # Testes Jest
│   ├── scripts/            # Scripts utilitários
│   └── template.yaml       # SAM template
├── frontend/               # Flutter Web
│   ├── lib/
│   │   ├── features/       # Módulos por feature
│   │   ├── core/           # Configurações
│   │   └── shared/         # Componentes compartilhados
└── docs/                   # Documentação
```

### **Fluxo de Dados**
```
Flutter → API Gateway → Lambda → DynamoDB
   ↓           ↓          ↓         ↓
 JWT      Cognito    Multi-Tenant  Single
Token    Authorizer  Middleware    Table
```

### **Multi-Tenant Pattern**
```javascript
// Cada tenant tem dados isolados
TENANT#uuid-a#SERVICES → SERVICE#service-1
TENANT#uuid-b#SERVICES → SERVICE#service-2

// Middleware extrai tenantId do JWT automaticamente
const { tenantId, userId } = event.tenant;
```

---

## 🚀 **PRIMEIRO DEPLOY (10 min)**

### **Deploy Backend Dev**
```bash
cd backend

# Build e deploy
sam build
sam deploy --guided

# Primeira vez vai pedir configurações:
# Stack Name: agenda-facil-dev-[seu-nome]
# AWS Region: us-east-1
# Confirm changes: Y
# Allow SAM to create IAM roles: Y
# Save parameters to samconfig.toml: Y
```

### **Executar Frontend**
```bash
cd frontend

# Atualizar API URL no config
# lib/core/config/app_config.dart
# baseUrl: 'https://sua-api-url.execute-api.us-east-1.amazonaws.com/dev'

# Executar
flutter run -d chrome
```

### **Testar Integração**
```bash
# Abrir http://localhost:3000
# Criar conta de teste
# Verificar logs no CloudWatch
```

---

## 🧪 **DESENVOLVIMENTO LOCAL**

### **Executar Testes**
```bash
cd backend

# Todos os testes
npm test

# Com coverage
npm run test:coverage

# Testes específicos
npm test auth.test.js
npm test tenant.test.js

# Lint
npm run lint
```

### **Debug Lambda Local**
```bash
# Executar API local
sam local start-api

# Testar endpoint
curl http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456"}'
```

### **Hot Reload Frontend**
```bash
cd frontend
flutter run -d chrome --hot
```

---

## 📚 **CONCEITOS IMPORTANTES**

### **1. Multi-Tenant Middleware**
```javascript
// Toda Lambda protegida usa este middleware
const MultiTenantMiddleware = require('../shared/multi-tenant');

exports.handler = MultiTenantMiddleware.withMultiTenant(async (event) => {
  // event.tenant contém: { id, userId, email, plan, groups }
  const { id: tenantId } = event.tenant;
  
  // Todos os dados são isolados por tenantId
  const params = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}#SERVICES`
    }
  };
});
```

### **2. DynamoDB Single Table**
```javascript
// Padrão de chaves para isolamento
const serviceKey = {
  PK: `TENANT#${tenantId}#SERVICES`,
  SK: `SERVICE#${serviceId}`
};

const appointmentKey = {
  PK: `TENANT#${tenantId}#APPOINTMENTS`, 
  SK: `APPOINTMENT#${appointmentId}`
};

// GSI para queries eficientes
const gsiKey = {
  GSI1PK: `TENANT#${tenantId}#APPOINTMENTS`,
  GSI1SK: `DATE#${date}`
};
```

### **3. Flutter Providers**
```dart
// Todos os providers seguem este padrão
class ServiceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Métodos async que notificam mudanças
  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/services');
      _services = response.data.map((s) => ServiceModel.fromJson(s)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
```

---

## 🔧 **WORKFLOWS COMUNS**

### **Adicionar Nova Feature**
```bash
# 1. Criar branch
git checkout -b feature/nova-funcionalidade

# 2. Backend: Criar Lambda function
mkdir backend/lambda/nova-feature
# Implementar handler, testes, etc.

# 3. Frontend: Criar provider e telas
mkdir lib/features/nova-feature
# Implementar provider, screens, models

# 4. Atualizar template.yaml
# Adicionar nova função e rotas

# 5. Testes
npm test
flutter test

# 6. Deploy dev
sam deploy --config-env dev

# 7. PR para develop
git push origin feature/nova-funcionalidade
```

### **Debug de Problemas**
```bash
# Logs Lambda em tempo real
aws logs tail /aws/lambda/agenda-facil-dev-TenantFunction --follow

# Métricas CloudWatch
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=agenda-facil-dev-TenantFunction

# DynamoDB queries
aws dynamodb scan --table-name agenda-facil-dev-main --limit 10
```

### **Monitoramento de Custos**
```bash
# Script de análise
node scripts/cost-monitor.js

# Dashboard CloudWatch
# https://console.aws.amazon.com/cloudwatch/home#dashboards:name=AgendaFacil-dev
```

---

## 📋 **CHECKLIST DIÁRIO**

### **Antes de Começar**
- [ ] `git pull origin develop`
- [ ] `npm install` (se package.json mudou)
- [ ] `flutter pub get` (se pubspec.yaml mudou)
- [ ] Verificar se ambiente dev está funcionando

### **Antes de Fazer PR**
- [ ] `npm run lint` (zero warnings)
- [ ] `npm run test:coverage` (>90%)
- [ ] `flutter analyze` (zero issues)
- [ ] Testar funcionalidade no browser
- [ ] Verificar logs no CloudWatch
- [ ] Documentar mudanças no PR

### **Deploy para Prod**
- [ ] Testes passando em develop
- [ ] Code review aprovado
- [ ] Merge para main
- [ ] CI/CD deploy automático
- [ ] Smoke tests pós-deploy
- [ ] Monitorar métricas por 30min

---

## 🆘 **TROUBLESHOOTING**

### **Problemas Comuns**

**1. "Missing required key 'TableName'"**
```bash
# Verificar variáveis de ambiente
aws lambda get-function-configuration \
  --function-name agenda-facil-dev-TenantFunction \
  --query 'Environment.Variables'
```

**2. "Cognito token invalid"**
```bash
# Verificar configuração Cognito
aws cognito-idp describe-user-pool \
  --user-pool-id us-east-1_XXXXXXX
```

**3. "CORS error no frontend"**
```bash
# Verificar API Gateway CORS
# template.yaml → Globals → Api → Cors
```

**4. "Flutter build failed"**
```bash
flutter clean
flutter pub get
flutter build web
```

### **Contatos de Suporte**
- **Tech Lead**: @tech-lead
- **DevOps**: @devops-team  
- **Slack**: #agenda-facil-dev
- **Docs**: https://docs.agendafacil.com

---

## 🎓 **RECURSOS DE APRENDIZADO**

### **Documentação Técnica**
- [AWS SAM Developer Guide](https://docs.aws.amazon.com/serverless-application-model/)
- [Flutter Documentation](https://flutter.dev/docs)
- [DynamoDB Single Table Design](https://aws.amazon.com/blogs/compute/creating-a-single-table-design-with-amazon-dynamodb/)

### **Vídeos Internos**
- Arquitetura Overview (15min)
- Multi-tenant Deep Dive (30min)
- Deploy e Monitoring (20min)

### **Código de Exemplo**
```bash
# Repositório com exemplos
git clone https://github.com/empresa/agenda-facil-examples.git
```

---

**Bem-vindo à equipe! 🚀**

**Em caso de dúvidas, não hesite em perguntar no Slack #agenda-facil-dev**