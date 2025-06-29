const AWS = require('aws-sdk');
const ResponseHelper = require('./shared/response');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  context.log('BookingFunction Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  try {
    const { httpMethod, pathParameters, body, queryStringParameters } = event;
    const path = pathParameters?.proxy || '';
    const requestBody = body ? JSON.parse(body) : {};

    switch (`${httpMethod}:${path}`) {
      case 'GET:available-slots':
        return await getAvailableSlots(queryStringParameters);
      case 'GET:services':
        return await getPublicServices(queryStringParameters);
      case 'POST:book':
        return await createPublicBooking(requestBody);
      case 'GET:booking':
        return await getBookingStatus(queryStringParameters);
      case 'GET:health':
        return ResponseHelper.success({ status: 'healthy', service: 'booking' });
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    context.log('BookingFunction Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function getPublicServices(queryParams) {
  const { tenantId } = queryParams || {};
  
  if (!tenantId) {
    return ResponseHelper.error('tenantId is required');
  }

  const params = {
    TableName: process.env.MAIN_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    FilterExpression: 'isActive = :isActive',
    ExpressionAttributeValues: {
      ':pk': `TENANT#${tenantId}`,
      ':sk': 'SERVICE#',
      ':isActive': true
    }
  };

  const result = await dynamodb.query(params).promise();
  return ResponseHelper.success(result.Items);
}

async function getAvailableSlots(queryParams) {
  const { tenantId, date, serviceId } = queryParams || {};
  
  if (!tenantId || !date) {
    return ResponseHelper.error('tenantId and date are required');
  }

  // Get existing appointments for the date
  const appointmentsParams = {
    TableName: process.env.MAIN_TABLE,
    IndexName: 'GSI1',
    KeyConditionExpression: 'GSI1PK = :gsi1pk AND begins_with(GSI1SK, :date)',
    FilterExpression: '#status <> :cancelled',
    ExpressionAttributeValues: {
      ':gsi1pk': `TENANT#${tenantId}#DATE`,
      ':date': date,
      ':cancelled': 'cancelled'
    },
    ExpressionAttributeNames: {
      '#status': 'status'
    }
  };

  const appointmentsResult = await dynamodb.query(appointmentsParams).promise();
  const bookedSlots = appointmentsResult.Items.map(item => item.appointmentTime);

  // Generate available slots (9:00 to 18:00, 30min intervals)
  const allSlots = [];
  for (let hour = 9; hour < 18; hour++) {
    allSlots.push(`${hour.toString().padStart(2, '0')}:00`);
    allSlots.push(`${hour.toString().padStart(2, '0')}:30`);
  }

  const availableSlots = allSlots.filter(slot => !bookedSlots.includes(slot));

  return ResponseHelper.success({
    date,
    availableSlots,
    bookedSlots
  });
}

async function createPublicBooking(body) {
  const { tenantId, serviceId, clientName, clientPhone, clientEmail, appointmentDate, appointmentTime, notes } = body;

  if (!tenantId || !serviceId || !clientName || !clientPhone || !appointmentDate || !appointmentTime) {
    return ResponseHelper.error('Missing required fields: tenantId, serviceId, clientName, clientPhone, appointmentDate, appointmentTime');
  }

  // Check if slot is still available
  const checkParams = {
    TableName: process.env.MAIN_TABLE,
    IndexName: 'GSI1',
    KeyConditionExpression: 'GSI1PK = :gsi1pk AND GSI1SK = :gsi1sk',
    FilterExpression: '#status <> :cancelled',
    ExpressionAttributeValues: {
      ':gsi1pk': `TENANT#${tenantId}#DATE`,
      ':gsi1sk': `${appointmentDate}#${appointmentTime}`,
      ':cancelled': 'cancelled'
    },
    ExpressionAttributeNames: {
      '#status': 'status'
    }
  };

  const existingBooking = await dynamodb.query(checkParams).promise();
  
  if (existingBooking.Items.length > 0) {
    return ResponseHelper.error('Time slot is no longer available', 409);
  }

  const bookingId = `booking_${Date.now()}`;
  const booking = {
    PK: `TENANT#${tenantId}`,
    SK: `APPOINTMENT#${bookingId}`,
    GSI1PK: `TENANT#${tenantId}#DATE`,
    GSI1SK: `${appointmentDate}#${appointmentTime}`,
    appointmentId: bookingId,
    serviceId,
    clientName,
    clientPhone,
    clientEmail: clientEmail || '',
    appointmentDate,
    appointmentTime,
    notes: notes || '',
    status: 'scheduled',
    source: 'public_booking',
    createdAt: new Date().toISOString()
  };

  const params = {
    TableName: process.env.MAIN_TABLE,
    Item: booking,
    ConditionExpression: 'attribute_not_exists(PK)'
  };

  try {
    await dynamodb.put(params).promise();
    return ResponseHelper.success({
      bookingId,
      message: 'Booking created successfully',
      booking
    }, 201);
  } catch (error) {
    if (error.code === 'ConditionalCheckFailedException') {
      return ResponseHelper.error('Time slot is no longer available', 409);
    }
    throw error;
  }
}

async function getBookingStatus(queryParams) {
  const { bookingId, tenantId } = queryParams || {};
  
  if (!bookingId || !tenantId) {
    return ResponseHelper.error('bookingId and tenantId are required');
  }

  const params = {
    TableName: process.env.MAIN_TABLE,
    Key: {
      PK: `TENANT#${tenantId}`,
      SK: `APPOINTMENT#${bookingId}`
    }
  };

  const result = await dynamodb.get(params).promise();
  
  if (!result.Item) {
    return ResponseHelper.notFound('Booking not found');
  }

  return ResponseHelper.success(result.Item);
}