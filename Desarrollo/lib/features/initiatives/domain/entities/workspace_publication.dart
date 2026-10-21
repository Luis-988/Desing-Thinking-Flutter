class WorkspacePublication {
  final String id;
  final String initiativeId;
  final String author;
  final String title;
  final String text;
  final DateTime createdAt;

  const WorkspacePublication({
    required this.id,
    required this.initiativeId,
    required this.author,
    required this.title,
    required this.text,
    required this.createdAt,
  });
}
