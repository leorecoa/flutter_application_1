# 🔧 **AMPLIFY BUILD TROUBLESHOOTING**

## ❌ **PROBLEMA ATUAL**
- URL: https://main.d31iho7gw23enq.amplifyapp.com/
- Erro: `apt-get: command not found`
- Status: Build falhando

## ✅ **SOLUÇÃO PASSO A PASSO**

### **PASSO 1: Verificar amplify.yml na Raiz**
```bash
# Deve estar na raiz do projeto (junto com pubspec.yaml)
ls -la | grep amplify.yml
```

### **PASSO 2: Configurar no Console AWS**
1. **Acesse**: [AWS Amplify Console](https://console.aws.amazon.com/amplify/)
2. **Selecione**: App `d31iho7gw23enq`
3. **Menu**: "Build settings" (Configurações de compilação)
4. **Ação**: APAGAR todo conteúdo do editor
5. **Colar**: Conteúdo do arquivo `AMPLIFY_CONSOLE_CONFIG.yml`
6. **Salvar**: Clique em "Save"

### **PASSO 3: Forçar Novo Build**
1. **Vá para**: Aba "Main" branch
2. **Clique**: "Redeploy this version"
3. **Aguarde**: 3-5 minutos
4. **Monitore**: Logs da fase preBuild

## 🔍 **LOGS ESPERADOS (SUCESSO)**
```
✅ git clone https://github.com/flutter/flutter.git -b 3.32.4 --depth 1
✅ export PATH="$PATH:`pwd`/flutter/bin"
✅ flutter --version
✅ flutter pub get
✅ flutter build web --release
```

## ❌ **SE AINDA FALHAR**
- Verificar versão Flutter no log
- Checar dependências no pubspec.yaml
- Validar sintaxe do amplify.yml

## 📞 **CONTATO**
Se o problema persistir, enviar:
1. Screenshot do console Amplify
2. Log completo do build
3. Conteúdo atual do amplify.yml