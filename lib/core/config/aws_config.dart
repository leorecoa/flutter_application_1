class AWSConfig {
  // Substitua pelos valores do seu User Pool
  static const String region = 'us-east-1';
  static const String userPoolId = 'us-east-1_XXXXXXXXX'; // Pegar do console
  static const String clientId = 'xxxxxxxxxxxxxxxxxxxxxxxxxx'; // Pegar do console
  static const String identityPoolId = 'us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'; // Opcional
  
  // Endpoints
  static const String cognitoEndpoint = 'https://cognito-idp.$region.amazonaws.com/';
  static const String cognitoIdentityEndpoint = 'https://cognito-identity.$region.amazonaws.com/';
}