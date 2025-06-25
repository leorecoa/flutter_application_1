const DynamoDBService = require('../shared/dynamodb');
const ResponseHelper = require('../shared/response');
const { v4: uuidv4 } = require('uuid');

exports.handler = async (event) => {
  console.log('Booking Event:', JSON.stringify(event, null, 2));

  if (event.httpMethod === 'OPTIONS') {
    return ResponseHelper.cors();
  }

  try {
    const { httpMethod, pathParameters, body, queryStringParameters } = event;
    const path = pathParameters?.proxy || '';
    const requestBody = body ? JSON.parse(body) : {};
    const queryParams = queryStringParameters || {};

    switch (`${httpMethod}:${path}`) {
      case 'GET:professional':
        return await getProfessionalByLink(queryParams.link);
      
      case 'GET:services':
        return await getPublicServices(queryParams.userId);
      
      case 'GET:availability':
        return await getAvailability(queryParams.userId, queryParams.date);
      
      case 'POST:appointment':
        return await createPublicAppointment(requestBody);
      
      default:
        return ResponseHelper.notFound('Endpoint not found');
    }
  } catch (error) {
    console.error('Booking Handler Error:', error);
    return ResponseHelper.serverError(error.message);
  }
};

async function getProfessionalByLink(customLink) {
  if (!customLink) {
    return ResponseHelper.error('Custom link is required');
  }

  try {
    const professionals = await DynamoDBService.query(
      `LINK#${customLink}`,
      null,
      'GSI1'
    );

    if (!professionals || professionals.length === 0) {
      return ResponseHelper.notFound('Professional not found');
    }

    const professional = professionals[0];
    
    // Remove sensitive information
    delete professional.settings;
    delete professional.planId;
    delete professional.planExpiry;

    return ResponseHelper.success(professional);

  } catch (error) {
    console.error('Get professional error:', error);
    return ResponseHelper.serverError('Failed to get professional');
  }
}

async function getPublicServices(userId) {
  if (!userId) {
    return ResponseHelper.error('User ID is required');
  }

  try {
    const services = await DynamoDBService.query(`USER#${userId}`, 'SERVICE#');
    
    // Filter only active services
    const activeServices = services.filter(service => service.isActive);
    
    return ResponseHelper.success(activeServices);

  } catch (error) {
    console.error('Get public services error:', error);
    return ResponseHelper.serverError('Failed to get services');
  }
}

async function getAvailability(userId, date) {
  if (!userId || !date) {
    return ResponseHelper.error('User ID and date are required');
  }

  try {
    // Get user's working hours
    const userProfile = await DynamoDBService.getItem(`USER#${userId}`, 'PROFILE');
    
    if (!userProfile) {
      return ResponseHelper.notFound('Professional not found');
    }

    const dayOfWeek = new Date(date).toLocaleDateString('en-US', { weekday: 'lowercase' });
    const workingHours = userProfile.settings?.workingHours?.[dayOfWeek];

    if (!workingHours || !workingHours.enabled) {
      return ResponseHelper.success({ availableSlots: [] });
    }

    // Get existing appointments for the date
    const existingAppointments = await DynamoDBService.query(
      `USER#${userId}`,
      `APPOINTMENT#${date}`
    );

    // Generate time slots (30-minute intervals)
    const availableSlots = generateTimeSlots(
      workingHours.start,
      workingHours.end,
      existingAppointments
    );

    return ResponseHelper.success({ availableSlots });

  } catch (error) {
    console.error('Get availability error:', error);
    return ResponseHelper.serverError('Failed to get availability');
  }
}

async function createPublicAppointment(body) {
  const {
    userId,
    clientName,
    clientPhone,
    clientEmail,
    serviceId,
    appointmentDate,
    appointmentTime,
    notes
  } = body;

  if (!userId || !clientName || !clientPhone || !serviceId || !appointmentDate || !appointmentTime) {
    return ResponseHelper.error('Missing required fields');
  }

  try {
    // Get service details
    const service = await DynamoDBService.getItem(`USER#${userId}`, `SERVICE#${serviceId}`);
    
    if (!service || !service.isActive) {
      return ResponseHelper.error('Service not found or inactive');
    }

    // Check if time slot is still available
    const existingAppointments = await DynamoDBService.query(
      `USER#${userId}`,
      `APPOINTMENT#${appointmentDate}`
    );

    const timeSlotTaken = existingAppointments.some(apt => 
      apt.appointmentTime === appointmentTime && 
      apt.status !== 'cancelled'
    );

    if (timeSlotTaken) {
      return ResponseHelper.error('Time slot is no longer available');
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
      serviceName: service.name,
      servicePrice: service.price,
      appointmentDate,
      appointmentTime,
      status: 'scheduled',
      paymentStatus: 'pending',
      paymentMethod: 'cash',
      notes: notes || '',
      source: 'public_booking',
      GSI1PK: `DATE#${appointmentDate}`,
      GSI1SK: `TIME#${appointmentTime}#${appointmentId}`
    };

    await DynamoDBService.putItem(appointment);

    // TODO: Send WhatsApp confirmation to both client and professional
    // await sendWhatsAppConfirmation(appointment);

    return ResponseHelper.success(appointment, 201);

  } catch (error) {
    console.error('Create public appointment error:', error);
    return ResponseHelper.serverError('Failed to create appointment');
  }
}

function generateTimeSlots(startTime, endTime, existingAppointments) {
  const slots = [];
  const start = parseTime(startTime);
  const end = parseTime(endTime);
  const interval = 30; // 30 minutes

  const bookedTimes = existingAppointments
    .filter(apt => apt.status !== 'cancelled')
    .map(apt => apt.appointmentTime);

  for (let time = start; time < end; time += interval) {
    const timeString = formatTime(time);
    
    if (!bookedTimes.includes(timeString)) {
      slots.push({
        time: timeString,
        available: true
      });
    }
  }

  return slots;
}

function parseTime(timeString) {
  const [hours, minutes] = timeString.split(':').map(Number);
  return hours * 60 + minutes;
}

function formatTime(minutes) {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}`;
}