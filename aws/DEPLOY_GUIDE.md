# 🚀 Guia de Deploy - AgendaFácil Web

## 📋 Opções de Deploy

### 1️⃣ Deploy Manual (Mais Rápido)

```bash
# No diretório do projeto
cd flutter_application_1

# Build Flutter Web
flutter clean
flutter pub get
flutter build web --release

# Deploy para S3
aws s3 sync build/web/ s3://agendafacil-web-prod/ --delete

# Invalidar cache CloudFront
aws cloudfront create-invalidation --distribution-id ABCDEF12345 --paths "/*"
```

### 2️⃣ Deploy via GitHub Actions (Automatizado)

1. Configure os secrets no GitHub:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `CLOUDFRONT_DISTRIBUTION_ID`

2. Push para a branch main:
   ```bash
   git add .
   git commit -m "Update web app"
   git push origin main
   ```

3. O workflow `.github/workflows/flutter-web.yml` fará o deploy automaticamente.

### 3️⃣ Deploy via Docker (Desenvolvimento)

```bash
# Build da imagem Docker
docker build -t agendafacil-web .

# Executar container
docker run -p 8080:8080 agendafacil-web
```

## 🏗️ Infraestrutura AWS

Para criar a infraestrutura necessária:

```bash
# Deploy da stack CloudFormation
aws cloudformation deploy \
  --template-file aws/cloudformation-web.yaml \
  --stack-name agendafacil-web-prod \
  --parameter-overrides Environment=prod \
  --capabilities CAPABILITY_IAM
```

## 🔄 Status Atual do Projeto

### ✅ Concluído
- Backend serverless com API Gateway + Lambda + DynamoDB
- Autenticação com Cognito
- Frontend Flutter Web básico
- Infraestrutura como código (CloudFormation)
- CI/CD via GitHub Actions

### 🔜 Próximos Passos
1. Implementar testes automatizados
2. Adicionar monitoramento com CloudWatch
3. Configurar domínio personalizado com Route 53
4. Implementar CDN para assets estáticos

## 📊 Evolução do Projeto

- **Semana 1**: Setup inicial, estrutura de projeto
- **Semana 2**: Implementação do backend serverless
- **Semana 3**: Desenvolvimento do frontend Flutter
- **Semana 4**: Integração frontend-backend
- **Semana 5**: CI/CD e deploy automatizado
- **Semana 6**: Testes e otimizações

## 🔐 Acesso

- **URL Produção**: https://d123abc.cloudfront.net
- **URL Staging**: https://staging.d123abc.cloudfront.net
- **Console AWS**: https://console.aws.amazon.com/amplify/home#/d31iho7gw23enq