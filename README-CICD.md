# 🚀 CI/CD com Flutter, AWS Amplify e SonarCloud

Este documento descreve a configuração de CI/CD para o projeto Flutter usando GitHub Actions, AWS Amplify e SonarCloud.

## 📋 Visão Geral

O pipeline de CI/CD automatiza:

1. **Verificação de Código**: Formatação, análise estática e testes
2. **Análise de Qualidade**: Integração com SonarCloud para métricas de qualidade
3. **Implantação**: Deploy automático para AWS Amplify após testes bem-sucedidos

## 🔧 Configuração

### Secrets do GitHub

Configure os seguintes secrets no seu repositório GitHub:

- `AWS_ACCESS_KEY_ID`: ID da chave de acesso da AWS
- `AWS_SECRET_ACCESS_KEY`: Chave de acesso secreta da AWS
- `AWS_REGION`: Região da AWS (ex: us-east-1)
- `AMPLIFY_APP_ID`: ID do aplicativo no AWS Amplify
- `SONAR_TOKEN`: Token de acesso ao SonarCloud
- `SLACK_WEBHOOK` (opcional): URL do webhook do Slack para notificações

### Arquivos de Configuração

1. **GitHub Actions Workflow**: `.github/workflows/flutter-sonar.yml`
2. **Configuração SonarCloud**: `sonar-project.properties`
3. **Script de Cobertura**: `scripts/generate_coverage.sh`

## 🏃‍♂️ Execução Local

Para executar a análise localmente antes de enviar para o CI:

```bash
# Instalar dependências
flutter pub get

# Executar testes com cobertura
chmod +x scripts/generate_coverage.sh
./scripts/generate_coverage.sh

# Verificar formatação
flutter format --set-exit-if-changed .

# Analisar código
flutter analyze
```

## 📊 Métricas de Qualidade

O SonarCloud analisa:

- **Cobertura de Código**: Porcentagem de código coberto por testes
- **Bugs e Vulnerabilidades**: Problemas de segurança e bugs potenciais
- **Code Smells**: Problemas de manutenibilidade
- **Duplicações**: Código duplicado
- **Complexidade**: Complexidade ciclomática

## 🔄 Fluxo de Trabalho

1. **Pull Request**:
   - Executa testes e análise
   - Envia resultados para SonarCloud
   - Verifica quality gate

2. **Push para Main**:
   - Executa testes e análise
   - Envia resultados para SonarCloud
   - Verifica quality gate
   - Se aprovado, implanta no AWS Amplify
   - Envia notificação de status

## 🛠️ Personalização

### Ajustar Quality Gate

Você pode personalizar as regras do quality gate no SonarCloud:

1. Acesse o projeto no SonarCloud
2. Vá para Quality Gates
3. Defina condições personalizadas (ex: cobertura mínima de 80%)

### Adicionar Análises Personalizadas

Para adicionar análises personalizadas, modifique o arquivo `sonar-project.properties`:

```properties
# Adicionar regras personalizadas
sonar.issue.ignore.multicriteria=e1
sonar.issue.ignore.multicriteria.e1.ruleKey=flutter:S1234
sonar.issue.ignore.multicriteria.e1.resourceKey=**/*.dart
```

## 📝 Boas Práticas

1. **Mantenha os Testes Atualizados**: Adicione testes para cada nova funcionalidade
2. **Verifique Localmente**: Execute o script de cobertura antes de enviar alterações
3. **Monitore o Dashboard**: Verifique regularmente o dashboard do SonarCloud
4. **Resolva Issues Rapidamente**: Corrija problemas identificados pelo SonarCloud
5. **Use Tags para Releases**: Marque releases estáveis com tags para rastreabilidade

## 🔍 Solução de Problemas

### Falha na Análise do SonarCloud

Verifique:
- Se o token SONAR_TOKEN está configurado corretamente
- Se o arquivo sonar-project.properties está correto
- Os logs do GitHub Actions para erros específicos

### Falha no Deploy para Amplify

Verifique:
- Se as credenciais AWS estão configuradas corretamente
- Se o AMPLIFY_APP_ID está correto
- Os logs do GitHub Actions para erros específicos