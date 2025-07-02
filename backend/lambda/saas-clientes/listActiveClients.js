const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET,OPTIONS'
    };

    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers };
    }

    try {
        const { status_filter = 'TODOS' } = event.queryStringParameters || {};

        // Buscar todos os pagamentos
        const scanParams = {
            TableName: process.env.CLIENTS_TABLE,
            FilterExpression: 'tipo_dado = :tipo',
            ExpressionAttributeValues: {
                ':tipo': 'pagamento'
            }
        };

        // Filtrar por status se especificado
        if (status_filter !== 'TODOS') {
            scanParams.FilterExpression += ' AND status_pagamento = :status';
            scanParams.ExpressionAttributeValues[':status'] = status_filter;
        }

        const result = await dynamodb.scan(scanParams).promise();

        // Processar dados para resposta
        const clientes = result.Items.map(item => ({
            empresa_id: item.empresa_id,
            status_pagamento: item.status_pagamento,
            valor: item.valor,
            vencimento: item.vencimento,
            descricao: item.descricao,
            data_ultimo_pagamento: item.data_ultimo_pagamento || null,
            dias_ate_vencimento: calculateDaysUntilDue(item.vencimento)
        }));

        // Estatísticas
        const stats = {
            total_clientes: clientes.length,
            pagos: clientes.filter(c => c.status_pagamento === 'PAGO').length,
            pendentes: clientes.filter(c => c.status_pagamento === 'PENDENTE').length,
            vencidos: clientes.filter(c => c.status_pagamento === 'VENCIDO').length,
            receita_mensal: clientes
                .filter(c => c.status_pagamento === 'PAGO')
                .reduce((sum, c) => sum + c.valor, 0)
        };

        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                success: true,
                clientes,
                estatisticas: stats,
                filtro_aplicado: status_filter
            })
        };

    } catch (error) {
        console.error('Erro:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ error: 'Erro interno do servidor' })
        };
    }
};

function calculateDaysUntilDue(vencimento) {
    const today = new Date();
    const dueDate = new Date(vencimento);
    const diffTime = dueDate - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
}