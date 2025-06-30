exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  return {
    statusCode: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      message: 'Hello from AgendaFácil API!',
      timestamp: new Date().toISOString(),
      path: event.pathParameters?.proxy || 'root'
    })
  };
};