const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const TABLE_NAME = process.env.PAGAMENTOS_TABLE;

exports.handler = async (event) => {
    const { httpMethod, pathParameters, body } = event;
    
    try {
        switch (httpMethod) {
            case 'GET':
                return await getPagamentos(event);
            case 'POST':
                return await createPagamento(JSON.parse(body));
            case 'PUT':
                return await updatePagamento(pathParameters.id, JSON.parse(body));
            default:
                return {
                    statusCode: 405,
                    headers: { 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({ message: 'Method not allowed' })
                };
        }
    } catch (error) {
        return {
            statusCode: 500,
            headers: { 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({ message: error.message })
        };
    }
};

async function getPagamentos(event) {
    const userId = event.requestContext.authorizer.claims.sub;
    
    const result = await dynamodb.query({
        TableName: TABLE_NAME,
        IndexName: 'GSI1',
        KeyConditionExpression: 'userId = :userId',
        ExpressionAttributeValues: {
            ':userId': userId
        }
    }).promise();
    
    return {
        statusCode: 200,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify(result.Items)
    };
}

async function createPagamento(pagamento) {
    const id = Date.now().toString();
    const item = {
        ...pagamento,
        id,
        createdAt: new Date().toISOString()
    };
    
    await dynamodb.put({
        TableName: TABLE_NAME,
        Item: item
    }).promise();
    
    return {
        statusCode: 201,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify(item)
    };
}

async function updatePagamento(id, pagamento) {
    const item = {
        ...pagamento,
        id,
        updatedAt: new Date().toISOString()
    };
    
    await dynamodb.put({
        TableName: TABLE_NAME,
        Item: item
    }).promise();
    
    return {
        statusCode: 200,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify(item)
    };
}