# 🛠️ Correção do Build Amplify - Problema de Extração Flutter

## ✅ Problema Corrigido

### Erro de Extração do Flutter
```
tar (child): xz: Cannot exec: No such file or directory
tar (child): Error is not recoverable: exiting now
tar: Child returned status 2
tar: Error is not recoverable: exiting now
```

O ambiente de build do Amplify não tinha o utilitário `xz-utils` necessário para extrair o arquivo `flutter.tar.xz`.

## 🔧 Solução Implementada

### 1. Instalação de Dependências
Adicionado comando para instalar `xz-utils`:
```yaml
- apt-get update -y
- apt-get install -y xz-utils
```

### 2. Método Alternativo de Instalação
Substituído o download e extração do arquivo tar.xz por um clone direto do repositório Git:
```yaml
- git clone -b stable https://github.com/flutter/flutter.git
```

### 3. Cache Otimizado
Adicionado cache do diretório Flutter para builds mais rápidos:
```yaml
cache:
  paths:
    - .pub-cache/**/*
    - flutter/**/*
```

## 📋 Arquivo amplify.yml Atualizado
```yaml
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - apt-get update -y
        - apt-get install -y xz-utils
        - git clone -b stable https://github.com/flutter/flutter.git
        - export PATH="$PATH:`pwd`/flutter/bin"
        - flutter --version
        - flutter config --enable-web
        - flutter pub get
    build:
      commands:
        - export PATH="$PATH:`pwd`/flutter/bin"
        - flutter build web --release --target=lib/main_web.dart
  artifacts:
    baseDirectory: build/web
    files:
      - '**/*'
  cache:
    paths:
      - .pub-cache/**/*
      - flutter/**/*
```

## 🚀 Como Aplicar

### Via Console Amplify
1. Acesse: https://console.aws.amazon.com/amplify/home#/d31iho7gw23enq
2. Vá em "Build settings"
3. Cole o conteúdo do arquivo `amplify.yml` atualizado
4. Salve e inicie um novo build

### Via AWS CLI
Execute o script:
```bash
cd aws
chmod +x update-amplify.sh
./update-amplify.sh
```