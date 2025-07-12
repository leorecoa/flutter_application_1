const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const crypto = require('crypto');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const PIX_TABLE = process.env.PIX_TABLE || 'agendemais-pix';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('PIX Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ message: 'OK' })
    };
  }

  try {
    const { httpMethod, pathParameters, body } = event;
    const pixId = pathParameters?.id;
    const action = pathParameters?.action;

    switch (httpMethod) {
      case 'GET':
        if (pixId && action === 'status') {
          return await getPixStatus(pixId);
        }
        if (pathParameters?.path === 'history') {
          return await getPixHistory();
        }
        return await getPixById(pixId);
      case 'POST':
        if (pathParameters?.path === 'generate') {
          return await generatePix(JSON.parse(body));
        }
        if (pixId && action === 'cancel') {
          return await cancelPix(pixId);
        }
        return await processWebhook(JSON.parse(body));
      default:
        return {
          statusCode: 405,
          headers: corsHeaders,
          body: JSON.stringify({ success: false, message: 'Method not allowed' })
        };
    }
  } catch (error) {
    console.error('PIX Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ 
        success: false, 
        message: 'Internal server error',
        error: error.message 
      })
    };
  }
};

async function generatePix(pixData) {
  const pixId = uuidv4();
  const now = new Date().toISOString();
  
  // Gerar código PIX EMV (simplificado para demo)
  const pixCode = generatePixEMV({
    amount: pixData.amount,
    description: pixData.description,
    pixId: pixId
  });

  const pixRecord = {
    id: pixId,
    amount: pixData.amount,
    description: pixData.description,
    clientName: pixData.clientName || '',
    clientEmail: pixData.clientEmail || '',
    pixCode: pixCode,
    status: 'PENDING',
    createdAt: now,
    updatedAt: now,
    expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString() // 24h
  };

  await dynamodb.put({
    TableName: PIX_TABLE,
    Item: pixRecord
  }).promise();

  return {
    statusCode: 201,
    headers: corsHeaders,
    body: JSON.stringify({
      success: true,
      pixId: pixId,
      pixCode: pixCode,
      data: pixRecord,
      message: 'PIX gerado com sucesso'
    })
  };
}

async function getPixStatus(pixId) {
  const result = await dynamodb.get({
    TableName: PIX_TABLE,
    Key: { id: pixId }
  }).promise();

  if (!result.Item) {
    return {
      statusCode: 404,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'PIX não encontrado' })
    };
  }

  return {
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({
      success: true,
      data: result.Item
    })
  };
}

async function getPixHistory() {
  const result = await dynamodb.scan({
    TableName: PIX_TABLE,
    ScanFilter: {
      createdAt: {
        AttributeValueList: [new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString()],
        ComparisonOperator: 'GT'
      }
    }
  }).promise();

  return {
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({
      success: true,
      data: result.Items || []
    })
  };
}

async function cancelPix(pixId) {
  await dynamodb.update({
    TableName: PIX_TABLE,
    Key: { id: pixId },
    UpdateExpression: 'SET #status = :status, updatedAt = :updatedAt',
    ExpressionAttributeNames: { '#status': 'status' },
    ExpressionAttributeValues: {
      ':status': 'CANCELLED',
      ':updatedAt': new Date().toISOString()
    }
  }).promise();

  return {
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({
      success: true,
      message: 'PIX cancelado com sucesso'
    })
  };
}

function generatePixEMV({ amount, description, pixId }) {
  // Código PIX EMV simplificado para demonstração
  // Em produção, usar biblioteca oficial do Banco Central
  const pixKey = process.env.PIX_KEY || '11999999999';
  const merchantName = process.env.MERCHANT_NAME || 'AGENDEMAIS';
  const merchantCity = process.env.MERCHANT_CITY || 'SAO PAULO';
  
  // Formato básico EMV para PIX (simplificado)
  const payload = `00020126580014br.gov.bcb.pix0136${pixKey}0208${description.substring(0, 25)}5204000053039865802BR5913${merchantName}6009${merchantCity}62070503***6304`;
  
  // Calcular CRC16 (simplificado)
  const crc = calculateCRC16(payload.substring(0, payload.length - 4));
  
  return payload.substring(0, payload.length - 4) + crc.toString(16).toUpperCase().padStart(4, '0');
}

function calculateCRC16(data) {
  // CRC16 simplificado para demonstração
  let crc = 0xFFFF;
  for (let i = 0; i < data.length; i++) {
    crc ^= data.charCodeAt(i) << 8;
    for (let j = 0; j < 8; j++) {
      if (crc & 0x8000) {
        crc = (crc << 1) ^ 0x1021;
      } else {
        crc <<= 1;
      }
    }
  }
  return crc & 0xFFFF;
}

async function processWebhook(webhookData) {
  // Processar webhook de confirmação de pagamento
  const { pixId, status, paidAt } = webhookData;
  
  if (pixId && status === 'PAID') {
    await dynamodb.update({
      TableName: PIX_TABLE,
      Key: { id: pixId },
      UpdateExpression: 'SET #status = :status, paidAt = :paidAt, updatedAt = :updatedAt',
      ExpressionAttributeNames: { '#status': 'status' },
      ExpressionAttributeValues: {
        ':status': 'PAID',
        ':paidAt': paidAt || new Date().toISOString(),
        ':updatedAt': new Date().toISOString()
      }
    }).promise();
  }

  return {
    statusCode: 200,
    headers: corsHeaders,
    body: JSON.stringify({ success: true, message: 'Webhook processado' })
  };
}