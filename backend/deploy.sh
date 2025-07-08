#!/bin/bash

echo "🚀 DEPLOYING AGENDEMAIS BACKEND..."

# Check if SAM CLI is installed
if ! command -v sam &> /dev/null; then
    echo "❌ SAM CLI not found. Installing..."
    pip install aws-sam-cli
fi

# Install dependencies
echo "📦 Installing dependencies..."
cd src/functions/auth && npm install && cd ../../..
cd src/functions/appointments && npm install && cd ../../..
cd src/functions/dashboard && npm install && cd ../../..

# Build
echo "🔨 Building SAM application..."
sam build

# Deploy
echo "🚀 Deploying to AWS..."
sam deploy --guided --stack-name agendemais-backend

echo "✅ BACKEND DEPLOYED SUCCESSFULLY!"
echo "📋 Check AWS Console for API Gateway URL"