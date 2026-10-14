import '../entities/project_activity.dart';

abstract class ProjectActivityRepository {
  Future<List<ProjectActivity>> getActivities(String initiativeId);
  Future<ProjectActivity> createActivity(ProjectActivity activity);
  Future<void> updateActivity(ProjectActivity activity);
  Future<void> deleteActivity(ProjectActivity activity);
}
