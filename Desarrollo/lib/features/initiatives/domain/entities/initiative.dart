/// Entidad de dominio: una iniciativa publicada por un estudiante.
/// No conoce Roble ni JSON; eso vive en la capa data.
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
  bool isMine;

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
    this.isMine = false,
  });

  void registerView() => views++;
}

/// Vacante que ofrece una iniciativa.
class InitiativeRole {
  final String name;
  final String description;

  const InitiativeRole({required this.name, required this.description});
}
