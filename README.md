# AgendaFácil SaaS - Sistema de Agendamento Multi-Tenant

[![Build & Deploy](https://github.com/leorecoa/flutter_application_1/actions/workflows/flutter-amplify-deploy.yml/badge.svg)](https://github.com/leorecoa/flutter_application_1/actions/workflows/flutter-amplify-deploy.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=leorecoa_flutter_application_1&metric=alert_status)](https://sonarcloud.io/dashboard?id=leorecoa_flutter_application_1)
[![Coverage](https://codecov.io/gh/leorecoa/flutter_application_1/branch/main/graph/badge.svg)](https://codecov.io/gh/leorecoa/flutter_application_1)
[![Security Tests](https://github.com/leorecoa/flutter_application_1/actions/workflows/performance-security.yml/badge.svg)](https://github.com/leorecoa/flutter_application_1/actions/workflows/performance-security.yml)

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

## 🌐 **MULTI-REGIÃO**

O sistema está implantado em múltiplas regiões da AWS para garantir alta disponibilidade e baixa latência:

- **Região Primária**: US East (N. Virginia)
- **Região Secundária**: US West (Oregon)
- **Regiões Adicionais**: South America (São Paulo), Europe (Ireland), Asia Pacific (Tokyo)

Para mais detalhes sobre a implementação multi-região, consulte [README-MULTI-REGION.md](README-MULTI-REGION.md).

## 🔄 **CI/CD**

O projeto utiliza GitHub Actions para automação de CI/CD com:

- **Testes Automatizados**: Execução de testes unitários e de integração
- **Análise de Qualidade**: Integração com SonarCloud para métricas de qualidade
- **Verificação de Cobertura**: Mínimo de 70% de cobertura de código
- **Deploy Automático**: Implantação automática no AWS Amplify após testes bem-sucedidos

Para mais detalhes sobre a configuração de CI/CD, consulte [README-CICD.md](README-CICD.md).

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

## 📄 **LICENÇA**

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

**AgendaFácil SaaS** - Sistema profissional de agendamento multi-tenant com arquitetura serverless escalável.