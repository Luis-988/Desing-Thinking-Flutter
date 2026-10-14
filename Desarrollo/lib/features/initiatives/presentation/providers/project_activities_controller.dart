import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/project_activity.dart';
import '../../domain/repositories/project_activity_repository.dart';

class ProjectActivitiesController extends ChangeNotifier {
  final ProjectActivityRepository _repository;

  ProjectActivitiesController(this._repository);

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
      _activities = await _repository.getActivities(initiativeId);
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
    if (!isLeader) {
      throw const AppException('Solo el líder puede añadir actividades.');
    }
    final saved = await _repository.createActivity(activity);
    _activities = [..._activities, saved]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  Future<void> setCompleted(
    ProjectActivity activity,
    bool isCompleted, {
    required bool isTeamMember,
  }) async {
    if (!isTeamMember) {
      throw const AppException(
        'Solo los integrantes del equipo pueden actualizar actividades.',
      );
    }
    final updated = activity.copyWith(isCompleted: isCompleted);
    await _repository.updateActivity(updated);
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
    if (!isLeader) {
      throw const AppException('Solo el líder puede modificar actividades.');
    }
    await _repository.updateActivity(activity);
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
    if (!isLeader) {
      throw const AppException('Solo el líder puede eliminar actividades.');
    }
    await _repository.deleteActivity(activity);
    _activities = _activities.where((item) => item.id != activity.id).toList();
    notifyListeners();
  }
}
