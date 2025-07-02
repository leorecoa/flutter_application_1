#!/bin/bash

echo "🚀 Deployando AgendaFácil SaaS..."

# Validar template
echo "📋 Validando template SAM..."
sam validate --template saas-template.yaml

if [ $? -ne 0 ]; then
    echo "❌ Template inválido!"
    exit 1
fi

# Build
echo "🔨 Building aplicação..."
sam build --template saas-template.yaml

if [ $? -ne 0 ]; then
    echo "❌ Build falhou!"
    exit 1
fi

# Deploy
echo "🚀 Fazendo deploy..."
sam deploy \
    --template saas-template.yaml \
    --stack-name agendafacil-saas-prod \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides Environment=prod \
    --region us-east-1 \
    --no-confirm-changeset \
    --no-fail-on-empty-changeset

if [ $? -eq 0 ]; then
    echo "✅ Deploy concluído com sucesso!"
    echo "📊 Obtendo outputs..."
    aws cloudformation describe-stacks \
        --stack-name agendafacil-saas-prod \
        --query 'Stacks[0].Outputs' \
        --output table
else
    echo "❌ Deploy falhou!"
    exit 1
fi