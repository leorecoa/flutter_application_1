# 📚 AgendaFácil SaaS - Guia da API

## 🎯 Endpoints Principais

### 1. Gerar QR Code PIX
```http
POST /pix/generate
Content-Type: application/json

{
  "empresa_id": "clinica-abc-123",
  "valor": 99.90,
  "descricao": "Mensalidade Julho 2025"
}
```

**Resposta:**
```json
{
  "success": true,
  "transaction_id": "abc123def456",
  "pix_code": "00020126580014BR.GOV.BCB.PIX...",
  "qr_code_base64": "iVBORw0KGgoAAAANSUhEUgAA...",
  "valor": 99.90,
  "vencimento": "2025-08-01"
}
```

### 2. Atualizar Status Pagamento
```http
PUT /payment/status
Content-Type: application/json

{
  "empresa_id": "clinica-abc-123",
  "transaction_id": "abc123def456",
  "status": "PAGO"
}
```

### 3. Listar Clientes Ativos
```http
GET /clientes/ativos?status_filter=PENDENTE
```

**Resposta:**
```json
{
  "success": true,
  "clientes": [
    {
      "empresa_id": "clinica-abc-123",
      "status_pagamento": "PENDENTE",
      "valor": 99.90,
      "vencimento": "2025-08-01",
      "dias_ate_vencimento": 15
    }
  ],
  "estatisticas": {
    "total_clientes": 25,
    "pagos": 20,
    "pendentes": 3,
    "vencidos": 2,
    "receita_mensal": 1998.00
  }
}
```

### 4. Webhook PIX (Futuro)
```http
POST /webhook/pix
Content-Type: application/json

{
  "transaction_id": "abc123def456",
  "status": "approved",
  "amount": 99.90,
  "paid_at": "2025-07-15T10:30:00Z"
}
```

## 🔐 Segurança

- Chave PIX armazenada no SSM Parameter Store (criptografada)
- CORS configurado para domínios específicos
- Validação de parâmetros obrigatórios
- Logs detalhados para auditoria

## 📊 Estrutura DynamoDB

**Tabela:** `agenda-clientes-prod`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| empresa_id | String (PK) | ID único da empresa |
| tipo_dado | String (SK) | Sempre "pagamento" |
| transaction_id | String | ID da transação PIX |
| valor | Number | Valor da mensalidade |
| status_pagamento | String | PENDENTE/PAGO/VENCIDO/CANCELADO |
| vencimento | String | Data de vencimento (YYYY-MM-DD) |
| pix_code | String | Código PIX EMV |
| created_at | String | Data de criação |
| updated_at | String | Última atualização |

## 🔄 Cobrança Recorrente

- **Agendamento:** Todo dia 1 às 9h (cron: `0 9 1 * ? *`)
- **Processo:** Gera nova cobrança para clientes ativos
- **Status:** Atualiza de PAGO/VENCIDO para PENDENTE
- **Logs:** CloudWatch para monitoramento

## 🧪 Testes

```bash
# Gerar PIX
curl -X POST https://API-URL/prod/pix/generate \
  -H "Content-Type: application/json" \
  -d '{"empresa_id":"teste-123","valor":99.90,"descricao":"Teste"}'

# Listar clientes
curl https://API-URL/prod/clientes/ativos

# Atualizar status
curl -X PUT https://API-URL/prod/payment/status \
  -H "Content-Type: application/json" \
  -d '{"empresa_id":"teste-123","transaction_id":"abc123","status":"PAGO"}'
```