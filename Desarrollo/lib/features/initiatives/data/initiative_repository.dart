import 'package:roble/roble.dart';

import '../../../core/roble/roble_client.dart';
import '../models/initiative.dart';

/// Todo el acceso a Roble para iniciativas y postulaciones.
class InitiativeRepository {
  RobleApiDataBase get _db => RobleClient.db;

  bool get isLoggedIn => _db.isLoggedIn;

  // ---------- Iniciativas ----------

  Future<List<Initiative>> fetchInitiatives() async {
    final rows = _db.isLoggedIn
        ? await _db.read(RobleClient.tablaIniciativas)
        : await _db.publicRead(RobleClient.tablaIniciativas);
    return rows
        .map((row) => Initiative.fromRoble(row, isMine: _db.isMine(row)))
        .toList();
  }

  Future<Initiative> createInitiative(Initiative initiative) async {
    final row = await _db.create(
      RobleClient.tablaIniciativas,
      initiative.toRoble(),
    );
    return Initiative.fromRoble(row, isMine: true);
  }

  Future<void> updateInitiative(Initiative initiative) async {
    await _db.update(
      RobleClient.tablaIniciativas,
      initiative.id,
      initiative.toRoble(),
    );
  }

  Future<void> saveViews(Initiative initiative) async {
    if (!_db.isLoggedIn) return;
    try {
      await _db.update(RobleClient.tablaIniciativas, initiative.id, {
        'visitas': initiative.views,
      });
    } catch (_) {
      // Si el rol no puede actualizar filas ajenas, las visitas quedan solo locales.
    }
  }

  Future<void> deleteInitiative(Initiative initiative) async {
    await _db.delete(RobleClient.tablaIniciativas, initiative.id);
  }

  // ---------- Postulaciones ----------

  Future<List<InitiativeApplication>> fetchApplications() async {
    if (!_db.isLoggedIn) return [];
    final rows = await _db.read(RobleClient.tablaPostulaciones);
    return rows
        .map(
          (row) =>
              InitiativeApplication.fromRoble(row, isMine: _db.isMine(row)),
        )
        .toList();
  }

  Future<InitiativeApplication> createApplication(
    InitiativeApplication application,
  ) async {
    final row = await _db.create(
      RobleClient.tablaPostulaciones,
      application.toRoble(),
    );
    return InitiativeApplication.fromRoble(row, isMine: true);
  }

  Future<void> updateApplicationStatus(
    InitiativeApplication application,
    ApplicationStatus status,
  ) async {
    await _db.update(RobleClient.tablaPostulaciones, application.id, {
      'estado': status.name,
    });
  }
}
