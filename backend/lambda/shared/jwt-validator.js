const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

class JWTValidator {
  constructor() {
    this.client = jwksClient({
      jwksUri: `https://cognito-idp.${process.env.AWS_REGION}.amazonaws.com/${process.env.COGNITO_USER_POOL_ID}/.well-known/jwks.json`,
      cache: true,
      cacheMaxEntries: 5,
      cacheMaxAge: 600000 // 10 minutes
    });
  }

  async getSigningKey(kid) {
    return new Promise((resolve, reject) => {
      this.client.getSigningKey(kid, (err, key) => {
        if (err) {
          reject(err);
        } else {
          resolve(key.getPublicKey());
        }
      });
    });
  }

  async validateToken(token) {
    try {
      // Remove 'Bearer ' prefix if present
      const cleanToken = token.replace(/^Bearer\s+/, '');
      
      // Decode token header to get kid
      const decoded = jwt.decode(cleanToken, { complete: true });
      if (!decoded || !decoded.header || !decoded.header.kid) {
        throw new Error('Invalid token structure');
      }

      // Get signing key
      const signingKey = await this.getSigningKey(decoded.header.kid);

      // Verify token
      const payload = jwt.verify(cleanToken, signingKey, {
        issuer: `https://cognito-idp.${process.env.AWS_REGION}.amazonaws.com/${process.env.COGNITO_USER_POOL_ID}`,
        audience: process.env.COGNITO_CLIENT_ID,
        algorithms: ['RS256']
      });

      return {
        valid: true,
        payload,
        userId: payload.sub,
        email: payload.email,
        groups: payload['cognito:groups'] || []
      };
    } catch (error) {
      console.error('JWT validation error:', error);
      return {
        valid: false,
        error: error.message
      };
    }
  }

  extractTokenFromEvent(event) {
    // Try Authorization header first
    const authHeader = event.headers?.Authorization || event.headers?.authorization;
    if (authHeader) {
      return authHeader;
    }

    // Try query parameter
    if (event.queryStringParameters?.token) {
      return event.queryStringParameters.token;
    }

    return null;
  }

  async authorizeRequest(event) {
    const token = this.extractTokenFromEvent(event);
    
    if (!token) {
      return {
        authorized: false,
        statusCode: 401,
        error: 'Missing authorization token'
      };
    }

    const validation = await this.validateToken(token);
    
    if (!validation.valid) {
      return {
        authorized: false,
        statusCode: 401,
        error: 'Invalid or expired token'
      };
    }

    return {
      authorized: true,
      user: validation
    };
  }
}

// Middleware function for Lambda
const withAuth = (handler) => {
  return async (event, context) => {
    const validator = new JWTValidator();
    const authResult = await validator.authorizeRequest(event);

    if (!authResult.authorized) {
      return {
        statusCode: authResult.statusCode,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          success: false,
          error: {
            message: authResult.error,
            code: 'UNAUTHORIZED'
          }
        })
      };
    }

    // Add user info to event
    event.user = authResult.user;
    
    // Call original handler
    return handler(event, context);
  };
};

module.exports = {
  JWTValidator,
  withAuth
};