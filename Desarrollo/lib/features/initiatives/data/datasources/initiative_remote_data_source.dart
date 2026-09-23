import 'package:roble/roble.dart';

import '../../../../core/network/roble_client.dart';

/// Único punto que habla con Roble para iniciativas y postulaciones.
class InitiativeRemoteDataSource {
  final RobleApiDataBase _db;

  InitiativeRemoteDataSource(this._db);

  bool get isLoggedIn => _db.isLoggedIn;

  bool isMine(Map<String, dynamic> row) => _db.isMine(row);

  Future<List<Map<String, dynamic>>> readInitiatives() => _db.isLoggedIn
      ? _db.read(RobleClient.tablaIniciativas)
      : _db.publicRead(RobleClient.tablaIniciativas);

  Future<Map<String, dynamic>> createInitiative(Map<String, dynamic> row) =>
      _db.create(RobleClient.tablaIniciativas, row);

  Future<void> updateInitiative(String id, Map<String, dynamic> row) =>
      _db.update(RobleClient.tablaIniciativas, id, row);

  Future<void> deleteInitiative(String id) =>
      _db.delete(RobleClient.tablaIniciativas, id);

  Future<List<Map<String, dynamic>>> readApplications() =>
      _db.read(RobleClient.tablaPostulaciones);

  Future<Map<String, dynamic>> createApplication(Map<String, dynamic> row) =>
      _db.create(RobleClient.tablaPostulaciones, row);

  Future<void> updateApplication(String id, Map<String, dynamic> row) =>
      _db.update(RobleClient.tablaPostulaciones, id, row);
}
