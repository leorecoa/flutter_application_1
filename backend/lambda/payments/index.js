const AWS = require('aws-sdk');
const axios = require('axios');

const secretsManager = new AWS.SecretsManager();
const dynamodb = new AWS.DynamoDB.DocumentClient();

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
        const { action } = event.pathParameters || {};
        const body = JSON.parse(event.body || '{}');

        switch (action) {
            case 'create-pix':
                return await createPixPayment(body);
            case 'check-status':
                return await checkPaymentStatus(body.paymentId);
            default:
                return {
                    statusCode: 400,
                    headers,
                    body: JSON.stringify({ error: 'Invalid action' })
                };
        }
    } catch (error) {
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ error: error.message })
        };
    }
};

async function createPixPayment(data) {
    const secrets = await getSecrets();
    
    const pixPayment = {
        transaction_amount: data.amount,
        description: data.description,
        payment_method_id: 'pix',
        payer: {
            email: data.email,
            first_name: data.name
        }
    };

    const response = await axios.post(
        'https://api.mercadopago.com/v1/payments',
        pixPayment,
        {
            headers: {
                'Authorization': `Bearer ${secrets.mercadopago_access_token}`,
                'Content-Type': 'application/json'
            }
        }
    );

    await dynamodb.put({
        TableName: process.env.MAIN_TABLE,
        Item: {
            PK: `PAYMENT#${response.data.id}`,
            SK: `TENANT#${data.tenantId}`,
            paymentId: response.data.id,
            tenantId: data.tenantId,
            amount: data.amount,
            status: response.data.status,
            pixCode: response.data.point_of_interaction?.transaction_data?.qr_code,
            pixQrCodeBase64: response.data.point_of_interaction?.transaction_data?.qr_code_base64,
            createdAt: new Date().toISOString()
        }
    }).promise();

    return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
            paymentId: response.data.id,
            status: response.data.status,
            pixCode: response.data.point_of_interaction?.transaction_data?.qr_code,
            pixQrCodeBase64: response.data.point_of_interaction?.transaction_data?.qr_code_base64
        })
    };
}

async function checkPaymentStatus(paymentId) {
    const secrets = await getSecrets();
    
    const response = await axios.get(
        `https://api.mercadopago.com/v1/payments/${paymentId}`,
        {
            headers: {
                'Authorization': `Bearer ${secrets.mercadopago_access_token}`
            }
        }
    );

    return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
            paymentId: response.data.id,
            status: response.data.status
        })
    };
}

async function getSecrets() {
    const result = await secretsManager.getSecretValue({
        SecretId: 'agendafacil/pix/keys'
    }).promise();
    
    return JSON.parse(result.SecretString);
}