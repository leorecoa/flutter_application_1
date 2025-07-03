#!/bin/bash

# Script para configurar monitoramento CloudWatch
REGION="us-east-1"
APP_NAME="agendafacil"
ENVIRONMENT="prod"

echo "🔍 Configurando monitoramento CloudWatch para $APP_NAME-$ENVIRONMENT..."

# Criar grupo de logs
echo "📝 Criando grupos de logs..."
aws logs create-log-group --log-group-name "/app/$APP_NAME/$ENVIRONMENT/frontend" --region $REGION
aws logs create-log-group --log-group-name "/app/$APP_NAME/$ENVIRONMENT/api" --region $REGION

# Configurar retenção de logs (30 dias)
echo "⏱️ Configurando retenção de logs..."
aws logs put-retention-policy --log-group-name "/app/$APP_NAME/$ENVIRONMENT/frontend" --retention-in-days 30 --region $REGION
aws logs put-retention-policy --log-group-name "/app/$APP_NAME/$ENVIRONMENT/api" --retention-in-days 30 --region $REGION

# Criar dashboard CloudWatch
echo "📊 Criando dashboard CloudWatch..."
aws cloudwatch put-dashboard \
  --dashboard-name "$APP_NAME-$ENVIRONMENT" \
  --dashboard-body file://cloudwatch-dashboard.json \
  --region $REGION

# Criar alarmes para erros de API
echo "🚨 Configurando alarmes..."
aws cloudwatch put-metric-alarm \
  --alarm-name "$APP_NAME-$ENVIRONMENT-api-errors" \
  --alarm-description "Alarme para erros de API" \
  --metric-name "ApiErrors" \
  --namespace "AgendaFacil/App" \
  --statistic "Sum" \
  --period 300 \
  --threshold 5 \
  --comparison-operator "GreaterThanThreshold" \
  --evaluation-periods 1 \
  --alarm-actions "arn:aws:sns:$REGION:123456789012:$APP_NAME-alerts" \
  --dimensions "Environment=$ENVIRONMENT" \
  --region $REGION

echo "✅ Monitoramento configurado com sucesso!"