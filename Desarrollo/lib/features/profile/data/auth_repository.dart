import 'package:roble/roble.dart';

import '../../../core/roble/roble_client.dart';
import '../pages/profile_page.dart';

/// Registro, inicio de sesión y sesión persistente con Roble.
class AuthRepository {
  RobleApiDataBase get _db => RobleClient.db;

  Future<ProfileUser?> restoreSession() async {
    try {
      if (!await _db.restoreSession()) return null;
      return _toProfileUser(await _db.currentUser());
    } catch (_) {
      return null;
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String program,
    required String semester,
    required String password,
  }) async {
    try {
      await _db.register(
        email: email,
        password: password,
        name: name,
        extra: {'programa': program, 'semestre': semester},
      );
      return login(email: email, password: password);
    } on RobleApiConflictException {
      return const AuthResult.failure(
        'Ya existe una cuenta con ese correo. Inicia sesión.',
      );
    } on RobleApiNetworkException {
      return const AuthResult.failure('Sin conexión con Roble.');
    } on RobleApiException catch (e) {
      return AuthResult.failure(e.message);
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final profile = await _db.login(email: email, password: password);
      return AuthResult.success(_toProfileUser(profile));
    } on RobleApiHttpException catch (e) {
      return AuthResult.failure(
        e.statusCode == 401
            ? 'El correo o la contraseña no son correctos.'
            : e.message,
      );
    } on RobleApiNetworkException {
      return const AuthResult.failure('Sin conexión con Roble.');
    } on RobleApiException catch (e) {
      return AuthResult.failure(e.message);
    }
  }

  Future<void> logout() async {
    try {
      await _db.logout();
    } catch (_) {}
  }

  ProfileUser _toProfileUser(Map<String, dynamic> profile) {
    final extra = profile['extra'] is Map
        ? Map<String, dynamic>.from(profile['extra'] as Map)
        : <String, dynamic>{};
    return ProfileUser(
      name: (profile['name'] ?? '').toString(),
      email: (profile['email'] ?? '').toString(),
      program: (extra['programa'] ?? '').toString(),
      semester: (extra['semestre'] ?? '').toString(),
      password: '',
    );
  }
}
