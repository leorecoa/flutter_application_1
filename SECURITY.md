# 🔒 SEGURANÇA - AgendaFácil SaaS

## 🛡️ **IMPLEMENTAÇÕES DE SEGURANÇA**

### **1. Autenticação e Autorização**
- ✅ **Cognito User Pool** com política de senha avançada
- ✅ **JWT Validation** manual com verificação de assinatura
- ✅ **API Gateway Authorizer** para rotas protegidas
- ✅ **Principle of Least Privilege** em todas as IAM Roles

### **2. Configurações de Segurança**

#### **Cognito User Pool**
```yaml
PasswordPolicy:
  MinimumLength: 8
  RequireUppercase: true
  RequireLowercase: true
  RequireNumbers: true
  RequireSymbols: true
AdvancedSecurityMode: ENFORCED
```

#### **CORS Seguro**
```yaml
AllowMethods: "'GET,POST,PUT,DELETE,OPTIONS'"
AllowHeaders: "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
AllowOrigin: "'*'"  # Configurar domínio específico em produção
```

### **3. IAM Policies por Função**

#### **AuthFunction**
- `dynamodb:PutItem`, `GetItem`, `Query` apenas na UsersTable
- `cognito-idp:AdminCreateUser`, `AdminInitiateAuth` apenas no UserPool

#### **ServicesFunction**
- `dynamodb:*` apenas na ServicesTable e seus índices
- Sem acesso a outras tabelas

#### **AppointmentsFunction**
- `dynamodb:*` apenas na AppointmentsTable e seus índices
- Sem acesso a Cognito

### **4. Monitoramento de Segurança**

#### **CloudWatch Alarms**
- Erros > 5 em 1 minuto
- Duração > 5 segundos
- Tentativas de login falhadas

#### **Logs Estruturados**
```javascript
logger.security('failed_login_attempt', {
  email: 'user@example.com',
  ip: event.sourceIp,
  userAgent: event.headers['User-Agent']
});
```

### **5. Validação JWT Manual**
```javascript
const { withAuth } = require('./shared/jwt-validator');

exports.handler = withAuth(async (event, context) => {
  // event.user contém dados do usuário autenticado
  const userId = event.user.userId;
  // Lógica da função...
});
```

## 🔍 **CHECKLIST DE SEGURANÇA**

### **Pré-Deploy**
- [ ] Senhas fortes configuradas no Cognito
- [ ] IAM Roles com permissões mínimas
- [ ] CORS configurado corretamente
- [ ] Logs estruturados implementados
- [ ] Testes de segurança executados

### **Pós-Deploy**
- [ ] Alarmes CloudWatch ativos
- [ ] Dashboard de monitoramento criado
- [ ] Testes de penetração básicos
- [ ] Verificação de endpoints protegidos
- [ ] Auditoria de logs de segurança

## 🚨 **INCIDENTES DE SEGURANÇA**

### **Detecção**
1. **Alarmes CloudWatch** disparam automaticamente
2. **Logs estruturados** capturam eventos suspeitos
3. **Métricas customizadas** monitoram comportamento anômalo

### **Resposta**
1. **Isolar** recursos comprometidos
2. **Analisar** logs para determinar escopo
3. **Revogar** tokens comprometidos
4. **Notificar** usuários afetados
5. **Documentar** incidente e lições aprendidas

## 🔧 **COMANDOS DE SEGURANÇA**

### **Verificar Configurações**
```bash
# Verificar políticas IAM
aws iam get-role-policy --role-name AuthFunctionRole --policy-name AuthFunctionPolicy

# Verificar configurações Cognito
aws cognito-idp describe-user-pool --user-pool-id us-east-1_XXXXXXX

# Verificar alarmes ativos
aws cloudwatch describe-alarms --alarm-names "agenda-facil-dev-AuthFunction-Errors"
```

### **Auditoria de Logs**
```bash
# Buscar tentativas de login falhadas
aws logs filter-log-events \
  --log-group-name "/aws/lambda/agenda-facil-dev-AuthFunction" \
  --filter-pattern "ERROR" \
  --start-time $(date -d "1 hour ago" +%s)000

# Monitorar eventos de segurança
aws logs filter-log-events \
  --log-group-name "/aws/lambda/agenda-facil-dev-AuthFunction" \
  --filter-pattern "{ $.level = \"SECURITY\" }"
```

## 📊 **MÉTRICAS DE SEGURANÇA**

### **KPIs Monitorados**
- Taxa de tentativas de login falhadas
- Tempo médio de resposta de autenticação
- Número de tokens expirados/inválidos
- Frequência de acessos por IP
- Padrões de uso anômalos

### **Relatórios Automáticos**
- **Diário**: Resumo de eventos de segurança
- **Semanal**: Análise de tendências
- **Mensal**: Auditoria completa de segurança

## 🎯 **PRÓXIMOS PASSOS**

### **Melhorias Planejadas**
- [ ] Implementar rate limiting
- [ ] Adicionar 2FA opcional
- [ ] Configurar WAF no API Gateway
- [ ] Implementar rotação automática de secrets
- [ ] Adicionar detecção de anomalias com ML

### **Compliance**
- [ ] Documentação LGPD/GDPR
- [ ] Política de retenção de dados
- [ ] Procedimentos de backup seguro
- [ ] Auditoria de terceiros