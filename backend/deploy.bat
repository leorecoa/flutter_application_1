@echo off
REM AgendaFacil Backend Deploy Script for Windows

set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=dev

set STACK_NAME=agenda-facil-%ENVIRONMENT%
set REGION=%2
if "%REGION%"=="" set REGION=us-east-1

echo 🚀 Deploying AgendaFacil Backend to %ENVIRONMENT% environment...

REM Check if AWS CLI is installed
aws --version >nul 2>&1
if errorlevel 1 (
    echo ❌ AWS CLI is not installed. Please install it first.
    exit /b 1
)

REM Check if SAM CLI is installed
sam --version >nul 2>&1
if errorlevel 1 (
    echo ❌ SAM CLI is not installed. Please install it first.
    exit /b 1
)

REM Install dependencies for each Lambda function
echo 📦 Installing Lambda dependencies...

cd lambda\auth && npm install && cd ..\..
cd lambda\users && npm install && cd ..\..
cd lambda\services && npm install && cd ..\..
cd lambda\appointments && npm install && cd ..\..
cd lambda\booking && npm install && cd ..\..

REM Build and deploy using SAM
echo 🏗️ Building SAM application...
sam build --template-file infrastructure\cloudformation.yaml

echo 🚀 Deploying to AWS...
sam deploy ^
  --template-file .aws-sam\build\template.yaml ^
  --stack-name %STACK_NAME% ^
  --capabilities CAPABILITY_IAM ^
  --region %REGION% ^
  --parameter-overrides ^
    Environment=%ENVIRONMENT% ^
    CognitoDomainPrefix=agenda-facil-%ENVIRONMENT% ^
  --confirm-changeset

REM Get stack outputs
echo 📋 Getting stack outputs...
aws cloudformation describe-stacks ^
  --stack-name %STACK_NAME% ^
  --region %REGION% ^
  --query "Stacks[0].Outputs" ^
  --output table

echo ✅ Deployment completed successfully!
echo.
echo 📝 Next steps:
echo 1. Update your Flutter app configuration with the new API URL
echo 2. Update Cognito User Pool ID and Client ID
echo 3. Test the APIs using the provided Postman collection