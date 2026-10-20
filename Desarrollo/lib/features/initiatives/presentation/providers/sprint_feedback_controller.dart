import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/sprint_feedback.dart';
import '../../domain/repositories/sprint_feedback_repository.dart';

class SprintFeedbackController extends ChangeNotifier {
  final SprintFeedbackRepository _repository;
  List<SprintFeedback> _items = [];
  String? _error;

  SprintFeedbackController(this._repository);

  List<SprintFeedback> get items => List.unmodifiable(_items);
  String? get error => _error;

  List<SprintFeedback> forSprint(String sprintId) =>
      _items.where((item) => item.sprintId == sprintId).toList();

  Future<void> load(String initiativeId) async {
    try {
      _error = null;
      _items = await _repository.getFeedback(initiativeId);
    } catch (error) {
      _error = messageOf(error);
    }
    notifyListeners();
  }

  Future<void> create(SprintFeedback feedback) async {
    final saved = await _repository.createFeedback(feedback);
    _items = [..._items, saved];
    notifyListeners();
  }
}
