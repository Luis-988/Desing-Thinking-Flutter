import '../entities/project_sprint.dart';

abstract class ProjectSprintRepository {
  Future<List<ProjectSprint>> getSprints(String initiativeId);
  Future<ProjectSprint> createSprint(ProjectSprint sprint);
  Future<void> updateSprint(ProjectSprint sprint);
  Future<void> deleteSprint(ProjectSprint sprint);
}
