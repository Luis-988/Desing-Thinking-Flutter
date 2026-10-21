import 'package:roble/roble.dart';

import '../../../../core/network/roble_client.dart';

class SprintFeedbackRemoteDataSource {
  final RobleApiDataBase _db;

  SprintFeedbackRemoteDataSource(this._db);

  Future<List<Map<String, dynamic>>> read() =>
      _db.read(RobleClient.tablaFeedbackSprints);

  Future<Map<String, dynamic>> create(Map<String, dynamic> row) =>
      _db.create(RobleClient.tablaFeedbackSprints, row);
}
