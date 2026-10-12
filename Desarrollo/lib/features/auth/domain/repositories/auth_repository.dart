import '../entities/auth_result.dart';
import '../entities/profile_user.dart';

/// Contrato del dominio para autenticación.
abstract class AuthRepository {
  Future<ProfileUser?> restoreSession();

  Future<AuthResult> register({
    required String name,
    required String email,
    required String program,
    required String semester,
    required String password,
  });

  Future<AuthResult> login({required String email, required String password});

  Future<void> logout();
}
