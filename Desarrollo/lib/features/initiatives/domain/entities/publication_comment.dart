class PublicationComment {
  final String id;
  final String publicationId;
  final String initiativeId;
  final String author;
  final String text;
  final DateTime createdAt;

  const PublicationComment({
    required this.id,
    required this.publicationId,
    required this.initiativeId,
    required this.author,
    required this.text,
    required this.createdAt,
  });
}
