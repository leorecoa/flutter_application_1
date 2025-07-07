#!/bin/bash

# AGENDEMAIS - Deploy Script para Pagamentos PIX e Stripe
# Este script faz o deploy completo das funções de pagamento no AWS

set -e

echo "🚀 AGENDEMAIS - Deploy de Pagamentos PIX e Stripe"
echo "================================================="

# Verificar se estamos no diretório correto
if [ ! -f "template.yaml" ]; then
    echo "❌ Erro: Execute este script no diretório backend/"
    exit 1
fi

# Verificar se SAM CLI está instalado
if ! command -v sam &> /dev/null; then
    echo "❌ SAM CLI não está instalado. Instale primeiro:"
    echo "   https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
    exit 1
fi

# Verificar se AWS CLI está configurado
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI não está configurado. Execute 'aws configure' primeiro."
    exit 1
fi

echo "✅ Pré-requisitos verificados"

# Instalar dependências das funções Lambda
echo "📦 Instalando dependências das funções Lambda..."

echo "   → Payments function..."
cd src/functions/payments
npm install --production
cd ../../../

echo "   → Webhooks function..."
cd src/functions/webhooks  
npm install --production
cd ../../../

echo "   → Auth function..."
cd src/functions/auth
npm install --production --ignore-optional
cd ../../../

echo "   → Appointments function..."
cd src/functions/appointments
npm install --production --ignore-optional 2>/dev/null || echo "     (Dependências já instaladas ou não necessárias)"
cd ../../../

echo "   → Dashboard function..."
cd src/functions/dashboard
npm install --production --ignore-optional 2>/dev/null || echo "     (Dependências já instaladas ou não necessárias)"
cd ../../../

echo "✅ Dependências instaladas"

# Verificar se o secret existe no Secrets Manager
echo "🔐 Verificando AWS Secrets Manager..."
if aws secretsmanager describe-secret --secret-id agendemais/payments &> /dev/null; then
    echo "✅ Secret 'agendemais/payments' encontrado"
else
    echo "⚠️  Secret 'agendemais/payments' não encontrado"
    echo "   Criando secret básico..."
    
    aws secretsmanager create-secret \
        --name agendemais/payments \
        --description "AGENDEMAIS Payment Secrets" \
        --secret-string '{
            "STRIPE_SECRET_KEY": "sk_test_CHANGE_ME",
            "STRIPE_WEBHOOK_SECRET": "whsec_CHANGE_ME",
            "OPENPIX_APP_ID": "CHANGE_ME",
            "PIX_WEBHOOK_SECRET": "CHANGE_ME"
        }' || echo "   (Secret pode já existir)"
    
    echo "⚠️  IMPORTANTE: Configure as chaves reais no Secrets Manager:"
    echo "   aws secretsmanager update-secret --secret-id agendemais/payments --secret-string '...'"
fi

# Build SAM
echo "🔨 Construindo aplicação SAM..."
sam build --use-container

if [ $? -ne 0 ]; then
    echo "❌ Erro no build. Verifique os logs acima."
    exit 1
fi

echo "✅ Build concluído"

# Deploy
echo "🚀 Fazendo deploy..."

# Verificar se é primeira vez ou update
STACK_NAME="agendemais-backend"
if aws cloudformation describe-stacks --stack-name $STACK_NAME &> /dev/null; then
    echo "   Stack existe, fazendo update..."
    sam deploy --stack-name $STACK_NAME --capabilities CAPABILITY_IAM --no-confirm-changeset
else
    echo "   Primeira vez, fazendo deploy guiado..."
    sam deploy --guided --stack-name $STACK_NAME
fi

if [ $? -ne 0 ]; then
    echo "❌ Erro no deploy. Verifique os logs acima."
    exit 1
fi

# Obter URL da API
echo "📋 Obtendo informações do deploy..."
API_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`].OutputValue' \
    --output text)

if [ "$API_URL" != "None" ] && [ ! -z "$API_URL" ]; then
    echo ""
    echo "🎉 Deploy concluído com sucesso!"
    echo "================================="
    echo ""
    echo "📡 API Gateway URL: $API_URL"
    echo ""
    echo "🔗 Endpoints disponíveis:"
    echo "   POST $API_URL/payments/pix"
    echo "   POST $API_URL/payments/stripe"
    echo "   GET  $API_URL/payments/history"
    echo "   GET  $API_URL/payments/{id}/status"
    echo "   POST $API_URL/webhooks/pix"
    echo "   POST $API_URL/webhooks/stripe"
    echo ""
    echo "⚙️  Próximos passos:"
    echo "   1. Configure os webhooks:"
    echo "      • Stripe: $API_URL/webhooks/stripe"
    echo "      • OpenPix: $API_URL/webhooks/pix"
    echo ""
    echo "   2. Atualize as chaves no Secrets Manager:"
    echo "      aws secretsmanager update-secret --secret-id agendemais/payments --secret-string '{...}'"
    echo ""
    echo "   3. Configure variáveis no Amplify Frontend:"
    echo "      AWS_API_ENDPOINT=$API_URL"
    echo ""
    echo "   4. Teste os endpoints:"
    echo "      curl -X POST $API_URL/payments/pix -H 'Authorization: Bearer TOKEN' -d '{...}'"
else
    echo "⚠️  Deploy concluído, mas não foi possível obter a URL da API"
    echo "   Verifique no console AWS CloudFormation"
fi

echo ""
echo "📊 Recursos criados:"
echo "   • Tabela DynamoDB: agendemais-payments"
echo "   • Funções Lambda: PaymentsFunction, WebhooksFunction"
echo "   • API Gateway com endpoints REST"
echo "   • Roles IAM com permissões mínimas"
echo ""
echo "🔍 Para monitorar:"
echo "   • CloudWatch Logs: /aws/lambda/agendemais-*"
echo "   • DynamoDB Console: agendemais-payments table"
echo "   • API Gateway Console: agendemais-backend"
echo ""
echo "✅ AGENDEMAIS pagamentos prontos para produção!"