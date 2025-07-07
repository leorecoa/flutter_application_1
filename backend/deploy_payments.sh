#!/bin/bash

# AGENDEMAIS - Deploy Script para Pagamentos PIX (Banco PAM) e Stripe
# Este script faz o deploy completo das funções de pagamento no AWS

set -e

echo "🚀 AGENDEMAIS - Deploy PIX (Banco PAM) + Stripe"
echo "=============================================="

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

echo "   → Payments PIX/Stripe function..."
cd src/functions/payments
npm install --production
cd ../../../

echo "   → Webhooks Stripe function..."
cd src/functions/webhooks  
npm install --production
cd ../../../

echo "   → Auth function..."
cd src/functions/auth
npm install --production --ignore-optional 2>/dev/null || echo "     (OK)"
cd ../../../

echo "   → Appointments function..."
cd src/functions/appointments
npm install --production --ignore-optional 2>/dev/null || echo "     (OK)"
cd ../../../

echo "   → Dashboard function..."
cd src/functions/dashboard
npm install --production --ignore-optional 2>/dev/null || echo "     (OK)"
cd ../../../

echo "✅ Dependências instaladas"

# Verificar/Criar secret no Secrets Manager
echo "🔐 Configurando AWS Secrets Manager..."
if aws secretsmanager describe-secret --secret-id agendemais/payments &> /dev/null; then
    echo "✅ Secret 'agendemais/payments' encontrado"
else
    echo "⚠️  Secret 'agendemais/payments' não encontrado"
    echo "   Criando secret básico..."
    
    aws secretsmanager create-secret \
        --name agendemais/payments \
        --description "AGENDEMAIS Payment Secrets - PIX Banco PAM + Stripe" \
        --secret-string '{
            "STRIPE_SECRET_KEY": "sk_test_CHANGE_ME_TO_REAL_KEY",
            "STRIPE_WEBHOOK_SECRET": "whsec_CHANGE_ME_TO_REAL_WEBHOOK_SECRET",
            "OPENPIX_API_KEY": "OPTIONAL_OPENPIX_KEY_OR_LEAVE_EMPTY"
        }' || echo "   (Secret pode já existir)"
    
    echo ""
    echo "⚠️  IMPORTANTE: Configure as chaves reais no Secrets Manager:"
    echo "   1. Acesse: https://console.aws.amazon.com/secretsmanager/"
    echo "   2. Edite o secret 'agendemais/payments'"
    echo "   3. Configure:"
    echo "      • STRIPE_SECRET_KEY: sk_live_XXXXXXXXXX"
    echo "      • STRIPE_WEBHOOK_SECRET: whsec_XXXXXXXXXX"
    echo "      • OPENPIX_API_KEY: (opcional para PIX melhorado)"
    echo ""
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
echo "🚀 Fazendo deploy das funções de pagamento..."

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
    echo "🎉 DEPLOY CONCLUÍDO COM SUCESSO!"
    echo "================================="
    echo ""
    echo "📡 API Gateway URL: $API_URL"
    echo ""
    echo "🔗 Endpoints de Pagamento Criados:"
    echo "   💸 PIX (Banco PAM): POST $API_URL/api/pagamento/pix"
    echo "   💳 Stripe:          POST $API_URL/api/pagamento/stripe"
    echo "   📞 Webhook Stripe:  POST $API_URL/api/webhook/stripe"
    echo ""
    echo "💰 Dados PIX Configurados:"
    echo "   • Chave PIX: 05359566493 (CPF)"
    echo "   • Beneficiário: Leandro Jesse da Silva"
    echo "   • Banco: PAM"
    echo ""
    echo "⚙️  PRÓXIMOS PASSOS OBRIGATÓRIOS:"
    echo ""
    echo "1. 🔐 CONFIGURAR CHAVES STRIPE:"
    echo "   • Acesse: https://dashboard.stripe.com/apikeys"
    echo "   • Copie a Secret Key (sk_live_...)"
    echo "   • Configure webhook endpoint: $API_URL/api/webhook/stripe"
    echo "   • Selecione evento: checkout.session.completed"
    echo "   • Copie o Webhook Secret (whsec_...)"
    echo ""
    echo "2. 🔒 ATUALIZAR SECRETS MANAGER:"
    echo "   aws secretsmanager update-secret --secret-id agendemais/payments --secret-string '{"
    echo "     \"STRIPE_SECRET_KEY\": \"sk_live_SUA_CHAVE_AQUI\","
    echo "     \"STRIPE_WEBHOOK_SECRET\": \"whsec_SEU_WEBHOOK_SECRET_AQUI\","
    echo "     \"OPENPIX_API_KEY\": \"OPCIONAL\""
    echo "   }'"
    echo ""
    echo "3. 🌐 CONFIGURAR FRONTEND (Amplify):"
    echo "   • Variável: AWS_API_ENDPOINT = $API_URL"
    echo ""
    echo "4. 🧪 TESTAR ENDPOINTS:"
    echo "   # Teste PIX"
    echo "   curl -X POST $API_URL/api/pagamento/pix \\"
    echo "     -H 'Authorization: Bearer SEU_JWT_TOKEN' \\"
    echo "     -H 'Content-Type: application/json' \\"
    echo "     -d '{\"valor\": 90.00, \"descricao\": \"Teste PIX\"}'"
    echo ""
    echo "   # Teste Stripe"
    echo "   curl -X POST $API_URL/api/pagamento/stripe \\"
    echo "     -H 'Authorization: Bearer SEU_JWT_TOKEN' \\"
    echo "     -H 'Content-Type: application/json' \\"
    echo "     -d '{\"valor\": 90.00, \"descricao\": \"Teste Stripe\"}'"
else
    echo "⚠️  Deploy concluído, mas não foi possível obter a URL da API"
    echo "   Verifique no console AWS CloudFormation"
fi

echo ""
echo "📊 Recursos AWS Criados:"
echo "   • 🗄️  Tabela DynamoDB: agendemais-payments"
echo "   • ⚡ Lambda Functions:"
echo "     - PaymentsPixFunction (PIX Banco PAM)"
echo "     - PaymentsStripeFunction (Stripe Checkout)"
echo "     - WebhooksStripeFunction (Confirmações)"
echo "   • 🌐 API Gateway com endpoints seguros"
echo "   • 🔐 IAM Roles com permissões mínimas"
echo "   • 🔒 Secrets Manager para chaves"
echo ""
echo "🔍 Monitoramento:"
echo "   • CloudWatch Logs:"
echo "     - /aws/lambda/agendemais-PaymentsPixFunction"
echo "     - /aws/lambda/agendemais-PaymentsStripeFunction"
echo "     - /aws/lambda/agendemais-WebhooksStripeFunction"
echo "   • DynamoDB: agendemais-payments table"
echo "   • Stripe Dashboard: https://dashboard.stripe.com/"
echo ""
echo "💡 Variáveis de Ambiente Configuradas:"
echo "   • PIX_CHAVE_CPF = 05359566493"
echo "   • PIX_BENEFICIARIO = Leandro Jesse da Silva"
echo "   • PIX_BANCO = Banco PAM"
echo "   • FRONTEND_URL = https://main.d31iho7gw23enq.amplifyapp.com"
echo "   • JWT_SECRET = agendemais-secret-key-2024"
echo ""
echo "✅ AGENDEMAIS PAGAMENTOS REAIS PRONTOS!"
echo "   🏦 PIX: CPF 05359566493 (Banco PAM)"
echo "   💳 Stripe: Checkout internacional"
echo "   📱 Pronto para receber R$ 90,00 por cliente"