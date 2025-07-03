#!/bin/bash

# Deploy Flutter Web para S3 e CloudFront
BUCKET_NAME="agendafacil-web-prod"
DISTRIBUTION_ID="E2ABCDEFGHIJKL"
REGION="us-east-1"

echo "🚀 Iniciando deploy para S3 e CloudFront..."

# Build Flutter Web
echo "📦 Fazendo build do Flutter Web..."
flutter clean
flutter pub get
flutter build web --release

# Deploy para S3
echo "☁️ Enviando arquivos para S3..."
aws s3 sync build/web/ s3://$BUCKET_NAME/ --delete --region $REGION

# Invalidar cache CloudFront
echo "🔄 Invalidando cache CloudFront..."
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*" --region $REGION

echo "✅ Deploy concluído com sucesso!"
echo "🌐 Acesse: https://d123abc.cloudfront.net"