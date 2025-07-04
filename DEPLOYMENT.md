# 🚀 Guia de Deploy - AgendaFácil SaaS

## 📋 Pré-requisitos

- AWS CLI configurado
- Flutter SDK 3.10.0+
- Node.js 18+
- Terraform 1.4.6+
- SAM CLI

## 🔧 Configuração de Secrets

Configure os seguintes secrets no GitHub:

```bash
# AWS
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1
AMPLIFY_APP_ID=your_amplify_app_id

# SonarCloud
SONAR_TOKEN=your_sonar_token

# Codecov (opcional)
CODECOV_TOKEN=your_codecov_token
```

## 🏗️ Deploy da Infraestrutura

### 1. Backend (Lambda + DynamoDB)
```bash
cd backend
sam build
sam deploy --guided
```

### 2. Multi-Região (opcional)
```bash
cd infrastructure
./deploy-multi-region.sh dev us-east-1 us-west-2
```

### 3. Frontend (Amplify)
```bash
cd frontend
flutter build web
aws s3 sync build/web/ s3://your-bucket --delete
```

## 🔄 Pipeline CI/CD

O deploy automático acontece via GitHub Actions:

1. **Push para main** → Deploy automático
2. **Pull Request** → Testes e análise
3. **Workflow manual** → Deploy sob demanda

### Workflows Disponíveis:

- `flutter-amplify-deploy.yml` - Build, teste e deploy
- `pr-checks.yml` - Verificações de PR
- `performance-security.yml` - Testes de performance
- `multi-region-deploy.yml` - Deploy multi-região

## 📊 Monitoramento

### CloudWatch
- Logs das funções Lambda
- Métricas de performance
- Alarmes configurados

### SonarCloud
- Qualidade de código
- Cobertura de testes
- Vulnerabilidades

### Codecov
- Relatórios de cobertura
- Tendências de qualidade

## 🌐 Ambientes

### Desenvolvimento
- **Frontend**: https://dev.agendafacil.com
- **API**: https://api-dev.agendafacil.com

### Produção
- **Frontend**: https://app.agendafacil.com
- **API**: https://api.agendafacil.com

## 🔍 Verificação de Deploy

```bash
# Verificar saúde da API
curl https://api.agendafacil.com/health

# Verificar frontend
curl -I https://app.agendafacil.com

# Verificar logs
aws logs tail /aws/lambda/agenda-facil-dev-AuthFunction --follow
```

## 🚨 Rollback

Em caso de problemas:

```bash
# Rollback do backend
sam deploy --parameter-overrides Version=previous-version

# Rollback do frontend
aws amplify start-deployment --app-id $AMPLIFY_APP_ID --branch-name main --source-url previous-build.zip
```

## 📝 Checklist de Deploy

- [ ] Testes passando localmente
- [ ] Secrets configurados
- [ ] Infraestrutura provisionada
- [ ] Pipeline CI/CD funcionando
- [ ] Monitoramento ativo
- [ ] Documentação atualizada
- [ ] Backup configurado
- [ ] Plano de rollback testado

## 🆘 Suporte

Em caso de problemas:

1. Verificar logs no CloudWatch
2. Consultar dashboard do SonarCloud
3. Verificar status dos workflows no GitHub
4. Consultar documentação técnica