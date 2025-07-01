const { gerarQrCodePix } = require('./services/pixService');
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
                return await createPixPayment(body);
            case 'status':
                return await checkPixStatus(body);
            default:
                return {
                    statusCode: 400,
                    headers,
                    body: JSON.stringify({ error: 'Invalid endpoint' })
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
    const { nome, valor, cpf, email } = data;
    
    const pixData = formatPixPayload({ nome, valor, cpf, email });
    const resultado = await gerarQrCodePix(pixData);

    return {
        statusCode: 200,
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            paymentId: resultado.paymentId,
            status: 'pending',
            pixCode: resultado.copiaCola,
            pixQrCodeBase64: resultado.qrCodeBase64
        })
    };
}

async function checkPixStatus(data) {
    const { paymentId } = data;
    
    // Simular verificação de status
    const status = Math.random() > 0.7 ? 'approved' : 'pending';
    
    return {
        statusCode: 200,
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            paymentId,
            status
        })
    };
}