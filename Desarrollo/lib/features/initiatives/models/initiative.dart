class Initiative {
  final String id;
  String title;
  List<String> categories;
  String description;
  final String leader;
  bool isPopularManually;
  final bool isActive;
  List<InitiativeRole> roles;
  int views;

  static const int automaticPopularityThreshold = 10;

  bool get isPopular =>
      isPopularManually || views >= automaticPopularityThreshold;

  Initiative({
    required this.id,
    required this.title,
    required this.categories,
    required this.description,
    required this.leader,
    required this.isPopularManually,
    required this.isActive,
    required this.roles,
    this.views = 0,
  });

  void registerView() => views++;
}

class InitiativeRole {
  final String name;
  final String description;

  const InitiativeRole({required this.name, required this.description});
}

enum ApplicationStatus { pending, accepted, rejected }

class InitiativeApplication {
  final String id;
  final String initiativeId;
  final String applicantName;
  final String program;
  final String semester;
  final String roleName;
  final String skills;
  final String message;
  ApplicationStatus status;

  InitiativeApplication({
    required this.id,
    required this.initiativeId,
    required this.applicantName,
    this.program = 'Programa académico',
    this.semester = 'Semestre no indicado',
    required this.roleName,
    this.skills = 'Habilidades por confirmar',
    required this.message,
    this.status = ApplicationStatus.pending,
  });
}
