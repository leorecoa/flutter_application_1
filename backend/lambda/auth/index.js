const { v4: uuidv4 } = require('uuid');

// Use AWS SDK v2 que está disponível no runtime
const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

const MAIN_TABLE = process.env.MAIN_TABLE;

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST,OPTIONS',
    'Content-Type': 'application/json'
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  try {
    const body = JSON.parse(event.body);
    const { name, email, businessName, password } = body;

    if (!name || !email || !businessName || !password) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          success: false,
          error: { message: 'Todos os campos são obrigatórios.' }
        })
      };
    }

    const userId = uuidv4();
    const tenantId = uuidv4();

    const tenant = {
      PK: `TENANT#${tenantId}`,
      SK: 'PROFILE',
      tenantId,
      businessName,
      businessType: 'barbearia',
      email,
      ownerId: userId,
      createdAt: new Date().toISOString(),
      isActive: true
    };

    const userProfile = {
      PK: `TENANT#${tenantId}`,
      SK: `USER#${userId}`,
      userId,
      name,
      email,
      role: 'admin',
      tenantId,
      createdAt: new Date().toISOString(),
      isActive: true
    };

    await Promise.all([
      dynamoDb.put({ TableName: MAIN_TABLE, Item: tenant }).promise(),
      dynamoDb.put({ TableName: MAIN_TABLE, Item: userProfile }).promise()
    ]);

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        success: true,
        data: {
          message: 'Usuário registrado com sucesso!',
          userId,
          tenantId
        }
      })
    };

  } catch (error) {
    console.error('Erro no cadastro:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        success: false,
        error: { message: 'Erro ao registrar usuário. Tente novamente.' }
      })
    };
  }
};