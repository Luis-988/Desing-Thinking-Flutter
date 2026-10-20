class WorkspaceMessage {
  final String id;
  final String initiativeId;
  final String author;
  final String text;
  final DateTime createdAt;

  const WorkspaceMessage({
    required this.id,
    required this.initiativeId,
    required this.author,
    required this.text,
    required this.createdAt,
  });
}
