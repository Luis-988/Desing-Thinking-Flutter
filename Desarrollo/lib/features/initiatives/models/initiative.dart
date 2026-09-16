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
