const AWS = require('aws-sdk');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const JWT_SECRET = process.env.JWT_SECRET || 'agendemais-secret-key';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

exports.handler = async (event) => {
  console.log('Auth Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers: corsHeaders, body: '' };
  }

  try {
    const { path, httpMethod, body } = event;
    const data = JSON.parse(body || '{}');

    if (path.includes('/auth/login') && httpMethod === 'POST') {
      return await handleLogin(data);
    }

    if (path.includes('/auth/register') && httpMethod === 'POST') {
      return await handleRegister(data);
    }

    return {
      statusCode: 404,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Endpoint não encontrado' })
    };

  } catch (error) {
    console.error('Auth Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro interno do servidor' })
    };
  }
};

async function handleLogin({ email, password }) {
  if (!email || !password) {
    return {
      statusCode: 400,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Email e senha são obrigatórios' })
    };
  }

  try {
    const result = await dynamodb.query({
      TableName: process.env.USERS_TABLE,
      IndexName: 'email-index',
      KeyConditionExpression: 'email = :email',
      ExpressionAttributeValues: { ':email': email }
    }).promise();

    if (result.Items.length === 0) {
      return {
        statusCode: 401,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Credenciais inválidas' })
      };
    }

    const user = result.Items[0];
    const validPassword = await bcrypt.compare(password, user.password);

    if (!validPassword) {
      return {
        statusCode: 401,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Credenciais inválidas' })
      };
    }

    const token = jwt.sign({ userId: user.id, email: user.email }, JWT_SECRET, { expiresIn: '24h' });

    const { password: _, ...userWithoutPassword } = user;

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        token,
        user: userWithoutPassword,
        message: 'Login realizado com sucesso'
      })
    };

  } catch (error) {
    console.error('Login Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro no login' })
    };
  }
}

async function handleRegister({ email, password, name, businessName, phone }) {
  if (!email || !password || !name) {
    return {
      statusCode: 400,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Email, senha e nome são obrigatórios' })
    };
  }

  try {
    // Verificar se email já existe
    const existingUser = await dynamodb.query({
      TableName: process.env.USERS_TABLE,
      IndexName: 'email-index',
      KeyConditionExpression: 'email = :email',
      ExpressionAttributeValues: { ':email': email }
    }).promise();

    if (existingUser.Items.length > 0) {
      return {
        statusCode: 409,
        headers: corsHeaders,
        body: JSON.stringify({ success: false, message: 'Email já cadastrado' })
      };
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const userId = uuidv4();

    const user = {
      id: userId,
      email,
      password: hashedPassword,
      name,
      businessName: businessName || '',
      phone: phone || '',
      createdAt: new Date().toISOString(),
      isActive: true
    };

    await dynamodb.put({
      TableName: process.env.USERS_TABLE,
      Item: user
    }).promise();

    return {
      statusCode: 201,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        message: 'Usuário criado com sucesso'
      })
    };

  } catch (error) {
    console.error('Register Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ success: false, message: 'Erro no cadastro' })
    };
  }
}