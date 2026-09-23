import 'profile_user.dart';

/// Resultado de registrarse o iniciar sesión: un usuario o un mensaje de error.
class AuthResult {
  final ProfileUser? user;
  final String? error;

  const AuthResult.success(this.user) : error = null;
  const AuthResult.failure(this.error) : user = null;
}
