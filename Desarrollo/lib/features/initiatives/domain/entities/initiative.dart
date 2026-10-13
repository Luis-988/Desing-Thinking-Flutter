/// Entidad de dominio: una iniciativa publicada por un estudiante.
/// Es inmutable; para modificarla se usa [copyWith].
/// No conoce Roble ni JSON; eso vive en la capa data.
class Initiative {
  final String id;
  final String title;
  final List<String> categories;
  final String description;
  final String leader;
  final bool isPopularManually;
  final bool isActive;
  final List<InitiativeRole> roles;
  final int views;
  final bool isMine;

  static const int automaticPopularityThreshold = 10;

  const Initiative({
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

  bool get isPopular =>
      isPopularManually || views >= automaticPopularityThreshold;

  /// Total de plazas abiertas sumando todas las vacantes.
  int get openSlots => roles.fold(0, (total, role) => total + role.slots);

  Initiative copyWith({
    String? title,
    List<String>? categories,
    String? description,
    bool? isPopularManually,
    bool? isActive,
    List<InitiativeRole>? roles,
    int? views,
    bool? isMine,
  }) {
    return Initiative(
      id: id,
      title: title ?? this.title,
      categories: categories ?? this.categories,
      description: description ?? this.description,
      leader: leader,
      isPopularManually: isPopularManually ?? this.isPopularManually,
      isActive: isActive ?? this.isActive,
      roles: roles ?? this.roles,
      views: views ?? this.views,
      isMine: isMine ?? this.isMine,
    );
  }
}

/// Vacante que ofrece una iniciativa.
class InitiativeRole {
  final String name;
  final String description;

  /// Cantidad de personas que se necesitan para este rol.
  final int slots;

  /// Habilidades que el líder espera (opcional).
  final List<String> skills;

  const InitiativeRole({
    required this.name,
    required this.description,
    this.slots = 1,
    this.skills = const [],
  });
}
