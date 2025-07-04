/**
 * Health check endpoint for multi-region deployment
 */
exports.handler = async (event) => {
  const region = process.env.AWS_REGION || 'unknown';
  
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'
    },
    body: JSON.stringify({
      status: 'healthy',
      region: region,
      timestamp: new Date().toISOString(),
      environment: process.env.ENVIRONMENT || 'dev'
    })
  };
};