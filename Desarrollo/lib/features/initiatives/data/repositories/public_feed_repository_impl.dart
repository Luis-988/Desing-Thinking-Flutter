import '../../../../core/network/roble_guard.dart';
import '../../domain/entities/publication_comment.dart';
import '../../domain/entities/workspace_publication.dart';
import '../../domain/repositories/public_feed_repository.dart';
import '../datasources/public_feed_remote_data_source.dart';

class PublicFeedRepositoryImpl implements PublicFeedRepository {
  final PublicFeedRemoteDataSource _remote;

  PublicFeedRepositoryImpl(this._remote);

  @override
  Future<List<WorkspacePublication>> getPublications() async {
    final rows = await guardRoble(_remote.readPublications);
    return rows.map(_publicationFromRow).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<WorkspacePublication> createPublication(
    WorkspacePublication publication,
  ) async {
    final saved = await guardRoble(
      () => _remote.createPublication({
        'iniciativa_id': publication.initiativeId,
        'autor': publication.author,
        'titulo': publication.title,
        'texto': publication.text,
        'creado_en': publication.createdAt.toIso8601String(),
      }),
    );
    return _publicationFromRow({
      ...saved,
      'iniciativa_id': saved['iniciativa_id'] ?? publication.initiativeId,
    });
  }

  @override
  Future<List<PublicationComment>> getComments() async {
    final rows = await guardRoble(_remote.readComments);
    return rows.map(_commentFromRow).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<PublicationComment> addComment(PublicationComment comment) async {
    final saved = await guardRoble(
      () => _remote.createComment({
        'publicacion_id': comment.publicationId,
        'iniciativa_id': comment.initiativeId,
        'autor': comment.author,
        'texto': comment.text,
        'creado_en': comment.createdAt.toIso8601String(),
      }),
    );
    return _commentFromRow({
      ...saved,
      'publicacion_id': saved['publicacion_id'] ?? comment.publicationId,
      'iniciativa_id': saved['iniciativa_id'] ?? comment.initiativeId,
    });
  }

  WorkspacePublication _publicationFromRow(Map<String, dynamic> row) =>
      WorkspacePublication(
        id: (row['_id'] ?? row['id'] ?? '').toString(),
        initiativeId: row['iniciativa_id'].toString(),
        author: row['autor'].toString(),
        title: row['titulo'].toString(),
        text: row['texto'].toString(),
        createdAt: DateTime.parse(row['creado_en'].toString()),
      );

  PublicationComment _commentFromRow(Map<String, dynamic> row) =>
      PublicationComment(
        id: (row['_id'] ?? row['id'] ?? '').toString(),
        publicationId: row['publicacion_id'].toString(),
        initiativeId: row['iniciativa_id'].toString(),
        author: row['autor'].toString(),
        text: row['texto'].toString(),
        createdAt: DateTime.parse(row['creado_en'].toString()),
      );
}
