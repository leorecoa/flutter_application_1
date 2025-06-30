const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const TABLE_NAME = process.env.AGENDAMENTOS_TABLE;

exports.handler = async (event) => {
    const { httpMethod, pathParameters, body } = event;
    
    try {
        switch (httpMethod) {
            case 'GET':
                return await getAgendamentos();
            case 'POST':
                return await createAgendamento(JSON.parse(body));
            case 'PUT':
                return await updateAgendamento(pathParameters.id, JSON.parse(body));
            case 'DELETE':
                return await deleteAgendamento(pathParameters.id);
            default:
                return {
                    statusCode: 405,
                    body: JSON.stringify({ message: 'Method not allowed' })
                };
        }
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ message: error.message })
        };
    }
};

async function getAgendamentos() {
    const result = await dynamodb.scan({
        TableName: TABLE_NAME
    }).promise();
    
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify(result.Items)
    };
}

async function createAgendamento(agendamento) {
    const id = Date.now().toString();
    const item = {
        ...agendamento,
        id,
        createdAt: new Date().toISOString()
    };
    
    await dynamodb.put({
        TableName: TABLE_NAME,
        Item: item
    }).promise();
    
    return {
        statusCode: 201,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify(item)
    };
}

async function updateAgendamento(id, agendamento) {
    const item = {
        ...agendamento,
        id,
        updatedAt: new Date().toISOString()
    };
    
    await dynamodb.put({
        TableName: TABLE_NAME,
        Item: item
    }).promise();
    
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify(item)
    };
}

async function deleteAgendamento(id) {
    await dynamodb.delete({
        TableName: TABLE_NAME,
        Key: { id }
    }).promise();
    
    return {
        statusCode: 204,
        headers: {
            'Access-Control-Allow-Origin': '*'
        }
    };
}