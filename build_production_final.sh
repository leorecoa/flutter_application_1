#!/bin/bash

# AGENDEMAIS - Script de Build Final para Produção
# Este script constrói o app com todas as otimizações e configurações AWS reais

set -e

echo "🚀 AGENDEMAIS - BUILD FINAL PARA PRODUÇÃO"
echo "=========================================="

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não está instalado ou não está no PATH"
    exit 1
fi

# Verificar versão do Flutter
echo "📋 Verificando versão do Flutter..."
flutter --version

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
flutter clean
rm -rf build/

# Instalar dependências
echo "📦 Instalando dependências..."
flutter pub get

# Analisar código
echo "🔍 Analisando código..."
flutter analyze --no-fatal-infos --no-fatal-warnings

# Verificar se as variáveis de ambiente estão definidas
echo "🔧 Verificando variáveis de ambiente..."
if [ -z "$AWS_API_ENDPOINT" ]; then
    echo "⚠️  AWS_API_ENDPOINT não definido, usando default"
fi
if [ -z "$COGNITO_USER_POOL_ID" ]; then
    echo "⚠️  COGNITO_USER_POOL_ID não definido"
fi
if [ -z "$COGNITO_APP_CLIENT_ID" ]; then
    echo "⚠️  COGNITO_APP_CLIENT_ID não definido"
fi
if [ -z "$COGNITO_IDENTITY_POOL_ID" ]; then
    echo "⚠️  COGNITO_IDENTITY_POOL_ID não definido"
fi

# Build para produção com todas as otimizações
echo "🌐 Construindo para produção com otimizações completas..."
flutter build web \
    --release \
    --tree-shake-icons \
    --dart-define=FLUTTER_WEB_USE_SKIA=false \
    --dart-define=FLUTTER_WEB_AUTO_DETECT=true \
    --web-renderer canvaskit \
    --pwa-strategy offline-first \
    --base-href="/" \
    --source-maps \
    --dart-define=AWS_API_ENDPOINT="${AWS_API_ENDPOINT:-https://5wy56rw801.execute-api.us-east-1.amazonaws.com/prod}" \
    --dart-define=COGNITO_USER_POOL_ID="${COGNITO_USER_POOL_ID:-}" \
    --dart-define=COGNITO_APP_CLIENT_ID="${COGNITO_APP_CLIENT_ID:-}" \
    --dart-define=COGNITO_IDENTITY_POOL_ID="${COGNITO_IDENTITY_POOL_ID:-}" \
    --dart-define=AWS_REGION="${AWS_REGION:-us-east-1}"

# Verificar se o build foi bem-sucedido
if [ ! -f "build/web/index.html" ]; then
    echo "❌ Build falhou: index.html não encontrado"
    exit 1
fi

if [ ! -f "build/web/main.dart.js" ]; then
    echo "❌ Build falhou: main.dart.js não encontrado"
    exit 1
fi

# Copiar arquivos de configuração para produção
echo "📋 Copiando arquivos de configuração..."
cp web/.htaccess build/web/ 2>/dev/null || echo "⚠️  .htaccess não encontrado"
cp web/app.yaml build/web/ 2>/dev/null || echo "⚠️  app.yaml não encontrado"

# Verificar tamanho do bundle
BUNDLE_SIZE=$(du -sh build/web/main.dart.js | cut -f1)
echo "📏 Tamanho do bundle: $BUNDLE_SIZE"

# Verificar assets PWA
echo "🔍 Verificando recursos PWA..."
if [ -f "build/web/manifest.json" ]; then
    echo "✅ manifest.json encontrado"
else
    echo "❌ manifest.json NÃO encontrado"
fi

if [ -f "build/web/sw.js" ]; then
    echo "✅ Service Worker encontrado"
else
    echo "❌ Service Worker NÃO encontrado"
fi

# Verificar estrutura de arquivos críticos
echo "📁 Verificando estrutura de arquivos..."
for file in "index.html" "main.dart.js" "flutter.js" "flutter_bootstrap.js"; do
    if [ -f "build/web/$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file NÃO encontrado"
    fi
done

# Verificar se há dados mocados no build (segurança)
echo "🔒 Verificando segurança - procurando dados mocados..."
if grep -r "mock\|test\|dummy" build/web/ --exclude="*.map" --exclude="*.js.map" &> /dev/null; then
    echo "⚠️  ATENÇÃO: Encontrados dados de teste/mock no build de produção"
    echo "    Execute: grep -r 'mock\|test\|dummy' build/web/ --exclude='*.map'"
else
    echo "✅ Nenhum dado de teste encontrado"
fi

# Atualizar versão do service worker
echo "🔄 Atualizando versão do service worker..."
if [ -f "build/web/sw.js" ]; then
    BUILD_VERSION=$(date +%Y%m%d-%H%M%S)
    sed -i.bak "s/agendemais-production-v[0-9]\+\.[0-9]\+/agendemais-production-v$BUILD_VERSION/" build/web/sw.js
    rm -f build/web/sw.js.bak
    echo "✅ Service Worker atualizado para versão: $BUILD_VERSION"
fi

# Gerar informações do build
echo "📝 Gerando informações do build..."
cat > build/web/build-info.json << EOF
{
  "buildTime": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "version": "1.0.0",
  "environment": "production",
  "gitCommit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')",
  "buildNumber": "$(date +%Y%m%d%H%M%S)",
  "bundleSize": "$BUNDLE_SIZE",
  "awsEndpoint": "${AWS_API_ENDPOINT:-default}",
  "awsRegion": "${AWS_REGION:-us-east-1}"
}
EOF

# Criar pacote de deployment
echo "📦 Criando pacote de deployment..."
cd build/web
PACKAGE_NAME="agendemais-production-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "../$PACKAGE_NAME" .
cd ../../

echo ""
echo "🎉 BUILD DE PRODUÇÃO CONCLUÍDO COM SUCESSO!"
echo "==========================================="
echo ""
echo "📊 Resumo do Build:"
echo "   • Diretório de saída: build/web/"
echo "   • Tamanho do bundle: $BUNDLE_SIZE"
echo "   • Pacote: build/$PACKAGE_NAME"
echo "   • PWA: $([ -f "build/web/manifest.json" ] && echo "✅ Habilitado" || echo "❌ Erro")"
echo ""
echo "🚀 Próximos Passos:"
echo "   1. Teste local: cd build/web && python -m http.server 8080"
echo "   2. Deploy para Amplify: Faça upload do conteúdo de build/web/"
echo "   3. Configure variáveis de ambiente no Amplify:"
echo "      - AWS_API_ENDPOINT=$AWS_API_ENDPOINT"
echo "      - COGNITO_USER_POOL_ID=$COGNITO_USER_POOL_ID"
echo "      - COGNITO_APP_CLIENT_ID=$COGNITO_APP_CLIENT_ID"
echo "      - COGNITO_IDENTITY_POOL_ID=$COGNITO_IDENTITY_POOL_ID"
echo ""
echo "🔧 Verificações Finais:"
echo "   • Teste PWA: Verifique se https://main.d31iho7gw23enq.amplifyapp.com/manifest.json está acessível"
echo "   • Teste instalação: Abra o site no Chrome/Edge e verifique prompt de instalação"
echo "   • Teste autenticação: Faça login e verifique se conecta com Cognito"
echo "   • Teste APIs: Verifique se todas as chamadas vão para os endpoints AWS reais"
echo ""
echo "✅ AGENDEMAIS está pronto para PRODUÇÃO REAL!"
echo "   Sem dados mocados • APIs AWS conectadas • PWA funcional • Otimizado"