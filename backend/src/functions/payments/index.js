const AWS = require('aws-sdk');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const axios = require('axios');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const JWT_SECRET = process.env.JWT_SECRET || 'agendemais-secret-key';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

// Configurações PIX
const PIX_CONFIG = {
  chave: process.env.PIX_CHAVE_CPF || '05359566493',
  beneficiario: process.env.PIX_BENEFICIARIO || 'Leandro Jesse da Silva',
  banco: process.env.PIX_BANCO || 'Banco PAM',
  openpix_app_id: process.env.OPENPIX_APP_ID
};

// Configurações Stripe
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

exports.handler = async (event) => {
  console.log('Payments Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers: corsHeaders, body: '' };
  }

  try {
    const { path, httpMethod, body, headers } = event;
    const data = JSON.parse(body || '{}');

    // Verificar autenticação
    const authResult = await verifyAuth(headers);
    if (!authResult.success) {
      return {
        statusCode: 401,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: authResult.message })
      };
    }

    const userId = authResult.userId;

    // Rotas de pagamento
    if (path.includes('/payments/pix') && httpMethod === 'POST') {
      return await handlePixPayment(data, userId);
    }

    if (path.includes('/payments/stripe') && httpMethod === 'POST') {
      return await handleStripePayment(data, userId);
    }

    if (path.includes('/payments/history') && httpMethod === 'GET') {
      return await handlePaymentHistory(userId);
    }

    if (path.includes('/payments/') && path.includes('/status') && httpMethod === 'GET') {
      const paymentId = path.split('/')[2];
      return await handlePaymentStatus(paymentId, userId);
    }

    return {
      statusCode: 404,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Endpoint não encontrado' })
    };

  } catch (error) {
    console.error('Payments Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro interno do servidor' })
    };
  }
};

async function verifyAuth(headers) {
  try {
    const authorization = headers.Authorization || headers.authorization;
    if (!authorization) {
      return { success: false, message: 'Token de autorização obrigatório' };
    }

    const token = authorization.replace('Bearer ', '');
    const decoded = jwt.verify(token, JWT_SECRET);
    
    return { success: true, userId: decoded.userId };
  } catch (error) {
    return { success: false, message: 'Token inválido' };
  }
}

async function handlePixPayment(data, userId) {
  try {
    const { amount, description, clientId, appointmentId } = data;

    if (!amount || amount <= 0) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Valor inválido' })
      };
    }

    if (!description) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Descrição obrigatória' })
      };
    }

    // Criar registro de pagamento no DynamoDB
    const paymentId = uuidv4();
    const payment = {
      id: paymentId,
      userId,
      amount: parseFloat(amount),
      description,
      paymentType: 'pix',
      status: 'pending',
      clientId: clientId || null,
      appointmentId: appointmentId || null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      pixData: {
        chave: PIX_CONFIG.chave,
        beneficiario: PIX_CONFIG.beneficiario,
        banco: PIX_CONFIG.banco
      }
    };

    // Gerar PIX usando OpenPix
    const pixResponse = await generatePixWithOpenPix({
      value: amount * 100, // OpenPix usa centavos
      correlationID: paymentId,
      comment: description
    });

    if (!pixResponse.success) {
      return {
        statusCode: 500,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Erro ao gerar PIX' })
      };
    }

    // Atualizar payment com dados do PIX
    payment.pixData = {
      ...payment.pixData,
      qrCode: pixResponse.qrCodeImage,
      copyPasteCode: pixResponse.brCode,
      transactionId: pixResponse.transactionId,
      expiresAt: pixResponse.expiresIn
    };

    // Salvar no DynamoDB
    await dynamodb.put({
      TableName: process.env.PAYMENTS_TABLE,
      Item: payment
    }).promise();

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        data: {
          paymentId: payment.id,
          amount: payment.amount,
          description: payment.description,
          qr_code: pixResponse.brCode,
          qr_code_image: pixResponse.qrCodeImage,
          transaction_id: pixResponse.transactionId,
          expires_at: pixResponse.expiresIn,
          status: 'pending'
        }
      })
    };

  } catch (error) {
    console.error('PIX Payment Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro ao processar pagamento PIX' })
    };
  }
}

async function generatePixWithOpenPix({ value, correlationID, comment }) {
  try {
    if (!PIX_CONFIG.openpix_app_id) {
      // Fallback - gerar PIX manualmente (versão simplificada)
      return {
        success: true,
        brCode: generateBRCode(value / 100, PIX_CONFIG.chave, comment, correlationID),
        qrCodeImage: `data:image/svg+xml;base64,${Buffer.from(generateQRCodeSVG()).toString('base64')}`,
        transactionId: correlationID,
        expiresIn: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24h
      };
    }

    const response = await axios.post('https://api.openpix.com.br/api/v1/charge', {
      correlationID,
      value,
      comment,
      customer: {
        name: PIX_CONFIG.beneficiario,
        taxID: PIX_CONFIG.chave
      }
    }, {
      headers: {
        'Authorization': PIX_CONFIG.openpix_app_id,
        'Content-Type': 'application/json'
      }
    });

    return {
      success: true,
      brCode: response.data.charge.brCode,
      qrCodeImage: response.data.charge.qrCodeImage,
      transactionId: response.data.charge.correlationID,
      expiresIn: response.data.charge.expiresIn
    };

  } catch (error) {
    console.error('OpenPix Error:', error);
    
    // Fallback manual
    return {
      success: true,
      brCode: generateBRCode(value / 100, PIX_CONFIG.chave, comment, correlationID),
      qrCodeImage: `data:image/svg+xml;base64,${Buffer.from(generateQRCodeSVG()).toString('base64')}`,
      transactionId: correlationID,
      expiresIn: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
    };
  }
}

function generateBRCode(amount, pixKey, description, transactionId) {
  // Geração simplificada do BR Code PIX
  // Em produção, usar biblioteca específica como @receita-federal/pix
  const pixPayload = `00020126${pixKey.length.toString().padStart(2, '0')}${pixKey}5204000053039865802BR5925${PIX_CONFIG.beneficiario.substring(0, 25).padEnd(25)}6009SAO PAULO62${(description.length + transactionId.length + 4).toString().padStart(2, '0')}05${transactionId.length.toString().padStart(2, '0')}${transactionId}${description.length.toString().padStart(2, '0')}${description}6304`;
  
  // Calcular CRC16 (simplificado)
  const crc = calculateCRC16(pixPayload);
  return pixPayload + crc.toString(16).toUpperCase().padStart(4, '0');
}

function calculateCRC16(data) {
  // Implementação simplificada do CRC16-CCITT
  let crc = 0xFFFF;
  for (let i = 0; i < data.length; i++) {
    crc ^= data.charCodeAt(i) << 8;
    for (let j = 0; j < 8; j++) {
      if (crc & 0x8000) {
        crc = (crc << 1) ^ 0x1021;
      } else {
        crc = crc << 1;
      }
    }
  }
  return crc & 0xFFFF;
}

function generateQRCodeSVG() {
  // QR Code SVG simplificado (placeholder)
  return `<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">
    <rect width="200" height="200" fill="white"/>
    <text x="100" y="100" text-anchor="middle" fill="black" font-size="12">QR Code PIX</text>
    <text x="100" y="120" text-anchor="middle" fill="black" font-size="10">Use o código copia e cola</text>
  </svg>`;
}

async function handleStripePayment(data, userId) {
  try {
    const { amount = 90.00, description = 'Plano Premium - Corte + Barba' } = data;

    // Criar sessão de checkout Stripe
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'brl',
          product_data: {
            name: description,
          },
          unit_amount: Math.round(amount * 100), // Stripe usa centavos
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: `${process.env.FRONTEND_URL}/payment/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${process.env.FRONTEND_URL}/payment/cancel`,
      metadata: {
        userId,
        description
      }
    });

    // Criar registro de pagamento no DynamoDB
    const paymentId = uuidv4();
    const payment = {
      id: paymentId,
      userId,
      amount: parseFloat(amount),
      description,
      paymentType: 'stripe',
      status: 'pending',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      stripeData: {
        sessionId: session.id,
        checkoutUrl: session.url
      }
    };

    await dynamodb.put({
      TableName: process.env.PAYMENTS_TABLE,
      Item: payment
    }).promise();

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        data: {
          paymentId: payment.id,
          checkoutUrl: session.url,
          sessionId: session.id,
          amount: payment.amount,
          description: payment.description
        }
      })
    };

  } catch (error) {
    console.error('Stripe Payment Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro ao processar pagamento com cartão' })
    };
  }
}

async function handlePaymentHistory(userId) {
  try {
    const result = await dynamodb.query({
      TableName: process.env.PAYMENTS_TABLE,
      IndexName: 'userId-index',
      KeyConditionExpression: 'userId = :userId',
      ExpressionAttributeValues: { ':userId': userId },
      ScanIndexForward: false // Mais recentes primeiro
    }).promise();

    const payments = result.Items.map(payment => ({
      id: payment.id,
      amount: payment.amount,
      description: payment.description,
      paymentType: payment.paymentType,
      status: payment.status,
      createdAt: payment.createdAt,
      ...(payment.paymentType === 'pix' && {
        pixData: {
          qrCode: payment.pixData?.copyPasteCode,
          transactionId: payment.pixData?.transactionId
        }
      }),
      ...(payment.paymentType === 'stripe' && {
        stripeData: {
          sessionId: payment.stripeData?.sessionId
        }
      })
    }));

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        data: {
          payments,
          total: payments.length
        }
      })
    };

  } catch (error) {
    console.error('Payment History Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro ao carregar histórico' })
    };
  }
}

async function handlePaymentStatus(paymentId, userId) {
  try {
    const result = await dynamodb.get({
      TableName: process.env.PAYMENTS_TABLE,
      Key: { id: paymentId }
    }).promise();

    if (!result.Item || result.Item.userId !== userId) {
      return {
        statusCode: 404,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Pagamento não encontrado' })
      };
    }

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        data: {
          status: result.Item.status,
          updatedAt: result.Item.updatedAt
        }
      })
    };

  } catch (error) {
    console.error('Payment Status Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro ao verificar status' })
    };
  }
}