#!/bin/bash

# Script para automatizar o deploy de novos tenants no AWS Amplify
# Uso: ./deploy_tenant.sh <tenant_id> <tenant_name> <tenant_domain>

# Verifica argumentos
if [ "$#" -lt 3 ]; then
    echo "Uso: $0 <tenant_id> <tenant_name> <tenant_domain>"
    echo "Exemplo: $0 tenant1 'Empresa ABC' empresa-abc.agendemais.com"
    exit 1
fi

TENANT_ID=$1
TENANT_NAME=$2
TENANT_DOMAIN=$3
APP_ID="d31iho7gw23enq" # ID do app no Amplify
BRANCH="main"
REGION="us-east-1"

echo "=== Iniciando deploy do tenant: $TENANT_NAME ($TENANT_ID) ==="
echo "Domínio: $TENANT_DOMAIN"

# Verifica se o AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    echo "AWS CLI não encontrado. Por favor, instale-o primeiro."
    exit 1
fi

# Verifica autenticação na AWS
echo "Verificando autenticação na AWS..."
aws sts get-caller-identity > /dev/null
if [ $? -ne 0 ]; then
    echo "Erro: Não foi possível autenticar na AWS. Execute 'aws configure' primeiro."
    exit 1
fi

# Cria branch para o tenant (se não existir)
echo "Criando branch para o tenant..."
aws amplify get-branch --app-id $APP_ID --branch-name $TENANT_ID > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Branch não existe, criando..."
    aws amplify create-branch \
        --app-id $APP_ID \
        --branch-name $TENANT_ID \
        --framework "Flutter" \
        --stage PRODUCTION
else
    echo "Branch já existe, atualizando..."
fi

# Configura variáveis de ambiente para o tenant
echo "Configurando variáveis de ambiente..."
aws amplify update-branch \
    --app-id $APP_ID \
    --branch-name $TENANT_ID \
    --environment-variables "ENV_NAME=prod,TENANT_ID=$TENANT_ID,TENANT_NAME=$TENANT_NAME"

# Configura o domínio personalizado
echo "Configurando domínio personalizado..."
aws amplify get-domain-association \
    --app-id $APP_ID \
    --domain-name $TENANT_DOMAIN > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Domínio não existe, criando..."
    aws amplify create-domain-association \
        --app-id $APP_ID \
        --domain-name $TENANT_DOMAIN \
        --sub-domain-settings "prefix=www,branchName=$TENANT_ID" "prefix=,branchName=$TENANT_ID"
    
    echo "Domínio criado. Siga as instruções no console do Amplify para configurar os registros DNS."
else
    echo "Domínio já existe, atualizando..."
    aws amplify update-domain-association \
        --app-id $APP_ID \
        --domain-name $TENANT_DOMAIN \
        --sub-domain-settings "prefix=www,branchName=$TENANT_ID" "prefix=,branchName=$TENANT_ID"
fi

# Inicia o build
echo "Iniciando build do tenant..."
aws amplify start-job \
    --app-id $APP_ID \
    --branch-name $TENANT_ID \
    --job-type RELEASE

echo "=== Deploy iniciado para $TENANT_NAME ($TENANT_ID) ==="
echo "Acompanhe o progresso no console do AWS Amplify:"
echo "https://$REGION.console.aws.amazon.com/amplify/home?region=$REGION#/$APP_ID/$TENANT_ID"
echo ""
echo "Após o deploy, o site estará disponível em:"
echo "https://$TENANT_DOMAIN"
echo "https://www.$TENANT_DOMAIN"