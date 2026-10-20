import '../../domain/entities/project_sprint.dart';

class ProjectSprintModel {
  const ProjectSprintModel._();

  static ProjectSprint fromRow(Map<String, dynamic> row) {
    return ProjectSprint(
      id: (row['_id'] ?? row['id']).toString(),
      initiativeId: (row['iniciativa_id'] ?? '').toString(),
      name: (row['nombre'] ?? '').toString(),
      objective: (row['objetivo'] ?? '').toString(),
      startDate: _date(row['fecha_inicio']),
      endDate: _date(row['fecha_fin']),
      status: _status(row['estado']),
      order: int.tryParse('${row['orden'] ?? 0}') ?? 0,
    );
  }

  static Map<String, dynamic> toRow(ProjectSprint sprint) => {
    'iniciativa_id': sprint.initiativeId,
    'nombre': sprint.name,
    'objetivo': sprint.objective,
    'fecha_inicio': sprint.startDate.toIso8601String(),
    'fecha_fin': sprint.endDate.toIso8601String(),
    'estado': sprint.status.name,
    'orden': sprint.order,
  };

  static DateTime _date(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static ProjectSprintStatus _status(dynamic value) {
    return ProjectSprintStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ProjectSprintStatus.planned,
    );
  }
}
