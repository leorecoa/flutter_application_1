import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/aws_config.dart';

class AWSCognitoService {
  static String? _accessToken;
  static String? _idToken;
  static String? _refreshToken;
  static Map<String, dynamic>? _userAttributes;

  static Future<Map<String, dynamic>> signIn(
      String email, String password) async {
    try {
      final headers = {
        'Content-Type': 'application/x-amz-json-1.1',
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
      };

      final body = {
        'AuthFlow': 'USER_PASSWORD_AUTH',
        'ClientId': AWSConfig.cognitoClientId,
        'AuthParameters': {
          'USERNAME': email,
          'PASSWORD': password,
        },
      };

      final response = await http.post(
        Uri.parse('https://cognito-idp.${AWSConfig.region}.amazonaws.com/'),
        headers: headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _accessToken = responseData['AuthenticationResult']['AccessToken'];
        _idToken = responseData['AuthenticationResult']['IdToken'];
        _refreshToken = responseData['AuthenticationResult']['RefreshToken'];

        _userAttributes = _decodeJWT(_idToken!);

        return {
          'success': true,
          'user': {
            'id': _userAttributes!['sub'],
            'email': _userAttributes!['email'],
            'name': _userAttributes!['name'] ?? _userAttributes!['email'],
          },
          'tokens': {
            'accessToken': _accessToken,
            'idToken': _idToken,
            'refreshToken': _refreshToken,
          }
        };
      } else {
        return {
          'success': false,
          'error': _getErrorMessage(responseData),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro de conexão: $e',
      };
    }
  }

  static Future<void> signOut() async {
    try {
      if (_accessToken != null) {
        final headers = {
          'Content-Type': 'application/x-amz-json-1.1',
          'X-Amz-Target': 'AWSCognitoIdentityProviderService.GlobalSignOut',
        };

        final body = {
          'AccessToken': _accessToken,
        };

        await http.post(
          Uri.parse('https://cognito-idp.${AWSConfig.region}.amazonaws.com/'),
          headers: headers,
          body: jsonEncode(body),
        );
      }
    } catch (e) {
      // Ignorar erros de logout
    } finally {
      _clearTokens();
    }
  }

  static Future<bool> isSignedIn() async {
    if (_accessToken == null) return false;

    try {
      final payload = _decodeJWT(_accessToken!);
      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return exp > now;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic>? getCurrentUser() {
    if (_userAttributes == null) return null;

    return {
      'id': _userAttributes!['sub'],
      'email': _userAttributes!['email'],
      'name': _userAttributes!['name'] ?? _userAttributes!['email'],
    };
  }

  static String? getAccessToken() => _accessToken;

  static Future<Map<String, dynamic>> refreshTokens() async {
    if (_refreshToken == null) {
      return {'success': false, 'error': 'No refresh token available'};
    }

    try {
      final headers = {
        'Content-Type': 'application/x-amz-json-1.1',
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
      };

      final body = {
        'AuthFlow': 'REFRESH_TOKEN_AUTH',
        'ClientId': AWSConfig.cognitoClientId,
        'AuthParameters': {
          'REFRESH_TOKEN': _refreshToken,
        },
      };

      final response = await http.post(
        Uri.parse('https://cognito-idp.${AWSConfig.region}.amazonaws.com/'),
        headers: headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _accessToken = responseData['AuthenticationResult']['AccessToken'];
        _idToken = responseData['AuthenticationResult']['IdToken'];

        return {'success': true};
      } else {
        return {'success': false, 'error': _getErrorMessage(responseData)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erro ao renovar token: $e'};
    }
  }

  static void _clearTokens() {
    _accessToken = null;
    _idToken = null;
    _refreshToken = null;
    _userAttributes = null;
  }

  static Map<String, dynamic> _decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid JWT token');

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));

    return jsonDecode(decoded);
  }

  static String _getErrorMessage(Map<String, dynamic> responseData) {
    final errorType = responseData['__type'] ?? '';

    switch (errorType) {
      case 'NotAuthorizedException':
        return 'Email ou senha incorretos';
      case 'UserNotFoundException':
        return 'Usuário não encontrado';
      case 'UserNotConfirmedException':
        return 'Email não confirmado';
      case 'TooManyRequestsException':
        return 'Muitas tentativas. Tente novamente mais tarde';
      default:
        return responseData['message'] ?? 'Erro desconhecido';
    }
  }
}
