/**
 * Lambda@Edge function for regional customization and redirection
 * 
 * This function:
 * 1. Detects user's region based on CloudFront-Viewer-Country header
 * 2. Customizes content based on region (language, currency, etc.)
 * 3. Redirects to nearest region if needed for API requests
 */
exports.handler = async (event) => {
  const request = event.Records[0].cf.request;
  const headers = request.headers;
  
  // Get viewer's country from CloudFront header
  const countryCode = headers['cloudfront-viewer-country'] 
    ? headers['cloudfront-viewer-country'][0].value 
    : 'US';
  
  // Add country code as a custom header to be used by the application
  headers['x-country-code'] = [{ key: 'X-Country-Code', value: countryCode }];
  
  // Map country to region for API routing
  const regionMap = {
    // North America
    'US': 'us-east-1',
    'CA': 'us-east-1',
    'MX': 'us-east-1',
    
    // South America
    'BR': 'sa-east-1',
    'AR': 'sa-east-1',
    'CL': 'sa-east-1',
    'CO': 'sa-east-1',
    'PE': 'sa-east-1',
    
    // Europe
    'GB': 'eu-west-1',
    'DE': 'eu-west-1',
    'FR': 'eu-west-1',
    'IT': 'eu-west-1',
    'ES': 'eu-west-1',
    
    // Asia Pacific
    'JP': 'ap-northeast-1',
    'KR': 'ap-northeast-2',
    'SG': 'ap-southeast-1',
    'AU': 'ap-southeast-2',
    'IN': 'ap-south-1',
  };
  
  // Add preferred region as a custom header
  const preferredRegion = regionMap[countryCode] || 'us-east-1';
  headers['x-preferred-region'] = [{ key: 'X-Preferred-Region', value: preferredRegion }];
  
  // Map country to language for content customization
  const languageMap = {
    'US': 'en-US',
    'CA': 'en-CA',
    'MX': 'es-MX',
    'BR': 'pt-BR',
    'AR': 'es-AR',
    'CL': 'es-CL',
    'CO': 'es-CO',
    'PE': 'es-PE',
    'GB': 'en-GB',
    'DE': 'de-DE',
    'FR': 'fr-FR',
    'IT': 'it-IT',
    'ES': 'es-ES',
    'JP': 'ja-JP',
    'KR': 'ko-KR',
    'SG': 'en-SG',
    'AU': 'en-AU',
    'IN': 'en-IN',
  };
  
  // Add preferred language as a custom header
  const preferredLanguage = languageMap[countryCode] || 'en-US';
  headers['x-preferred-language'] = [{ key: 'X-Preferred-Language', value: preferredLanguage }];
  
  // Map country to currency for content customization
  const currencyMap = {
    'US': 'USD',
    'CA': 'CAD',
    'MX': 'MXN',
    'BR': 'BRL',
    'AR': 'ARS',
    'CL': 'CLP',
    'CO': 'COP',
    'PE': 'PEN',
    'GB': 'GBP',
    'DE': 'EUR',
    'FR': 'EUR',
    'IT': 'EUR',
    'ES': 'EUR',
    'JP': 'JPY',
    'KR': 'KRW',
    'SG': 'SGD',
    'AU': 'AUD',
    'IN': 'INR',
  };
  
  // Add preferred currency as a custom header
  const preferredCurrency = currencyMap[countryCode] || 'USD';
  headers['x-preferred-currency'] = [{ key: 'X-Preferred-Currency', value: preferredCurrency }];
  
  // Check if this is an API request that should be redirected to the nearest region
  if (request.uri.startsWith('/api/')) {
    // For API requests, we could redirect to the nearest regional API endpoint
    // This is just a placeholder - in a real implementation, you would use Route53 latency-based routing
    // or API Gateway with regional endpoints
    
    // For now, we'll just add a header that the application can use
    headers['x-api-region'] = [{ key: 'X-API-Region', value: preferredRegion }];
  }
  
  return request;
};