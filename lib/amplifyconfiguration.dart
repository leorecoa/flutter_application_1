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
                            "PoolId": "us-east-1:AIDACKCEVSQ6C2EXAMPLE",
                            "Region": "us-east-1"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "us-east-1_GrxATGznC",
                        "AppClientId": "7c86ku17e2ff7uvrsuh7k0822h",
                        "Region": "us-east-1"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": ["email"],
                        "signupAttributes": ["email"],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": ["SMS"],
                        "verificationMechanisms": ["email"]
                    }
                }
            }
        }
    },
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "agendaFacilAPI": {
                    "endpointType": "REST",
                    "endpoint": "https://hk5bp3m596.execute-api.us-east-1.amazonaws.com/Prod",
                    "region": "us-east-1",
                    "authorizationType": "AMAZON_COGNITO_USER_POOLS"
                }
            }
        }
    },
    "storage": {
        "plugins": {
            "awsS3StoragePlugin": {
                "bucket": "agenda-facil-simple-working-files-400621361850",
                "region": "us-east-1",
                "defaultAccessLevel": "guest"
            }
        }
    }
}''';