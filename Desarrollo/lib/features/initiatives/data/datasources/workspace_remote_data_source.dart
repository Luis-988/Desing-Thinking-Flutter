import 'package:roble/roble.dart';

import '../../../../core/network/roble_client.dart';

class WorkspaceRemoteDataSource {
  final RobleApiDataBase _db;

  WorkspaceRemoteDataSource(this._db);

  Future<List<Map<String, dynamic>>> readMessages() =>
      _db.read(RobleClient.tablaMensajesWorkspace);

  Future<Map<String, dynamic>> createMessage(Map<String, dynamic> row) =>
      _db.create(RobleClient.tablaMensajesWorkspace, row);

  Future<List<Map<String, dynamic>>> readComments() =>
      _db.read(RobleClient.tablaComentariosWorkspace);

  Future<Map<String, dynamic>> createComment(Map<String, dynamic> row) =>
      _db.create(RobleClient.tablaComentariosWorkspace, row);

  Future<List<Map<String, dynamic>>> readMembers() =>
      _db.read(RobleClient.tablaMiembrosWorkspace);

  Future<Map<String, dynamic>> createMember(Map<String, dynamic> row) =>
      _db.create(RobleClient.tablaMiembrosWorkspace, row);

  Future<void> updateMember(String id, Map<String, dynamic> row) =>
      _db.update(RobleClient.tablaMiembrosWorkspace, id, row);
}
