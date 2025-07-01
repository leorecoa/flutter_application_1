const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

async function gerarQrCodePix(pixData) {
    const paymentId = `pix_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // Gerar código PIX simplificado (em produção usar API real)
    const pixCode = generatePixCode(pixData);
    const qrCodeBase64 = generateQRCodeBase64(pixCode);
    
    // Salvar no DynamoDB
    await dynamodb.put({
        TableName: process.env.MAIN_TABLE,
        Item: {
            PK: `PIX#${paymentId}`,
            SK: `TENANT#${pixData.tenantId || 'default'}`,
            paymentId,
            amount: pixData.valor,
            status: 'pending',
            pixCode,
            createdAt: new Date().toISOString()
        }
    }).promise();

    return {
        paymentId,
        copiaCola: pixCode,
        qrCodeBase64
    };
}

function generatePixCode(data) {
    // Código PIX simplificado para demonstração
    const pixKey = process.env.PIX_KEY || 'agendafacil@pix.com';
    return `00020126580014BR.GOV.BCB.PIX0136${pixKey}52040000530398654${String(data.valor).padStart(2, '0')}5802BR5925AGENDA FACIL LTDA6009SAO PAULO62070503***6304`;
}

function generateQRCodeBase64(pixCode) {
    // Em produção, usar biblioteca real de QR Code
    // Por enquanto, retornar um placeholder base64
    return 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
}

module.exports = { gerarQrCodePix };