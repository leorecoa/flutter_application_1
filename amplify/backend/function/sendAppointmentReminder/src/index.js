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

// Initialize AWS services
const pinpoint = new AWS.Pinpoint({ region });
const ses = new AWS.SES({ region });

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event) => {
    console.log(`EVENT: ${JSON.stringify(event)}`);
    
    // Get input parameters
    const appointmentId = event.arguments.appointmentId;
    
    // Validate input
    if (!appointmentId) {
        return {
            statusCode: 400,
            body: JSON.stringify({
                message: 'Missing required parameter: appointmentId'
            }),
        };
    }
    
    try {
        // 1. Get the appointment with client details
        const appointment = await getAppointmentWithClient(appointmentId);
        if (!appointment) {
            throw new Error(`Appointment not found: ${appointmentId}`);
        }
        
        // 2. Get tenant settings for notification preferences
        const tenantSettings = await getTenantSettings(appointment.tenantId);
        const notificationSettings = JSON.parse(tenantSettings.notificationSettings || '{}');
        
        // 3. Send reminders based on tenant settings
        const results = {
            email: false,
            sms: false,
            push: false
        };
        
        // Send email reminder if enabled
        if (notificationSettings.emailReminders && appointment.client.email) {
            results.email = await sendEmailReminder(appointment, notificationSettings);
        }
        
        // Send SMS reminder if enabled
        if (notificationSettings.smsReminders && appointment.client.phone) {
            results.sms = await sendSmsReminder(appointment, notificationSettings);
        }
        
        // Send push notification if enabled
        if (notificationSettings.pushReminders) {
            results.push = await sendPushNotification(appointment, notificationSettings);
        }
        
        // 4. Log the reminder
        await logReminderSent(appointmentId, results);
        
        return {
            success: results.email || results.sms || results.push,
            sentVia: Object.keys(results).filter(key => results[key]),
            appointmentId
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Error sending appointment reminder',
                error: error.message
            }),
        };
    }
};

/**
 * Get appointment with client details
 */
async function getAppointmentWithClient(appointmentId) {
    const query = /* GraphQL */ `
        query GetAppointmentWithClient($id: ID!) {
            getAppointment(id: $id) {
                id
                clientId
                clientName
                serviceId
                serviceName
                tenantId
                date
                startTime
                endTime
                status
                client {
                    id
                    name
                    email
                    phone
                }
            }
        }
    `;
    
    const variables = { id: appointmentId };
    const response = await executeGraphQLQuery(query, variables);
    return response.data.getAppointment;
}

/**
 * Get tenant settings
 */
async function getTenantSettings(tenantId) {
    const query = /* GraphQL */ `
        query GetTenantSettings($tenantId: ID!) {
            listTenantSettings(filter: {tenantId: {eq: $tenantId}}, limit: 1) {
                items {
                    id
                    tenantId
                    notificationSettings
                }
            }
        }
    `;
    
    const variables = { tenantId };
    const response = await executeGraphQLQuery(query, variables);
    
    const items = response.data.listTenantSettings.items;
    if (items && items.length > 0) {
        return items[0];
    }
    
    // Return default settings if none found
    return {
        notificationSettings: JSON.stringify({
            emailReminders: true,
            smsReminders: true,
            pushReminders: false,
            reminderTemplate: "Olá {clientName}, lembrete para seu agendamento de {serviceName} amanhã às {startTime}.",
            emailSubject: "Lembrete de Agendamento - {serviceName}"
        })
    };
}

/**
 * Send email reminder
 */
async function sendEmailReminder(appointment, settings) {
    try {
        // Format the email content
        const subject = formatReminderText(settings.emailSubject || "Lembrete de Agendamento", appointment);
        const body = formatReminderText(settings.reminderTemplate, appointment);
        
        // Send email using SES
        const params = {
            Destination: {
                ToAddresses: [appointment.client.email]
            },
            Message: {
                Body: {
                    Html: {
                        Charset: "UTF-8",
                        Data: `<html><body><p>${body}</p></body></html>`
                    },
                    Text: {
                        Charset: "UTF-8",
                        Data: body
                    }
                },
                Subject: {
                    Charset: "UTF-8",
                    Data: subject
                }
            },
            Source: "noreply@agendemais.com" // This should be a verified email in SES
        };
        
        await ses.sendEmail(params).promise();
        return true;
    } catch (error) {
        console.error('Error sending email reminder:', error);
        return false;
    }
}

/**
 * Send SMS reminder
 */
async function sendSmsReminder(appointment, settings) {
    try {
        // Format the SMS content
        const message = formatReminderText(settings.reminderTemplate, appointment);
        
        // Send SMS using Pinpoint
        const params = {
            ApplicationId: process.env.PINPOINT_APPLICATION_ID || 'mock-app-id',
            MessageRequest: {
                Addresses: {
                    [appointment.client.phone]: {
                        ChannelType: 'SMS'
                    }
                },
                MessageConfiguration: {
                    SMSMessage: {
                        Body: message,
                        MessageType: 'TRANSACTIONAL'
                    }
                }
            }
        };
        
        // In development environment, just log the message
        if (process.env.ENV !== 'prod') {
            console.log('Mock SMS sent:', message);
            return true;
        }
        
        await pinpoint.sendMessages(params).promise();
        return true;
    } catch (error) {
        console.error('Error sending SMS reminder:', error);
        return false;
    }
}

/**
 * Send push notification
 */
async function sendPushNotification(appointment, settings) {
    try {
        // This would require device tokens to be stored for the client
        // For now, we'll just simulate this functionality
        console.log('Push notification would be sent for appointment:', appointment.id);
        return false; // Not implemented yet
    } catch (error) {
        console.error('Error sending push notification:', error);
        return false;
    }
}

/**
 * Format reminder text with appointment details
 */
function formatReminderText(template, appointment) {
    return template
        .replace('{clientName}', appointment.clientName)
        .replace('{serviceName}', appointment.serviceName)
        .replace('{date}', appointment.date)
        .replace('{startTime}', appointment.startTime)
        .replace('{endTime}', appointment.endTime);
}

/**
 * Log that a reminder was sent
 */
async function logReminderSent(appointmentId, channels) {
    const mutation = /* GraphQL */ `
        mutation UpdateAppointment($input: UpdateAppointmentInput!) {
            updateAppointment(input: $input) {
                id
                updatedAt
            }
        }
    `;
    
    const variables = {
        input: {
            id: appointmentId,
            reminderSent: true,
            reminderSentAt: new Date().toISOString(),
            reminderChannels: JSON.stringify(channels)
        }
    };
    
    await executeGraphQLMutation(mutation, variables);
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