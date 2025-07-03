# DevOps - AgendaFácil SaaS

Este diretório contém configurações e scripts para CI/CD, monitoramento e auto-scaling do AgendaFácil SaaS.

## Estrutura

```
devops/
├── monitoring/           # Configurações de monitoramento
│   ├── cloudwatch-alarms.yml   # Template CloudFormation para alertas
│   ├── dashboard.json          # Template de dashboard
│   └── custom-metrics.js       # Módulo para métricas personalizadas
├── scaling/              # Configurações de auto-scaling
│   ├── auto-scaling.yml        # Template CloudFormation para auto-scaling
│   ├── usage-analyzer.js       # Analisador de padrões de uso
│   └── deploy.sh               # Script de implantação
└── testing/              # Testes de performance e segurança
    ├── load-test.js            # Teste de carga
    ├── stress-test.js          # Teste de estresse
    ├── spike-test.js           # Teste de pico
    └── test-users.json         # Usuários de teste
```

## CI/CD Avançado

Os workflows de CI/CD estão configurados no diretório `.github/workflows/` e incluem:

- **performance-security.yml**: Executa testes de performance e segurança automatizados
- **deploy.yml**: Implanta a aplicação em diferentes ambientes
- **flutter-test.yml**: Executa testes unitários e de integração
- **flutter-web.yml**: Compila e implanta a versão web da aplicação

## Monitoramento Proativo

### Alertas Preditivos

Os alertas preditivos são configurados usando detecção de anomalias do CloudWatch. Para implantar:

```bash
cd devops/monitoring
aws cloudformation deploy --template-file cloudwatch-alarms.yml --stack-name agenda-facil-monitoring --parameter-overrides Environment=dev
```

### Dashboard

Para criar o dashboard de monitoramento:

```bash
cd devops/monitoring
aws cloudwatch put-dashboard --dashboard-name "AgendaFacil-Dev" --dashboard-body file://dashboard.json
```

### Métricas Personalizadas

O módulo `custom-metrics.js` permite publicar métricas personalizadas no CloudWatch:

```javascript
const metrics = require('./monitoring/custom-metrics');

// Registrar métrica de negócio
await metrics.recordBusinessMetric('tenant-123', 'AppointmentsCreated', 1);

// Registrar métrica de performance
await metrics.recordPerformanceMetric('AuthFunction', 'login', 150);
```

## Auto-scaling Inteligente

### Configuração de Auto-scaling

Para implantar as configurações de auto-scaling:

```bash
cd devops/scaling
aws cloudformation deploy --template-file auto-scaling.yml --stack-name agenda-facil-scaling --parameter-overrides Environment=dev
```

### Análise de Padrões de Uso

O analisador de padrões de uso ajusta automaticamente as configurações de auto-scaling com base no histórico de uso:

```bash
cd devops
node scaling/usage-analyzer.js
```

### Implantação Completa

Para implantar todas as configurações de monitoramento e auto-scaling:

```bash
cd devops/scaling
./deploy.sh dev us-east-1
```

## Testes de Performance e Segurança

### Testes de Carga

Para executar testes de carga:

```bash
cd devops/testing
k6 run load-test.js
```

### Testes de Estresse

Para executar testes de estresse:

```bash
cd devops/testing
k6 run stress-test.js
```

### Testes de Pico

Para executar testes de pico:

```bash
cd devops/testing
k6 run spike-test.js
```

## Integração com AWS

Todas as configurações são projetadas para funcionar com a AWS, utilizando:

- CloudWatch para monitoramento e alertas
- Lambda para funções serverless
- DynamoDB para armazenamento de dados
- API Gateway para APIs
- CloudFormation para infraestrutura como código
- Application Auto Scaling para auto-scaling

## Requisitos

- AWS CLI configurado
- Node.js 18+
- k6 para testes de performance
- jq para processamento de JSON