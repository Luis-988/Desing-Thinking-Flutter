import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/project_sprint.dart';
import '../../domain/repositories/project_sprint_repository.dart';

class ProjectSprintsController extends ChangeNotifier {
  final ProjectSprintRepository _repository;

  ProjectSprintsController(this._repository);

  List<ProjectSprint> _sprints = [];
  bool _isLoading = false;
  String? _error;

  List<ProjectSprint> get sprints => List.unmodifiable(_sprints);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(String initiativeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _sprints = await _repository.getSprints(initiativeId);
    } catch (error) {
      _error = messageOf(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(ProjectSprint sprint) async {
    final saved = await _repository.createSprint(sprint);
    _sprints = [..._sprints, saved]..sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  Future<void> update(ProjectSprint sprint) async {
    await _repository.updateSprint(sprint);
    _sprints = [
      for (final item in _sprints) item.id == sprint.id ? sprint : item,
    ]..sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  Future<void> delete(ProjectSprint sprint) async {
    await _repository.deleteSprint(sprint);
    _sprints = _sprints.where((item) => item.id != sprint.id).toList();
    notifyListeners();
  }
}
