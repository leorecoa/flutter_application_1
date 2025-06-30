#!/bin/bash

# Deploy script para AWS
APP_NAME="agendamentos-app"
REGION="us-east-1"

echo "🚀 Iniciando deploy da infraestrutura AWS..."

# 1. Deploy CloudFormation
echo "📦 Criando stack CloudFormation..."
aws cloudformation deploy \
  --template-file cloudformation-template.yaml \
  --stack-name $APP_NAME \
  --parameter-overrides AppName=$APP_NAME \
  --capabilities CAPABILITY_IAM \
  --region $REGION

# 2. Obter outputs do CloudFormation
echo "📋 Obtendo informações da stack..."
USER_POOL_ID=$(aws cloudformation describe-stacks \
  --stack-name $APP_NAME \
  --query 'Stacks[0].Outputs[?OutputKey==`UserPoolId`].OutputValue' \
  --output text \
  --region $REGION)

CLIENT_ID=$(aws cloudformation describe-stacks \
  --stack-name $APP_NAME \
  --query 'Stacks[0].Outputs[?OutputKey==`UserPoolClientId`].OutputValue' \
  --output text \
  --region $REGION)

API_URL=$(aws cloudformation describe-stacks \
  --stack-name $APP_NAME \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' \
  --output text \
  --region $REGION)

# 3. Criar pacote Lambda
echo "📦 Criando pacote Lambda..."
cd lambda
zip -r agendamentos.zip agendamentos.js
cd ..

# 4. Deploy Lambda
echo "🔧 Fazendo deploy da função Lambda..."
aws lambda create-function \
  --function-name $APP_NAME-agendamentos \
  --runtime nodejs18.x \
  --role arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/$APP_NAME-LambdaExecutionRole \
  --handler agendamentos.handler \
  --zip-file fileb://lambda/agendamentos.zip \
  --environment Variables="{AGENDAMENTOS_TABLE=$APP_NAME-agendamentos}" \
  --region $REGION

echo "✅ Deploy concluído!"
echo "📋 Informações importantes:"
echo "User Pool ID: $USER_POOL_ID"
echo "Client ID: $CLIENT_ID"
echo "API URL: $API_URL"
echo ""
echo "🔧 Atualize o arquivo aws_config.dart com essas informações."