import '../../../../core/network/roble_guard.dart';
import '../../domain/repositories/saved_initiative_repository.dart';
import '../datasources/saved_initiative_remote_data_source.dart';

class SavedInitiativeRepositoryImpl implements SavedInitiativeRepository {
  final SavedInitiativeRemoteDataSource _remote;
  final Map<String, String> _rowIdsByInitiative = {};

  SavedInitiativeRepositoryImpl(this._remote);

  @override
  Future<Set<String>> getSavedInitiativeIds() async {
    if (!_remote.isLoggedIn) return {};
    final rows = await guardRoble(_remote.readSaved);
    _rowIdsByInitiative
      ..clear()
      ..addEntries(
        rows
            .where((row) => row['iniciativa_id'] != null && _remote.isMine(row))
            .map(
              (row) => MapEntry(
                row['iniciativa_id'].toString(),
                row['_id'].toString(),
              ),
            ),
      );
    return _rowIdsByInitiative.keys.toSet();
  }

  @override
  Future<void> saveInitiative(String initiativeId) async {
    if (!_remote.isLoggedIn) return;
    final row = await guardRoble(
      () => _remote.createSaved(initiativeId),
    );
    _rowIdsByInitiative[initiativeId] = row['_id'].toString();
  }

  @override
  Future<void> removeInitiative(String initiativeId) async {
    if (!_remote.isLoggedIn) return;
    final rowId = _rowIdsByInitiative[initiativeId];
    if (rowId == null) return;
    await guardRoble(() => _remote.deleteSaved(rowId));
    _rowIdsByInitiative.remove(initiativeId);
  }
}
