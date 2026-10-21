import '../../../../core/network/roble_guard.dart';
import '../../domain/entities/project_sprint.dart';
import '../../domain/repositories/project_sprint_repository.dart';
import '../datasources/project_sprint_remote_data_source.dart';
import '../models/project_sprint_model.dart';

class ProjectSprintRepositoryImpl implements ProjectSprintRepository {
  final ProjectSprintRemoteDataSource _remote;

  ProjectSprintRepositoryImpl(this._remote);

  @override
  Future<List<ProjectSprint>> getSprints(String initiativeId) async {
    final rows = await guardRoble(_remote.readSprints);
    return rows
        .where((row) => row['iniciativa_id']?.toString() == initiativeId)
        .map(ProjectSprintModel.fromRow)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<ProjectSprint> createSprint(ProjectSprint sprint) async {
    final row = await guardRoble(
      () => _remote.createSprint(ProjectSprintModel.toRow(sprint)),
    );
    return ProjectSprintModel.fromRow(row);
  }

  @override
  Future<void> updateSprint(ProjectSprint sprint) => guardRoble(
    () => _remote.updateSprint(
      sprint.id,
      ProjectSprintModel.toRow(sprint),
    ),
  );

  @override
  Future<void> deleteSprint(ProjectSprint sprint) =>
      guardRoble(() => _remote.deleteSprint(sprint.id));
}
