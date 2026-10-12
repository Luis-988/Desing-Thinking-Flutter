import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository _repository;

  const RegisterUser(this._repository);

  Future<AuthResult> call({
    required String name,
    required String email,
    required String program,
    required String semester,
    required String password,
  }) =>
      _repository.register(
        name: name,
        email: email,
        program: program,
        semester: semester,
        password: password,
      );
}
