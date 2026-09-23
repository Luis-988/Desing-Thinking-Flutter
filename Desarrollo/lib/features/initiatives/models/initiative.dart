import 'dart:convert';

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

  /// Datos que se guardan en la tabla `iniciativas` de Roble.
  Map<String, dynamic> toRoble() => {
    'titulo': title,
    'descripcion': description,
    'categorias': jsonEncode(categories),
    'lider': leader,
    'popular_manual': isPopularManually,
    'activa': isActive,
    'vacantes': jsonEncode(roles.map((role) => role.toJson()).toList()),
    'visitas': views,
  };

  factory Initiative.fromRoble(Map<String, dynamic> row, {bool isMine = false}) {
    return Initiative(
      id: row['_id'].toString(),
      title: (row['titulo'] ?? '').toString(),
      categories: _decodeList(row['categorias']).map((e) => e.toString()).toList(),
      description: (row['descripcion'] ?? '').toString(),
      leader: (row['lider'] ?? 'Equipo Uninorte').toString(),
      isPopularManually: _toBool(row['popular_manual']),
      isActive: row['activa'] == null ? true : _toBool(row['activa']),
      roles: _decodeList(row['vacantes'])
          .whereType<Map>()
          .map((e) => InitiativeRole.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      views: int.tryParse('${row['visitas'] ?? 0}') ?? 0,
      isMine: isMine,
    );
  }
}

class InitiativeRole {
  final String name;
  final String description;

  const InitiativeRole({required this.name, required this.description});

  Map<String, dynamic> toJson() => {'name': name, 'description': description};

  factory InitiativeRole.fromJson(Map<String, dynamic> json) => InitiativeRole(
    name: (json['name'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
  );
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
  bool isMine;

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
    this.isMine = false,
  });

  /// Datos que se guardan en la tabla `postulaciones` de Roble.
  Map<String, dynamic> toRoble() => {
    'iniciativa_id': initiativeId,
    'nombre': applicantName,
    'programa': program,
    'semestre': semester,
    'vacante': roleName,
    'habilidades': skills,
    'mensaje': message,
    'estado': status.name,
  };

  factory InitiativeApplication.fromRoble(
    Map<String, dynamic> row, {
    bool isMine = false,
  }) {
    return InitiativeApplication(
      id: row['_id'].toString(),
      initiativeId: (row['iniciativa_id'] ?? '').toString(),
      applicantName: (row['nombre'] ?? '').toString(),
      program: (row['programa'] ?? '').toString(),
      semester: (row['semestre'] ?? '').toString(),
      roleName: (row['vacante'] ?? '').toString(),
      skills: (row['habilidades'] ?? '').toString(),
      message: (row['mensaje'] ?? '').toString(),
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == row['estado'],
        orElse: () => ApplicationStatus.pending,
      ),
      isMine: isMine,
    );
  }
}

List<dynamic> _decodeList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value;
  try {
    final decoded = jsonDecode(value.toString());
    return decoded is List ? decoded : [];
  } catch (_) {
    return [];
  }
}

bool _toBool(dynamic value) =>
    value == true || value.toString().toLowerCase() == 'true' || value == 1;
