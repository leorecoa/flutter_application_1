# 🛠️ Correção do Build Amplify

## ✅ Problemas Corrigidos

### 1. Pubspec.yaml Inválido
O arquivo `pubspec.yaml` continha caracteres inválidos no final do arquivo que causavam o erro:
```
[WARNING]: Please correct the pubspec.yaml file
```

**Solução:** Reescrito o arquivo `pubspec.yaml` com formato correto e dependências atualizadas.

### 2. Conflitos de Dependências Web
Algumas dependências não eram compatíveis com Flutter Web:
- `pdf`
- `mailer`
- `path_provider`

**Solução:** Criado `main_web.dart` simplificado para build web.

### 3. Build Command Incorreto
O comando de build não estava usando o arquivo web-compatível.

**Solução:** Atualizado `amplify.yml` para usar:
```yaml
flutter build web --release --target=lib/main_web.dart
```

## 🚀 Como Aplicar a Correção

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

## ✅ Verificação
Após o build, verifique:
- Logs não mostram erros de pubspec.yaml
- Aplicação carrega corretamente
- Autenticação funciona com backend SAM

## 🔄 Integração Backend-Frontend
- Frontend: Amplify (d31iho7gw23enq.amplifyapp.com)
- Backend: API Gateway (dy2yuasirk.execute-api.us-east-1.amazonaws.com/dev)
- Auth: Cognito (us-east-1_Pe0LL9WS7)