import '../../../../core/network/roble_guard.dart';
import '../../domain/entities/initiative.dart';
import '../../domain/entities/initiative_application.dart';
import '../../domain/repositories/initiative_repository.dart';
import '../datasources/initiative_remote_data_source.dart';
import '../models/initiative_application_model.dart';
import '../models/initiative_model.dart';

class InitiativeRepositoryImpl implements InitiativeRepository {
  final InitiativeRemoteDataSource _remote;

  InitiativeRepositoryImpl(this._remote);

  @override
  Future<List<Initiative>> getInitiatives() async {
    final rows = await guardRoble(_remote.readInitiatives);
    return rows
        .map((row) => InitiativeModel.fromRow(row, isMine: _remote.isMine(row)))
        .toList();
  }

  @override
  Future<Initiative> createInitiative(Initiative initiative) async {
    final row = await guardRoble(
      () => _remote.createInitiative(InitiativeModel.toRow(initiative)),
    );
    return InitiativeModel.fromRow(row, isMine: true);
  }

  @override
  Future<void> updateInitiative(Initiative initiative) => guardRoble(
    () => _remote.updateInitiative(
      initiative.id,
      InitiativeModel.toRow(initiative),
    ),
  );

  @override
  Future<void> deleteInitiative(Initiative initiative) =>
      guardRoble(() => _remote.deleteInitiative(initiative.id));

  @override
  Future<void> saveViews(Initiative initiative) async {
    if (!_remote.isLoggedIn) return;
    try {
      await _remote.updateInitiative(initiative.id, {
        'visitas': initiative.views,
      });
    } catch (_) {
      // Si el rol no puede actualizar, las visitas quedan solo en local.
    }
  }

  @override
  Future<List<InitiativeApplication>> getApplications() async {
    if (!_remote.isLoggedIn) return [];
    final rows = await guardRoble(_remote.readApplications);
    return rows
        .map(
          (row) => InitiativeApplicationModel.fromRow(
            row,
            isMine: _remote.isMine(row),
          ),
        )
        .toList();
  }

  @override
  Future<InitiativeApplication> submitApplication(
    InitiativeApplication application,
  ) async {
    final row = await guardRoble(
      () => _remote.createApplication(
        InitiativeApplicationModel.toRow(application),
      ),
    );
    return InitiativeApplicationModel.fromRow(row, isMine: true);
  }

  @override
  Future<void> updateApplicationStatus(
    InitiativeApplication application,
    ApplicationStatus status,
  ) => guardRoble(
    () => _remote.updateApplication(application.id, {'estado': status.name}),
  );
}
