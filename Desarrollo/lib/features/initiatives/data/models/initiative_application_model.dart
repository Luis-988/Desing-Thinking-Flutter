import '../../domain/entities/initiative_application.dart';

/// Traduce entre [InitiativeApplication] y las filas de la tabla `postulaciones`.
class InitiativeApplicationModel {
  const InitiativeApplicationModel._();

  static Map<String, dynamic> toRow(InitiativeApplication application) => {
    'iniciativa_id': application.initiativeId,
    'nombre': application.applicantName,
    'programa': application.program,
    'semestre': application.semester,
    'vacante': application.roleName,
    'habilidades': application.skills,
    'mensaje': application.message,
    'estado': application.status.name,
  };

  static InitiativeApplication fromRow(
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
