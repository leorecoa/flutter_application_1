#!/bin/bash

# Deploy Flutter SaaS no AWS Amplify
APP_NAME="agendafacil-saas"
REGION="us-east-1"
GITHUB_REPO="https://github.com/leorecoa/flutter_application_1"

echo "🚀 Configurando AWS Amplify para Flutter SaaS..."

# 1. Criar app Amplify
echo "📱 Criando aplicação Amplify..."
AMPLIFY_APP_ID=$(aws amplify create-app \
  --name $APP_NAME \
  --description "Flutter SaaS - AgendaFácil" \
  --platform WEB \
  --build-spec file://amplify.yml \
  --custom-rules '[
    {
      "source": "/<*>",
      "target": "/index.html",
      "status": "200"
    }
  ]' \
  --region $REGION \
  --query 'app.appId' \
  --output text)

echo "✅ App criado: $AMPLIFY_APP_ID"

# 2. Conectar repositório GitHub
echo "🔗 Conectando repositório GitHub..."
aws amplify create-branch \
  --app-id $AMPLIFY_APP_ID \
  --branch-name main \
  --description "Branch principal" \
  --enable-auto-build \
  --region $REGION

# 3. Configurar variáveis de ambiente
echo "⚙️ Configurando variáveis de ambiente..."
aws amplify put-backend-environment \
  --app-id $AMPLIFY_APP_ID \
  --environment-name dev \
  --region $REGION

# 4. Iniciar primeiro deploy
echo "🚀 Iniciando primeiro deploy..."
JOB_ID=$(aws amplify start-job \
  --app-id $AMPLIFY_APP_ID \
  --branch-name main \
  --job-type RELEASE \
  --region $REGION \
  --query 'jobSummary.jobId' \
  --output text)

echo "✅ Deploy iniciado: $JOB_ID"

# 5. Obter URL da aplicação
APP_URL=$(aws amplify get-app \
  --app-id $AMPLIFY_APP_ID \
  --region $REGION \
  --query 'app.defaultDomain' \
  --output text)

echo ""
echo "🎉 Deploy configurado com sucesso!"
echo "📋 Informações:"
echo "App ID: $AMPLIFY_APP_ID"
echo "Job ID: $JOB_ID"
echo "URL: https://main.$APP_URL"
echo ""
echo "🔧 Para monitorar o deploy:"
echo "aws amplify get-job --app-id $AMPLIFY_APP_ID --branch-name main --job-id $JOB_ID"