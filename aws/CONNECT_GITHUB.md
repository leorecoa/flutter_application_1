# 🔗 Como Conectar GitHub ao AWS Amplify

## ✅ Nova App Criada
- **App ID**: `d31iho7gw23enq`
- **URL**: `https://d31iho7gw23enq.amplifyapp.com`
- **Console**: `https://console.aws.amazon.com/amplify/home#/d31iho7gw23enq`

## 🚀 Passos para Conectar GitHub

### 1. Acesse o Console Amplify
```
https://console.aws.amazon.com/amplify/home#/d31iho7gw23enq
```

### 2. Conectar Repositório
1. **Na página da app**, procure por:
   - "Connect repository" ou
   - "Host your web app" ou  
   - "Get started" button

2. **Se não aparecer**, tente:
   - Refresh da página (F5)
   - Clique em "Hosting" no menu lateral
   - Procure por "Connect app"

### 3. Configurar Conexão
- **Provider**: GitHub
- **Repository**: `leorecoa/flutter_application_1`
- **Branch**: `main`
- **Build settings**: Já configurado automaticamente

### 4. Autorizar GitHub
- Clique em "Authorize AWS Amplify"
- Permita acesso ao repositório

### 5. Deploy Automático
- Após conectar, o primeiro deploy iniciará automaticamente
- Tempo estimado: 5-10 minutos

## 🔧 Alternativa: Deploy Manual

Se ainda não conseguir conectar, você pode fazer deploy manual:

```bash
# 1. Fazer build local
flutter build web

# 2. Fazer zip do build
cd build/web
zip -r ../../web-build.zip .

# 3. Upload manual no console Amplify
# Vá em "Hosting" > "Deploy without Git"
```

## 📱 URLs Finais
- **App**: `https://main.d31iho7gw23enq.amplifyapp.com` (após conectar)
- **Console**: `https://console.aws.amazon.com/amplify/home#/d31iho7gw23enq`

## ⚠️ Troubleshooting
- **Não vê "Connect"**: Tente outro navegador
- **GitHub não aparece**: Verifique permissões da conta AWS
- **Erro de autorização**: Desconecte e reconecte GitHub nas configurações

---
**Status**: Aguardando conexão manual do GitHub