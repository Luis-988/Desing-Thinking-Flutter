import '../../../../core/error/app_exception.dart';

class ProjectActivityPolicy {
  const ProjectActivityPolicy._();

  static void requireLeader(bool isLeader) {
    if (!isLeader) {
      throw const AppException('Solo el líder puede gestionar actividades.');
    }
  }

  static void requireTeamMember(bool isTeamMember) {
    if (!isTeamMember) {
      throw const AppException(
        'Solo los integrantes del equipo pueden actualizar actividades.',
      );
    }
  }
}
