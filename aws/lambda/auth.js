const AWS = require('aws-sdk');
const cognito = new AWS.CognitoIdentityServiceProvider();

const USER_POOL_ID = process.env.COGNITO_USER_POOL_ID;
const CLIENT_ID = process.env.COGNITO_CLIENT_ID;

exports.handler = async (event) => {
    const { httpMethod, path, body } = event;
    
    try {
        if (path.includes('/auth/login')) {
            return await login(JSON.parse(body));
        } else if (path.includes('/auth/register')) {
            return await register(JSON.parse(body));
        } else if (path.includes('/auth/refresh')) {
            return await refreshToken(JSON.parse(body));
        }
        
        return {
            statusCode: 404,
            headers: { 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({ message: 'Not found' })
        };
    } catch (error) {
        return {
            statusCode: 500,
            headers: { 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({ message: error.message })
        };
    }
};

async function login({ email, password }) {
    try {
        const params = {
            AuthFlow: 'ADMIN_NO_SRP_AUTH',
            UserPoolId: USER_POOL_ID,
            ClientId: CLIENT_ID,
            AuthParameters: {
                USERNAME: email,
                PASSWORD: password
            }
        };
        
        const result = await cognito.adminInitiateAuth(params).promise();
        
        return {
            statusCode: 200,
            headers: { 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({
                accessToken: result.AuthenticationResult.AccessToken,
                idToken: result.AuthenticationResult.IdToken,
                refreshToken: result.AuthenticationResult.RefreshToken,
                expiresIn: result.AuthenticationResult.ExpiresIn
            })
        };
    } catch (error) {
        return {
            statusCode: 401,
            headers: { 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({ message: 'Invalid credentials' })
        };
    }
}

async function register({ email, password, name }) {
    try {
        const params = {
            UserPoolId: USER_POOL_ID,
            Username: email,
            TemporaryPassword: password,
            MessageAction: 'SUPPRESS',
            UserAttributes: [
                {
                    Name: 'email',
                    Value: email
                },
                {
                    Name: 'name',
                    Value: name
                },
                {
                    Name: 'email_verified',
                    Value: 'true'
                }
            ]
        };
        
        await cognito.adminCreateUser(params).promise();
        
        // Set permanent password
        await cognito.adminSetUserPassword({
            UserPoolId: USER_POOL_ID,
            Username: email,
            Password: password,
            Permanent: true
        }).promise();
        
        return {
            statusCode: 201,
            headers: { 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({ message: 'User created successfully' })
        };
    } catch (error) {
        return {
            statusCode: 400,
            headers: { 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({ message: error.message })
        };
    }
}

async function refreshToken({ refreshToken }) {
    try {
        const params = {
            AuthFlow: 'REFRESH_TOKEN_AUTH',
            UserPoolId: USER_POOL_ID,
            ClientId: CLIENT_ID,
            AuthParameters: {
                REFRESH_TOKEN: refreshToken
            }
        };
        
        const result = await cognito.adminInitiateAuth(params).promise();
        
        return {
            statusCode: 200,
            headers: { 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({
                accessToken: result.AuthenticationResult.AccessToken,
                idToken: result.AuthenticationResult.IdToken,
                expiresIn: result.AuthenticationResult.ExpiresIn
            })
        };
    } catch (error) {
        return {
            statusCode: 401,
            headers: { 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({ message: 'Invalid refresh token' })
        };
    }
}