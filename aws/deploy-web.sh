#!/bin/bash

# Script para build e deploy do Flutter Web para AWS Amplify
echo "🚀 Iniciando build e deploy do Flutter Web"

# Configurações
APP_ID="d31iho7gw23enq"
BRANCH="main"
REGION="us-east-1"
BUILD_DIR="build/web"
ZIP_FILE="web-build.zip"

# 1. Build Flutter Web
echo "📦 Fazendo build do Flutter Web..."
flutter clean
flutter pub get
flutter build web --release

# 2. Verificar se o build foi bem sucedido
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ Erro: Build falhou. Diretório $BUILD_DIR não encontrado."
  exit 1
fi

# 3. Comprimir build
echo "🗜️ Comprimindo build..."
cd $BUILD_DIR
zip -r ../../$ZIP_FILE .
cd ../..

# 4. Upload para S3 (alternativa ao Amplify)
echo "☁️ Fazendo upload para S3..."
aws s3 cp $ZIP_FILE s3://agendafacil-deploy/

# 5. Limpar arquivos temporários
echo "🧹 Limpando arquivos temporários..."
rm $ZIP_FILE

echo "✅ Deploy concluído com sucesso!"
echo "🌐 Acesse: https://main.$APP_ID.amplifyapp.com"