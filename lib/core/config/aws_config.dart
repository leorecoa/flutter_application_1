class AWSConfig {
  static const String region = 'us-east-1';
  static const String cognitoUserPoolId = 'us-east-1_Pe0LL9WS7';
  static const String cognitoClientId = '2gq42d2p3v8s4et9i8h916oce6';
  static const String dynamoTableName = 'agendafacil-dev-agendamentos';
  static const String environment = 'dev'; // 'dev', 'staging', 'prod'
  
  // Endpoints de produção - SAM Deploy
  static const String apiGatewayUrl = 'https://dy2yuasirk.execute-api.us-east-1.amazonaws.com/dev';
  static const String authEndpoint = '$apiGatewayUrl/auth';
  static const String agendamentosEndpoint = '$apiGatewayUrl/agendamentos';
  static const String pagamentosEndpoint = '$apiGatewayUrl/pagamentos';
  static const String clientesEndpoint = '$apiGatewayUrl/clientes';
  static const String servicosEndpoint = '$apiGatewayUrl/servicos';
  
  // Configurações do Amplify
  static const String amplifyAppId = 'agendafacil-saas';
  static const String amplifyDomain = 'amplifyapp.com';
}