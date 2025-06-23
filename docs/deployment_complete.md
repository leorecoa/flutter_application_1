# 🚀 Guia Completo de Deploy - AgendaFácil

## 📋 Pré-requisitos

### 1. Ferramentas Necessárias
```bash
# AWS CLI
aws --version

# SAM CLI
sam --version

# Node.js (para Lambda functions)
node --version
npm --version

# Flutter (para frontend)
flutter --version
```

### 2. Configuração AWS
```bash
# Configurar credenciais AWS
aws configure
# AWS Access Key ID: [Sua chave]
# AWS Secret Access Key: [Sua chave secreta]
# Default region name: us-east-1
# Default output format: json
```

## 🏗️ Deploy do Backend

### 1. Preparar o Ambiente
```bash
cd backend

# Instalar dependências de todas as funções Lambda
cd lambda/auth && npm install && cd ../..
cd lambda/users && npm install && cd ../..
cd lambda/services && npm install && cd ../..
cd lambda/appointments && npm install && cd ../..
cd lambda/booking && npm install && cd ../..
```

### 2. Deploy usando SAM
```bash
# Build da aplicação
sam build --template-file infrastructure/cloudformation.yaml

# Deploy para desenvolvimento
sam deploy \
  --template-file .aws-sam/build/template.yaml \
  --stack-name agenda-facil-dev \
  --capabilities CAPABILITY_IAM \
  --region us-east-1 \
  --parameter-overrides \
    Environment=dev \
    CognitoDomainPrefix=agenda-facil-dev \
  --confirm-changeset

# Para produção, use:
# --stack-name agenda-facil-prod
# Environment=prod
# CognitoDomainPrefix=agenda-facil-prod
```

### 3. Obter URLs e IDs
```bash
# Obter outputs do CloudFormation
aws cloudformation describe-stacks \
  --stack-name agenda-facil-dev \
  --query 'Stacks[0].Outputs' \
  --output table
```

**Anote os seguintes valores:**
- `ApiGatewayUrl`: URL da API
- `UserPoolId`: ID do Cognito User Pool
- `UserPoolClientId`: ID do Cognito Client
- `DynamoDBTable`: Nome da tabela DynamoDB

## 📱 Configurar Frontend Flutter

### 1. Atualizar Configurações
Edite `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  // Substitua pelos valores obtidos do CloudFormation
  static const String apiGatewayUrl = 'https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/dev';
  static const String cognitoUserPoolId = 'us-east-1_XXXXXXXXX';
  static const String cognitoClientId = 'XXXXXXXXXXXXXXXXXXXXXXXXXX';
  
  // ... resto da configuração
}
```

### 2. Instalar Dependências
```bash
cd flutter_application_1
flutter pub get
```

### 3. Testar Localmente
```bash
# Web
flutter run -d web

# Mobile (Android)
flutter run -d android

# Mobile (iOS)
flutter run -d ios
```

## 🌐 Deploy Frontend Web

### 1. Build para Produção
```bash
flutter build web --release
```

### 2. Deploy no S3 + CloudFront
```bash
# Criar bucket S3 (substitua pelo nome único)
aws s3 mb s3://agenda-facil-frontend-prod

# Configurar bucket para hosting
aws s3 website s3://agenda-facil-frontend-prod \
  --index-document index.html \
  --error-document index.html

# Upload dos arquivos
aws s3 sync build/web/ s3://agenda-facil-frontend-prod --delete

# Configurar política pública
aws s3api put-bucket-policy \
  --bucket agenda-facil-frontend-prod \
  --policy '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublicReadGetObject",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::agenda-facil-frontend-prod/*"
      }
    ]
  }'
```

### 3. Configurar CloudFront (Opcional)
```bash
# Criar distribuição CloudFront via console AWS
# Origin: agenda-facil-frontend-prod.s3-website-us-east-1.amazonaws.com
# Default Root Object: index.html
# Error Pages: 404 -> /index.html (para SPA routing)
```

## 📱 Deploy Mobile Apps

### Android (Google Play Store)

#### 1. Configurar Signing
```bash
# Gerar keystore
keytool -genkey -v -keystore ~/agenda-facil-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Criar android/key.properties
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=upload
storeFile=C:/Users/SeuUsuario/agenda-facil-upload-keystore.jks
```

#### 2. Build e Upload
```bash
# Build AAB
flutter build appbundle --release

# Arquivo gerado: build/app/outputs/bundle/release/app-release.aab
# Upload via Google Play Console
```

### iOS (App Store)

#### 1. Configurar Xcode
```bash
# Abrir projeto iOS
open ios/Runner.xcworkspace

# Configurar:
# - Bundle Identifier: com.agendafacil.app
# - Team: Sua conta de desenvolvedor
# - Signing Certificates
```

#### 2. Build e Upload
```bash
# Build para iOS
flutter build ios --release

# Archive e upload via Xcode:
# Product > Archive > Distribute App
```

## 🧪 Testar APIs

### 1. Importar Coleção Postman
1. Abra o Postman
2. Importe `backend/api-docs/postman-collection.json`
3. Configure a variável `baseUrl` com sua URL da API

### 2. Testar Endpoints
```bash
# Teste básico via curl
curl -X POST https://YOUR-API-URL/dev/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "Teste123!",
    "name": "Usuário Teste",
    "phone": "+5511999999999",
    "businessName": "Negócio Teste",
    "businessType": "barbeiro"
  }'
```

## 🔧 Configurações Adicionais

### 1. Domínio Personalizado
```bash
# Registrar domínio no Route 53
aws route53domains register-domain --domain-name agendafacil.com.br

# Criar certificado SSL
aws acm request-certificate \
  --domain-name agendafacil.com.br \
  --domain-name *.agendafacil.com.br \
  --validation-method DNS

# Configurar API Gateway Custom Domain
aws apigateway create-domain-name \
  --domain-name api.agendafacil.com.br \
  --certificate-arn arn:aws:acm:us-east-1:ACCOUNT:certificate/CERT-ID
```

### 2. Monitoramento
```bash
# Configurar CloudWatch Alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "AgendaFacil-API-Errors" \
  --alarm-description "API Gateway 4XX/5XX errors" \
  --metric-name 4XXError \
  --namespace AWS/ApiGateway \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold
```

### 3. Backup e Segurança
```bash
# Habilitar backup DynamoDB
aws dynamodb put-backup-policy \
  --table-name agenda-facil-dev \
  --backup-policy BackupEnabled=true

# Configurar WAF para API Gateway
aws wafv2 create-web-acl \
  --name AgendaFacil-WAF \
  --scope REGIONAL \
  --default-action Allow={}
```

## 📊 Custos Estimados

### Desenvolvimento (1000 usuários/mês)
- **Lambda**: $20/mês
- **DynamoDB**: $25/mês
- **API Gateway**: $15/mês
- **S3 + CloudFront**: $10/mês
- **Cognito**: $5/mês
- **Total**: ~$75/mês

### Produção (10000 usuários/mês)
- **Lambda**: $100/mês
- **DynamoDB**: $150/mês
- **API Gateway**: $75/mês
- **S3 + CloudFront**: $30/mês
- **Cognito**: $25/mês
- **Total**: ~$380/mês

## 🚨 Troubleshooting

### Problemas Comuns

#### 1. Erro de CORS
```javascript
// Verificar headers nas funções Lambda
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};
```

#### 2. Erro de Autenticação
```bash
# Verificar configuração do Cognito
aws cognito-idp describe-user-pool --user-pool-id us-east-1_XXXXXXXXX
```

#### 3. Erro de DynamoDB
```bash
# Verificar permissões IAM
aws iam get-role-policy --role-name agenda-facil-dev-AuthFunction-XXXXX --policy-name DynamoDBCrudPolicy
```

## 📝 Checklist de Deploy

### Backend
- [ ] AWS CLI configurado
- [ ] SAM CLI instalado
- [ ] Dependências Lambda instaladas
- [ ] CloudFormation stack deployado
- [ ] APIs testadas via Postman
- [ ] Cognito User Pool configurado
- [ ] DynamoDB funcionando

### Frontend
- [ ] Configurações atualizadas
- [ ] Build web funcionando
- [ ] S3 bucket configurado
- [ ] CloudFront configurado (opcional)
- [ ] Domínio configurado (opcional)

### Mobile
- [ ] Android keystore configurado
- [ ] iOS certificates configurados
- [ ] Apps testados em dispositivos
- [ ] Stores configuradas

### Produção
- [ ] Domínio personalizado
- [ ] SSL certificado
- [ ] Monitoramento configurado
- [ ] Backup habilitado
- [ ] WAF configurado
- [ ] Logs centralizados

## 🎯 Próximos Passos

1. **Integrar WhatsApp API** (Z-API ou UltraMsg)
2. **Configurar pagamentos** (Stripe/Mercado Pago)
3. **Implementar notificações** push
4. **Adicionar analytics** (Google Analytics)
5. **Configurar CI/CD** (GitHub Actions)
6. **Implementar testes** automatizados
7. **Documentar APIs** (Swagger/OpenAPI)
8. **Configurar staging** environment

---

**🎉 Parabéns! Seu SaaS AgendaFácil está pronto para produção!**