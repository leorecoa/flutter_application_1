const AWS = require('aws-sdk');
const QRCode = require('qrcode');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();
const ssm = new AWS.SSM();

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
        const { empresa_id, valor, descricao } = JSON.parse(event.body);

        if (!empresa_id || !valor || !descricao) {
            return {
                statusCode: 400,
                headers,
                body: JSON.stringify({ error: 'Parâmetros obrigatórios: empresa_id, valor, descricao' })
            };
        }

        // Buscar chave PIX do SSM
        const pixKeyParam = await ssm.getParameter({
            Name: process.env.PIX_KEY_PARAM,
            WithDecryption: true
        }).promise();

        const pixKey = pixKeyParam.Parameter.Value;
        const transactionId = uuidv4().replace(/-/g, '').substring(0, 25);

        // Gerar código PIX EMV
        const pixCode = generatePixEMV({
            pixKey,
            valor: parseFloat(valor),
            descricao,
            transactionId
        });

        // Gerar QR Code
        const qrCodeBase64 = await QRCode.toDataURL(pixCode, {
            errorCorrectionLevel: 'M',
            width: 256
        });

        // Salvar no DynamoDB
        const vencimento = new Date();
        vencimento.setMonth(vencimento.getMonth() + 1);

        await dynamodb.put({
            TableName: process.env.CLIENTS_TABLE,
            Item: {
                empresa_id,
                tipo_dado: 'pagamento',
                transaction_id: transactionId,
                valor: parseFloat(valor),
                descricao,
                status_pagamento: 'PENDENTE',
                vencimento: vencimento.toISOString().split('T')[0],
                pix_code: pixCode,
                created_at: new Date().toISOString()
            }
        }).promise();

        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                success: true,
                transaction_id: transactionId,
                pix_code: pixCode,
                qr_code_base64: qrCodeBase64.split(',')[1],
                valor,
                vencimento: vencimento.toISOString().split('T')[0]
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

function generatePixEMV({ pixKey, valor, descricao, transactionId }) {
    let payload = '';
    
    // Payload Format Indicator
    payload += '000201';
    
    // Point of Initiation Method
    payload += '010212';
    
    // Merchant Account Information
    const pixKeyLength = pixKey.length.toString().padStart(2, '0');
    const merchantInfo = `0014BR.GOV.BCB.PIX01${pixKeyLength}${pixKey}`;
    const merchantInfoLength = merchantInfo.length.toString().padStart(2, '0');
    payload += `26${merchantInfoLength}${merchantInfo}`;
    
    // Merchant Category Code
    payload += '52040000';
    
    // Transaction Currency
    payload += '5303986';
    
    // Transaction Amount
    const amount = valor.toFixed(2);
    const amountLength = amount.length.toString().padStart(2, '0');
    payload += `54${amountLength}${amount}`;
    
    // Country Code
    payload += '5802BR';
    
    // Merchant Name
    const merchantName = 'AGENDAFACIL SAAS';
    const merchantNameLength = merchantName.length.toString().padStart(2, '0');
    payload += `59${merchantNameLength}${merchantName}`;
    
    // Merchant City
    const merchantCity = 'SAO PAULO';
    const merchantCityLength = merchantCity.length.toString().padStart(2, '0');
    payload += `60${merchantCityLength}${merchantCity}`;
    
    // Additional Data Field Template
    const txidLength = transactionId.length.toString().padStart(2, '0');
    const additionalData = `05${txidLength}${transactionId}`;
    const additionalDataLength = additionalData.length.toString().padStart(2, '0');
    payload += `62${additionalDataLength}${additionalData}`;
    
    // CRC16
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