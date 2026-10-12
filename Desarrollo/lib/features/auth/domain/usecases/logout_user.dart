import '../repositories/auth_repository.dart';

class LogoutUser {
  final AuthRepository _repository;

  const LogoutUser(this._repository);

  Future<void> call() => _repository.logout();
}
