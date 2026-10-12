import '../entities/initiative_application.dart';
import '../repositories/initiative_repository.dart';

class SubmitApplication {
  final InitiativeRepository _repository;

  const SubmitApplication(this._repository);

  Future<InitiativeApplication> call(InitiativeApplication application) => _repository.submitApplication(application);
}
