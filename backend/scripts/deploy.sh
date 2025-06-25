#!/bin/bash

# AgendaFácil Deploy Script
set -e

ENVIRONMENT=${1:-dev}
STACK_NAME="agenda-facil-${ENVIRONMENT}"
AWS_REGION=${AWS_REGION:-us-east-1}

echo "🚀 Deploying AgendaFácil to ${ENVIRONMENT} environment..."

# Install dependencies
echo "📦 Installing dependencies..."
npm ci

# Run tests
echo "🧪 Running tests..."
npm run test

# Run linting
echo "🔍 Running ESLint..."
npm run lint

# Build SAM application
echo "🔨 Building SAM application..."
sam build --use-container

# Deploy
echo "🚀 Deploying to AWS..."
sam deploy \
  --stack-name ${STACK_NAME} \
  --parameter-overrides Environment=${ENVIRONMENT} \
  --capabilities CAPABILITY_IAM \
  --region ${AWS_REGION} \
  --no-confirm-changeset \
  --no-fail-on-empty-changeset \
  --resolve-s3

# Get outputs
echo "📋 Getting stack outputs..."
aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --region ${AWS_REGION} \
  --query 'Stacks[0].Outputs' \
  --output table

# Create CloudWatch dashboard
echo "📊 Creating CloudWatch dashboard..."
aws cloudwatch put-dashboard \
  --dashboard-name "AgendaFacil-${ENVIRONMENT}" \
  --dashboard-body file://cloudwatch-dashboard.json \
  --region ${AWS_REGION}

echo "✅ Deployment completed successfully!"
echo "🔗 API URL: $(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --region ${AWS_REGION} --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' --output text)"