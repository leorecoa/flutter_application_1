# Guia de Deploy - SaaS AgendaFácil

## 🚀 Deploy AWS (Recomendado)

### 1. Configuração da Infraestrutura

#### AWS CDK Stack (TypeScript)
```typescript
import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';

export class AgendaFacilStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // DynamoDB Table
    const table = new dynamodb.Table(this, 'AgendaFacilTable', {
      tableName: 'agenda-facil-prod',
      partitionKey: { name: 'PK', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'SK', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      pointInTimeRecovery: true,
    });

    // Lambda Function
    const apiLambda = new lambda.Function(this, 'ApiLambda', {
      runtime: lambda.Runtime.NODEJS_18_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset('lambda'),
      environment: {
        TABLE_NAME: table.tableName,
        WHATSAPP_API_URL: process.env.WHATSAPP_API_URL!,
        STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY!,
      },
    });

    // API Gateway
    const api = new apigateway.RestApi(this, 'AgendaFacilApi', {
      restApiName: 'AgendaFácil API',
      description: 'API para SaaS de agendamento',
      defaultCorsPreflightOptions: {
        allowOrigins: apigateway.Cors.ALL_ORIGINS,
        allowMethods: apigateway.Cors.ALL_METHODS,
      },
    });

    const integration = new apigateway.LambdaIntegration(apiLambda);
    api.root.addProxy({
      defaultIntegration: integration,
    });

    // S3 + CloudFront para Frontend
    const websiteBucket = new s3.Bucket(this, 'WebsiteBucket', {
      bucketName: 'agenda-facil-frontend',
      websiteIndexDocument: 'index.html',
      publicReadAccess: true,
    });

    const distribution = new cloudfront.CloudFrontWebDistribution(this, 'Distribution', {
      originConfigs: [{
        s3OriginSource: {
          s3BucketSource: websiteBucket,
        },
        behaviors: [{ isDefaultBehavior: true }],
      }],
    });
  }
}
```

### 2. Deploy do Backend

#### Comandos de Deploy
```bash
# Instalar AWS CDK
npm install -g aws-cdk

# Configurar credenciais AWS
aws configure

# Deploy da infraestrutura
cdk bootstrap
cdk deploy

# Deploy das funções Lambda
zip -r lambda-function.zip index.js node_modules/
aws lambda update-function-code --function-name AgendaFacilApi --zip-file fileb://lambda-function.zip
```

### 3. Deploy do Frontend Flutter Web

#### Build e Deploy
```bash
# Build para produção
flutter build web --release

# Upload para S3
aws s3 sync build/web/ s3://agenda-facil-frontend --delete

# Invalidar cache do CloudFront
aws cloudfront create-invalidation --distribution-id E1234567890 --paths "/*"
```

## 📱 Deploy Mobile (App Stores)

### Android (Google Play Store)

#### 1. Configurar Signing
```bash
# Gerar keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configurar android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<location of the key store file>
```

#### 2. Build e Upload
```bash
# Build AAB
flutter build appbundle --release

# Upload via Google Play Console
# Arquivo: build/app/outputs/bundle/release/app-release.aab
```

### iOS (App Store)

#### 1. Configurar Xcode
```bash
# Abrir projeto iOS
open ios/Runner.xcworkspace

# Configurar Bundle ID, Team, Certificates
# Build Settings > Signing & Capabilities
```

#### 2. Build e Upload
```bash
# Build para iOS
flutter build ios --release

# Archive via Xcode
# Product > Archive > Distribute App
```

## 🔧 Configuração de Ambiente

### Variáveis de Ambiente (.env)
```env
# AWS
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# APIs Externas
WHATSAPP_API_URL=https://api.z-api.io
WHATSAPP_TOKEN=your_whatsapp_token
STRIPE_SECRET_KEY=sk_test_...
MERCADOPAGO_ACCESS_TOKEN=TEST-...

# Database
DYNAMODB_TABLE_NAME=agenda-facil-prod

# Frontend
FLUTTER_WEB_URL=https://app.agendafacil.com.br
API_BASE_URL=https://api.agendafacil.com.br
```

## 🔒 Configuração de Segurança

### 1. AWS IAM Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:*:table/agenda-facil-prod"
    }
  ]
}
```

### 2. API Gateway CORS
```javascript
const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://app.agendafacil.com.br',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};
```

### 3. Rate Limiting
```javascript
// API Gateway Usage Plan
const usagePlan = {
  throttle: {
    rateLimit: 1000,
    burstLimit: 2000
  },
  quota: {
    limit: 10000,
    period: 'DAY'
  }
};
```

## 📊 Monitoramento

### CloudWatch Dashboards
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/Lambda", "Invocations", "FunctionName", "AgendaFacilApi"],
          ["AWS/Lambda", "Errors", "FunctionName", "AgendaFacilApi"],
          ["AWS/Lambda", "Duration", "FunctionName", "AgendaFacilApi"]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "us-east-1",
        "title": "Lambda Metrics"
      }
    }
  ]
}
```

### Alertas CloudWatch
```javascript
const errorAlarm = new cloudwatch.Alarm(this, 'LambdaErrorAlarm', {
  metric: apiLambda.metricErrors(),
  threshold: 10,
  evaluationPeriods: 2,
});
```

## 💰 Estimativa de Custos

### Custos Mensais (1000 usuários ativos):
- **Lambda**: $20 (1M execuções)
- **DynamoDB**: $25 (5GB + RCU/WCU)
- **API Gateway**: $15 (1M requests)
- **S3 + CloudFront**: $10
- **CloudWatch**: $5
- **Total AWS**: ~$75/mês

### Custos Externos:
- **Domínio**: $15/ano
- **SSL Certificate**: Gratuito (AWS Certificate Manager)
- **WhatsApp API**: $50/mês
- **Stripe**: 2.9% + $0.30 por transação