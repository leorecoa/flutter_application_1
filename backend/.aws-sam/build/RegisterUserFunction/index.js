const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();

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
        body: JSON.stringify({ message: "Campos obrigatórios ausentes" }),
      };
    }

    const id = uuidv4();
    const createdAt = new Date().toISOString();

    const params = {
      TableName: "Users",
      Item: {
        id,
        name,
        email,
        businessName,
        password,
        createdAt,
      },
    };

    await dynamodb.put(params).promise();

    return {
      statusCode: 201,
      headers,
      body: JSON.stringify({
        message: "Usuário criado com sucesso!",
        user: {
          id,
          name,
          email,
          businessName,
          createdAt,
        },
      }),
    };
  } catch (error) {
    console.error("Erro no cadastro:", error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ message: "Erro interno ao criar o usuário" }),
    };
  }
};