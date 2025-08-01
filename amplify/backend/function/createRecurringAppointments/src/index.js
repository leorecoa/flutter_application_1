/* Amplify Params - DO NOT EDIT
	API_AGENDEMAIS_GRAPHQLAPIENDPOINTOUTPUT
	API_AGENDEMAIS_GRAPHQLAPIIDOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

const AWS = require('aws-sdk');
const https = require('https');
const urlParse = require('url').URL;
const region = process.env.REGION;
const endpoint = new urlParse(process.env.API_AGENDEMAIS_GRAPHQLAPIENDPOINTOUTPUT).hostname.toString();

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {
    console.log(`EVENT: ${JSON.stringify(event)}`);
    
    // Get input parameters
    const appointments = event.arguments.appointments;
    
    // Validate input
    if (!appointments || !Array.isArray(appointments) || appointments.length === 0) {
        return {
            statusCode: 400,
            body: JSON.stringify({
                message: 'Missing or invalid appointments array'
            }),
        };
    }
    
    try {
        // Validate each appointment
        for (const appointment of appointments) {
            if (!appointment.clientId || !appointment.serviceId || !appointment.userId || 
                !appointment.tenantId || !appointment.date || !appointment.startTime || 
                !appointment.endTime || !appointment.status) {
                throw new Error('Missing required fields in appointment');
            }
        }
        
        // Create appointments in batches to avoid hitting API limits
        const batchSize = 25; // DynamoDB batch write limit is 25 items
        const createdAppointments = [];
        
        for (let i = 0; i < appointments.length; i += batchSize) {
            const batch = appointments.slice(i, i + batchSize);
            const batchResults = await createAppointmentsBatch(batch);
            createdAppointments.push(...batchResults);
        }
        
        return createdAppointments;
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Error creating recurring appointments',
                error: error.message
            }),
        };
    }
};

/**
 * Create a batch of appointments
 */
async function createAppointmentsBatch(appointments) {
    const createdAppointments = [];
    
    for (const appointment of appointments) {
        try {
            const createdAppointment = await createAppointment(appointment);
            createdAppointments.push(createdAppointment);
        } catch (error) {
            console.error(`Error creating appointment: ${error.message}`);
            // Continue with the next appointment even if one fails
        }
    }
    
    return createdAppointments;
}

/**
 * Create a single appointment
 */
async function createAppointment(appointment) {
    const mutation = /* GraphQL */ `
        mutation CreateAppointment($input: CreateAppointmentInput!) {
            createAppointment(input: $input) {
                id
                clientId
                clientName
                serviceId
                serviceName
                servicePrice
                userId
                tenantId
                date
                startTime
                endTime
                status
                notes
                paymentStatus
                paymentMethod
                paymentAmount
                paymentDate
                createdAt
                updatedAt
            }
        }
    `;
    
    // Generate a unique ID for the appointment if not provided
    if (!appointment.id) {
        appointment.id = generateId();
    }
    
    const variables = { input: appointment };
    const response = await executeGraphQLMutation(mutation, variables);
    return response.data.createAppointment;
}

/**
 * Generate a unique ID
 */
function generateId() {
    return 'appt_' + Date.now().toString(36) + Math.random().toString(36).substr(2, 5);
}

/**
 * Execute a GraphQL mutation against AppSync
 */
async function executeGraphQLMutation(mutation, variables) {
    const req = new AWS.HttpRequest(endpoint, region);
    req.method = 'POST';
    req.path = '/graphql';
    req.headers.host = endpoint;
    req.headers['Content-Type'] = 'application/json';
    req.body = JSON.stringify({
        query: mutation,
        variables
    });
    
    const signer = new AWS.Signers.V4(req, 'appsync', true);
    signer.addAuthorization(AWS.config.credentials, AWS.util.date.getDate());
    
    return new Promise((resolve, reject) => {
        const httpRequest = https.request({ ...req, host: endpoint }, (result) => {
            let data = '';
            result.on('data', (chunk) => {
                data += chunk;
            });
            result.on('end', () => {
                const parsedData = JSON.parse(data.toString());
                if (parsedData.errors) {
                    reject(new Error(parsedData.errors[0].message));
                } else {
                    resolve(parsedData);
                }
            });
        });
        
        httpRequest.on('error', (error) => {
            reject(error);
        });
        
        httpRequest.write(req.body);
        httpRequest.end();
    });
}