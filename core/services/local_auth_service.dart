import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_application_1/domain/entities/user.dart';
import '../logging/logger.dart';

/// Provider para o serviço de autenticação local
final localAuthServiceProvider = Provider<LocalAuthService>((ref) {
  return LocalAuthServiceImpl();
});

/// Interface para o serviço de autenticação local
abstract class LocalAuthService {
  /// Inicializa o serviço
  Future<void> initialize();

  /// Registra um novo usuário
  Future<bool> register(
    String email,
    String password,
    String name, {
    String? phone,
  });

  /// Faz login do usuário
  Future<User?> signIn(String email, String password);

  /// Faz logout do usuário
  Future<void> signOut();

  /// Verifica se há um usuário logado
  Future<bool> isSignedIn();

  /// Obtém o usuário atual
  Future<User?> getCurrentUser();

  /// Atualiza os dados do usuário
  Future<bool> updateUser(User user);

  /// Altera a senha do usuário
  Future<bool> changePassword(String currentPassword, String newPassword);

  /// Remove a conta do usuário
  Future<bool> deleteAccount(String password);
}

/// Implementação do serviço de autenticação local
class LocalAuthServiceImpl implements LocalAuthService {
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';
  static const String _sessionKey = 'user_session';

  late SharedPreferences _prefs;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    Logger.info('Serviço de autenticação local inicializado');
  }

  @override
  Future<bool> register(
    String email,
    String password,
    String name, {
    String? phone,
  }) async {
    try {
      final users = _getUsers();

      // Verifica se o email já está cadastrado
      if (users.any(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      )) {
        throw AuthException('Email já está cadastrado');
      }

      // Cria o novo usuário
      final newUser = User(
        id: _generateUserId(),
        email: email.toLowerCase(),
        name: name,
        phone: phone,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Hash da senha
      final hashedPassword = _hashPassword(password);

      // Adiciona o usuário à lista
      users.add(newUser);
      _saveUsers(users);

      // Salva a senha hash
      _saveUserPassword(newUser.id, hashedPassword);

      Logger.info(
        'Usuário registrado com sucesso',
        context: {'userId': newUser.id, 'email': newUser.email},
      );

      return true;
    } catch (e) {
      Logger.error('Erro ao registrar usuário', error: e);
      rethrow;
    }
  }

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      final users = _getUsers();
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw AuthException('Email ou senha incorretos'),
      );

      // Verifica a senha
      final hashedPassword = _getUserPassword(user.id);
      if (hashedPassword == null || hashedPassword != _hashPassword(password)) {
        throw AuthException('Email ou senha incorretos');
      }

      // Verifica se o usuário está ativo
      if (!user.isActive) {
        throw AuthException('Conta desativada');
      }

      // Salva a sessão
      await _saveSession(user);

      Logger.info(
        'Usuário logado com sucesso',
        context: {'userId': user.id, 'email': user.email},
      );

      return user;
    } catch (e) {
      Logger.error('Erro ao fazer login', error: e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_currentUserKey);
    await _prefs.remove(_sessionKey);
    Logger.info('Usuário deslogado');
  }

  @override
  Future<bool> isSignedIn() async {
    final sessionData = _prefs.getString(_sessionKey);
    if (sessionData == null) return false;

    try {
      final session = json.decode(sessionData);
      final expiresAt = DateTime.parse(session['expiresAt']);
      return DateTime.now().isBefore(expiresAt);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    if (!await isSignedIn()) return null;

    try {
      final userData = _prefs.getString(_currentUserKey);
      if (userData == null) return null;

      final userJson = json.decode(userData);
      return User.fromJson(userJson);
    } catch (e) {
      Logger.error('Erro ao obter usuário atual', error: e);
      return null;
    }
  }

  @override
  Future<bool> updateUser(User user) async {
    try {
      final users = _getUsers();
      final index = users.indexWhere((u) => u.id == user.id);

      if (index == -1) {
        throw AuthException('Usuário não encontrado');
      }

      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      users[index] = updatedUser;
      _saveUsers(users);

      // Atualiza o usuário atual se for o mesmo
      final currentUser = await getCurrentUser();
      if (currentUser?.id == user.id) {
        await _saveSession(updatedUser);
      }

      Logger.info(
        'Usuário atualizado com sucesso',
        context: {'userId': user.id, 'email': user.email},
      );

      return true;
    } catch (e) {
      Logger.error('Erro ao atualizar usuário', error: e);
      rethrow;
    }
  }

  @override
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw AuthException('Usuário não logado');
      }

      // Verifica a senha atual
      final currentHashedPassword = _getUserPassword(currentUser.id);
      if (currentHashedPassword != _hashPassword(currentPassword)) {
        throw AuthException('Senha atual incorreta');
      }

      // Salva a nova senha
      _saveUserPassword(currentUser.id, _hashPassword(newPassword));

      Logger.info(
        'Senha alterada com sucesso',
        context: {'userId': currentUser.id},
      );

      return true;
    } catch (e) {
      Logger.error('Erro ao alterar senha', error: e);
      rethrow;
    }
  }

  @override
  Future<bool> deleteAccount(String password) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw AuthException('Usuário não logado');
      }

      // Verifica a senha
      final hashedPassword = _getUserPassword(currentUser.id);
      if (hashedPassword != _hashPassword(password)) {
        throw AuthException('Senha incorreta');
      }

      // Remove o usuário
      final users = _getUsers();
      users.removeWhere((u) => u.id == currentUser.id);
      _saveUsers(users);

      // Remove a senha
      _prefs.remove('user_password_${currentUser.id}');

      // Faz logout
      await signOut();

      Logger.info(
        'Conta deletada com sucesso',
        context: {'userId': currentUser.id},
      );

      return true;
    } catch (e) {
      Logger.error('Erro ao deletar conta', error: e);
      rethrow;
    }
  }

  // Métodos auxiliares

  List<User> _getUsers() {
    final usersData = _prefs.getString(_usersKey);
    if (usersData == null) return [];

    try {
      final usersJson = json.decode(usersData) as List;
      return usersJson.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      Logger.error('Erro ao carregar usuários', error: e);
      return [];
    }
  }

  void _saveUsers(List<User> users) {
    final usersJson = users.map((user) => user.toJson()).toList();
    _prefs.setString(_usersKey, json.encode(usersJson));
  }

  String _generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String? _getUserPassword(String userId) {
    return _prefs.getString('user_password_$userId');
  }

  void _saveUserPassword(String userId, String hashedPassword) {
    _prefs.setString('user_password_$userId', hashedPassword);
  }

  Future<void> _saveSession(User user) async {
    final userJson = user.toJson();
    await _prefs.setString(_currentUserKey, json.encode(userJson));

    // Sessão expira em 30 dias
    final expiresAt = DateTime.now().add(const Duration(days: 30));
    final sessionData = {
      'userId': user.id,
      'expiresAt': expiresAt.toIso8601String(),
    };
    await _prefs.setString(_sessionKey, json.encode(sessionData));
  }
}

/// Exceção de autenticação
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
