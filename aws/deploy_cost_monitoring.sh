#!/bin/bash

# Script para implantar recursos de monitoramento de custos AWS
# Uso: ./deploy_cost_monitoring.sh email@exemplo.com

# Verifica se o email foi fornecido
if [ -z "$1" ]; then
  echo "❌ Erro: Email não fornecido"
  echo "Uso: ./deploy_cost_monitoring.sh email@exemplo.com"
  exit 1
fi

EMAIL=$1
STACK_NAME="AGENDEMAIS-Cost-Monitoring"

echo "🚀 Implantando recursos de monitoramento de custos AWS..."
echo "📧 Email para alertas: $EMAIL"

# Substitui o placeholder de email no template
sed "s/\${EMAIL_ADDRESS}/$EMAIL/g" cloudwatch_budget.yaml > cloudwatch_budget_deploy.yaml

# Implanta a stack CloudFormation
aws cloudformation deploy \
  --template-file cloudwatch_budget_deploy.yaml \
  --stack-name $STACK_NAME \
  --capabilities CAPABILITY_IAM \
  --tags Project=AGENDEMAIS Environment=All

# Verifica se a implantação foi bem-sucedida
if [ $? -eq 0 ]; then
  echo "✅ Recursos de monitoramento de custos implantados com sucesso!"
  
  # Obtém o ARN do tópico SNS
  TOPIC_ARN=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='BudgetAlertTopicArn'].OutputValue" --output text)
  
  echo "📊 Tópico SNS para alertas: $TOPIC_ARN"
  echo "📊 Orçamentos e alarmes configurados para monitorar custos"
  echo "📊 Você receberá alertas por email quando os limites forem atingidos"
else
  echo "❌ Erro ao implantar recursos de monitoramento de custos"
  exit 1
fi

# Limpa o arquivo temporário
rm cloudwatch_budget_deploy.yaml

echo "🔍 Configurando detecção de anomalias de custo..."

# Cria um monitor de anomalias
MONITOR_ARN=$(aws ce create-anomaly-monitor \
  --monitor-name "AGENDEMAIS-AnomalyMonitor" \
  --monitor-type DIMENSIONAL \
  --monitor-dimension SERVICE \
  --query "MonitorArn" \
  --output text)

# Cria uma assinatura de anomalias
aws ce create-anomaly-subscription \
  --subscription-name "AGENDEMAIS-AnomalySubscription" \
  --threshold 5.0 \
  --frequency IMMEDIATE \
  --monitor-arn-list "$MONITOR_ARN" \
  --subscribers Type=EMAIL,Address=$EMAIL

echo "✅ Detecção de anomalias de custo configurada!"
echo "📊 Você receberá alertas por email quando houver gastos anormais"

echo "🔒 Configurando AWS Trusted Advisor..."
echo "📊 Trusted Advisor verificará automaticamente otimizações de custo"
echo "📊 Acesse o console AWS para ver as recomendações: https://console.aws.amazon.com/trustedadvisor"

echo "✅ Configuração de monitoramento de custos concluída!"