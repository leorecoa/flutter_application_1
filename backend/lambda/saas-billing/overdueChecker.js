const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    console.log('Verificando clientes em atraso...');

    try {
        // Buscar todos os pagamentos pendentes
        const scanParams = {
            TableName: process.env.CLIENTS_TABLE,
            FilterExpression: 'tipo_dado = :tipo AND status_pagamento = :status',
            ExpressionAttributeValues: {
                ':tipo': 'pagamento',
                ':status': 'PENDENTE'
            }
        };

        const result = await dynamodb.scan(scanParams).promise();
        const pagamentosPendentes = result.Items;

        console.log(`Encontrados ${pagamentosPendentes.length} pagamentos pendentes`);

        const hoje = new Date();
        const clientesVencidos = [];
        const NotificationService = require('./notificationService');

        // Verificar cada pagamento
        for (const pagamento of pagamentosPendentes) {
            const vencimento = new Date(pagamento.vencimento);
            const diasAtraso = Math.floor((hoje - vencimento) / (1000 * 60 * 60 * 24));

            if (diasAtraso > 0) {
                // Atualizar status para VENCIDO
                await dynamodb.update({
                    TableName: process.env.CLIENTS_TABLE,
                    Key: {
                        empresa_id: pagamento.empresa_id,
                        tipo_dado: 'pagamento'
                    },
                    UpdateExpression: 'SET status_pagamento = :status, updated_at = :updated',
                    ExpressionAttributeValues: {
                        ':status': 'VENCIDO',
                        ':updated': new Date().toISOString()
                    }
                }).promise();

                clientesVencidos.push({
                    empresa_id: pagamento.empresa_id,
                    valor: pagamento.valor,
                    dias_atraso: diasAtraso
                });

                // Enviar notificação de atraso
                try {
                    await NotificationService.sendOverdueNotification(
                        pagamento.empresa_id,
                        pagamento.valor,
                        diasAtraso
                    );
                } catch (notificationError) {
                    console.error(`Erro ao enviar notificação para ${pagamento.empresa_id}:`, notificationError);
                }
            }
        }

        console.log(`${clientesVencidos.length} clientes marcados como vencidos`);

        return {
            statusCode: 200,
            body: JSON.stringify({
                success: true,
                message: 'Verificação de atraso concluída',
                clientes_vencidos: clientesVencidos.length,
                detalhes: clientesVencidos
            })
        };

    } catch (error) {
        console.error('Erro na verificação de atraso:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Erro na verificação de atraso' })
        };
    }
};