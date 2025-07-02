const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST,OPTIONS'
    };

    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers };
    }

    try {
        console.log('Webhook PIX recebido:', JSON.stringify(event.body));
        
        const webhookData = JSON.parse(event.body);
        
        // Validar estrutura do webhook (adaptar conforme provedor PIX)
        if (!webhookData.transaction_id || !webhookData.status) {
            return {
                statusCode: 400,
                headers,
                body: JSON.stringify({ error: 'Dados do webhook inválidos' })
            };
        }

        const { transaction_id, status, amount, paid_at } = webhookData;

        // Buscar transação no DynamoDB
        const scanParams = {
            TableName: process.env.CLIENTS_TABLE,
            FilterExpression: 'transaction_id = :tid AND tipo_dado = :tipo',
            ExpressionAttributeValues: {
                ':tid': transaction_id,
                ':tipo': 'pagamento'
            }
        };

        const result = await dynamodb.scan(scanParams).promise();
        
        if (result.Items.length === 0) {
            console.log(`Transação ${transaction_id} não encontrada`);
            return {
                statusCode: 404,
                headers,
                body: JSON.stringify({ error: 'Transação não encontrada' })
            };
        }

        const transaction = result.Items[0];

        // Atualizar status baseado no webhook
        let newStatus = 'PENDENTE';
        if (status === 'approved' || status === 'paid') {
            newStatus = 'PAGO';
        } else if (status === 'cancelled' || status === 'failed') {
            newStatus = 'CANCELADO';
        }

        // Atualizar no DynamoDB
        const updateParams = {
            TableName: process.env.CLIENTS_TABLE,
            Key: {
                empresa_id: transaction.empresa_id,
                tipo_dado: 'pagamento'
            },
            UpdateExpression: 'SET status_pagamento = :status, updated_at = :updated',
            ExpressionAttributeValues: {
                ':status': newStatus,
                ':updated': new Date().toISOString()
            }
        };

        if (newStatus === 'PAGO') {
            updateParams.UpdateExpression += ', data_ultimo_pagamento = :payment_date';
            updateParams.ExpressionAttributeValues[':payment_date'] = paid_at || new Date().toISOString();
        }

        await dynamodb.update(updateParams).promise();

        console.log(`Status da transação ${transaction_id} atualizado para ${newStatus}`);

        // Enviar notificação por email/WhatsApp
        if (newStatus === 'PAGO') {
            const NotificationService = require('./notificationService');
            await NotificationService.sendPaymentConfirmation(
                transaction.empresa_id, 
                amount || transaction.valor, 
                transaction_id
            );
        }

        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                success: true,
                message: 'Webhook processado com sucesso',
                transaction_id,
                new_status: newStatus
            })
        };

    } catch (error) {
        console.error('Erro no webhook PIX:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ error: 'Erro interno do servidor' })
        };
    }
};

