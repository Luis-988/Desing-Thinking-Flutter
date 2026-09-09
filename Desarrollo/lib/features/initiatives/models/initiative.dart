class Initiative {
  final String id;
  final String title;
  final String category;
  final String description;
  final String leader;
  final bool isFeatured;
  final bool isActive;
  final List<InitiativeRole> roles;

  const Initiative({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.leader,
    required this.isFeatured,
    required this.isActive,
    required this.roles,
  });
}

class InitiativeRole {
  final String name;
  final int availablePlaces;

  const InitiativeRole({required this.name, required this.availablePlaces});
}
