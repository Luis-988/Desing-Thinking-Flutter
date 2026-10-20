import '../entities/workspace_comment.dart';
import '../entities/workspace_member.dart';
import '../entities/workspace_message.dart';
import '../entities/workspace_publication.dart';
import '../entities/publication_comment.dart';

abstract class WorkspaceRepository {
  Future<List<WorkspaceMessage>> getMessages(String initiativeId);
  Future<WorkspaceMessage> sendMessage({
    required String initiativeId,
    required String author,
    required String text,
  });
  Future<List<WorkspaceComment>> getComments(String initiativeId);
  Future<WorkspaceComment> addComment({
    required String initiativeId,
    required String author,
    required String text,
  });
  Future<List<WorkspaceMember>> getMembers(String initiativeId);
  Future<WorkspaceMember> updateMember(WorkspaceMember member);
  Future<List<WorkspacePublication>> getPublications(String initiativeId);
  Future<WorkspacePublication> createPublication(WorkspacePublication publication);
  Future<List<PublicationComment>> getPublicationComments(String initiativeId);
  Future<PublicationComment> addPublicationComment(PublicationComment comment);
}
