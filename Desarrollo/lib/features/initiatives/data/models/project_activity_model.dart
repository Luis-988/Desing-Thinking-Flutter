import '../../domain/entities/project_activity.dart';

class ProjectActivityModel {
  const ProjectActivityModel._();

  static ProjectActivity fromRow(Map<String, dynamic> row) => ProjectActivity(
    id: (row['id'] ?? '').toString(),
    initiativeId: (row['iniciativa_id'] ?? '').toString(),
    title: (row['titulo'] ?? '').toString(),
    description: (row['descripcion'] ?? '').toString(),
    dueDate: DateTime.parse((row['fecha_limite'] ?? '').toString()),
    isCompleted: row['completada'] == true || row['completada'] == 1,
  );

  static Map<String, dynamic> toRow(ProjectActivity activity) => {
    'id': activity.id,
    'iniciativa_id': activity.initiativeId,
    'titulo': activity.title,
    'descripcion': activity.description,
    'fecha_limite': DateTime(
      activity.dueDate.year,
      activity.dueDate.month,
      activity.dueDate.day,
    ).toIso8601String(),
    'completada': activity.isCompleted,
  };

  static ProjectActivity fromStoredJson(Map<String, dynamic> row) =>
      fromRow(row);
}
