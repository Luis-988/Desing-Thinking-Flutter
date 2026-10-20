import '../../../../core/network/roble_guard.dart';
import '../../domain/entities/workspace_comment.dart';
import '../../domain/entities/workspace_member.dart';
import '../../domain/entities/workspace_message.dart';
import '../../domain/entities/workspace_publication.dart';
import '../../domain/entities/publication_comment.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../datasources/workspace_remote_data_source.dart';
import 'in_memory_workspace_repository.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final WorkspaceRemoteDataSource _remote;
  final InMemoryWorkspaceRepository _membersRepository =
      InMemoryWorkspaceRepository();

  WorkspaceRepositoryImpl(this._remote);

  @override
  Future<List<WorkspaceMessage>> getMessages(String initiativeId) async {
    final rows = await guardRoble(_remote.readMessages);
    return rows
        .where((row) => row['iniciativa_id'] == initiativeId)
        .map(_messageFromRow)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<WorkspaceMessage> sendMessage({
    required String initiativeId,
    required String author,
    required String text,
  }) async {
    final message = WorkspaceMessage(
      id: '',
      initiativeId: initiativeId,
      author: author,
      text: text,
      createdAt: DateTime.now(),
    );
    final row = await guardRoble(
      () => _remote.createMessage({
        'iniciativa_id': initiativeId,
        'autor': author,
        'texto': text,
        'creado_en': message.createdAt.toIso8601String(),
      }),
    );
    return _messageFromRow({
      ...row,
      ...{'iniciativa_id': initiativeId},
    });
  }

  @override
  Future<List<WorkspaceComment>> getComments(String initiativeId) async {
    final rows = await guardRoble(_remote.readComments);
    return rows
        .where((row) => row['iniciativa_id'] == initiativeId)
        .map(_commentFromRow)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<WorkspaceComment> addComment({
    required String initiativeId,
    required String author,
    required String text,
  }) async {
    final comment = WorkspaceComment(
      id: '',
      initiativeId: initiativeId,
      author: author,
      text: text,
      createdAt: DateTime.now(),
    );
    final row = await guardRoble(
      () => _remote.createComment({
        'iniciativa_id': initiativeId,
        'autor': author,
        'texto': text,
        'creado_en': comment.createdAt.toIso8601String(),
      }),
    );
    return _commentFromRow({
      ...row,
      ...{'iniciativa_id': initiativeId},
    });
  }

  @override
  Future<List<WorkspaceMember>> getMembers(String initiativeId) =>
      _membersRepository.getMembers(initiativeId);

  @override
  Future<WorkspaceMember> updateMember(WorkspaceMember member) =>
      _membersRepository.updateMember(member);

  @override
  Future<List<WorkspacePublication>> getPublications(String initiativeId) =>
      _membersRepository.getPublications(initiativeId);

  @override
  Future<WorkspacePublication> createPublication(
    WorkspacePublication publication,
  ) => _membersRepository.createPublication(publication);

  @override
  Future<List<PublicationComment>> getPublicationComments(
    String initiativeId,
  ) => _membersRepository.getPublicationComments(initiativeId);

  @override
  Future<PublicationComment> addPublicationComment(
    PublicationComment comment,
  ) => _membersRepository.addPublicationComment(comment);

  WorkspaceMessage _messageFromRow(Map<String, dynamic> row) =>
      WorkspaceMessage(
        id: (row['_id'] ?? row['id'] ?? '').toString(),
        initiativeId: row['iniciativa_id'].toString(),
        author: row['autor'].toString(),
        text: row['texto'].toString(),
        createdAt: DateTime.parse(row['creado_en'].toString()),
      );

  WorkspaceComment _commentFromRow(Map<String, dynamic> row) =>
      WorkspaceComment(
        id: (row['_id'] ?? row['id'] ?? '').toString(),
        initiativeId: row['iniciativa_id'].toString(),
        author: row['autor'].toString(),
        text: row['texto'].toString(),
        createdAt: DateTime.parse(row['creado_en'].toString()),
      );
}
