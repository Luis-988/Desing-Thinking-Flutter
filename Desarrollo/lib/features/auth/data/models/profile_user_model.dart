import '../../domain/entities/profile_user.dart';

/// Traduce el perfil que devuelve Roble a la entidad [ProfileUser].
class ProfileUserModel {
  const ProfileUserModel._();

  static ProfileUser fromProfile(Map<String, dynamic> profile) {
    final extra = profile['extra'] is Map
        ? Map<String, dynamic>.from(profile['extra'] as Map)
        : <String, dynamic>{};
    return ProfileUser(
      name: (profile['name'] ?? '').toString(),
      email: (profile['email'] ?? '').toString(),
      program: (extra['programa'] ?? '').toString(),
      semester: (extra['semestre'] ?? '').toString(),
    );
  }
}
