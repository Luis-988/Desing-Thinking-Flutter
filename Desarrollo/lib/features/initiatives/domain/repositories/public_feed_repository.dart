import '../entities/publication_comment.dart';
import '../entities/workspace_publication.dart';

abstract class PublicFeedRepository {
  Future<List<WorkspacePublication>> getPublications();
  Future<WorkspacePublication> createPublication(
    WorkspacePublication publication,
  );
  Future<List<PublicationComment>> getComments();
  Future<PublicationComment> addComment(PublicationComment comment);
}
