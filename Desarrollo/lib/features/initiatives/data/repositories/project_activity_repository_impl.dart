import '../../../../core/network/roble_guard.dart';
import '../../domain/entities/project_activity.dart';
import '../../domain/repositories/project_activity_repository.dart';
import '../datasources/project_activity_remote_data_source.dart';
import '../models/project_activity_model.dart';

class ProjectActivityRepositoryImpl implements ProjectActivityRepository {
  final ProjectActivityRemoteDataSource _remote;

  ProjectActivityRepositoryImpl(this._remote);

  @override
  Future<List<ProjectActivity>> getActivities(String initiativeId) async {
    final rows = await guardRoble(() => _remote.readActivities(initiativeId));
    final activities =
        rows
            .where((row) => row['iniciativa_id']?.toString() == initiativeId)
            .map(ProjectActivityModel.fromStoredJson)
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return activities;
  }

  @override
  Future<ProjectActivity> createActivity(ProjectActivity activity) async {
    final row = await guardRoble(
      () => _remote.createActivity(
        activity.initiativeId,
        ProjectActivityModel.toRow(activity),
      ),
    );
    return ProjectActivityModel.fromStoredJson(row);
  }

  @override
  Future<void> updateActivity(ProjectActivity activity) => guardRoble(
    () => _remote.updateActivity(activity.initiativeId, activity.id, {
      'titulo': activity.title,
      'descripcion': activity.description,
      'fecha_limite': DateTime(
        activity.dueDate.year,
        activity.dueDate.month,
        activity.dueDate.day,
      ).toIso8601String(),
      'completada': activity.isCompleted,
    }),
  );

  @override
  Future<void> deleteActivity(ProjectActivity activity) => guardRoble(
    () => _remote.deleteActivity(activity.initiativeId, activity.id),
  );
}
