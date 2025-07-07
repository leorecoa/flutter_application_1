const amplifyconfig = '''
{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "agendemais": {
          "endpointType": "REST",
          "endpoint": "${String.fromEnvironment('AWS_API_ENDPOINT', defaultValue: 'https://5wy56rw801.execute-api.us-east-1.amazonaws.com/prod')}",
          "region": "${String.fromEnvironment('AWS_REGION', defaultValue: 'us-east-1')}",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  },
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/2.0",
        "Version": "2.0",
        "IdentityManager": {
          "Default": {}
        },
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "${String.fromEnvironment('COGNITO_IDENTITY_POOL_ID', defaultValue: 'us-east-1:YOUR_IDENTITY_POOL_ID')}",
              "Region": "${String.fromEnvironment('AWS_REGION', defaultValue: 'us-east-1')}"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "${String.fromEnvironment('COGNITO_USER_POOL_ID', defaultValue: 'us-east-1_YOUR_USER_POOL_ID')}",
            "AppClientId": "${String.fromEnvironment('COGNITO_APP_CLIENT_ID', defaultValue: 'YOUR_APP_CLIENT_ID')}",
            "Region": "${String.fromEnvironment('AWS_REGION', defaultValue: 'us-east-1')}"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "socialProviders": [],
            "usernameAttributes": ["email"],
            "signupAttributes": ["email", "name"],
            "passwordProtectionSettings": {
              "passwordPolicyMinLength": 8,
              "passwordPolicyCharacters": ["REQUIRES_LOWERCASE", "REQUIRES_UPPERCASE", "REQUIRES_NUMBERS", "REQUIRES_SYMBOLS"]
            },
            "mfaConfiguration": "OFF",
            "mfaTypes": ["SMS"],
            "verificationMechanisms": ["email"]
          }
        }
      }
    }
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "${String.fromEnvironment('S3_BUCKET_NAME', defaultValue: 'agendemais-storage')}",
        "region": "${String.fromEnvironment('AWS_REGION', defaultValue: 'us-east-1')}",
        "defaultAccessLevel": "guest"
      }
    }
  }
}
''';