#!/bin/bash

# AgendaFácil Deploy Script - Optimized
set -e

ENVIRONMENT=${1:-dev}
AWS_REGION=${AWS_REGION:-us-east-1}
SKIP_TESTS=${SKIP_TESTS:-false}

echo "🚀 Deploying AgendaFácil to ${ENVIRONMENT} environment..."
echo "📍 Region: ${AWS_REGION}"
echo "⚙️  Environment: ${ENVIRONMENT}"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
  echo "❌ Invalid environment: $ENVIRONMENT. Use: dev, staging, or prod"
  exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm ci --silent

# Run tests (skip in CI if requested)
if [ "$SKIP_TESTS" != "true" ]; then
  echo "🧪 Running tests..."
  npm run test:coverage
  
  echo "🔍 Running ESLint..."
  npm run lint
else
  echo "⏭️  Skipping tests (SKIP_TESTS=true)"
fi

# Build SAM application
echo "🔨 Building SAM application..."
sam build --use-container --cached

# Deploy using samconfig.toml
echo "🚀 Deploying to AWS..."
sam deploy --config-env ${ENVIRONMENT} --region ${AWS_REGION}

# Get outputs
echo "📋 Getting stack outputs..."
STACK_NAME="agenda-facil-${ENVIRONMENT}"
aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --region ${AWS_REGION} \
  --query 'Stacks[0].Outputs' \
  --output table

# Create/Update CloudWatch dashboard
echo "📊 Creating CloudWatch dashboard..."
sed "s/agenda-facil-dev/agenda-facil-${ENVIRONMENT}/g" cloudwatch-dashboard.json > /tmp/dashboard-${ENVIRONMENT}.json
aws cloudwatch put-dashboard \
  --dashboard-name "AgendaFacil-${ENVIRONMENT}" \
  --dashboard-body file:///tmp/dashboard-${ENVIRONMENT}.json \
  --region ${AWS_REGION}

# Run post-deploy health checks
echo "🏥 Running health checks..."
API_URL=$(aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --region ${AWS_REGION} \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' \
  --output text)

if [ -n "$API_URL" ]; then
  echo "🔗 API URL: $API_URL"
  
  # Test API health
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${API_URL}/auth/health" || echo "000")
  if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "404" ]; then
    echo "✅ API is responding"
  else
    echo "⚠️  API health check failed (HTTP $HTTP_STATUS)"
  fi
else
  echo "❌ Could not retrieve API URL"
fi

# Generate deployment report
echo "📄 Generating deployment report..."
cat > deployment-report-${ENVIRONMENT}.txt << EOF
AgendaFácil SaaS Deployment Report
==================================
Environment: ${ENVIRONMENT}
Region: ${AWS_REGION}
Stack: ${STACK_NAME}
Timestamp: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
API URL: ${API_URL}
Status: ✅ SUCCESS
EOF

echo "✅ Deployment completed successfully!"
echo "📄 Report saved: deployment-report-${ENVIRONMENT}.txt"
echo "🎉 AgendaFácil SaaS is ready for ${ENVIRONMENT}!"