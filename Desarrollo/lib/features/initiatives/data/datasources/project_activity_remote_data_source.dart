import 'package:roble/roble.dart';

import '../../../../core/error/app_exception.dart';

class ProjectActivityRemoteDataSource {
  final RobleApiDataBase _db;

  ProjectActivityRemoteDataSource(this._db);

  String _activitiesPath(String initiativeId) =>
      'iniciativas/$initiativeId/actividades';

  Future<List<Map<String, dynamic>>> readActivities(String initiativeId) async {
    final raw = await _db.json.read(_activitiesPath(initiativeId));
    if (raw == null) return [];
    if (raw is! Map) {
      throw const FormatException(
        'Roble devolvió un formato inválido para las actividades.',
      );
    }

    return raw.entries.map((entry) {
      if (entry.value is! Map) {
        throw const FormatException(
          'Roble devolvió una actividad con formato inválido.',
        );
      }
      return {
        ...Map<String, dynamic>.from(entry.value as Map),
        'id': entry.key.toString(),
      };
    }).toList();
  }

  Future<Map<String, dynamic>> createActivity(
    String initiativeId,
    Map<String, dynamic> row,
  ) async {
    final activityData = Map<String, dynamic>.from(row)..remove('id');
    final id = await _db.json.push(_activitiesPath(initiativeId), {
      ...activityData,
      'iniciativa_id': initiativeId,
    });
    return {...activityData, 'id': id, 'iniciativa_id': initiativeId};
  }

  Future<void> updateActivity(
    String initiativeId,
    String activityId,
    Map<String, dynamic> updates,
  ) async {
    if (activityId.isEmpty) {
      throw const AppException(
        'La actividad no tiene un identificador válido.',
      );
    }
    await _db.json.update(
      '${_activitiesPath(initiativeId)}/$activityId',
      updates,
    );
  }

  Future<void> deleteActivity(String initiativeId, String activityId) async {
    if (activityId.isEmpty) {
      throw const AppException(
        'La actividad no tiene un identificador válido.',
      );
    }
    await _db.json.remove(
      '${_activitiesPath(initiativeId)}/$activityId',
    );
  }
}
