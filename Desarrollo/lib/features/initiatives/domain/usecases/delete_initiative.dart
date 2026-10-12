import '../entities/initiative.dart';
import '../repositories/initiative_repository.dart';

class DeleteInitiative {
  final InitiativeRepository _repository;

  const DeleteInitiative(this._repository);

  Future<void> call(Initiative initiative) => _repository.deleteInitiative(initiative);
}
