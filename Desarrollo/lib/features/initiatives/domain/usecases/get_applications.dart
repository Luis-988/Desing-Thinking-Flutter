import '../entities/initiative_application.dart';
import '../repositories/initiative_repository.dart';

class GetApplications {
  final InitiativeRepository _repository;

  const GetApplications(this._repository);

  Future<List<InitiativeApplication>> call() => _repository.getApplications();
}
