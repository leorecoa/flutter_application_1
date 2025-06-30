const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const TABLE_NAME = process.env.CLIENTES_TABLE;

exports.handler = async (event) => {
    const { httpMethod, pathParameters, body } = event;
    
    try {
        switch (httpMethod) {
            case 'GET':
                return await getClientes(event);
            case 'POST':
                return await createCliente(JSON.parse(body));
            case 'PUT':
                return await updateCliente(pathParameters.id, JSON.parse(body));
            case 'DELETE':
                return await deleteCliente(pathParameters.id);
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

async function getClientes(event) {
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

async function createCliente(cliente) {
    const id = Date.now().toString();
    const item = {
        ...cliente,
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

async function updateCliente(id, cliente) {
    const item = {
        ...cliente,
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

async function deleteCliente(id) {
    await dynamodb.delete({
        TableName: TABLE_NAME,
        Key: { id }
    }).promise();
    
    return {
        statusCode: 204,
        headers: { 'Access-Control-Allow-Origin': '*' }
    };
}