import '../../../../core/error/app_exception.dart';
import '../entities/initiative.dart';

class InitiativePolicy {
  const InitiativePolicy._();

  static void requireCanApply({
    required Initiative? initiative,
    required bool alreadyApplied,
  }) {
    if (initiative?.isMine == true) {
      throw const AppException('No puedes postularte a tu propia iniciativa.');
    }
    if (alreadyApplied) {
      throw const AppException('Ya te postulaste a esta vacante.');
    }
  }

  static Initiative consumeAcceptedRoleSlot(
    Initiative initiative,
    String roleName,
  ) {
    final updatedRoles = initiative.roles.map((role) {
      if (role.name != roleName) return role;
      final nextSlots = role.slots > 0 ? role.slots - 1 : 0;
      return InitiativeRole(
        name: role.name,
        description: role.description,
        slots: nextSlots,
        skills: role.skills,
      );
    }).toList();

    return initiative.copyWith(roles: updatedRoles);
  }
}
