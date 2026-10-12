import '../entities/initiative.dart';
import '../repositories/initiative_repository.dart';

class SaveInitiativeViews {
  final InitiativeRepository _repository;

  const SaveInitiativeViews(this._repository);

  Future<void> call(Initiative initiative) => _repository.saveViews(initiative);
}
