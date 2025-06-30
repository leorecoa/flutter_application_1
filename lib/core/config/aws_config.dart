class AWSConfig {
  static const String region = 'us-east-1';
  static const String cognitoUserPoolId = 'us-east-1_1ILlzLRnO';
  static const String cognitoClientId = '7pcl8uniop2pphr76mc5vk8lao';
  static const String dynamoTableName = 'agendamentos-app-agendamentos';
  
  // Endpoints de produção (serão atualizados após deploy das Lambdas)
  static const String apiGatewayUrl = 'https://api.agendafacil.app';
  static const String authEndpoint = '$apiGatewayUrl/auth';
  static const String agendamentosEndpoint = '$apiGatewayUrl/agendamentos';
  static const String pagamentosEndpoint = '$apiGatewayUrl/pagamentos';
  static const String subscriptionEndpoint = '$apiGatewayUrl/subscription';
  
  // Configurações do Amplify
  static const String amplifyAppId = 'agendafacil-saas';
  static const String amplifyDomain = 'amplifyapp.com';
}