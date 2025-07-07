import '../core/constants/app_constants.dart';

const amplifyconfig = '''
{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "agendemais": {
          "endpointType": "REST",
          "endpoint": "${AppConstants.apiBaseUrl}",
          "region": "${AppConstants.awsRegion}",
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
              "PoolId": "${AppConstants.cognitoIdentityPoolId}",
              "Region": "${AppConstants.awsRegion}"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "${AppConstants.cognitoUserPoolId}",
            "AppClientId": "${AppConstants.cognitoAppClientId}",
            "Region": "${AppConstants.awsRegion}"
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