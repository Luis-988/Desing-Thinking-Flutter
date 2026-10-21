import '../entities/project_activity.dart';
import '../repositories/project_activity_repository.dart';

class UpdateProjectActivity {
  final ProjectActivityRepository _repository;

  const UpdateProjectActivity(this._repository);

  Future<void> call(ProjectActivity activity) =>
      _repository.updateActivity(activity);
}
