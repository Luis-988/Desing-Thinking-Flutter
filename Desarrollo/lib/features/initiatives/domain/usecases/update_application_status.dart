import '../entities/initiative_application.dart';
import '../repositories/initiative_repository.dart';

class UpdateApplicationStatus {
  final InitiativeRepository _repository;

  const UpdateApplicationStatus(this._repository);

  Future<void> call(
    InitiativeApplication application,
    ApplicationStatus status,
  ) =>
      _repository.updateApplicationStatus(application, status);
}
