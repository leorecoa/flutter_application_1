import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import '../../amplifyconfiguration.dart';

class AmplifyService {
  static bool _isConfigured = false;

  static Future<void> configureAmplify() async {
    if (_isConfigured) return;

    try {
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyAPI(),
        AmplifyStorageS3(),
      ]);

      await Amplify.configure(amplifyconfig);
      _isConfigured = true;
      safePrint('Amplify configured successfully');
    } catch (e) {
      safePrint('Error configuring Amplify: $e');
      rethrow;
    }
  }

  static Future<bool> isSignedIn() async {
    try {
      final result = await Amplify.Auth.fetchAuthSession();
      return result.isSignedIn;
    } catch (e) {
      safePrint('Error checking auth status: $e');
      return false;
    }
  }

  static Future<AuthUser?> getCurrentUser() async {
    try {
      return await Amplify.Auth.getCurrentUser();
    } catch (e) {
      safePrint('Error getting current user: $e');
      return null;
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session is CognitoAuthSession) {
        return session.userPoolTokensResult.value.accessToken.raw;
      }
      return null;
    } catch (e) {
      safePrint('Error getting access token: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final Map<String, dynamic> userInfo = {};
      
      for (final attr in attributes) {
        userInfo[attr.userAttributeKey.key] = attr.value;
      }
      
      return userInfo;
    } catch (e) {
      safePrint('Error getting user attributes: $e');
      return null;
    }
  }

  static Future<SignInResult> signIn(String email, String password) async {
    try {
      return await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
    } catch (e) {
      safePrint('Error signing in: $e');
      rethrow;
    }
  }

  static Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userAttributes = <AuthUserAttributeKey, String>{
        AuthUserAttributeKey.email: email,
        AuthUserAttributeKey.name: name,
      };

      return await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(userAttributes: userAttributes),
      );
    } catch (e) {
      safePrint('Error signing up: $e');
      rethrow;
    }
  }

  static Future<SignUpResult> confirmSignUp(String email, String code) async {
    try {
      return await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: code,
      );
    } catch (e) {
      safePrint('Error confirming sign up: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      safePrint('Error signing out: $e');
      rethrow;
    }
  }

  static Future<ResetPasswordResult> resetPassword(String email) async {
    try {
      return await Amplify.Auth.resetPassword(username: email);
    } catch (e) {
      safePrint('Error resetting password: $e');
      rethrow;
    }
  }

  static Future<ResetPasswordResult> confirmResetPassword({
    required String email,
    required String newPassword,
    required String confirmationCode,
  }) async {
    try {
      return await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
    } catch (e) {
      safePrint('Error confirming reset password: $e');
      rethrow;
    }
  }
}