import '../entities/project_activity.dart';
import '../repositories/project_activity_repository.dart';

class CreateProjectActivity {
  final ProjectActivityRepository _repository;

  const CreateProjectActivity(this._repository);

  Future<ProjectActivity> call(ProjectActivity activity) =>
      _repository.createActivity(activity);
}
