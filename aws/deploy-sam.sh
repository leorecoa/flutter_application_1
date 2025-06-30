#!/bin/bash

# Deploy AWS SAM - AgendaFácil Backend
ENVIRONMENT=${1:-dev}
APP_NAME="agendafacil"
REGION="us-east-1"

echo "🚀 Iniciando deploy SAM para ambiente: $ENVIRONMENT"

# 1. Validar template
echo "📋 Validando template SAM..."
sam validate --template template.yaml

if [ $? -ne 0 ]; then
    echo "❌ Template inválido!"
    exit 1
fi

# 2. Build
echo "🔨 Fazendo build das funções Lambda..."
sam build --template template.yaml

# 3. Deploy
echo "🚀 Fazendo deploy..."
sam deploy \
  --template-file .aws-sam/build/template.yaml \
  --stack-name "${APP_NAME}-${ENVIRONMENT}" \
  --parameter-overrides \
    Environment=$ENVIRONMENT \
    AppName=$APP_NAME \
  --capabilities CAPABILITY_IAM \
  --region $REGION \
  --confirm-changeset \
  --resolve-s3

# 4. Obter outputs
echo "📋 Obtendo informações do deploy..."
API_URL=$(aws cloudformation describe-stacks \
  --stack-name "${APP_NAME}-${ENVIRONMENT}" \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' \
  --output text \
  --region $REGION)

USER_POOL_ID=$(aws cloudformation describe-stacks \
  --stack-name "${APP_NAME}-${ENVIRONMENT}" \
  --query 'Stacks[0].Outputs[?OutputKey==`UserPoolId`].OutputValue' \
  --output text \
  --region $REGION)

CLIENT_ID=$(aws cloudformation describe-stacks \
  --stack-name "${APP_NAME}-${ENVIRONMENT}" \
  --query 'Stacks[0].Outputs[?OutputKey==`UserPoolClientId`].OutputValue' \
  --output text \
  --region $REGION)

echo ""
echo "✅ Deploy concluído com sucesso!"
echo "📋 Informações do ambiente $ENVIRONMENT:"
echo "API URL: $API_URL"
echo "User Pool ID: $USER_POOL_ID"
echo "Client ID: $CLIENT_ID"
echo ""
echo "🔧 Atualize seu aws_config.dart com essas informações."