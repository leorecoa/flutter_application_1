# AGENDEMAIS - Sistema de Agendamento SaaS

[![Deploy Status](https://img.shields.io/badge/Deploy-Live-brightgreen)](https://main.d31iho7gw23enq.amplifyapp.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.16.9-blue)](https://flutter.dev)
[![AWS Amplify](https://img.shields.io/badge/AWS-Amplify-orange)](https://aws.amazon.com/amplify/)
[![Code Quality](https://img.shields.io/badge/Code%20Quality-Refactored-success)](./REFACTORING_SUMMARY.md)

## 🚀 **SISTEMA EM PRODUÇÃO**

**URL:** https://main.d31iho7gw23enq.amplifyapp.com/

> ✨ **CÓDIGO RECÉM REFATORADO** - Veja as melhorias em [REFACTORING_SUMMARY.md](./REFACTORING_SUMMARY.md)

## 📱 **FUNCIONALIDADES**

### ✅ **Autenticação**
- Login/Registro de usuários
- Validação de dados
- Sessões seguras

### ✅ **Dashboard**
- Métricas em tempo real
- Agendamentos do dia
- Receita mensal
- Crescimento semanal

### ✅ **PIX Pagamentos**
- Geração de códigos PIX
- Histórico de transações
- Status de pagamentos

### ✅ **Configurações**
- Perfil do usuário
- Configurações do negócio
- Logout seguro

## 🏗️ **ARQUITETURA**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter Web  │────│   AWS Amplify    │────│   API Gateway   │
│   (Frontend)    │    │   (Hosting)      │    │   (Backend)     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🛠️ **TECNOLOGIAS**

- **Frontend**: Flutter Web (Material Design 3)
- **Hosting**: AWS Amplify
- **Roteamento**: GoRouter
- **Estado**: Riverpod
- **Persistência**: SharedPreferences
- **HTTP**: Dart HTTP Client
- **PIX**: QR Flutter

## 📦 **BUILD & DEPLOY**

```bash
# Instalar dependências
flutter pub get

# Build para produção
flutter build web --release

# Deploy automático via Amplify
git push origin main
```

## 🎯 **PRÓXIMOS PASSOS**

- [ ] Integração com backend real (substituir mocks)
- [ ] Implementar testes unitários
- [ ] Adicionar funcionalidades de agendamento
- [ ] Sistema de notificações
- [ ] Relatórios e analytics
- [ ] App mobile nativo

---

**AGENDEMAIS** - Seu negócio sempre em primeiro lugar! 💼✨