# AWS Infrastructure Setup

## Pré-requisitos

1. **AWS CLI** instalado e configurado
```bash
aws configure
```

2. **Permissões necessárias:**
   - CloudFormation
   - Cognito
   - DynamoDB
   - Lambda
   - API Gateway
   - IAM

## Deploy

### 1. Deploy Automático
```bash
cd aws
chmod +x deploy.sh
./deploy.sh
```

### 2. Deploy Manual

#### CloudFormation
```bash
aws cloudformation deploy \
  --template-file cloudformation-template.yaml \
  --stack-name agendamentos-app \
  --capabilities CAPABILITY_IAM \
  --region us-east-1
```

#### Lambda
```bash
cd lambda
zip -r agendamentos.zip agendamentos.js
aws lambda create-function \
  --function-name agendamentos-app-agendamentos \
  --runtime nodejs18.x \
  --role arn:aws:iam::ACCOUNT:role/agendamentos-app-LambdaExecutionRole \
  --handler agendamentos.handler \
  --zip-file fileb://agendamentos.zip
```

## Configuração do App

Após o deploy, atualize `lib/core/config/aws_config.dart`:

```dart
class AWSConfig {
  static const String region = 'us-east-1';
  static const String cognitoUserPoolId = 'SEU_USER_POOL_ID';
  static const String cognitoClientId = 'SEU_CLIENT_ID';
  static const String apiGatewayUrl = 'SUA_API_URL';
}
```

## Endpoints Disponíveis

- `GET /agendamentos` - Listar agendamentos
- `POST /agendamentos` - Criar agendamento
- `PUT /agendamentos/{id}` - Atualizar agendamento
- `DELETE /agendamentos/{id}` - Deletar agendamento

## Monitoramento

- **CloudWatch Logs**: Logs das funções Lambda
- **DynamoDB Console**: Visualizar dados das tabelas
- **Cognito Console**: Gerenciar usuários

## Custos Estimados

- **Cognito**: Gratuito até 50.000 MAUs
- **DynamoDB**: Pay-per-request (muito baixo para início)
- **Lambda**: Gratuito até 1M requests/mês
- **API Gateway**: Gratuito até 1M requests/mês

## Limpeza

Para remover todos os recursos:
```bash
aws cloudformation delete-stack --stack-name agendamentos-app
```