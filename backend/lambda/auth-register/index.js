const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  console.log('RegisterUser Event:', JSON.stringify(event, null, 2));

  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'POST,OPTIONS',
    'Content-Type': 'application/json'
  };

  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({})
    };
  }

  try {
    const body = JSON.parse(event.body || '{}');
    const { name, email, businessName, password } = body;

    console.log('Parsed body:', { name, email, businessName, password: '***' });

    if (!name || !email || !businessName || !password) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          success: false,
          message: 'Campos obrigatórios ausentes: name, email, businessName, password'
        })
      };
    }

    const id = uuidv4();
    const createdAt = new Date().toISOString();

    const params = {
      TableName: process.env.USERS_TABLE || 'Users',
      Item: {
        id,
        name,
        email,
        businessName,
        password,
        createdAt
      }
    };

    console.log('DynamoDB params:', params);

    await dynamodb.put(params).promise();

    console.log('User created successfully:', id);

    return {
      statusCode: 201,
      headers,
      body: JSON.stringify({
        success: true,
        message: 'Usuário criado com sucesso!',
        user: {
          id,
          name,
          email,
          businessName,
          createdAt
        }
      })
    };

  } catch (error) {
    console.error('RegisterUser Error:', error);
    
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        success: false,
        message: 'Erro interno do servidor',
        error: error.message
      })
    };
  }
};