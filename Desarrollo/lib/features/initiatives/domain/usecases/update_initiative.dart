import '../entities/initiative.dart';
import '../repositories/initiative_repository.dart';

class UpdateInitiative {
  final InitiativeRepository _repository;

  const UpdateInitiative(this._repository);

  Future<void> call(Initiative initiative) => _repository.updateInitiative(initiative);
}
