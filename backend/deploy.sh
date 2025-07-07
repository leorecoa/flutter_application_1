#!/bin/bash

echo "🚀 DEPLOY AGENDEMAIS BACKEND - AWS LAMBDA + DYNAMODB"

# Instalar dependências
echo "📦 Instalando dependências..."
cd src/functions/auth && npm install && cd ../../..
cd src/functions/appointments && npm install && cd ../../..
cd src/functions/dashboard && npm install && cd ../../..

# Build e Deploy com SAM
echo "🔨 Building com SAM..."
sam build

echo "🚀 Deploy para AWS..."
sam deploy --guided --stack-name agendemais-backend

echo "✅ Deploy concluído!"
echo "📋 Para obter a URL da API:"
echo "aws cloudformation describe-stacks --stack-name agendemais-backend --query 'Stacks[0].Outputs'"