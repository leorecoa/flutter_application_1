const AWS = require('aws-sdk');
const crypto = require('crypto');

const dynamodb = new AWS.DynamoDB.DocumentClient();

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization,X-Webhook-Signature',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('Webhook Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers: corsHeaders, body: '' };
  }

  try {
    const { path, httpMethod, body, headers } = event;
    
    if (path.includes('/webhooks/pix') && httpMethod === 'POST') {
      return await handlePixWebhook(body, headers);
    }

    if (path.includes('/webhooks/stripe') && httpMethod === 'POST') {
      return await handleStripeWebhook(body, headers);
    }

    return {
      statusCode: 404,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Webhook endpoint não encontrado' })
    };

  } catch (error) {
    console.error('Webhook Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro interno do servidor' })
    };
  }
};

async function handlePixWebhook(body, headers) {
  try {
    console.log('PIX Webhook received:', body);
    
    // Verificar assinatura se configurada
    if (process.env.PIX_WEBHOOK_SECRET) {
      const signature = headers['X-Webhook-Signature'] || headers['x-webhook-signature'];
      if (!verifyPixSignature(body, signature, process.env.PIX_WEBHOOK_SECRET)) {
        return {
          statusCode: 401,
          headers: corsHeaders,
          body: JSON.stringify({ success: false, message: 'Assinatura inválida' })
        };
      }
    }

    const webhookData = JSON.parse(body);
    
    // Processar diferentes tipos de evento PIX
    if (webhookData.event === 'OPENPIX:CHARGE_COMPLETED') {
      return await processPixPaymentCompleted(webhookData.charge);
    }

    if (webhookData.event === 'OPENPIX:CHARGE_EXPIRED') {
      return await processPixPaymentExpired(webhookData.charge);
    }

    // Formato genérico de webhook PIX
    if (webhookData.status === 'COMPLETED' || webhookData.status === 'paid') {
      return await processPixPaymentCompleted(webhookData);
    }

    console.log('PIX Webhook event não processado:', webhookData.event || 'unknown');
    
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ success: true, message: 'Webhook recebido' })
    };

  } catch (error) {
    console.error('PIX Webhook Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro ao processar webhook PIX' })
    };
  }
}

async function processPixPaymentCompleted(chargeData) {
  try {
    const paymentId = chargeData.correlationID || chargeData.transactionId;
    
    if (!paymentId) {
      console.error('PaymentId não encontrado nos dados do webhook PIX');
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'PaymentId não encontrado' })
      };
    }

    // Buscar pagamento no DynamoDB
    const result = await dynamodb.get({
      TableName: process.env.PAYMENTS_TABLE,
      Key: { id: paymentId }
    }).promise();

    if (!result.Item) {
      console.log('Pagamento não encontrado:', paymentId);
      return {
        statusCode: 404,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Pagamento não encontrado' })
      };
    }

    // Atualizar status para pago
    await dynamodb.update({
      TableName: process.env.PAYMENTS_TABLE,
      Key: { id: paymentId },
      UpdateExpression: 'SET #status = :status, updatedAt = :updatedAt, pixData.paidAt = :paidAt',
      ExpressionAttributeNames: {
        '#status': 'status'
      },
      ExpressionAttributeValues: {
        ':status': 'paid',
        ':updatedAt': new Date().toISOString(),
        ':paidAt': new Date().toISOString()
      }
    }).promise();

    console.log('Pagamento PIX confirmado:', paymentId);

    // Opcional: Enviar notificação ou email
    await notifyPaymentCompleted(result.Item);

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ success: true, message: 'Pagamento confirmado' })
    };

  } catch (error) {
    console.error('Erro ao processar pagamento PIX confirmado:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro interno' })
    };
  }
}

async function processPixPaymentExpired(chargeData) {
  try {
    const paymentId = chargeData.correlationID || chargeData.transactionId;
    
    if (!paymentId) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'PaymentId não encontrado' })
      };
    }

    // Atualizar status para expirado
    await dynamodb.update({
      TableName: process.env.PAYMENTS_TABLE,
      Key: { id: paymentId },
      UpdateExpression: 'SET #status = :status, updatedAt = :updatedAt',
      ExpressionAttributeNames: {
        '#status': 'status'
      },
      ExpressionAttributeValues: {
        ':status': 'expired',
        ':updatedAt': new Date().toISOString()
      }
    }).promise();

    console.log('Pagamento PIX expirado:', paymentId);

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ success: true, message: 'Status atualizado para expirado' })
    };

  } catch (error) {
    console.error('Erro ao processar PIX expirado:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro interno' })
    };
  }
}

async function handleStripeWebhook(body, headers) {
  try {
    const signature = headers['stripe-signature'] || headers['Stripe-Signature'];
    
    if (!signature || !process.env.STRIPE_WEBHOOK_SECRET) {
      return {
        statusCode: 401,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Assinatura Stripe necessária' })
      };
    }

    // Verificar assinatura Stripe
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
    let event;

    try {
      event = stripe.webhooks.constructEvent(body, signature, process.env.STRIPE_WEBHOOK_SECRET);
    } catch (err) {
      console.error('Erro na verificação da assinatura Stripe:', err.message);
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Assinatura inválida' })
      };
    }

    // Processar eventos Stripe
    switch (event.type) {
      case 'checkout.session.completed':
        return await processStripePaymentCompleted(event.data.object);
      
      case 'payment_intent.succeeded':
        return await processStripePaymentSucceeded(event.data.object);
      
      case 'payment_intent.payment_failed':
        return await processStripePaymentFailed(event.data.object);
      
      default:
        console.log('Stripe event não processado:', event.type);
        return {
          statusCode: 200,
          headers: corsHeaders,
          body: JSON.stringify({ success: true, message: 'Event recebido' })
        };
    }

  } catch (error) {
    console.error('Stripe Webhook Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro ao processar webhook Stripe' })
    };
  }
}

async function processStripePaymentCompleted(session) {
  try {
    const userId = session.metadata.userId;
    
    if (!userId) {
      console.error('UserId não encontrado nos metadata da sessão Stripe');
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'UserId não encontrado' })
      };
    }

    // Buscar pagamento no DynamoDB pela sessionId
    const result = await dynamodb.scan({
      TableName: process.env.PAYMENTS_TABLE,
      FilterExpression: 'stripeData.sessionId = :sessionId',
      ExpressionAttributeValues: {
        ':sessionId': session.id
      }
    }).promise();

    if (result.Items.length === 0) {
      console.log('Pagamento Stripe não encontrado:', session.id);
      return {
        statusCode: 404,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Pagamento não encontrado' })
      };
    }

    const payment = result.Items[0];

    // Atualizar status para pago
    await dynamodb.update({
      TableName: process.env.PAYMENTS_TABLE,
      Key: { id: payment.id },
      UpdateExpression: 'SET #status = :status, updatedAt = :updatedAt, stripeData.paidAt = :paidAt, stripeData.paymentIntentId = :paymentIntentId',
      ExpressionAttributeNames: {
        '#status': 'status'
      },
      ExpressionAttributeValues: {
        ':status': 'paid',
        ':updatedAt': new Date().toISOString(),
        ':paidAt': new Date().toISOString(),
        ':paymentIntentId': session.payment_intent
      }
    }).promise();

    console.log('Pagamento Stripe confirmado:', payment.id);

    // Opcional: Enviar notificação ou email
    await notifyPaymentCompleted(payment);

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ success: true, message: 'Pagamento Stripe confirmado' })
    };

  } catch (error) {
    console.error('Erro ao processar pagamento Stripe confirmado:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro interno' })
    };
  }
}

async function processStripePaymentSucceeded(paymentIntent) {
  console.log('Payment Intent succeeded:', paymentIntent.id);
  // Este evento é complementar ao checkout.session.completed
  return {
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({ success: true, message: 'Payment Intent processado' })
  };
}

async function processStripePaymentFailed(paymentIntent) {
  try {
    // Buscar pagamento no DynamoDB pelo paymentIntentId
    const result = await dynamodb.scan({
      TableName: process.env.PAYMENTS_TABLE,
      FilterExpression: 'stripeData.paymentIntentId = :paymentIntentId',
      ExpressionAttributeValues: {
        ':paymentIntentId': paymentIntent.id
      }
    }).promise();

    if (result.Items.length > 0) {
      const payment = result.Items[0];
      
      // Atualizar status para falhou
      await dynamodb.update({
        TableName: process.env.PAYMENTS_TABLE,
        Key: { id: payment.id },
        UpdateExpression: 'SET #status = :status, updatedAt = :updatedAt',
        ExpressionAttributeNames: {
          '#status': 'status'
        },
        ExpressionAttributeValues: {
          ':status': 'failed',
          ':updatedAt': new Date().toISOString()
        }
      }).promise();

      console.log('Pagamento Stripe falhou:', payment.id);
    }

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ success: true, message: 'Falha de pagamento processada' })
    };

  } catch (error) {
    console.error('Erro ao processar falha de pagamento Stripe:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro interno' })
    };
  }
}

function verifyPixSignature(payload, signature, secret) {
  if (!signature || !secret) return false;
  
  try {
    const expectedSignature = crypto
      .createHmac('sha256', secret)
      .update(payload)
      .digest('hex');
    
    return crypto.timingSafeEqual(
      Buffer.from(signature, 'hex'),
      Buffer.from(expectedSignature, 'hex')
    );
  } catch (error) {
    console.error('Erro ao verificar assinatura PIX:', error);
    return false;
  }
}

async function notifyPaymentCompleted(payment) {
  try {
    // Aqui você pode implementar notificações por email, SMS, etc.
    console.log('Pagamento confirmado - Enviar notificação:', {
      paymentId: payment.id,
      userId: payment.userId,
      amount: payment.amount,
      type: payment.paymentType
    });
    
    // Exemplo: Enviar email via SES
    // const ses = new AWS.SES();
    // await ses.sendEmail({...}).promise();
    
  } catch (error) {
    console.error('Erro ao enviar notificação:', error);
  }
}