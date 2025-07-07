const AWS = require('aws-sdk');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const secretsManager = new AWS.SecretsManager();

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization,Stripe-Signature',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('Stripe Webhook Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers: corsHeaders, body: '' };
  }

  try {
    const body = event.body;
    const signature = event.headers['Stripe-Signature'] || event.headers['stripe-signature'];

    if (!signature) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Assinatura Stripe obrigatória' })
      };
    }

    // Obter webhook secret do Secrets Manager
    const webhookSecret = await getSecret('STRIPE_WEBHOOK_SECRET');
    if (!webhookSecret) {
      return {
        statusCode: 500,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Webhook secret não configurado' })
      };
    }

    // Obter chave secreta do Stripe
    const stripeSecretKey = await getSecret('STRIPE_SECRET_KEY');
    if (!stripeSecretKey) {
      return {
        statusCode: 500,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Chave Stripe não configurada' })
      };
    }

    // Inicializar Stripe
    const stripe = require('stripe')(stripeSecretKey);

    let stripeEvent;

    try {
      // Verificar assinatura do webhook
      stripeEvent = stripe.webhooks.constructEvent(body, signature, webhookSecret);
    } catch (err) {
      console.error('Erro na verificação da assinatura:', err.message);
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Assinatura inválida' })
      };
    }

    console.log('Evento Stripe verificado:', stripeEvent.type);

    // Processar eventos específicos
    switch (stripeEvent.type) {
      case 'checkout.session.completed':
        await processCheckoutCompleted(stripeEvent.data.object);
        break;
      
      case 'payment_intent.succeeded':
        await processPaymentSucceeded(stripeEvent.data.object);
        break;
      
      case 'payment_intent.payment_failed':
        await processPaymentFailed(stripeEvent.data.object);
        break;
      
      default:
        console.log('Evento não processado:', stripeEvent.type);
    }

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ success: true, message: 'Webhook processado' })
    };

  } catch (error) {
    console.error('Erro no webhook Stripe:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ 
        success: false, 
        message: 'Erro interno do servidor',
        error: error.message 
      })
    };
  }
};

async function processCheckoutCompleted(session) {
  try {
    console.log('Processing checkout completed:', session.id);
    
    const transacaoId = session.metadata.transacaoId;
    
    if (!transacaoId) {
      console.error('transacaoId não encontrado nos metadata');
      return;
    }

    // Buscar transação no DynamoDB
    const result = await dynamodb.get({
      TableName: process.env.PAYMENTS_TABLE,
      Key: { id: transacaoId }
    }).promise();

    if (!result.Item) {
      console.error('Transação não encontrada:', transacaoId);
      return;
    }

    // Atualizar status para pago
    await dynamodb.update({
      TableName: process.env.PAYMENTS_TABLE,
      Key: { id: transacaoId },
      UpdateExpression: 'SET #status = :status, updatedAt = :updatedAt, stripePaymentIntentId = :paymentIntentId, stripePaidAt = :paidAt, customerEmail = :email',
      ExpressionAttributeNames: {
        '#status': 'status'
      },
      ExpressionAttributeValues: {
        ':status': 'pago',
        ':updatedAt': new Date().toISOString(),
        ':paymentIntentId': session.payment_intent,
        ':paidAt': new Date().toISOString(),
        ':email': session.customer_email || null
      }
    }).promise();

    console.log('Pagamento Stripe confirmado:', transacaoId);

    // Opcional: Enviar notificação ou email
    await enviarNotificacaoPagamento(result.Item, session);

  } catch (error) {
    console.error('Erro ao processar checkout completed:', error);
    throw error;
  }
}

async function processPaymentSucceeded(paymentIntent) {
  try {
    console.log('Processing payment succeeded:', paymentIntent.id);
    
    // Este evento é complementar ao checkout.session.completed
    // Pode ser usado para logging adicional ou outras ações
    
  } catch (error) {
    console.error('Erro ao processar payment succeeded:', error);
  }
}

async function processPaymentFailed(paymentIntent) {
  try {
    console.log('Processing payment failed:', paymentIntent.id);
    
    // Buscar transação pelo paymentIntentId
    const result = await dynamodb.scan({
      TableName: process.env.PAYMENTS_TABLE,
      FilterExpression: 'stripePaymentIntentId = :paymentIntentId',
      ExpressionAttributeValues: {
        ':paymentIntentId': paymentIntent.id
      }
    }).promise();

    if (result.Items.length > 0) {
      const transacao = result.Items[0];
      
      // Atualizar status para falhou
      await dynamodb.update({
        TableName: process.env.PAYMENTS_TABLE,
        Key: { id: transacao.id },
        UpdateExpression: 'SET #status = :status, updatedAt = :updatedAt, stripeFailureReason = :reason',
        ExpressionAttributeNames: {
          '#status': 'status'
        },
        ExpressionAttributeValues: {
          ':status': 'falhou',
          ':updatedAt': new Date().toISOString(),
          ':reason': paymentIntent.last_payment_error?.message || 'Pagamento falhou'
        }
      }).promise();

      console.log('Pagamento Stripe falhou:', transacao.id);
    }
    
  } catch (error) {
    console.error('Erro ao processar payment failed:', error);
  }
}

async function enviarNotificacaoPagamento(transacao, session) {
  try {
    // Aqui você pode implementar notificações por email, SMS, etc.
    console.log('Enviar notificação de pagamento:', {
      transacaoId: transacao.id,
      userId: transacao.userId,
      valor: transacao.valor,
      email: session.customer_email,
      tipo: 'stripe'
    });

    // Exemplo: Enviar email via SES
    // const ses = new AWS.SES();
    // await ses.sendEmail({
    //   Source: 'noreply@agendemais.com',
    //   Destination: { ToAddresses: [session.customer_email] },
    //   Message: {
    //     Subject: { Data: 'Pagamento Confirmado - AGENDEMAIS' },
    //     Body: { Text: { Data: 'Seu pagamento foi processado com sucesso!' } }
    //   }
    // }).promise();
    
  } catch (error) {
    console.error('Erro ao enviar notificação:', error);
  }
}

async function getSecret(secretKey) {
  try {
    const result = await secretsManager.getSecretValue({
      SecretId: 'agendemais/payments'
    }).promise();
    
    const secrets = JSON.parse(result.SecretString);
    return secrets[secretKey];
  } catch (error) {
    console.log(`Secret ${secretKey} não encontrado:`, error.message);
    return null;
  }
}