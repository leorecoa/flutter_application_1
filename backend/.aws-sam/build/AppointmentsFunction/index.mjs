import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand, UpdateCommand, QueryCommand, GetCommand } from "@aws-sdk/lib-dynamodb";
import { v4 as uuidv4 } from 'uuid';

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.MAIN_TABLE;

export const handler = async (event) => {
    const { httpMethod, pathParameters, queryStringParameters, body } = event;
    const cognitoSub = event.requestContext?.authorizer?.jwt?.claims?.sub || 'mock-user-123';

    const corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
    };

    if (httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers: corsHeaders };
    }

    try {
        let result;
        
        switch (httpMethod) {
            case 'POST':
                result = await createAppointment(cognitoSub, JSON.parse(body || '{}'));
                break;
            case 'GET':
                result = await getAppointments(cognitoSub, queryStringParameters);
                break;
            case 'PUT':
                const appointmentId = pathParameters?.id;
                result = await updateAppointmentStatus(cognitoSub, appointmentId, JSON.parse(body || '{}'));
                break;
            default:
                result = { statusCode: 404, body: JSON.stringify({ message: "Not Found" }) };
        }

        return {
            ...result,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers: corsHeaders,
            body: JSON.stringify({ success: false, message: "Internal Server Error" })
        };
    }
};

const createAppointment = async (clientId, data) => {
    if (!data.professionalId || !data.serviceId || !data.appointmentDateTime) {
        return { 
            statusCode: 400, 
            body: JSON.stringify({ success: false, message: "Missing required fields" }) 
        };
    }

    const appointmentId = uuidv4();
    const now = new Date().toISOString();
    
    const item = {
        PK: `USER#${clientId}`,
        SK: `APPOINTMENT#${appointmentId}`,
        entityType: "APPOINTMENT",
        appointmentId,
        clientId,
        professionalId: data.professionalId,
        serviceId: data.serviceId,
        appointmentDateTime: data.appointmentDateTime,
        status: "pendente",
        GSI1PK: data.professionalId,
        GSI1SK: data.appointmentDateTime,
        GSI2PK: "pendente",
        GSI2SK: data.appointmentDateTime,
        clientName: data.clientName || '',
        clientPhone: data.clientPhone || '',
        service: data.service || '',
        price: data.price || 0,
        notes: data.notes || '',
        createdAt: now,
        updatedAt: now
    };

    await docClient.send(new PutCommand({ TableName: TABLE_NAME, Item: item }));

    return { 
        statusCode: 201, 
        body: JSON.stringify({ success: true, data: item }) 
    };
};

const getAppointments = async (clientId, filters) => {
    const params = {
        TableName: TABLE_NAME,
        KeyConditionExpression: "PK = :pk and begins_with(SK, :sk)",
        ExpressionAttributeValues: {
            ":pk": `USER#${clientId}`,
            ":sk": "APPOINTMENT#"
        }
    };

    if (filters?.status) {
        params.FilterExpression = "#status = :status";
        params.ExpressionAttributeNames = { "#status": "status" };
        params.ExpressionAttributeValues[":status"] = filters.status;
    }

    const { Items } = await docClient.send(new QueryCommand(params));

    return { 
        statusCode: 200, 
        body: JSON.stringify({ success: true, data: Items || [] }) 
    };
};

const updateAppointmentStatus = async (cognitoSub, appointmentId, data) => {
    if (!appointmentId || !data.status) {
        return { 
            statusCode: 400, 
            body: JSON.stringify({ success: false, message: "Missing appointmentId or status" }) 
        };
    }

    const validStatuses = ["pendente", "confirmado", "cancelado", "concluido"];
    if (!validStatuses.includes(data.status)) {
        return { 
            statusCode: 400, 
            body: JSON.stringify({ success: false, message: "Invalid status" }) 
        };
    }

    // Buscar o item primeiro para validar permissões
    const getParams = {
        TableName: TABLE_NAME,
        Key: { PK: `USER#${cognitoSub}`, SK: `APPOINTMENT#${appointmentId}` }
    };

    const { Item } = await docClient.send(new GetCommand(getParams));
    
    if (!Item) {
        return { 
            statusCode: 404, 
            body: JSON.stringify({ success: false, message: "Appointment not found" }) 
        };
    }

    const now = new Date().toISOString();
    const updateParams = {
        TableName: TABLE_NAME,
        Key: { PK: `USER#${cognitoSub}`, SK: `APPOINTMENT#${appointmentId}` },
        UpdateExpression: "set #status = :status, GSI2PK = :status, updatedAt = :updatedAt",
        ExpressionAttributeNames: { "#status": "status" },
        ExpressionAttributeValues: { 
            ":status": data.status, 
            ":updatedAt": now 
        },
        ReturnValues: "ALL_NEW"
    };

    const result = await docClient.send(new UpdateCommand(updateParams));

    return { 
        statusCode: 200, 
        body: JSON.stringify({ success: true, data: result.Attributes }) 
    };
};