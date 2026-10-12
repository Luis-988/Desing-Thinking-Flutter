import '../entities/initiative.dart';
import '../repositories/initiative_repository.dart';

class GetInitiatives {
  final InitiativeRepository _repository;

  const GetInitiatives(this._repository);

  Future<List<Initiative>> call() => _repository.getInitiatives();
}
