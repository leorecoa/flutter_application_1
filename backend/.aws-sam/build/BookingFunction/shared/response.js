const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
};

class ResponseHelper {
  static success(data, statusCode = 200) {
    return {
      statusCode,
      headers: corsHeaders,
      body: JSON.stringify({
        success: true,
        data
      })
    };
  }

  static error(message, statusCode = 400, details = null) {
    return {
      statusCode,
      headers: corsHeaders,
      body: JSON.stringify({
        success: false,
        error: {
          message,
          details
        }
      })
    };
  }

  static cors() {
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: ''
    };
  }

  static unauthorized(message = 'Unauthorized') {
    return this.error(message, 401);
  }

  static forbidden(message = 'Forbidden') {
    return this.error(message, 403);
  }

  static notFound(message = 'Not found') {
    return this.error(message, 404);
  }

  static serverError(message = 'Internal server error') {
    return this.error(message, 500);
  }
}

module.exports = ResponseHelper;