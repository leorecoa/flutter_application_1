const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'agendemais-secret-key';

const authMiddleware = (handler) => {
    return async (event) => {
        const headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,Authorization',
            'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
            'Content-Type': 'application/json'
        };

        if (event.httpMethod === 'OPTIONS') {
            return { statusCode: 200, headers };
        }

        try {
            const authHeader = event.headers.Authorization || event.headers.authorization;
            if (!authHeader) {
                return {
                    statusCode: 401,
                    headers,
                    body: JSON.stringify({
                        success: false,
                        message: 'Token necessário'
                    })
                };
            }

            const token = authHeader.replace('Bearer ', '');
            const decoded = jwt.verify(token, JWT_SECRET);
            
            event.user = {
                userId: decoded.userId,
                email: decoded.email
            };

            return await handler(event, headers);
            
        } catch (error) {
            return {
                statusCode: 401,
                headers,
                body: JSON.stringify({
                    success: false,
                    message: 'Token inválido'
                })
            };
        }
    };
};

module.exports = { authMiddleware };