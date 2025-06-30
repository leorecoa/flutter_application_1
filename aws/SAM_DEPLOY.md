# 🚀 AWS SAM Deploy - AgendaFácil Backend

## ✅ Template Corrigido

### 🔧 Correções Aplicadas:
- ✅ **Authorizer**: Cognito corretamente configurado
- ✅ **CORS**: Habilitado em todas as APIs
- ✅ **Multi-tenant**: GSI1 para isolamento por usuário
- ✅ **Ambientes**: dev, staging, prod
- ✅ **Políticas**: DynamoDBCrudPolicy aplicadas

## 🚀 Deploy via SAM (Recomendado)

### 1. Instalar SAM CLI
```bash
# Windows
choco install aws-sam-cli

# macOS
brew install aws-sam-cli

# Linux
pip install aws-sam-cli
```

### 2. Deploy por Ambiente

#### Desenvolvimento
```bash
cd aws
sam deploy --config-env default
# ou
./deploy-sam.sh dev
```

#### Staging
```bash
sam deploy --config-env staging
# ou
./deploy-sam.sh staging
```

#### Produção
```bash
sam deploy --config-env prod
# ou
./deploy-sam.sh prod
```

### 3. Deploy Manual
```bash
# Build
sam build

# Deploy
sam deploy \
  --stack-name agendafacil-dev \
  --parameter-overrides Environment=dev AppName=agendafacil \
  --capabilities CAPABILITY_IAM \
  --region us-east-1 \
  --resolve-s3
```

## 📦 Recursos Criados

### 🔐 Cognito
- User Pool com políticas de senha
- Client sem secret (para web/mobile)
- Auto-verificação por email

### 🗄️ DynamoDB (Multi-tenant)
- **agendamentos**: GSI1 por userId + dataHora
- **pagamentos**: GSI1 por userId
- **clientes**: GSI1 por userId  
- **servicos**: GSI1 por userId

### ⚡ Lambda Functions
- **auth**: Login, registro, refresh token
- **agendamentos**: CRUD completo
- **pagamentos**: GET, POST, PUT
- **clientes**: CRUD completo
- **servicos**: CRUD completo

### 🌐 API Gateway
- Authorizer Cognito padrão
- CORS habilitado
- Endpoints RESTful

## 🔧 Configuração Flutter

Após deploy, atualize `aws_config.dart`:

```dart
class AWSConfig {
  static const String region = 'us-east-1';
  static const String cognitoUserPoolId = 'SEU_USER_POOL_ID';
  static const String cognitoClientId = 'SEU_CLIENT_ID';
  static const String apiGatewayUrl = 'SUA_API_URL';
}
```

## 📊 Monitoramento

```bash
# Logs das funções
sam logs -n AgendamentosFunction --stack-name agendafacil-dev --tail

# Métricas
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=agendafacil-dev-agendamentos
```

## 🧹 Limpeza

```bash
# Deletar stack
aws cloudformation delete-stack --stack-name agendafacil-dev

# Limpar bucket S3 (se necessário)
aws s3 rm s3://aws-sam-cli-managed-default-samclisourcebucket-* --recursive
```

## ❌ Por que não Amplify?

- **SAM** é específico para serverless
- **Amplify** é mais para full-stack com frontend
- **Template complexo** funciona melhor no SAM
- **Controle granular** de recursos
- **Multi-ambiente** mais simples

---
**Status**: ✅ Pronto para deploy via SAM