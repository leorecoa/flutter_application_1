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
    const tenantId = event.arguments.tenantId;
    const startDate = event.arguments.startDate;
    const endDate = event.arguments.endDate;
    const status = event.arguments.status;
    
    // Validate input
    if (!tenantId || !startDate || !endDate) {
        return {
            statusCode: 400,
            body: JSON.stringify({
                message: 'Missing required parameters: tenantId, startDate, endDate'
            }),
        };
    }
    
    try {
        // Build GraphQL query
        let query = /* GraphQL */ `
            query GetAppointmentsByDateRange(
                $tenantId: ID!
                $startDate: AWSDate!
                $endDate: AWSDate!
                $status: AppointmentStatus
                $limit: Int
                $nextToken: String
            ) {
                listAppointments(
                    filter: {
                        tenantId: { eq: $tenantId }
                        date: { between: [$startDate, $endDate] }
                        ${status ? 'status: { eq: $status }' : ''}
                    }
                    limit: $limit
                    nextToken: $nextToken
                ) {
                    items {
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
                    nextToken
                }
            }
        `;
        
        // Replace the status placeholder if status is not provided
        if (!status) {
            query = query.replace('${status ? \'status: { eq: $status }\' : \'\'}', '');
        }
        
        // Set up request parameters
        const req = new AWS.HttpRequest(endpoint, region);
        req.method = 'POST';
        req.path = '/graphql';
        req.headers.host = endpoint;
        req.headers['Content-Type'] = 'application/json';
        req.body = JSON.stringify({
            query,
            variables: {
                tenantId,
                startDate,
                endDate,
                status,
                limit: 100
            }
        });
        
        // Sign the request (IAM auth)
        const signer = new AWS.Signers.V4(req, 'appsync', true);
        signer.addAuthorization(AWS.config.credentials, AWS.util.date.getDate());
        
        // Send the request
        const data = await new Promise((resolve, reject) => {
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
        
        // Process and return the results
        if (data.errors) {
            console.error('GraphQL errors:', data.errors);
            return data.errors;
        }
        
        return data.data.listAppointments.items;
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Error fetching appointments',
                error: error.message
            }),
        };
    }
};