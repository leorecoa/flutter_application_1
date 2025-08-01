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
    const appointmentId = event.arguments.appointmentId;
    const method = event.arguments.method;
    const amount = event.arguments.amount;
    
    // Validate input
    if (!appointmentId || !method || !amount) {
        return {
            statusCode: 400,
            body: JSON.stringify({
                message: 'Missing required parameters: appointmentId, method, amount'
            }),
        };
    }
    
    try {
        // 1. Get the appointment
        const appointment = await getAppointment(appointmentId);
        if (!appointment) {
            throw new Error(`Appointment not found: ${appointmentId}`);
        }
        
        // 2. Process the payment (in a real implementation, this would integrate with a payment gateway)
        const paymentResult = await processPaymentWithGateway(appointment, method, amount);
        
        // 3. Create a payment record
        const payment = await createPayment({
            appointmentId,
            tenantId: appointment.tenantId,
            amount,
            method,
            status: paymentResult.success ? 'PAID' : 'FAILED',
            transactionId: paymentResult.transactionId,
            pixCode: method === 'PIX' ? paymentResult.pixCode : null,
            receiptUrl: paymentResult.receiptUrl
        });
        
        // 4. Update the appointment with payment information
        if (paymentResult.success) {
            await updateAppointmentPayment(appointmentId, {
                paymentStatus: 'PAID',
                paymentMethod: method,
                paymentAmount: amount,
                paymentDate: new Date().toISOString()
            });
        }
        
        return payment;
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Error processing payment',
                error: error.message
            }),
        };
    }
};

/**
 * Get appointment by ID
 */
async function getAppointment(appointmentId) {
    const query = /* GraphQL */ `
        query GetAppointment($id: ID!) {
            getAppointment(id: $id) {
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
                paymentStatus
            }
        }
    `;
    
    const variables = { id: appointmentId };
    const response = await executeGraphQLQuery(query, variables);
    return response.data.getAppointment;
}

/**
 * Process payment with payment gateway
 * Note: This is a mock implementation. In a real app, this would integrate with a payment gateway API.
 */
async function processPaymentWithGateway(appointment, method, amount) {
    // Simulate payment processing delay
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Generate a mock transaction ID
    const transactionId = 'txn_' + Date.now().toString(36) + Math.random().toString(36).substr(2, 5);
    
    // Mock implementation for different payment methods
    switch (method.toUpperCase()) {
        case 'PIX':
            // Generate a mock PIX code
            const pixCode = generateMockPixCode();
            return {
                success: true,
                transactionId,
                pixCode,
                receiptUrl: null // PIX receipt would be generated after payment confirmation
            };
            
        case 'CREDIT_CARD':
            // In a real implementation, this would process a credit card payment
            return {
                success: true,
                transactionId,
                pixCode: null,
                receiptUrl: `https://receipts.example.com/${transactionId}.pdf`
            };
            
        case 'CASH':
            // Cash payments are always successful
            return {
                success: true,
                transactionId,
                pixCode: null,
                receiptUrl: null
            };
            
        default:
            throw new Error(`Unsupported payment method: ${method}`);
    }
}

/**
 * Generate a mock PIX code
 */
function generateMockPixCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let result = '';
    for (let i = 0; i < 32; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
}

/**
 * Create a payment record
 */
async function createPayment(payment) {
    const mutation = /* GraphQL */ `
        mutation CreatePayment($input: CreatePaymentInput!) {
            createPayment(input: $input) {
                id
                appointmentId
                tenantId
                amount
                method
                status
                transactionId
                pixCode
                receiptUrl
                createdAt
                updatedAt
            }
        }
    `;
    
    // Generate a unique ID for the payment
    payment.id = 'pay_' + Date.now().toString(36) + Math.random().toString(36).substr(2, 5);
    
    const variables = { input: payment };
    const response = await executeGraphQLMutation(mutation, variables);
    return response.data.createPayment;
}

/**
 * Update appointment with payment information
 */
async function updateAppointmentPayment(appointmentId, paymentInfo) {
    const mutation = /* GraphQL */ `
        mutation UpdateAppointment($input: UpdateAppointmentInput!) {
            updateAppointment(input: $input) {
                id
                paymentStatus
                paymentMethod
                paymentAmount
                paymentDate
                updatedAt
            }
        }
    `;
    
    const variables = {
        input: {
            id: appointmentId,
            ...paymentInfo
        }
    };
    
    const response = await executeGraphQLMutation(mutation, variables);
    return response.data.updateAppointment;
}

/**
 * Execute a GraphQL query against AppSync
 */
async function executeGraphQLQuery(query, variables) {
    const req = new AWS.HttpRequest(endpoint, region);
    req.method = 'POST';
    req.path = '/graphql';
    req.headers.host = endpoint;
    req.headers['Content-Type'] = 'application/json';
    req.body = JSON.stringify({
        query,
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
                resolve(JSON.parse(data.toString()));
            });
        });
        
        httpRequest.on('error', (error) => {
            reject(error);
        });
        
        httpRequest.write(req.body);
        httpRequest.end();
    });
}

/**
 * Execute a GraphQL mutation against AppSync
 */
async function executeGraphQLMutation(mutation, variables) {
    return executeGraphQLQuery(mutation, variables);
}