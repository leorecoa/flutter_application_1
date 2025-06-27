import 'dart:convert';
import 'package:http/http.dart' as http;

class CognitoService {
  static const String _clientId = 'kaog4tnmh1trlbuiu4ckf3sc8';
  static const String _endpoint = 'https://cognito-idp.us-east-1.amazonaws.com/';

  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    final headers = {
      'Content-Type': 'application/x-amz-json-1.1',
      'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
    };

    final body = {
      'AuthFlow': 'USER_PASSWORD_AUTH',
      'ClientId': _clientId,
      'AuthParameters': {
        'USERNAME': email,
        'PASSWORD': password,
      },
    };

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: headers,
      body: jsonEncode(body),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'accessToken': responseData['AuthenticationResult']['AccessToken'],
        'idToken': responseData['AuthenticationResult']['IdToken'],
        'refreshToken': responseData['AuthenticationResult']['RefreshToken'],
      };
    } else {
      return {
        'success': false,
        'error': responseData['message'] ?? 'Login failed',
      };
    }
  }
}