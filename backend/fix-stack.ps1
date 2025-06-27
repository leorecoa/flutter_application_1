# Script para corrigir stack em ROLLBACK_COMPLETE
param(
    [string]$StackName = "agenda-facil-dev",
    [string]$Region = "us-east-1"
)

Write-Host "🔧 Corrigindo stack $StackName em estado ROLLBACK_COMPLETE..." -ForegroundColor Yellow

# 1. Verificar estado atual do stack
Write-Host "📋 Verificando estado do stack..." -ForegroundColor Cyan
try {
    $stackStatus = aws cloudformation describe-stacks --stack-name $StackName --region $Region --query 'Stacks[0].StackStatus' --output text 2>$null
    Write-Host "Estado atual: $stackStatus" -ForegroundColor White
} catch {
    Write-Host "Stack não encontrado ou erro ao verificar" -ForegroundColor Red
    $stackStatus = "NOT_FOUND"
}

# 2. Se stack está em ROLLBACK_COMPLETE, deletar
if ($stackStatus -eq "ROLLBACK_COMPLETE") {
    Write-Host "🗑️ Deletando stack em ROLLBACK_COMPLETE..." -ForegroundColor Red
    aws cloudformation delete-stack --stack-name $StackName --region $Region
    
    Write-Host "⏳ Aguardando exclusão do stack..." -ForegroundColor Yellow
    aws cloudformation wait stack-delete-complete --stack-name $StackName --region $Region
    Write-Host "✅ Stack deletado com sucesso!" -ForegroundColor Green
}

# 3. Limpar cache do SAM
Write-Host "🧹 Limpando cache do SAM..." -ForegroundColor Cyan
Remove-Item -Path ".aws-sam" -Recurse -Force -ErrorAction SilentlyContinue

# 4. Build do SAM
Write-Host "🔨 Executando SAM build..." -ForegroundColor Cyan
sam build --use-container

# 5. Deploy com novo nome se necessário
$newStackName = "$StackName-$(Get-Date -Format 'yyyyMMdd-HHmm')"
Write-Host "🚀 Fazendo deploy com stack: $newStackName" -ForegroundColor Green

sam deploy --stack-name $newStackName --resolve-s3 --capabilities CAPABILITY_IAM --region $Region --no-confirm-changeset --parameter-overrides "Environment=dev CognitoDomainPrefix=agenda-facil-dev"

if ($LASTEXITCODE -eq 0) {
    Write-Host "🎉 Deploy realizado com sucesso!" -ForegroundColor Green
    Write-Host "📋 Stack name: $newStackName" -ForegroundColor White
    
    # Obter outputs
    Write-Host "📊 Outputs do stack:" -ForegroundColor Cyan
    aws cloudformation describe-stacks --stack-name $newStackName --region $Region --query 'Stacks[0].Outputs' --output table
} else {
    Write-Host "❌ Falha no deploy. Verificando logs..." -ForegroundColor Red
    aws cloudformation describe-stack-events --stack-name $newStackName --region $Region --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`].[LogicalResourceId,ResourceStatusReason]' --output table
}