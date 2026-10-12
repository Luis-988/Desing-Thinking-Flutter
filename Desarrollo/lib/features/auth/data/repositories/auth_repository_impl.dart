import 'package:roble/roble.dart';

import '../../domain/entities/auth_result.dart';
import '../../domain/entities/profile_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/profile_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Future<ProfileUser?> restoreSession() async {
    try {
      if (!await _remote.restoreSession()) return null;
      return ProfileUserModel.fromProfile(await _remote.currentUser());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String program,
    required String semester,
    required String password,
  }) async {
    try {
      await _remote.register(
        name: name,
        email: email,
        password: password,
        extra: {'programa': program, 'semestre': semester},
      );
      return await login(email: email, password: password);
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

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final profile = await _remote.login(email: email, password: password);
      return AuthResult.success(ProfileUserModel.fromProfile(profile));
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

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {}
  }
}
