/// Entidad de dominio: el estudiante con sesión iniciada.
class ProfileUser {
  final String name;
  final String email;
  final String program;
  final String semester;

  const ProfileUser({
    required this.name,
    required this.email,
    required this.program,
    required this.semester,
  });
}
