import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository _repository;

  const LoginUser(this._repository);

  Future<AuthResult> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}
