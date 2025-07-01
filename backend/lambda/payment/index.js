const { gerarQrCodePix, verificarStatusPix } = require('./services/pixService');
const { formatPixPayload } = require('./utils/formatPixPayload');

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
        const { proxy } = event.pathParameters || {};
        const body = JSON.parse(event.body || '{}');

        switch (proxy) {
            case 'create':
                return await createPixPayment(body, headers);
            case 'status':
                return await checkPixStatus(body, headers);
            default:
                return {
                    statusCode: 400,
                    headers,
                    body: JSON.stringify({ error: 'Invalid endpoint' })
                };
        }
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ error: error.message })
        };
    }
};

async function createPixPayment(data, headers) {
    const pixData = formatPixPayload(data);
    const resultado = await gerarQrCodePix(pixData);

    return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
            paymentId: resultado.paymentId,
            status: 'pending',
            pixCode: resultado.copiaCola,
            pixQrCodeBase64: resultado.qrCodeBase64
        })
    };
}

async function checkPixStatus(data, headers) {
    const { paymentId } = data;
    const status = await verificarStatusPix(paymentId);
    
    return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
            paymentId,
            status
        })
    };
}