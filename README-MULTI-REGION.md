# 🌐 Expansão da Infraestrutura Multi-Região - AgendaFácil SaaS

Este documento descreve a implementação da infraestrutura multi-região para o AgendaFácil SaaS, incluindo DynamoDB Global Tables e CloudFront com Lambda@Edge.

## 📋 Visão Geral

A arquitetura multi-região foi projetada para:

1. **Reduzir latência global** - Aproximando os recursos dos usuários
2. **Aumentar disponibilidade** - Garantindo resiliência contra falhas regionais
3. **Melhorar experiência do usuário** - Fornecendo acesso rápido independente da localização

## 🏗️ Componentes Principais

### 1. Multi-Região AWS

A infraestrutura está implantada em múltiplas regiões da AWS:

- **Região Primária**: `us-east-1` (Norte da Virgínia)
- **Região Secundária**: `us-west-2` (Oregon)
- **Regiões Adicionais** (opcional):
  - `sa-east-1` (São Paulo)
  - `eu-west-1` (Irlanda)
  - `ap-northeast-1` (Tóquio)

Cada região contém:
- API Gateway
- Funções Lambda
- Réplicas do DynamoDB
- Buckets S3 para frontend

### 2. DynamoDB Global Tables

Implementamos DynamoDB Global Tables para replicação multi-região:

```terraform
resource "aws_dynamodb_table" "primary" {
  name             = "${var.app_name}-${var.environment}"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "PK"
  range_key        = "SK"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  replica {
    region_name = var.secondary_region
  }
}
```

Benefícios:
- Replicação bidirecional automática
- Leituras e escritas locais em cada região
- Failover transparente em caso de falha regional

### 3. CloudFront com Lambda@Edge

Implementamos CloudFront com Lambda@Edge para otimizar a entrega de conteúdo:

```terraform
resource "aws_cloudfront_distribution" "frontend" {
  # ...
  
  lambda_function_association {
    event_type   = "viewer-request"
    lambda_arn   = aws_lambda_function.edge_regional_redirect.qualified_arn
    include_body = false
  }
}
```

A função Lambda@Edge:
- Detecta a localização do usuário
- Personaliza o conteúdo com base na região
- Redireciona para o endpoint de API mais próximo

## 🚀 Como Implantar

### Pré-requisitos

- AWS CLI configurado
- Terraform instalado
- Certificado ACM para `*.agendafacil.com`
- Zona hospedada no Route 53 para `agendafacil.com`

### Implantação

1. **Configurar variáveis**:

```bash
export AWS_PROFILE=your-profile
export ENVIRONMENT=dev
export PRIMARY_REGION=us-east-1
export SECONDARY_REGION=us-west-2
```

2. **Implantar infraestrutura multi-região**:

```bash
cd infrastructure
./deploy-multi-region.sh $ENVIRONMENT $PRIMARY_REGION $SECONDARY_REGION
```

3. **Verificar implantação**:

```bash
aws cloudformation describe-stacks --stack-name agenda-facil-$ENVIRONMENT --region $PRIMARY_REGION
aws cloudformation describe-stacks --stack-name agenda-facil-$ENVIRONMENT --region $SECONDARY_REGION
```

### CI/CD Multi-Região

Configuramos um workflow GitHub Actions para implantação multi-região:

```yaml
name: Multi-Region Deployment

on:
  push:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'dev'
```

O workflow:
1. Implanta a infraestrutura em todas as regiões
2. Implanta o backend em cada região
3. Implanta o frontend no CloudFront
4. Executa testes em todas as regiões

## 📱 Suporte no Frontend

### Configuração Multi-Região

O frontend foi adaptado para suportar multi-região:

```dart
class MultiRegionConfig {
  static const Map<String, String> regions = {
    'us-east-1': 'Leste dos EUA (Norte da Virgínia)',
    'us-west-2': 'Oeste dos EUA (Oregon)',
    // ...
  };
}
```

### Serviço de API com Fallback

O serviço de API suporta fallback automático entre regiões:

```dart
Future<dynamic> _handleError(dynamic error, Future<dynamic> Function() retryCallback) async {
  // Se for um erro de conexão, tenta outra região
  final newRegion = await MultiRegionConfig.findLowestLatencyRegion();
  if (newRegion != _currentRegion) {
    await changeRegion(newRegion);
    return retryCallback();
  }
}
```

### Seleção de Região

Os usuários podem selecionar manualmente a região preferida:

```dart
RegionSelectorScreen(
  // Permite ao usuário escolher a região mais próxima
)
```

## 📊 Monitoramento Multi-Região

Implementamos monitoramento específico para a infraestrutura multi-região:

- **CloudWatch Cross-Region Dashboards** - Visão unificada de todas as regiões
- **Health Checks** - Verificação de saúde de cada região
- **Alarmes de Latência** - Alertas para problemas de performance regional

## 🔄 Failover Automático

O sistema suporta failover automático entre regiões:

1. **Route 53 Health Checks** - Monitora a saúde de cada região
2. **Failover DNS** - Redireciona tráfego para regiões saudáveis
3. **Fallback no Cliente** - O frontend tenta automaticamente outras regiões

## 📝 Considerações Importantes

- **Consistência de Dados**: DynamoDB Global Tables usa consistência eventual
- **Custos**: A implantação multi-região aumenta os custos de infraestrutura
- **Complexidade**: O gerenciamento multi-região adiciona complexidade operacional

## 🔍 Testes

Execute os testes multi-região para verificar a implantação:

```bash
cd devops/testing
newman run multi-region-tests.json --env-var "baseUrl=https://api.us-east-1.agendafacil.com"
newman run multi-region-tests.json --env-var "baseUrl=https://api.us-west-2.agendafacil.com"
```