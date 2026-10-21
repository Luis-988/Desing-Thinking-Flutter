import '../../../../core/network/roble_guard.dart';
import '../../domain/entities/sprint_feedback.dart';
import '../../domain/repositories/sprint_feedback_repository.dart';
import '../datasources/sprint_feedback_remote_data_source.dart';

class SprintFeedbackRepositoryImpl implements SprintFeedbackRepository {
  final SprintFeedbackRemoteDataSource _remote;

  SprintFeedbackRepositoryImpl(this._remote);

  @override
  Future<List<SprintFeedback>> getFeedback(String initiativeId) async {
    final rows = await guardRoble(_remote.read);
    return rows
        .where((row) => row['iniciativa_id'] == initiativeId)
        .map(_fromRow)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<SprintFeedback> createFeedback(SprintFeedback feedback) async {
    final row = await guardRoble(
      () => _remote.create({
        'iniciativa_id': feedback.initiativeId,
        'sprint_id': feedback.sprintId,
        'autor': feedback.author,
        'texto': feedback.text,
        'creado_en': feedback.createdAt.toIso8601String(),
      }),
    );
    return _fromRow({...row, 'iniciativa_id': feedback.initiativeId});
  }

  SprintFeedback _fromRow(Map<String, dynamic> row) => SprintFeedback(
    id: (row['_id'] ?? row['id'] ?? '').toString(),
    initiativeId: row['iniciativa_id'].toString(),
    sprintId: row['sprint_id'].toString(),
    author: row['autor'].toString(),
    text: row['texto'].toString(),
    createdAt: DateTime.parse(row['creado_en'].toString()),
  );
}
