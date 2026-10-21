class SprintFeedback {
  final String id;
  final String initiativeId;
  final String sprintId;
  final String author;
  final String text;
  final DateTime createdAt;

  const SprintFeedback({
    required this.id,
    required this.initiativeId,
    required this.sprintId,
    required this.author,
    required this.text,
    required this.createdAt,
  });
}
