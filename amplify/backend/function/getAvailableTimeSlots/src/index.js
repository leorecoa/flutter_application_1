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
    const serviceId = event.arguments.serviceId;
    const date = event.arguments.date;
    
    // Validate input
    if (!tenantId || !serviceId || !date) {
        return {
            statusCode: 400,
            body: JSON.stringify({
                message: 'Missing required parameters: tenantId, serviceId, date'
            }),
        };
    }
    
    try {
        // 1. Get the service to determine duration
        const service = await getService(serviceId);
        if (!service) {
            throw new Error(`Service not found: ${serviceId}`);
        }
        
        const serviceDuration = service.duration; // Duration in minutes
        
        // 2. Get tenant settings to determine working hours
        const tenantSettings = await getTenantSettings(tenantId);
        const workingHours = JSON.parse(tenantSettings.workingHours || '{}');
        
        // Get day of week (0 = Sunday, 1 = Monday, etc.)
        const dayOfWeek = new Date(date).getDay();
        const dayKey = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'][dayOfWeek];
        
        // Check if the business is open on this day
        if (!workingHours[dayKey] || !workingHours[dayKey].isOpen) {
            return {
                slots: [],
                message: 'Business is closed on this day'
            };
        }
        
        // Get working hours for this day
        const dayHours = workingHours[dayKey];
        const startTime = dayHours.start; // Format: "09:00"
        const endTime = dayHours.end;     // Format: "18:00"
        
        // 3. Get existing appointments for this date
        const appointments = await getAppointmentsForDate(tenantId, date);
        
        // 4. Calculate available time slots
        const availableSlots = calculateAvailableSlots(
            startTime,
            endTime,
            serviceDuration,
            appointments
        );
        
        return {
            slots: availableSlots,
            serviceDuration: serviceDuration,
            workingHours: {
                start: startTime,
                end: endTime
            }
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Error calculating available time slots',
                error: error.message
            }),
        };
    }
};

/**
 * Get service details by ID
 */
async function getService(serviceId) {
    const query = /* GraphQL */ `
        query GetService($id: ID!) {
            getService(id: $id) {
                id
                name
                description
                price
                duration
                color
                active
            }
        }
    `;
    
    const variables = { id: serviceId };
    const response = await executeGraphQLQuery(query, variables);
    return response.data.getService;
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
                    workingHours
                    notificationSettings
                    paymentSettings
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
        workingHours: JSON.stringify({
            monday: { isOpen: true, start: "09:00", end: "18:00" },
            tuesday: { isOpen: true, start: "09:00", end: "18:00" },
            wednesday: { isOpen: true, start: "09:00", end: "18:00" },
            thursday: { isOpen: true, start: "09:00", end: "18:00" },
            friday: { isOpen: true, start: "09:00", end: "18:00" },
            saturday: { isOpen: false, start: "09:00", end: "13:00" },
            sunday: { isOpen: false, start: "09:00", end: "13:00" }
        })
    };
}

/**
 * Get appointments for a specific date
 */
async function getAppointmentsForDate(tenantId, date) {
    const query = /* GraphQL */ `
        query GetAppointmentsForDate($tenantId: ID!, $date: AWSDate!) {
            listAppointments(filter: {
                tenantId: {eq: $tenantId},
                date: {eq: $date},
                status: {ne: "CANCELLED"}
            }) {
                items {
                    id
                    startTime
                    endTime
                    status
                }
            }
        }
    `;
    
    const variables = { tenantId, date };
    const response = await executeGraphQLQuery(query, variables);
    return response.data.listAppointments.items;
}

/**
 * Calculate available time slots based on working hours and existing appointments
 */
function calculateAvailableSlots(startTime, endTime, serviceDuration, appointments) {
    // Convert times to minutes since midnight
    const startMinutes = timeToMinutes(startTime);
    const endMinutes = timeToMinutes(endTime);
    
    // Create array of all possible slots
    const slots = [];
    for (let time = startMinutes; time <= endMinutes - serviceDuration; time += 15) {
        slots.push({
            startTime: minutesToTime(time),
            endTime: minutesToTime(time + serviceDuration),
            available: true
        });
    }
    
    // Mark slots as unavailable if they overlap with existing appointments
    appointments.forEach(appointment => {
        const apptStart = timeToMinutes(appointment.startTime);
        const apptEnd = timeToMinutes(appointment.endTime);
        
        slots.forEach(slot => {
            const slotStart = timeToMinutes(slot.startTime);
            const slotEnd = timeToMinutes(slot.endTime);
            
            // Check for overlap
            if (
                (slotStart >= apptStart && slotStart < apptEnd) || // Slot starts during appointment
                (slotEnd > apptStart && slotEnd <= apptEnd) ||     // Slot ends during appointment
                (slotStart <= apptStart && slotEnd >= apptEnd)     // Slot contains appointment
            ) {
                slot.available = false;
            }
        });
    });
    
    // Filter out unavailable slots
    return slots.filter(slot => slot.available);
}

/**
 * Convert time string (HH:MM) to minutes since midnight
 */
function timeToMinutes(timeStr) {
    const [hours, minutes] = timeStr.split(':').map(Number);
    return hours * 60 + minutes;
}

/**
 * Convert minutes since midnight to time string (HH:MM)
 */
function minutesToTime(minutes) {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
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