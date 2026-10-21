import 'package:roble/roble.dart';

import '../../../../core/network/roble_client.dart';

class ProjectSprintRemoteDataSource {
  final RobleApiDataBase _db;

  ProjectSprintRemoteDataSource(this._db);

  Future<List<Map<String, dynamic>>> readSprints() =>
      _db.read(RobleClient.tablaSprints);

  Future<Map<String, dynamic>> createSprint(Map<String, dynamic> row) =>
      _db.create(RobleClient.tablaSprints, row);

  Future<void> updateSprint(String id, Map<String, dynamic> row) =>
      _db.update(RobleClient.tablaSprints, id, row);

  Future<void> deleteSprint(String id) =>
      _db.delete(RobleClient.tablaSprints, id);
}
