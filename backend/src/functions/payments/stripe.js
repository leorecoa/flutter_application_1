const AWS = require('aws-sdk');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const secretsManager = new AWS.SecretsManager();

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('Stripe Payment Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers: corsHeaders, body: '' };
  }

  try {
    // Verificar autenticação JWT
    const authResult = await verifyJWT(event.headers);
    if (!authResult.success) {
      return {
        statusCode: 401,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: authResult.message })
      };
    }

    const userId = authResult.userId;
    const body = JSON.parse(event.body || '{}');
    const { valor, descricao = 'Plano Premium - Corte + Barba' } = body;

    // Validação
    if (!valor || valor <= 0) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Valor inválido' })
      };
    }

    // Obter chave secreta do Stripe
    const stripeSecretKey = await getSecret('STRIPE_SECRET_KEY');
    if (!stripeSecretKey) {
      return {
        statusCode: 500,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Configuração Stripe não encontrada' })
      };
    }

    // Inicializar Stripe
    const stripe = require('stripe')(stripeSecretKey);

    // Gerar ID da transação
    const transacaoId = uuidv4();

    // Criar Checkout Session no Stripe
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'brl',
            product_data: {
              name: descricao,
              description: 'AGENDEMAIS - Sistema de Agendamento',
              images: ['https://main.d31iho7gw23enq.amplifyapp.com/icons/Icon-192.png'],
            },
            unit_amount: Math.round(parseFloat(valor) * 100), // Stripe usa centavos
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: `${process.env.FRONTEND_URL}/pagamento/sucesso?session_id={CHECKOUT_SESSION_ID}&transacao_id=${transacaoId}`,
      cancel_url: `${process.env.FRONTEND_URL}/pagamento/cancelado?transacao_id=${transacaoId}`,
      metadata: {
        transacaoId,
        userId,
        valor: valor.toString(),
        descricao,
        sistema: 'AGENDEMAIS'
      },
      customer_email: null, // Será preenchido pelo usuário no checkout
      locale: 'pt-BR',
      expires_at: Math.floor(Date.now() / 1000) + (30 * 60) // 30 minutos
    });

    // Salvar transação no DynamoDB
    const transacao = {
      id: transacaoId,
      userId,
      valor: parseFloat(valor),
      descricao,
      status: 'pendente',
      tipoPagamento: 'stripe',
      stripeSessionId: session.id,
      stripePaymentUrl: session.url,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      expiresAt: new Date(session.expires_at * 1000).toISOString()
    };

    await dynamodb.put({
      TableName: process.env.PAYMENTS_TABLE,
      Item: transacao
    }).promise();

    console.log('Transação Stripe criada:', transacaoId, 'Session:', session.id);

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        data: {
          transacaoId,
          valor: transacao.valor,
          descricao: transacao.descricao,
          checkoutUrl: session.url,
          sessionId: session.id,
          status: 'pendente',
          expiresAt: transacao.expiresAt
        }
      })
    };

  } catch (error) {
    console.error('Erro Stripe Payment:', error);
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

async function verifyJWT(headers) {
  try {
    const authorization = headers.Authorization || headers.authorization;
    if (!authorization) {
      return { success: false, message: 'Token de autorização obrigatório' };
    }

    const token = authorization.replace('Bearer ', '');
    const JWT_SECRET = process.env.JWT_SECRET || 'agendemais-secret-key-2024';
    const decoded = jwt.verify(token, JWT_SECRET);
    
    return { success: true, userId: decoded.userId || decoded.sub };
  } catch (error) {
    return { success: false, message: 'Token inválido ou expirado' };
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