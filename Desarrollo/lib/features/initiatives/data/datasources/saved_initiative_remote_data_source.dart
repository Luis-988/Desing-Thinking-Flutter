import 'package:roble/roble.dart';

import '../../../../core/network/roble_client.dart';

class SavedInitiativeRemoteDataSource {
  final RobleApiDataBase _db;

  SavedInitiativeRemoteDataSource(this._db);

  bool get isLoggedIn => _db.isLoggedIn;

  bool isMine(Map<String, dynamic> row) => _db.isMine(row);

  Future<List<Map<String, dynamic>>> readSaved() =>
      _db.read(RobleClient.tablaIniciativasGuardadas);

  Future<Map<String, dynamic>> createSaved(String initiativeId) =>
      _db.create(RobleClient.tablaIniciativasGuardadas, {
        'iniciativa_id': initiativeId,
      });

  Future<void> deleteSaved(String id) =>
      _db.delete(RobleClient.tablaIniciativasGuardadas, id);
}
