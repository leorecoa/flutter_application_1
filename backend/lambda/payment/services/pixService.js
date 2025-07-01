const AWS = require('aws-sdk');
const QRCode = require('qrcode');
const { v4: uuidv4 } = require('uuid');

const dynamodb = new AWS.DynamoDB.DocumentClient();

async function gerarQrCodePix(pixData) {
    const txid = uuidv4().replace(/-/g, '').substring(0, 25);
    const paymentId = `pix_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // Gerar código PIX EMV
    const pixCode = generatePixEMV(pixData, txid);
    
    // Gerar QR Code Base64
    const qrCodeBase64 = await QRCode.toDataURL(pixCode, {
        errorCorrectionLevel: 'M',
        type: 'image/png',
        quality: 0.92,
        margin: 1,
        color: {
            dark: '#000000',
            light: '#FFFFFF'
        }
    });

    // Salvar no DynamoDB
    await dynamodb.put({
        TableName: process.env.MAIN_TABLE,
        Item: {
            PK: `PIX#${paymentId}`,
            SK: `TENANT#${pixData.tenantId}`,
            paymentId,
            txid,
            amount: pixData.valor,
            status: 'pending',
            pixCode,
            customerName: pixData.nome,
            customerEmail: pixData.email,
            description: pixData.description || 'Pagamento AgendaFácil',
            createdAt: new Date().toISOString(),
            expiresAt: new Date(Date.now() + 30 * 60 * 1000).toISOString() // 30 min
        }
    }).promise();

    return {
        paymentId,
        txid,
        copiaCola: pixCode,
        qrCodeBase64: qrCodeBase64.split(',')[1] // Remove data:image/png;base64,
    };
}

async function verificarStatusPix(paymentId) {
    try {
        const result = await dynamodb.get({
            TableName: process.env.MAIN_TABLE,
            Key: {
                PK: `PIX#${paymentId}`,
                SK: { S: `TENANT#default` }
            }
        }).promise();

        if (!result.Item) {
            return 'not_found';
        }

        // Simular aprovação aleatória para demonstração
        if (result.Item.status === 'pending' && Math.random() > 0.8) {
            await dynamodb.update({
                TableName: process.env.MAIN_TABLE,
                Key: {
                    PK: `PIX#${paymentId}`,
                    SK: `TENANT#default`
                },
                UpdateExpression: 'SET #status = :status, paidAt = :paidAt',
                ExpressionAttributeNames: {
                    '#status': 'status'
                },
                ExpressionAttributeValues: {
                    ':status': 'approved',
                    ':paidAt': new Date().toISOString()
                }
            }).promise();

            return 'approved';
        }

        return result.Item.status;
    } catch (error) {
        console.error('Error checking PIX status:', error);
        return 'error';
    }
}

function generatePixEMV(data, txid) {
    const pixKey = process.env.PIX_KEY || 'agendafacil@pix.com.br';
    const merchantName = 'AGENDA FACIL LTDA';
    const merchantCity = 'SAO PAULO';
    const amount = data.valor.toFixed(2);
    
    // Construir payload EMV PIX
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
    const amountLength = amount.length.toString().padStart(2, '0');
    payload += `54${amountLength}${amount}`;
    
    // Country Code
    payload += '5802BR';
    
    // Merchant Name
    const merchantNameLength = merchantName.length.toString().padStart(2, '0');
    payload += `59${merchantNameLength}${merchantName}`;
    
    // Merchant City
    const merchantCityLength = merchantCity.length.toString().padStart(2, '0');
    payload += `60${merchantCityLength}${merchantCity}`;
    
    // Additional Data Field Template
    const txidLength = txid.length.toString().padStart(2, '0');
    const additionalData = `05${txidLength}${txid}`;
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

module.exports = { gerarQrCodePix, verificarStatusPix };