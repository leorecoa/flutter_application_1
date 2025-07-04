#!/bin/bash

# Script para gerar relatório de cobertura de código formatado para SonarCloud

# Executa os testes com cobertura
flutter test --coverage

# Verifica se o lcov está instalado
if ! command -v lcov &> /dev/null; then
    echo "lcov não encontrado. Instalando..."
    sudo apt-get update
    sudo apt-get install -y lcov
fi

# Remove arquivos gerados da cobertura
lcov --remove coverage/lcov.info \
  '**/*.g.dart' \
  '**/*.freezed.dart' \
  '**/generated/**' \
  -o coverage/lcov.info

# Gera relatório HTML para visualização local (opcional)
genhtml coverage/lcov.info -o coverage/html

echo "Relatório de cobertura gerado em coverage/lcov.info"
echo "Relatório HTML disponível em coverage/html/index.html"