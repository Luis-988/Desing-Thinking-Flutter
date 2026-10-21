import '../entities/project_activity.dart';
import '../repositories/project_activity_repository.dart';

class GetProjectActivities {
  final ProjectActivityRepository _repository;

  const GetProjectActivities(this._repository);

  Future<List<ProjectActivity>> call(String initiativeId) =>
      _repository.getActivities(initiativeId);
}
