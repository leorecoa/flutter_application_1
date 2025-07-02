const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const ssm = new AWS.SSM();

exports.handler = async (event) => {
    console.log('Iniciando cobrança recorrente mensal...');

    try {
        // Buscar todos os clientes ativos
        const scanParams = {
            TableName: process.env.CLIENTS_TABLE,
            FilterExpression: 'tipo_dado = :tipo AND (status_pagamento = :pago OR status_pagamento = :vencido)',
            ExpressionAttributeValues: {
                ':tipo': 'pagamento',
                ':pago': 'PAGO',
                ':vencido': 'VENCIDO'
            }
        };

        const result = await dynamodb.scan(scanParams).promise();
        const clientesAtivos = result.Items;

        console.log(`Encontrados ${clientesAtivos.length} clientes para cobrança`);

        // Buscar chave PIX
        const pixKeyParam = await ssm.getParameter({
            Name: process.env.PIX_KEY_PARAM,
            WithDecryption: true
        }).promise();

        const pixKey = pixKeyParam.Parameter.Value;
        const processedClients = [];

        // Processar cada cliente
        for (const cliente of clientesAtivos) {
            try {
                const novoVencimento = new Date();
                novoVencimento.setMonth(novoVencimento.getMonth() + 1);

                // Gerar nova cobrança
                const transactionId = require('uuid').v4().replace(/-/g, '').substring(0, 25);
                
                const pixCode = generatePixEMV({
                    pixKey,
                    valor: cliente.valor,
                    descricao: `Mensalidade ${new Date().toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' })}`,
                    transactionId
                });

                // Atualizar registro existente
                await dynamodb.update({
                    TableName: process.env.CLIENTS_TABLE,
                    Key: {
                        empresa_id: cliente.empresa_id,
                        tipo_dado: 'pagamento'
                    },
                    UpdateExpression: 'SET transaction_id = :tid, status_pagamento = :status, vencimento = :venc, pix_code = :pix, updated_at = :updated',
                    ExpressionAttributeValues: {
                        ':tid': transactionId,
                        ':status': 'PENDENTE',
                        ':venc': novoVencimento.toISOString().split('T')[0],
                        ':pix': pixCode,
                        ':updated': new Date().toISOString()
                    }
                }).promise();

                processedClients.push({
                    empresa_id: cliente.empresa_id,
                    novo_vencimento: novoVencimento.toISOString().split('T')[0],
                    valor: cliente.valor
                });

            } catch (clientError) {
                console.error(`Erro ao processar cliente ${cliente.empresa_id}:`, clientError);
            }
        }

        console.log(`Cobrança recorrente concluída. ${processedClients.length} clientes processados.`);

        return {
            statusCode: 200,
            body: JSON.stringify({
                success: true,
                message: 'Cobrança recorrente executada com sucesso',
                clientes_processados: processedClients.length,
                detalhes: processedClients
            })
        };

    } catch (error) {
        console.error('Erro na cobrança recorrente:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Erro na cobrança recorrente' })
        };
    }
};

function generatePixEMV({ pixKey, valor, descricao, transactionId }) {
    let payload = '';
    
    payload += '000201';
    payload += '010212';
    
    const pixKeyLength = pixKey.length.toString().padStart(2, '0');
    const merchantInfo = `0014BR.GOV.BCB.PIX01${pixKeyLength}${pixKey}`;
    const merchantInfoLength = merchantInfo.length.toString().padStart(2, '0');
    payload += `26${merchantInfoLength}${merchantInfo}`;
    
    payload += '52040000';
    payload += '5303986';
    
    const amount = valor.toFixed(2);
    const amountLength = amount.length.toString().padStart(2, '0');
    payload += `54${amountLength}${amount}`;
    
    payload += '5802BR';
    
    const merchantName = 'AGENDAFACIL SAAS';
    const merchantNameLength = merchantName.length.toString().padStart(2, '0');
    payload += `59${merchantNameLength}${merchantName}`;
    
    const merchantCity = 'SAO PAULO';
    const merchantCityLength = merchantCity.length.toString().padStart(2, '0');
    payload += `60${merchantCityLength}${merchantCity}`;
    
    const txidLength = transactionId.length.toString().padStart(2, '0');
    const additionalData = `05${txidLength}${transactionId}`;
    const additionalDataLength = additionalData.length.toString().padStart(2, '0');
    payload += `62${additionalDataLength}${additionalData}`;
    
    payload += '6304';
    const crc = calculateCRC16(payload);
    payload += crc;
    
    return payload;
}

function calculateCRC16(payload) {
    const polynomial = 0x1021;
    let crc = 0xFFFF;
    
    for (let i = 0; i < payload.length; i++) {
        crc ^= (payload.charCodeAt(i) << 8);
        for (let j = 0; j < 8; j++) {
            if (crc & 0x8000) {
                crc = (crc << 1) ^ polynomial;
            } else {
                crc <<= 1;
            }
            crc &= 0xFFFF;
        }
    }
    
    return crc.toString(16).toUpperCase().padStart(4, '0');
}