enum ApplicationStatus { pending, accepted, rejected }

/// Entidad de dominio: postulación de un estudiante a una vacante.
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
}
