enum ProjectSprintStatus { planned, active, completed }

class ProjectSprint {
  final String id;
  final String initiativeId;
  final String name;
  final String objective;
  final DateTime startDate;
  final DateTime endDate;
  final ProjectSprintStatus status;
  final int order;

  const ProjectSprint({
    required this.id,
    required this.initiativeId,
    required this.name,
    required this.objective,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.order,
  });

  ProjectSprint copyWith({
    String? name,
    String? objective,
    DateTime? startDate,
    DateTime? endDate,
    ProjectSprintStatus? status,
    int? order,
  }) {
    return ProjectSprint(
      id: id,
      initiativeId: initiativeId,
      name: name ?? this.name,
      objective: objective ?? this.objective,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      order: order ?? this.order,
    );
  }
}
