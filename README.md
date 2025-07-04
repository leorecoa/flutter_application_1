# AgendaFácil SaaS - Sistema de Agendamento Multi-Tenant

[![Flutter Tests](https://github.com/leorecoa/flutter_application_1/actions/workflows/flutter-test.yml/badge.svg)](https://github.com/leorecoa/flutter_application_1/actions/workflows/flutter-test.yml)

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

### **Desenvolvimento Local**
```bash
# Clone o repositório
git clone https://github.com/leorecoa/flutter_application_1.git
cd flutter_application_1

# Instalar dependências
flutter pub get

# Executar testes
flutter test

# Executar aplicação
flutter run -d chrome
```

### **Build para Produção**
```bash
# Build web
flutter build web

# Analisar código
flutter analyze
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

## 🔄 **CI/CD**

O projeto utiliza GitHub Actions para automação de CI/CD com:

- **Testes Automatizados**: Execução de testes unitários
- **Análise de Código**: Flutter analyze
- **Build Automático**: Build web para produção

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