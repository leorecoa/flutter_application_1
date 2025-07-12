@echo off
echo 🚀 Deploying Services Module...

cd /d "%~dp0"

echo 📦 Installing dependencies...
cd src\functions\services
call npm install
cd ..\..\..

echo 🔨 Building and deploying with SAM...
call sam build
call sam deploy --no-confirm-changeset --no-fail-on-empty-changeset

echo ✅ Services module deployed successfully!
pause