import 'package:roble/roble.dart';

import '../../../../core/network/roble_client.dart';

class PublicFeedRemoteDataSource {
  final RobleApiDataBase _db;

  PublicFeedRemoteDataSource(this._db);

  Future<List<Map<String, dynamic>>> readPublications() =>
      _db.read(RobleClient.tablaPublicacionesAvance);

  Future<Map<String, dynamic>> createPublication(
    Map<String, dynamic> row,
  ) => _db.create(RobleClient.tablaPublicacionesAvance, row);

  Future<List<Map<String, dynamic>>> readComments() =>
      _db.read(RobleClient.tablaComentariosPublicacion);

  Future<Map<String, dynamic>> createComment(Map<String, dynamic> row) =>
      _db.create(RobleClient.tablaComentariosPublicacion, row);
}
