const AWS = require('aws-sdk');
const jwt = require('jsonwebtoken');

const cognito = new AWS.CognitoIdentityServiceProvider();

class AuthHelper {
  static extractUserFromEvent(event) {
    try {
      const claims = event.requestContext?.authorizer?.claims;
      if (!claims) return null;

      return {
        userId: claims.sub,
        email: claims.email,
        name: claims.name,
        phoneNumber: claims.phone_number
      };
    } catch (error) {
      console.error('Error extracting user from event:', error);
      return null;
    }
  }

  static async verifyToken(token) {
    try {
      // For Cognito JWT verification, you would typically use jwks
      // This is a simplified version
      const decoded = jwt.decode(token, { complete: true });
      return decoded?.payload;
    } catch (error) {
      console.error('Token verification error:', error);
      return null;
    }
  }

  static async createCognitoUser(email, password, name, phoneNumber) {
    try {
      const params = {
        UserPoolId: process.env.COGNITO_USER_POOL_ID,
        Username: email,
        TemporaryPassword: password,
        MessageAction: 'SUPPRESS',
        UserAttributes: [
          { Name: 'email', Value: email },
          { Name: 'name', Value: name },
          { Name: 'email_verified', Value: 'true' }
        ]
      };

      if (phoneNumber) {
        params.UserAttributes.push({ Name: 'phone_number', Value: phoneNumber });
      }

      const result = await cognito.adminCreateUser(params).promise();

      // Set permanent password
      await cognito.adminSetUserPassword({
        UserPoolId: process.env.COGNITO_USER_POOL_ID,
        Username: email,
        Password: password,
        Permanent: true
      }).promise();

      return result.User;
    } catch (error) {
      console.error('Cognito user creation error:', error);
      throw error;
    }
  }

  static async authenticateUser(email, password) {
    try {
      const params = {
        AuthFlow: 'ADMIN_NO_SRP_AUTH',
        UserPoolId: process.env.COGNITO_USER_POOL_ID,
        ClientId: process.env.COGNITO_CLIENT_ID,
        AuthParameters: {
          USERNAME: email,
          PASSWORD: password
        }
      };

      const result = await cognito.adminInitiateAuth(params).promise();
      return result.AuthenticationResult;
    } catch (error) {
      console.error('Authentication error:', error);
      throw error;
    }
  }

  static generateUserId() {
    return 'user_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  }
}

module.exports = AuthHelper;