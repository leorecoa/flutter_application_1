# 💰 AGENDEMAIS - Guia de Configuração de Pagamentos

Este guia contém todas as instruções necessárias para configurar os pagamentos PIX e Stripe em produção no AGENDEMAIS.

---

## 🎯 Resumo da Implementação

### ✅ **PIX Pagamentos**
- **Chave PIX:** 05359566493 (CPF)
- **Titular:** Leandro Jesse da Silva
- **Banco:** PAM
- **Integração:** OpenPix (API opcional) + Fallback manual
- **QR Code:** Geração dinâmica
- **Webhook:** Confirmação automática de pagamento

### ✅ **Stripe Pagamentos**
- **Produto:** Plano Premium - Corte + Barba
- **Valor:** R$ 90,00
- **Método:** Checkout Session
- **Webhook:** Confirmação automática de pagamento

---

## 🔧 Configuração AWS

### 1. **Secrets Manager - Criar Segredos**

Acesse o AWS Secrets Manager e crie um novo segredo:

```json
{
  "name": "agendemais/payments",
  "description": "AGENDEMAIS Payment Secrets",
  "secretString": {
    "STRIPE_SECRET_KEY": "sk_live_XXXXXXXXXXXXXXXXXX",
    "STRIPE_WEBHOOK_SECRET": "whsec_XXXXXXXXXXXXXXXXXX", 
    "OPENPIX_APP_ID": "Q2xpZW50X0lkXzxxxxxxxxxx",
    "PIX_WEBHOOK_SECRET": "your-pix-webhook-secret"
  }
}
```

### 2. **Deploy do Backend**

No diretório `backend/`, execute:

```bash
# Instalar dependências
cd backend/src/functions/payments && npm install
cd ../webhooks && npm install
cd ../../

# Deploy com SAM
sam build
sam deploy --guided
```

### 3. **Configurar Variáveis de Ambiente**

No Amplify Console, adicionar as variáveis:

```env
# PIX Configuration
PIX_CHAVE_CPF=05359566493
PIX_BENEFICIARIO=Leandro Jesse da Silva
PIX_BANCO=Banco PAM

# Frontend URL for Stripe redirects
FRONTEND_URL=https://main.d31iho7gw23enq.amplifyapp.com

# JWT Secret
JWT_SECRET=agendemais-secret-key-2024
```

---

## 💳 Configuração Stripe

### 1. **Criar Conta Stripe**

1. Acesse [stripe.com](https://stripe.com) e crie uma conta
2. Complete a verificação da conta para ativação
3. Configure conta para aceitar pagamentos no Brasil

### 2. **Obter Chaves API**

Dashboard Stripe → Developers → API Keys:

```bash
# Chave Secreta (Servidor)
STRIPE_SECRET_KEY=sk_live_XXXXXXXXXXXXXXXXXX

# Chave Pública (Frontend - se necessário)
STRIPE_PUBLIC_KEY=pk_live_XXXXXXXXXXXXXXXXXX
```

### 3. **Configurar Webhooks**

Dashboard Stripe → Developers → Webhooks → Add endpoint:

```
URL: https://sua-api-gateway-url.amazonaws.com/prod/webhooks/stripe
Events:
  - checkout.session.completed
  - payment_intent.succeeded
  - payment_intent.payment_failed
```

Copie o **Webhook Secret**:
```bash
STRIPE_WEBHOOK_SECRET=whsec_XXXXXXXXXXXXXXXXXX
```

---

## 🏦 Configuração PIX

### 1. **OpenPix (Opcional)**

Se desejar usar a API OpenPix para melhor integração:

1. Acesse [openpix.com.br](https://openpix.com.br)
2. Crie uma conta e cadastre sua chave PIX (05359566493)
3. Obtenha o App ID:

```bash
OPENPIX_APP_ID=Q2xpZW50X0lkXzxxxxxxxxxx
```

### 2. **Configurar Webhook PIX (OpenPix)**

No painel OpenPix → Webhooks:

```
URL: https://sua-api-gateway-url.amazonaws.com/prod/webhooks/pix
Eventos: charge.completed, charge.expired
```

### 3. **Fallback Manual**

Se não usar OpenPix, o sistema já funciona com:
- Geração manual do BR Code PIX
- QR Code placeholder
- Verificação manual de status

---

## 🛠️ Configuração Técnica

### 1. **Tabela DynamoDB**

A tabela `agendemais-payments` será criada automaticamente com:

```json
{
  "id": "uuid",
  "userId": "user-id",
  "amount": 90.00,
  "description": "Plano Premium - Corte + Barba",
  "paymentType": "pix|stripe",
  "status": "pending|paid|failed|expired",
  "createdAt": "ISO-date",
  "updatedAt": "ISO-date",
  "pixData": {
    "chave": "05359566493",
    "beneficiario": "Leandro Jesse da Silva",
    "banco": "Banco PAM",
    "qrCode": "base64-image",
    "copyPasteCode": "br-code",
    "transactionId": "uuid"
  },
  "stripeData": {
    "sessionId": "cs_xxx",
    "checkoutUrl": "https://checkout.stripe.com/xxx",
    "paymentIntentId": "pi_xxx"
  }
}
```

### 2. **Endpoints API**

```
POST /payments/pix         - Gerar pagamento PIX
POST /payments/stripe      - Gerar pagamento Stripe  
GET  /payments/history     - Histórico de pagamentos
GET  /payments/{id}/status - Status do pagamento

POST /webhooks/pix         - Webhook PIX
POST /webhooks/stripe      - Webhook Stripe
```

### 3. **Autenticação**

Todos os endpoints (exceto webhooks) exigem token JWT:

```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 🧪 Testando a Integração

### 1. **Teste PIX**

```bash
curl -X POST https://sua-api.com/payments/pix \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "amount": 90.00,
    "description": "Teste PIX - Plano Premium"
  }'
```

### 2. **Teste Stripe**

```bash
curl -X POST https://sua-api.com/payments/stripe \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "amount": 90.00,
    "description": "Teste Stripe - Plano Premium"
  }'
```

### 3. **Teste Webhook PIX**

```bash
curl -X POST https://sua-api.com/webhooks/pix \
  -H "Content-Type: application/json" \
  -d '{
    "event": "OPENPIX:CHARGE_COMPLETED",
    "charge": {
      "correlationID": "payment-id-uuid",
      "status": "COMPLETED"
    }
  }'
```

### 4. **Teste Webhook Stripe**

Use o Stripe CLI para testar webhooks:

```bash
stripe listen --forward-to https://sua-api.com/webhooks/stripe
stripe trigger checkout.session.completed
```

---

## 🚀 Deploy em Produção

### 1. **Checklist Pré-Deploy**

- [ ] Secrets Manager configurado
- [ ] Stripe account verificada
- [ ] Webhooks configurados
- [ ] Variáveis de ambiente definidas
- [ ] Testes realizados

### 2. **Deploy Backend**

```bash
cd backend/
sam build --use-container
sam deploy --stack-name agendemais-payments-prod
```

### 3. **Deploy Frontend**

```bash
cd ../
chmod +x build_production_final.sh
./build_production_final.sh
```

### 4. **Configurar Amplify**

Amplify Console → Environment Variables:

```env
PIX_CHAVE_CPF=05359566493
PIX_BENEFICIARIO=Leandro Jesse da Silva
PIX_BANCO=Banco PAM
FRONTEND_URL=https://main.d31iho7gw23enq.amplifyapp.com
JWT_SECRET=agendemais-secret-key-2024
```

---

## 📊 Monitoramento

### 1. **CloudWatch Logs**

Monitore os logs das funções Lambda:
- `/aws/lambda/agendemais-PaymentsFunction`
- `/aws/lambda/agendemais-WebhooksFunction`

### 2. **DynamoDB Metrics**

Acompanhe:
- Read/Write capacity
- Item count na tabela payments
- Throttled requests

### 3. **Stripe Dashboard**

Monitor:
- Pagamentos processados
- Taxa de sucesso
- Chargebacks/disputes

---

## 🔒 Segurança

### 1. **Chaves e Segredos**

- ✅ Stripe keys no Secrets Manager
- ✅ Webhook secrets validados
- ✅ JWT tokens com expiração
- ✅ HTTPS obrigatório

### 2. **Validações**

- ✅ Verificação de assinatura webhook
- ✅ Autenticação JWT em endpoints
- ✅ Validação de valores e tipos
- ✅ Rate limiting (via API Gateway)

### 3. **Compliance**

- ✅ PCI DSS (Stripe)
- ✅ LGPD compliance
- ✅ Logs auditáveis
- ✅ Dados criptografados

---

## 🆘 Troubleshooting

### 1. **PIX não funciona**

```bash
# Verificar logs Lambda
aws logs tail /aws/lambda/agendemais-PaymentsFunction --follow

# Testar geração manual
curl -X POST .../payments/pix -H "..." -d "{...}"
```

### 2. **Stripe webhook falha**

```bash
# Verificar endpoint webhook
curl -X POST .../webhooks/stripe

# Testar com Stripe CLI
stripe listen --forward-to .../webhooks/stripe
```

### 3. **DynamoDB errors**

```bash
# Verificar permissões IAM
aws iam get-role --role-name agendemais-payments-role

# Verificar tabela
aws dynamodb describe-table --table-name agendemais-payments
```

---

## 📞 Suporte

Para problemas específicos:

1. **PIX Issues:** Verificar logs do webhook PIX
2. **Stripe Issues:** Stripe Dashboard → Logs  
3. **AWS Issues:** CloudWatch → Lambda logs
4. **Frontend Issues:** Browser DevTools → Network

---

**🎉 Com esta configuração, o AGENDEMAIS está pronto para processar pagamentos reais em produção!**

**Desenvolvido pela equipe AGENDEMAIS - Sistema de Agendamento SaaS**