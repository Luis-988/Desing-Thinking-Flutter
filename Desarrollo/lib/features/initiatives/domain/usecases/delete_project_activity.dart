import '../entities/project_activity.dart';
import '../repositories/project_activity_repository.dart';

class DeleteProjectActivity {
  final ProjectActivityRepository _repository;

  const DeleteProjectActivity(this._repository);

  Future<void> call(ProjectActivity activity) =>
      _repository.deleteActivity(activity);
}
