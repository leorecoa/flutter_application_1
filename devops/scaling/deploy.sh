#!/bin/bash
# Script para implantar configurações de auto-scaling e monitoramento

set -e

# Configurações
ENVIRONMENT=${1:-dev}
REGION=${2:-us-east-1}
STACK_NAME="agenda-facil-${ENVIRONMENT}"
MONITORING_STACK_NAME="${STACK_NAME}-monitoring"
SCALING_STACK_NAME="${STACK_NAME}-scaling"

echo "Deploying to environment: ${ENVIRONMENT} in region: ${REGION}"

# Verifica se o AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    echo "AWS CLI não encontrado. Por favor, instale-o primeiro."
    exit 1
fi

# Verifica se o jq está instalado
if ! command -v jq &> /dev/null; then
    echo "jq não encontrado. Por favor, instale-o primeiro."
    exit 1
fi

# Obtém informações sobre a tabela DynamoDB
echo "Obtendo informações sobre recursos existentes..."
DYNAMODB_TABLE=$(aws dynamodb list-tables --region ${REGION} --query "TableNames[?contains(@, 'AgendaFacil')]" --output text)

if [ -z "$DYNAMODB_TABLE" ]; then
    echo "Tabela DynamoDB não encontrada. Usando nome padrão."
    DYNAMODB_TABLE="AgendaFacilTable-${ENVIRONMENT}"
fi

# Obtém informações sobre as funções Lambda
LAMBDA_FUNCTIONS=$(aws lambda list-functions --region ${REGION} --query "Functions[?contains(FunctionName, 'agenda-facil')].FunctionName" --output json)
LAMBDA_PREFIX=$(echo $LAMBDA_FUNCTIONS | jq -r '.[0]' | sed -E 's/^(agenda-facil-[^-]+)-.*/\1/')

if [ -z "$LAMBDA_PREFIX" ]; then
    echo "Funções Lambda não encontradas. Usando prefixo padrão."
    LAMBDA_PREFIX="agenda-facil"
fi

# Obtém informações sobre o API Gateway
API_NAME=$(aws apigateway get-rest-apis --region ${REGION} --query "items[?contains(name, 'agenda-facil')].name" --output text)

if [ -z "$API_NAME" ]; then
    echo "API Gateway não encontrado. Usando nome padrão."
    API_NAME="agenda-facil-api"
fi

# Implanta stack de monitoramento
echo "Implantando stack de monitoramento..."
aws cloudformation deploy \
    --template-file cloudwatch-alarms.yml \
    --stack-name ${MONITORING_STACK_NAME} \
    --parameter-overrides \
        Environment=${ENVIRONMENT} \
        ApiGatewayName=${API_NAME} \
        LambdaFunctionPrefix=${LAMBDA_PREFIX} \
        DynamoDBTableName=${DYNAMODB_TABLE} \
        NotificationEmail="alerts@agendafacil.com" \
    --capabilities CAPABILITY_IAM \
    --region ${REGION}

# Implanta stack de auto-scaling
echo "Implantando stack de auto-scaling..."
aws cloudformation deploy \
    --template-file auto-scaling.yml \
    --stack-name ${SCALING_STACK_NAME} \
    --parameter-overrides \
        Environment=${ENVIRONMENT} \
        LambdaFunctionPrefix=${LAMBDA_PREFIX} \
        DynamoDBTableName=${DYNAMODB_TABLE} \
        MinReadCapacity=5 \
        MaxReadCapacity=100 \
        MinWriteCapacity=5 \
        MaxWriteCapacity=100 \
        TargetUtilization=70 \
    --capabilities CAPABILITY_IAM \
    --region ${REGION}

# Cria dashboard no CloudWatch
echo "Criando dashboard no CloudWatch..."
DASHBOARD_BODY=$(cat dashboard.json | sed "s/\${env}/${ENVIRONMENT}/g" | sed "s/\${region}/${REGION}/g")
aws cloudwatch put-dashboard \
    --dashboard-name "AgendaFacil-${ENVIRONMENT}" \
    --dashboard-body "${DASHBOARD_BODY}" \
    --region ${REGION}

# Executa análise de uso para ajustar auto-scaling
echo "Executando análise de uso para ajustar auto-scaling..."
cd ..
node -e "
const UsageAnalyzer = require('./scaling/usage-analyzer');
const analyzer = new UsageAnalyzer({
  environment: '${ENVIRONMENT}',
  dynamodbTable: '${DYNAMODB_TABLE}',
  lambdaFunctionPrefix: '${LAMBDA_PREFIX}'
});
analyzer.analyzeAndAdjust()
  .then(result => console.log('Análise concluída com sucesso:', JSON.stringify(result, null, 2)))
  .catch(error => {
    console.error('Falha na análise:', error);
    process.exit(1);
  });
"

echo "Implantação concluída com sucesso!"