const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'PUT,OPTIONS'
    };

    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers };
    }

    try {
        const { empresa_id, transaction_id, status } = JSON.parse(event.body);

        if (!empresa_id || !transaction_id || !status) {
            return {
                statusCode: 400,
                headers,
                body: JSON.stringify({ error: 'Parâmetros obrigatórios: empresa_id, transaction_id, status' })
            };
        }

        const validStatuses = ['PENDENTE', 'PAGO', 'VENCIDO', 'CANCELADO'];
        if (!validStatuses.includes(status)) {
            return {
                statusCode: 400,
                headers,
                body: JSON.stringify({ error: 'Status inválido. Use: PENDENTE, PAGO, VENCIDO, CANCELADO' })
            };
        }

        // Atualizar status no DynamoDB
        const updateParams = {
            TableName: process.env.CLIENTS_TABLE,
            Key: {
                empresa_id,
                tipo_dado: 'pagamento'
            },
            UpdateExpression: 'SET status_pagamento = :status, updated_at = :updated_at',
            ConditionExpression: 'transaction_id = :transaction_id',
            ExpressionAttributeValues: {
                ':status': status,
                ':transaction_id': transaction_id,
                ':updated_at': new Date().toISOString()
            }
        };

        if (status === 'PAGO') {
            updateParams.UpdateExpression += ', data_ultimo_pagamento = :payment_date';
            updateParams.ExpressionAttributeValues[':payment_date'] = new Date().toISOString();
        }

        await dynamodb.update(updateParams).promise();

        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                success: true,
                message: `Status atualizado para ${status}`,
                empresa_id,
                transaction_id
            })
        };

    } catch (error) {
        console.error('Erro:', error);
        
        if (error.code === 'ConditionalCheckFailedException') {
            return {
                statusCode: 404,
                headers,
                body: JSON.stringify({ error: 'Transação não encontrada' })
            };
        }

        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ error: 'Erro interno do servidor' })
        };
    }
};