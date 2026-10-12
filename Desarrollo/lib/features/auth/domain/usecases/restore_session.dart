import '../entities/profile_user.dart';
import '../repositories/auth_repository.dart';

class RestoreSession {
  final AuthRepository _repository;

  const RestoreSession(this._repository);

  Future<ProfileUser?> call() => _repository.restoreSession();
}
