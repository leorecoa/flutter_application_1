import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/models/appointment.dart';
import 'package:flutter_application_1/core/services/amplify_service_mock.dart';
import 'package:flutter_application_1/core/services/amplify_service_real.dart';

/// Controla se a aplicação deve usar o mock ou a implementação real da AWS.
/// Para rodar com a AWS, use: `flutter run --dart-define=USE_REAL_AWS=true`
const bool _useRealAws = bool.fromEnvironment('USE_REAL_AWS');

/// Provider que decide qual implementação do AmplifyService usar.
final amplifyServiceProvider = Provider<AmplifyService>((ref) {
  if (_useRealAws) {
    return AmplifyServiceReal();
  }
  return AmplifyServiceMock();
});

/// Interface para abstrair os serviços do AWS Amplify.
/// Isso permite alternar entre uma implementação real e uma simulada (mock).
abstract class AmplifyService {
  Future<void> configure() async {
    // A implementação será feita nas classes filhas
  }

  Future<bool> isUserSignedIn();
  Future<bool> signIn(String email, String password);
  Future<void> signOut();
  Future<List<Appointment>> getAppointments(
    String tenantId, {
    int limit = 20,
    String? nextToken,
  });
  Future<void> resetPassword(String username);
  Future<void> confirmResetPassword({
    required String username,
    required String newPassword,
    required String confirmationCode,
  });
}
