#!/bin/bash
# Script para implantar infraestrutura multi-região

set -e

# Configurações
ENVIRONMENT=${1:-dev}
PRIMARY_REGION=${2:-us-east-1}
SECONDARY_REGION=${3:-us-west-2}
APP_NAME="agenda-facil"
DOMAIN_NAME="agendafacil.com"

echo "Deploying multi-region infrastructure for ${APP_NAME} in ${ENVIRONMENT} environment"
echo "Primary region: ${PRIMARY_REGION}"
echo "Secondary region: ${SECONDARY_REGION}"

# Verifica se o AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    echo "AWS CLI não encontrado. Por favor, instale-o primeiro."
    exit 1
fi

# Verifica se o Terraform está instalado
if ! command -v terraform &> /dev/null; then
    echo "Terraform não encontrado. Por favor, instale-o primeiro."
    exit 1
fi

# Obtém o ID da zona hospedada do Route 53
ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name ${DOMAIN_NAME} --query "HostedZones[0].Id" --output text | sed 's/\/hostedzone\///')

if [ -z "$ZONE_ID" ]; then
    echo "Zona hospedada para ${DOMAIN_NAME} não encontrada. Por favor, crie-a primeiro."
    exit 1
fi

# Obtém o ARN do certificado ACM
CERTIFICATE_ARN=$(aws acm list-certificates --region ${PRIMARY_REGION} --query "CertificateSummaryList[?DomainName=='*.${DOMAIN_NAME}'].CertificateArn" --output text)

if [ -z "$CERTIFICATE_ARN" ]; then
    echo "Certificado para *.${DOMAIN_NAME} não encontrado. Por favor, crie-o primeiro."
    exit 1
fi

# Implanta a infraestrutura multi-região
echo "Implantando infraestrutura multi-região..."
cd multi-region
terraform init
terraform apply -auto-approve \
  -var="app_name=${APP_NAME}" \
  -var="environment=${ENVIRONMENT}" \
  -var="primary_region=${PRIMARY_REGION}" \
  -var="secondary_region=${SECONDARY_REGION}" \
  -var="domain_name=${DOMAIN_NAME}" \
  -var="route53_zone_id=${ZONE_ID}"

# Implanta o CloudFront com Lambda@Edge
echo "Implantando CloudFront com Lambda@Edge..."
cd ../cloudfront
terraform init
terraform apply -auto-approve \
  -var="app_name=${APP_NAME}" \
  -var="environment=${ENVIRONMENT}" \
  -var="primary_region=${PRIMARY_REGION}" \
  -var="secondary_region=${SECONDARY_REGION}" \
  -var="domain_name=${DOMAIN_NAME}" \
  -var="acm_certificate_arn=${CERTIFICATE_ARN}"

echo "Implantação multi-região concluída com sucesso!"
echo "Frontend: https://app.${DOMAIN_NAME}"
echo "API: https://api.${DOMAIN_NAME}"