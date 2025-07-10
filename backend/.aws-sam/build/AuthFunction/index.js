const AWS = require('aws-sdk');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const JWT_SECRET = process.env.JWT_SECRET || 'agendemais-secret-key';

exports.handler = async (event) => {
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
    };

    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers };
    }

    try {
        const { httpMethod, path } = event;
        const body = JSON.parse(event.body || '{}');

        if (path.includes('/auth/login')) {
            return await login(body);
        } else if (path.includes('/auth/register')) {
            return await register(body);
        }

        return {
            statusCode: 404,
            headers,
            body: JSON.stringify({ success: false, message: 'Endpoint não encontrado' })
        };
    } catch (error) {
        console.error('Erro na função auth:', error);
        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ 
                success: false, 
                message: error.message || 'Erro interno do servidor'
            })
        };
    }
};

async function login({ email, password }) {
    const params = {
        TableName: process.env.USERS_TABLE,
        IndexName: 'email-index',
        KeyConditionExpression: 'email = :email',
        ExpressionAttributeValues: { ':email': email }
    };

    const result = await dynamodb.query(params).promise();
    
    if (result.Items.length === 0) {
        throw new Error('Usuário não encontrado');
    }

    const user = result.Items[0];
    const validPassword = await bcrypt.compare(password, user.password);
    
    if (!validPassword) {
        throw new Error('Senha incorreta');
    }

    const token = jwt.sign({ userId: user.id, email: user.email }, JWT_SECRET, { expiresIn: '24h' });

    return {
        statusCode: 200,
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,Authorization',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            success: true,
            token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email
            }
        })
    };
}

async function register({ name, email, password }) {
    const hashedPassword = await bcrypt.hash(password, 10);
    const userId = uuidv4();

    const params = {
        TableName: process.env.USERS_TABLE,
        Item: {
            id: userId,
            name,
            email,
            password: hashedPassword,
            createdAt: new Date().toISOString()
        }
    };

    await dynamodb.put(params).promise();

    const token = jwt.sign({ userId, email }, JWT_SECRET, { expiresIn: '24h' });

    return {
        statusCode: 201,
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,Authorization',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            success: true,
            token,
            user: { id: userId, name, email }
        })
    };
}