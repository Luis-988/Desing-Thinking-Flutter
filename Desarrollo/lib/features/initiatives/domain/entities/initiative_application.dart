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
  final ApplicationStatus status;
  final bool isMine;

  const InitiativeApplication({
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

  InitiativeApplication copyWith({ApplicationStatus? status}) {
    return InitiativeApplication(
      id: id,
      initiativeId: initiativeId,
      applicantName: applicantName,
      program: program,
      semester: semester,
      roleName: roleName,
      skills: skills,
      message: message,
      status: status ?? this.status,
      isMine: isMine,
    );
  }
}
