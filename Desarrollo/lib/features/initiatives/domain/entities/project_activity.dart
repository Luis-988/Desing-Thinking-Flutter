class ProjectActivity {
  final String id;
  final String initiativeId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String? sprintId;

  const ProjectActivity({
    required this.id,
    required this.initiativeId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.sprintId,
  });

  ProjectActivity copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    String? sprintId,
  }) => ProjectActivity(
    id: id,
    initiativeId: initiativeId,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate ?? this.dueDate,
    isCompleted: isCompleted ?? this.isCompleted,
    sprintId: sprintId ?? this.sprintId,
  );
}
