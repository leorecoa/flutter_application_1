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
    const period = event.arguments.period || 'week'; // 'day', 'week', 'month', 'year'
    
    // Validate input
    if (!tenantId) {
        return {
            statusCode: 400,
            body: JSON.stringify({
                message: 'Missing required parameter: tenantId'
            }),
        };
    }
    
    try {
        // Calculate date ranges based on period
        const { startDate, endDate, previousStartDate, previousEndDate } = calculateDateRanges(period);
        
        // Get appointments for current period
        const currentAppointments = await getAppointmentsByDateRange(
            tenantId, 
            startDate.toISOString().split('T')[0], 
            endDate.toISOString().split('T')[0]
        );
        
        // Get appointments for previous period (for comparison)
        const previousAppointments = await getAppointmentsByDateRange(
            tenantId, 
            previousStartDate.toISOString().split('T')[0], 
            previousEndDate.toISOString().split('T')[0]
        );
        
        // Calculate statistics
        const stats = calculateStats(currentAppointments, previousAppointments, period);
        
        // Get upcoming appointments for today
        const today = new Date().toISOString().split('T')[0];
        const upcomingAppointments = await getAppointmentsForToday(tenantId, today);
        
        // Return dashboard data
        return {
            period,
            dateRange: {
                start: startDate.toISOString().split('T')[0],
                end: endDate.toISOString().split('T')[0]
            },
            stats,
            upcomingAppointments: upcomingAppointments.map(formatAppointment)
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Error calculating dashboard statistics',
                error: error.message
            }),
        };
    }
};

/**
 * Calculate date ranges for current and previous periods
 */
function calculateDateRanges(period) {
    const now = new Date();
    const startDate = new Date();
    const endDate = new Date();
    const previousStartDate = new Date();
    const previousEndDate = new Date();
    
    switch (period) {
        case 'day':
            // Current: today
            startDate.setHours(0, 0, 0, 0);
            endDate.setHours(23, 59, 59, 999);
            
            // Previous: yesterday
            previousStartDate.setDate(now.getDate() - 1);
            previousStartDate.setHours(0, 0, 0, 0);
            previousEndDate.setDate(now.getDate() - 1);
            previousEndDate.setHours(23, 59, 59, 999);
            break;
            
        case 'week':
            // Current: this week (Sunday to Saturday)
            const dayOfWeek = now.getDay(); // 0 = Sunday, 6 = Saturday
            startDate.setDate(now.getDate() - dayOfWeek); // Go to beginning of week (Sunday)
            startDate.setHours(0, 0, 0, 0);
            endDate.setDate(startDate.getDate() + 6); // Go to end of week (Saturday)
            endDate.setHours(23, 59, 59, 999);
            
            // Previous: last week
            previousStartDate.setDate(startDate.getDate() - 7);
            previousStartDate.setHours(0, 0, 0, 0);
            previousEndDate.setDate(endDate.getDate() - 7);
            previousEndDate.setHours(23, 59, 59, 999);
            break;
            
        case 'month':
            // Current: this month
            startDate.setDate(1); // First day of month
            startDate.setHours(0, 0, 0, 0);
            endDate.setMonth(now.getMonth() + 1, 0); // Last day of month
            endDate.setHours(23, 59, 59, 999);
            
            // Previous: last month
            previousStartDate.setMonth(now.getMonth() - 1, 1); // First day of previous month
            previousStartDate.setHours(0, 0, 0, 0);
            previousEndDate.setMonth(now.getMonth(), 0); // Last day of previous month
            previousEndDate.setHours(23, 59, 59, 999);
            break;
            
        case 'year':
            // Current: this year
            startDate.setMonth(0, 1); // January 1st
            startDate.setHours(0, 0, 0, 0);
            endDate.setMonth(11, 31); // December 31st
            endDate.setHours(23, 59, 59, 999);
            
            // Previous: last year
            previousStartDate.setFullYear(now.getFullYear() - 1, 0, 1); // January 1st of last year
            previousStartDate.setHours(0, 0, 0, 0);
            previousEndDate.setFullYear(now.getFullYear() - 1, 11, 31); // December 31st of last year
            previousEndDate.setHours(23, 59, 59, 999);
            break;
    }
    
    return { startDate, endDate, previousStartDate, previousEndDate };
}

/**
 * Calculate statistics based on appointments
 */
function calculateStats(currentAppointments, previousAppointments, period) {
    // Total appointments
    const totalAppointments = currentAppointments.length;
    const previousTotalAppointments = previousAppointments.length;
    const appointmentGrowth = calculateGrowth(totalAppointments, previousTotalAppointments);
    
    // Completed appointments
    const completedAppointments = currentAppointments.filter(a => a.status === 'COMPLETED').length;
    const previousCompletedAppointments = previousAppointments.filter(a => a.status === 'COMPLETED').length;
    const completionRate = totalAppointments > 0 ? (completedAppointments / totalAppointments) * 100 : 0;
    const previousCompletionRate = previousTotalAppointments > 0 ? (previousCompletedAppointments / previousTotalAppointments) * 100 : 0;
    const completionRateGrowth = calculateGrowth(completionRate, previousCompletionRate);
    
    // Cancelled appointments
    const cancelledAppointments = currentAppointments.filter(a => a.status === 'CANCELLED').length;
    const previousCancelledAppointments = previousAppointments.filter(a => a.status === 'CANCELLED').length;
    const cancellationRate = totalAppointments > 0 ? (cancelledAppointments / totalAppointments) * 100 : 0;
    const previousCancellationRate = previousTotalAppointments > 0 ? (previousCancelledAppointments / previousTotalAppointments) * 100 : 0;
    const cancellationRateGrowth = calculateGrowth(cancellationRate, previousCancellationRate);
    
    // Revenue
    const revenue = currentAppointments
        .filter(a => a.status === 'COMPLETED' && a.paymentStatus === 'PAID')
        .reduce((sum, a) => sum + (a.paymentAmount || a.servicePrice || 0), 0);
    const previousRevenue = previousAppointments
        .filter(a => a.status === 'COMPLETED' && a.paymentStatus === 'PAID')
        .reduce((sum, a) => sum + (a.paymentAmount || a.servicePrice || 0), 0);
    const revenueGrowth = calculateGrowth(revenue, previousRevenue);
    
    // Average appointment value
    const avgValue = completedAppointments > 0 ? revenue / completedAppointments : 0;
    const previousAvgValue = previousCompletedAppointments > 0 ? previousRevenue / previousCompletedAppointments : 0;
    const avgValueGrowth = calculateGrowth(avgValue, previousAvgValue);
    
    // Distribution by day (for weekly view)
    let distributionByDay = null;
    if (period === 'week') {
        distributionByDay = [0, 0, 0, 0, 0, 0, 0]; // Sun, Mon, Tue, Wed, Thu, Fri, Sat
        
        currentAppointments.forEach(appointment => {
            const date = new Date(appointment.date);
            const dayOfWeek = date.getDay(); // 0 = Sunday, 6 = Saturday
            distributionByDay[dayOfWeek]++;
        });
    }
    
    // Distribution by month (for yearly view)
    let distributionByMonth = null;
    if (period === 'year') {
        distributionByMonth = Array(12).fill(0); // Jan to Dec
        
        currentAppointments.forEach(appointment => {
            const date = new Date(appointment.date);
            const month = date.getMonth(); // 0 = January, 11 = December
            distributionByMonth[month]++;
        });
    }
    
    return {
        appointments: {
            total: totalAppointments,
            growth: appointmentGrowth,
            completed: completedAppointments,
            cancelled: cancelledAppointments,
            completionRate: completionRate.toFixed(2),
            completionRateGrowth: completionRateGrowth,
            cancellationRate: cancellationRate.toFixed(2),
            cancellationRateGrowth: cancellationRateGrowth
        },
        revenue: {
            total: revenue.toFixed(2),
            growth: revenueGrowth,
            avgValue: avgValue.toFixed(2),
            avgValueGrowth: avgValueGrowth
        },
        distribution: {
            byDay: distributionByDay,
            byMonth: distributionByMonth
        }
    };
}

/**
 * Calculate growth percentage
 */
function calculateGrowth(current, previous) {
    if (previous === 0) {
        return current > 0 ? 100 : 0;
    }
    return ((current - previous) / previous * 100).toFixed(2);
}

/**
 * Format appointment for display
 */
function formatAppointment(appointment) {
    return {
        id: appointment.id,
        clientName: appointment.clientName,
        serviceName: appointment.serviceName,
        date: appointment.date,
        startTime: appointment.startTime,
        endTime: appointment.endTime,
        status: appointment.status
    };
}

/**
 * Get appointments by date range
 */
async function getAppointmentsByDateRange(tenantId, startDate, endDate) {
    const query = /* GraphQL */ `
        query GetAppointmentsByDateRange($tenantId: ID!, $startDate: AWSDate!, $endDate: AWSDate!) {
            getAppointmentsByDateRange(tenantId: $tenantId, startDate: $startDate, endDate: $endDate) {
                id
                clientName
                serviceName
                servicePrice
                date
                startTime
                endTime
                status
                paymentStatus
                paymentAmount
            }
        }
    `;
    
    const variables = { tenantId, startDate, endDate };
    const response = await executeGraphQLQuery(query, variables);
    return response.data.getAppointmentsByDateRange || [];
}

/**
 * Get appointments for today
 */
async function getAppointmentsForToday(tenantId, date) {
    const query = /* GraphQL */ `
        query GetAppointmentsForToday($tenantId: ID!, $date: AWSDate!) {
            listAppointments(filter: {
                tenantId: {eq: $tenantId},
                date: {eq: $date},
                status: {ne: "CANCELLED"}
            }, limit: 10) {
                items {
                    id
                    clientName
                    serviceName
                    date
                    startTime
                    endTime
                    status
                }
            }
        }
    `;
    
    const variables = { tenantId, date };
    const response = await executeGraphQLQuery(query, variables);
    return response.data.listAppointments.items || [];
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