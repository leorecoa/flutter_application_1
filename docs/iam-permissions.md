# Configurações IAM para Amplify + SAM

## Políticas Criadas

### 1. AmplifySAMFullAccess
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:CreateChangeSet",
        "cloudformation:DescribeChangeSet", 
        "cloudformation:ExecuteChangeSet",
        "cloudformation:DescribeStacks",
        "cloudformation:ListStackResources",
        "iam:PassRole",
        "lambda:*",
        "apigateway:*",
        "dynamodb:*",
        "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### 2. AmplifyCloudFormationExtended
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*",
        "iam:CreateRole",
        "iam:DeleteRole", 
        "iam:GetRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "cognito-idp:*",
        "cognito-identity:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Role Configurado
- **Role:** AmplifyServiceRole
- **Políticas Anexadas:**
  - AmplifySAMFullAccess
  - AmplifyCloudFormationExtended  
  - AdministratorAccess-Amplify

## Status
✅ Configurações aplicadas em: 2025-07-01T05:36:11Z
✅ Permissões para SAM deploy habilitadas
✅ Pronto para deploy automático via Amplify