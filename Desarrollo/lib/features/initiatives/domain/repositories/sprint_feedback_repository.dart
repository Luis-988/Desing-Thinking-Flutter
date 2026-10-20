import '../entities/sprint_feedback.dart';

abstract class SprintFeedbackRepository {
  Future<List<SprintFeedback>> getFeedback(String initiativeId);
  Future<SprintFeedback> createFeedback(SprintFeedback feedback);
}
