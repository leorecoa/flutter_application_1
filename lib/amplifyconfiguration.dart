// This file is generated during the Amplify initialization process
// It will be replaced with actual values after running 'amplify init'
// For now, we're providing a placeholder that can be used in development

const amplifyconfig = '''{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "COGNITO_IDENTITY_POOL_ID",
              "Region": "REGION"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "COGNITO_USER_POOL_ID",
            "AppClientId": "COGNITO_APP_CLIENT_ID",
            "Region": "REGION"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "socialProviders": [],
            "usernameAttributes": ["EMAIL"],
            "signupAttributes": ["EMAIL", "NAME"],
            "passwordProtectionSettings": {
              "passwordPolicyMinLength": 8,
              "passwordPolicyCharacters": [
                "REQUIRES_LOWERCASE",
                "REQUIRES_UPPERCASE",
                "REQUIRES_NUMBERS",
                "REQUIRES_SYMBOLS"
              ]
            },
            "mfaConfiguration": "OFF",
            "mfaTypes": ["SMS"],
            "verificationMechanisms": ["EMAIL"]
          }
        }
      }
    }
  },
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "agendemais": {
          "endpointType": "GraphQL",
          "endpoint": "API_ENDPOINT",
          "region": "REGION",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "STORAGE_BUCKET",
        "region": "REGION",
        "defaultAccessLevel": "private"
      }
    }
  },
  "analytics": {
    "plugins": {
      "awsPinpointAnalyticsPlugin": {
        "pinpointAnalytics": {
          "appId": "PINPOINT_APP_ID",
          "region": "REGION"
        },
        "pinpointTargeting": {
          "region": "REGION"
        }
      }
    }
  }
}''';