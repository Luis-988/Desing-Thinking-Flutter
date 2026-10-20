import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/project_activity.dart';
import '../../domain/repositories/project_activity_repository.dart';
import '../../domain/services/project_activity_policy.dart';
import '../../domain/usecases/create_project_activity.dart';
import '../../domain/usecases/delete_project_activity.dart';
import '../../domain/usecases/get_project_activities.dart';
import '../../domain/usecases/update_project_activity.dart';

class ProjectActivitiesController extends ChangeNotifier {
  final GetProjectActivities _getActivities;
  final CreateProjectActivity _createActivity;
  final UpdateProjectActivity _updateActivity;
  final DeleteProjectActivity _deleteActivity;

  ProjectActivitiesController(ProjectActivityRepository repository)
    : this._(
        getActivities: GetProjectActivities(repository),
        createActivity: CreateProjectActivity(repository),
        updateActivity: UpdateProjectActivity(repository),
        deleteActivity: DeleteProjectActivity(repository),
      );

  ProjectActivitiesController.fromUseCases({
    required GetProjectActivities getActivities,
    required CreateProjectActivity createActivity,
    required UpdateProjectActivity updateActivity,
    required DeleteProjectActivity deleteActivity,
  }) : this._(
         getActivities: getActivities,
         createActivity: createActivity,
         updateActivity: updateActivity,
         deleteActivity: deleteActivity,
       );

  ProjectActivitiesController._({
    required GetProjectActivities getActivities,
    required CreateProjectActivity createActivity,
    required UpdateProjectActivity updateActivity,
    required DeleteProjectActivity deleteActivity,
  }) : _getActivities = getActivities,
       _createActivity = createActivity,
       _updateActivity = updateActivity,
       _deleteActivity = deleteActivity;

  List<ProjectActivity> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<ProjectActivity> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(String initiativeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _activities = await _getActivities(initiativeId);
    } catch (error) {
      _error = messageOf(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(
    ProjectActivity activity, {
    required bool isLeader,
  }) async {
    ProjectActivityPolicy.requireLeader(isLeader);
    final saved = await _createActivity(activity);
    _activities = [..._activities, saved]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  Future<void> setCompleted(
    ProjectActivity activity,
    bool isCompleted, {
    required bool isTeamMember,
  }) async {
    ProjectActivityPolicy.requireTeamMember(isTeamMember);
    final updated = activity.copyWith(isCompleted: isCompleted);
    await _updateActivity(updated);
    _activities = [
      for (final item in _activities)
        if (item.id == updated.id) updated else item,
    ];
    notifyListeners();
  }

  Future<void> update(
    ProjectActivity activity, {
    required bool isLeader,
  }) async {
    ProjectActivityPolicy.requireLeader(isLeader);
    await _updateActivity(activity);
    _activities = [
      for (final item in _activities)
        if (item.id == activity.id) activity else item,
    ]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  Future<void> delete(
    ProjectActivity activity, {
    required bool isLeader,
  }) async {
    ProjectActivityPolicy.requireLeader(isLeader);
    await _deleteActivity(activity);
    _activities = _activities.where((item) => item.id != activity.id).toList();
    notifyListeners();
  }
}
