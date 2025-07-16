# 🚀 **CI/CD Pipeline - AGENDEMAIS**

## 📋 **Workflows Implementados**

### **1. Main Pipeline** (`main-pipeline.yml`)
- **Trigger**: Push/PR para `main`
- **Etapas**:
  - ✅ Checkout do código
  - ✅ Setup Flutter 3.32.4
  - ✅ Install dependencies
  - ✅ Check formatting
  - ✅ Analyze code
  - ✅ Run tests
  - ✅ Build web
  - ✅ Deploy status

### **2. Tests** (`test.yml`)
- **Trigger**: Push/PR para `main`/`develop`
- **Etapas**:
  - ✅ Unit tests com coverage
  - ✅ Upload para Codecov

### **3. Release** (`release.yml`)
- **Trigger**: Tags `v*`
- **Etapas**:
  - ✅ Build web + APK
  - ✅ Create GitHub Release
  - ✅ Upload APK asset

## 🔧 **Configuração**

### **Badges para README.md**
```markdown
[![CI/CD](https://github.com/leorecoa/flutter_application_1/workflows/Flutter%20CI/CD%20Pipeline/badge.svg)](https://github.com/leorecoa/flutter_application_1/actions)
[![Tests](https://github.com/leorecoa/flutter_application_1/workflows/Tests/badge.svg)](https://github.com/leorecoa/flutter_application_1/actions)
[![codecov](https://codecov.io/gh/leorecoa/flutter_application_1/branch/main/graph/badge.svg)](https://codecov.io/gh/leorecoa/flutter_application_1)
```

### **Comandos Locais**
```bash
# Verificar formatação
flutter format --output=none --set-exit-if-changed .

# Análise estática
flutter analyze

# Testes com coverage
flutter test --coverage

# Build web
flutter build web --release
```

## 📊 **Qualidade de Código**

- **Cobertura mínima**: 80%
- **Linting**: Flutter Lints + regras customizadas
- **Formatação**: Dart format automático
- **Análise estática**: Zero warnings/errors

## 🚀 **Deploy Automático**

- **AWS Amplify** detecta push na `main`
- **Build automático** após CI passar
- **URL**: https://main.d31iho7gw23enq.amplifyapp.com/

## 📱 **Releases**

```bash
# Criar release
git tag v1.0.0
git push origin v1.0.0

# APK será gerado automaticamente
```