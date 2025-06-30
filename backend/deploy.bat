@echo off
echo ========================================
echo  AgendaFacil SaaS - Deploy Corrigido
echo ========================================

echo.
echo [1/4] Validando template...
sam validate --template template.yaml
if %ERRORLEVEL% neq 0 (
    echo ERRO: Template inválido!
    pause
    exit /b 1
)

echo.
echo [2/4] Fazendo build...
sam build --template template.yaml
if %ERRORLEVEL% neq 0 (
    echo ERRO: Build falhou!
    pause
    exit /b 1
)

echo.
echo [3/4] Fazendo deploy...
sam deploy --template template.yaml --stack-name agendafacil-dev --capabilities CAPABILITY_IAM --parameter-overrides Environment=dev --no-confirm-changeset
if %ERRORLEVEL% neq 0 (
    echo ERRO: Deploy falhou!
    pause
    exit /b 1
)

echo.
echo [4/4] Deploy concluído com sucesso!
echo.
echo Para ver os outputs:
echo sam list stack-outputs --stack-name agendafacil-dev
echo.
pause