# AGENDEMAIS - Sistema de Agendamento SaaS

[![Deploy Status](https://img.shields.io/badge/Deploy-Live-brightgreen)](https://main.d31iho7gw23enq.amplifyapp.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.16.9-blue)](https://flutter.dev)
[![AWS Amplify](https://img.shields.io/badge/AWS-Amplify-orange)](https://aws.amazon.com/amplify/)

## 🚀 **SISTEMA EM PRODUÇÃO**

**URL:** https://main.d31iho7gw23enq.amplifyapp.com/

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

- **Frontend**: Flutter Web
- **Hosting**: AWS Amplify
- **Roteamento**: GoRouter
- **Estado**: Riverpod
- **UI**: Material Design 3

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

- [ ] Integração com backend real
- [ ] Notificações push
- [ ] App mobile nativo
- [ ] Relatórios avançados

---

**AGENDEMAIS** - Seu negócio sempre em primeiro lugar! 💼✨