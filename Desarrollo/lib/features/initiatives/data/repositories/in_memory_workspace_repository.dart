import '../../domain/entities/workspace_comment.dart';
import '../../domain/entities/workspace_member.dart';
import '../../domain/entities/workspace_message.dart';
import '../../domain/entities/workspace_publication.dart';
import '../../domain/entities/publication_comment.dart';
import '../../domain/repositories/workspace_repository.dart';

class InMemoryWorkspaceRepository implements WorkspaceRepository {
  final Map<String, List<WorkspaceMessage>> _messages = {};
  final Map<String, List<WorkspaceComment>> _comments = {};
  final Map<String, List<WorkspaceMember>> _members = {};
  final Map<String, List<WorkspacePublication>> _publications = {};
  final Map<String, List<PublicationComment>> _publicationComments = {};
  int _nextId = 1;

  @override
  Future<List<WorkspaceMessage>> getMessages(String initiativeId) async =>
      List.unmodifiable(_messages[initiativeId] ?? const []);

  @override
  Future<WorkspaceMessage> sendMessage({
    required String initiativeId,
    required String author,
    required String text,
  }) async {
    final message = WorkspaceMessage(
      id: 'local-message-${_nextId++}',
      initiativeId: initiativeId,
      author: author,
      text: text,
      createdAt: DateTime.now(),
    );
    (_messages[initiativeId] ??= []).add(message);
    return message;
  }

  @override
  Future<List<WorkspaceComment>> getComments(String initiativeId) async =>
      List.unmodifiable(_comments[initiativeId] ?? const []);

  @override
  Future<WorkspaceComment> addComment({
    required String initiativeId,
    required String author,
    required String text,
  }) async {
    final comment = WorkspaceComment(
      id: 'local-comment-${_nextId++}',
      initiativeId: initiativeId,
      author: author,
      text: text,
      createdAt: DateTime.now(),
    );
    (_comments[initiativeId] ??= []).add(comment);
    return comment;
  }

  @override
  Future<List<WorkspaceMember>> getMembers(String initiativeId) async =>
      List.unmodifiable(_members[initiativeId] ?? const []);

  @override
  Future<WorkspaceMember> updateMember(WorkspaceMember member) async {
    final members = _members[member.initiativeId] ??= [];
    final index = members.indexWhere((item) => item.id == member.id);
    if (index == -1) {
      members.add(member);
    } else {
      members[index] = member;
    }
    return member;
  }

  @override
  Future<List<WorkspacePublication>> getPublications(
    String initiativeId,
  ) async => List.unmodifiable(_publications[initiativeId] ?? const []);

  @override
  Future<WorkspacePublication> createPublication(
    WorkspacePublication publication,
  ) async {
    final saved = WorkspacePublication(
      id: 'local-publication-${_nextId++}',
      initiativeId: publication.initiativeId,
      author: publication.author,
      title: publication.title,
      text: publication.text,
      createdAt: publication.createdAt,
    );
    (_publications[publication.initiativeId] ??= []).add(saved);
    return saved;
  }

  @override
  Future<List<PublicationComment>> getPublicationComments(
    String initiativeId,
  ) async => List.unmodifiable(_publicationComments[initiativeId] ?? const []);

  @override
  Future<PublicationComment> addPublicationComment(
    PublicationComment comment,
  ) async {
    final saved = PublicationComment(
      id: 'local-publication-comment-${_nextId++}',
      publicationId: comment.publicationId,
      initiativeId: comment.initiativeId,
      author: comment.author,
      text: comment.text,
      createdAt: comment.createdAt,
    );
    (_publicationComments[comment.initiativeId] ??= []).add(saved);
    return saved;
  }
}
