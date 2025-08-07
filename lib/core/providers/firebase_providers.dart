import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/services/auth_service.dart';
import 'package:flutter_application_1/core/services/auth_service_firebase.dart';

/// Provider para a instância do FirebaseAuth.
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

/// Provider para a instância do FirebaseFirestore.
final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// Provider para o nosso [AuthService].
///
/// Ele depende do [firebaseAuthProvider] para obter a instância do Firebase
/// e cria a implementação [AuthServiceFirebase].
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthServiceFirebase(ref.watch(firebaseAuthProvider));
});
