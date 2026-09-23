import '../entities/initiative.dart';
import '../repositories/initiative_repository.dart';

class CreateInitiative {
  final InitiativeRepository _repository;

  const CreateInitiative(this._repository);

  Future<Initiative> call(Initiative initiative) => _repository.createInitiative(initiative);
}
