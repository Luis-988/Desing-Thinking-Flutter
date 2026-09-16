class Initiative {
  final String id;
  final String title;
  final String category;
  final String description;
  final String leader;
  bool isPopularManually;
  final bool isActive;
  final List<InitiativeRole> roles;
  int views;

  static const int automaticPopularityThreshold = 10;

  bool get isPopular =>
      isPopularManually || views >= automaticPopularityThreshold;

  Initiative({
    required this.id,
    required this.title,
    required this.category,
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
  final int availablePlaces;

  const InitiativeRole({required this.name, required this.availablePlaces});
}

enum ApplicationStatus { pending, accepted, rejected }

class InitiativeApplication {
  final String id;
  final String initiativeId;
  final String applicantName;
  final String roleName;
  final String message;
  ApplicationStatus status;

  InitiativeApplication({
    required this.id,
    required this.initiativeId,
    required this.applicantName,
    required this.roleName,
    required this.message,
    this.status = ApplicationStatus.pending,
  });
}
