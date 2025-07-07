const AWS = require('aws-sdk');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const axios = require('axios');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const secretsManager = new AWS.SecretsManager();

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

// Configurações PIX
const PIX_CONFIG = {
  chave: process.env.PIX_CHAVE_CPF || '05359566493',
  beneficiario: process.env.PIX_BENEFICIARIO || 'Leandro Jesse da Silva',
  banco: process.env.PIX_BANCO || 'Banco PAM'
};

exports.handler = async (event) => {
  console.log('PIX Payment Event:', JSON.stringify(event, null, 2));

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

    // Gerar transação PIX
    const transacaoId = uuidv4();
    const pixData = await gerarPixQRCode({
      valor: parseFloat(valor),
      descricao,
      transacaoId
    });

    // Salvar no DynamoDB
    const transacao = {
      id: transacaoId,
      userId,
      valor: parseFloat(valor),
      descricao,
      status: 'pendente',
      tipoPagamento: 'pix',
      chavePix: PIX_CONFIG.chave,
      nomeBeneficiario: PIX_CONFIG.beneficiario,
      banco: PIX_CONFIG.banco,
      qrCode: pixData.qrCode,
      codigoCopiaECola: pixData.codigoCopiaECola,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      expiresAt: new Date(Date.now() + 30 * 60 * 1000).toISOString() // 30 minutos
    };

    await dynamodb.put({
      TableName: process.env.PAYMENTS_TABLE,
      Item: transacao
    }).promise();

    console.log('Transação PIX criada:', transacaoId);

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        data: {
          transacaoId,
          valor: transacao.valor,
          descricao: transacao.descricao,
          qrCode: pixData.qrCode,
          codigoCopiaECola: pixData.codigoCopiaECola,
          nomeBeneficiario: PIX_CONFIG.beneficiario,
          chavePix: PIX_CONFIG.chave,
          banco: PIX_CONFIG.banco,
          status: 'pendente',
          expiresAt: transacao.expiresAt
        }
      })
    };

  } catch (error) {
    console.error('Erro PIX Payment:', error);
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

async function gerarPixQRCode({ valor, descricao, transacaoId }) {
  try {
    // Tentar usar OpenPix primeiro
    const openPixResult = await tentarOpenPix({ valor, descricao, transacaoId });
    if (openPixResult.success) {
      return openPixResult;
    }

    // Fallback: Gerar PIX manual
    console.log('OpenPix falhou, usando geração manual...');
    return gerarPixManual({ valor, descricao, transacaoId });

  } catch (error) {
    console.error('Erro ao gerar PIX:', error);
    // Fallback para geração manual
    return gerarPixManual({ valor, descricao, transacaoId });
  }
}

async function tentarOpenPix({ valor, descricao, transacaoId }) {
  try {
    // Buscar chave API do Secrets Manager
    const openPixKey = await getSecret('OPENPIX_API_KEY');
    if (!openPixKey) {
      return { success: false, message: 'Chave OpenPix não configurada' };
    }

    const response = await axios.post('https://api.openpix.com.br/api/v1/charge', {
      correlationID: transacaoId,
      value: Math.round(valor * 100), // OpenPix usa centavos
      comment: descricao,
      customer: {
        name: PIX_CONFIG.beneficiario,
        taxID: PIX_CONFIG.chave
      },
      additionalInfo: [
        {
          key: 'Banco',
          value: PIX_CONFIG.banco
        }
      ]
    }, {
      headers: {
        'Authorization': openPixKey,
        'Content-Type': 'application/json'
      }
    });

    if (response.data && response.data.charge) {
      return {
        success: true,
        qrCode: response.data.charge.qrCodeImage || null,
        codigoCopiaECola: response.data.charge.brCode,
        transactionId: response.data.charge.correlationID
      };
    }

    return { success: false, message: 'Resposta inválida da OpenPix' };

  } catch (error) {
    console.error('Erro OpenPix:', error.response?.data || error.message);
    return { success: false, message: error.message };
  }
}

function gerarPixManual({ valor, descricao, transacaoId }) {
  try {
    // Gerar BR Code PIX manualmente
    const chavePix = PIX_CONFIG.chave;
    const nomeBeneficiario = PIX_CONFIG.beneficiario.substring(0, 25);
    
    // Construir payload PIX EMV
    let payload = '';
    
    // Payload Format Indicator
    payload += '00020';
    
    // Point of Initiation Method
    payload += '01012';
    
    // Merchant Account Information
    const chaveLenth = chavePix.length.toString().padStart(2, '0');
    payload += `26${(chaveLenth.length + chavePix.length + 4).toString().padStart(2, '0')}0014br.gov.bcb.pix01${chaveLenth}${chavePix}`;
    
    // Merchant Category Code
    payload += '52040000';
    
    // Transaction Currency
    payload += '5303986';
    
    // Transaction Amount
    const valorStr = valor.toFixed(2);
    payload += `54${valorStr.length.toString().padStart(2, '0')}${valorStr}`;
    
    // Country Code
    payload += '5802BR';
    
    // Merchant Name
    payload += `59${nomeBeneficiario.length.toString().padStart(2, '0')}${nomeBeneficiario}`;
    
    // Merchant City
    payload += '6009SAO PAULO';
    
    // Additional Data Field Template
    const additionalData = `05${transacaoId.length.toString().padStart(2, '0')}${transacaoId}`;
    payload += `62${additionalData.length.toString().padStart(2, '0')}${additionalData}`;
    
    // CRC16
    payload += '6304';
    const crc = calcularCRC16(payload);
    payload += crc.toString(16).toUpperCase().padStart(4, '0');

    return {
      success: true,
      qrCode: null, // Não temos geração de imagem QR Code
      codigoCopiaECola: payload,
      transactionId: transacaoId
    };

  } catch (error) {
    console.error('Erro PIX manual:', error);
    throw new Error('Falha ao gerar código PIX');
  }
}

function calcularCRC16(data) {
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