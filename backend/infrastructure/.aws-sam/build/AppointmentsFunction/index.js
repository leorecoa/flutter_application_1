const DynamoDBService = require('../shared/dynamodb');
const ResponseHelper = require('../shared/response');
const AuthHelper = require('../shared/auth');
const { v4: uuidv4 } = require('uuid');

exports.handler = async (event) => {
  console.log('Appointments Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  const user = AuthHelper.extractUserFromEvent(event);
  if (!user) {
    return ResponseHelper.unauthorized();
  }

  try {
    const { httpMethod, pathParameters, body, queryStringParameters } = event;
    const appointmentId = pathParameters?.proxy;
    const requestBody = body ? JSON.parse(body) : {};
    const queryParams = queryStringParameters || {};

    switch (httpMethod) {
      case 'GET':
        return appointmentId ? 
          await getAppointment(user.userId, appointmentId) : 
          await getAppointments(user.userId, queryParams);
      
      case 'POST':
        return await createAppointment(user.userId, requestBody);
      
      case 'PUT':
        return await updateAppointment(user.userId, appointmentId, requestBody);
      
      case 'DELETE':
        return await deleteAppointment(user.userId, appointmentId);
      
      default:
        return ResponseHelper.error('Method not allowed', 405);
    }
  } catch (error) {
    console.error('Appointments Handler Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function getAppointments(userId, queryParams) {
  try {
    const { date, status, limit } = queryParams;
    let appointments;

    if (date) {
      // Query appointments for specific date
      appointments = await DynamoDBService.query(
        `USER#${userId}`,
        `APPOINTMENT#${date}`
      );
    } else {
      // Get all appointments
      appointments = await DynamoDBService.query(`USER#${userId}`, 'APPOINTMENT#');
    }

    // Filter by status if provided
    if (status) {
      appointments = appointments.filter(apt => apt.status === status);
    }

    // Limit results if provided
    if (limit) {
      appointments = appointments.slice(0, parseInt(limit));
    }

    // Sort by date and time
    appointments.sort((a, b) => {
      const dateTimeA = new Date(`${a.appointmentDate}T${a.appointmentTime}`);
      const dateTimeB = new Date(`${b.appointmentDate}T${b.appointmentTime}`);
      return dateTimeA - dateTimeB;
    });

    return ResponseHelper.success(appointments);
  } catch (error) {
    console.error('Get appointments error:', error);
    return ResponseHelper.serverError('Failed to get appointments');
  }
}

async function getAppointment(userId, appointmentId) {
  try {
    const appointment = await DynamoDBService.getItem(`USER#${userId}`, `APPOINTMENT#${appointmentId}`);
    
    if (!appointment) {
      return ResponseHelper.notFound('Appointment not found');
    }

    return ResponseHelper.success(appointment);
  } catch (error) {
    console.error('Get appointment error:', error);
    return ResponseHelper.serverError('Failed to get appointment');
  }
}

async function createAppointment(userId, body) {
  const {
    clientName,
    clientPhone,
    clientEmail,
    serviceId,
    serviceName,
    servicePrice,
    appointmentDate,
    appointmentTime,
    notes,
    paymentMethod = 'cash'
  } = body;

  if (!clientName || !clientPhone || !serviceId || !appointmentDate || !appointmentTime) {
    return ResponseHelper.error('Missing required fields');
  }

  try {
    // Check if time slot is available
    const existingAppointments = await DynamoDBService.query(
      `USER#${userId}`,
      `APPOINTMENT#${appointmentDate}`
    );

    const timeSlotTaken = existingAppointments.some(apt => 
      apt.appointmentTime === appointmentTime && 
      apt.status !== 'cancelled'
    );

    if (timeSlotTaken) {
      return ResponseHelper.error('Time slot is not available');
    }

    const appointmentId = uuidv4();
    const appointment = {
      PK: `USER#${userId}`,
      SK: `APPOINTMENT#${appointmentId}`,
      appointmentId,
      userId,
      clientName,
      clientPhone,
      clientEmail: clientEmail || '',
      serviceId,
      serviceName,
      servicePrice: parseFloat(servicePrice),
      appointmentDate,
      appointmentTime,
      status: 'scheduled',
      paymentStatus: 'pending',
      paymentMethod,
      notes: notes || '',
      GSI1PK: `DATE#${appointmentDate}`,
      GSI1SK: `TIME#${appointmentTime}#${appointmentId}`
    };

    await DynamoDBService.putItem(appointment);

    // TODO: Send WhatsApp confirmation
    // await sendWhatsAppConfirmation(appointment);

    return ResponseHelper.success(appointment, 201);

  } catch (error) {
    console.error('Create appointment error:', error);
    return ResponseHelper.serverError('Failed to create appointment');
  }
}

async function updateAppointment(userId, appointmentId, body) {
  if (!appointmentId) {
    return ResponseHelper.error('Appointment ID is required');
  }

  try {
    const existingAppointment = await DynamoDBService.getItem(`USER#${userId}`, `APPOINTMENT#${appointmentId}`);
    
    if (!existingAppointment) {
      return ResponseHelper.notFound('Appointment not found');
    }

    const {
      clientName,
      clientPhone,
      clientEmail,
      appointmentDate,
      appointmentTime,
      status,
      paymentStatus,
      paymentMethod,
      notes
    } = body;

    let updateExpression = 'SET updatedAt = :updatedAt';
    const expressionAttributeValues = {
      ':updatedAt': new Date().toISOString()
    };

    if (clientName !== undefined) {
      updateExpression += ', clientName = :clientName';
      expressionAttributeValues[':clientName'] = clientName;
    }

    if (clientPhone !== undefined) {
      updateExpression += ', clientPhone = :clientPhone';
      expressionAttributeValues[':clientPhone'] = clientPhone;
    }

    if (clientEmail !== undefined) {
      updateExpression += ', clientEmail = :clientEmail';
      expressionAttributeValues[':clientEmail'] = clientEmail;
    }

    if (appointmentDate !== undefined) {
      updateExpression += ', appointmentDate = :appointmentDate';
      expressionAttributeValues[':appointmentDate'] = appointmentDate;
    }

    if (appointmentTime !== undefined) {
      updateExpression += ', appointmentTime = :appointmentTime';
      expressionAttributeValues[':appointmentTime'] = appointmentTime;
    }

    if (status !== undefined) {
      updateExpression += ', #status = :status';
      expressionAttributeValues[':status'] = status;
    }

    if (paymentStatus !== undefined) {
      updateExpression += ', paymentStatus = :paymentStatus';
      expressionAttributeValues[':paymentStatus'] = paymentStatus;
    }

    if (paymentMethod !== undefined) {
      updateExpression += ', paymentMethod = :paymentMethod';
      expressionAttributeValues[':paymentMethod'] = paymentMethod;
    }

    if (notes !== undefined) {
      updateExpression += ', notes = :notes';
      expressionAttributeValues[':notes'] = notes;
    }

    const expressionAttributeNames = status !== undefined ? { '#status': 'status' } : {};

    const updatedAppointment = await DynamoDBService.updateItem(
      `USER#${userId}`,
      `APPOINTMENT#${appointmentId}`,
      updateExpression,
      expressionAttributeValues,
      expressionAttributeNames
    );

    return ResponseHelper.success(updatedAppointment);

  } catch (error) {
    console.error('Update appointment error:', error);
    return ResponseHelper.serverError('Failed to update appointment');
  }
}

async function deleteAppointment(userId, appointmentId) {
  if (!appointmentId) {
    return ResponseHelper.error('Appointment ID is required');
  }

  try {
    const existingAppointment = await DynamoDBService.getItem(`USER#${userId}`, `APPOINTMENT#${appointmentId}`);
    
    if (!existingAppointment) {
      return ResponseHelper.notFound('Appointment not found');
    }

    await DynamoDBService.deleteItem(`USER#${userId}`, `APPOINTMENT#${appointmentId}`);
    return ResponseHelper.success({ message: 'Appointment deleted successfully' });

  } catch (error) {
    console.error('Delete appointment error:', error);
    return ResponseHelper.serverError('Failed to delete appointment');
  }
}