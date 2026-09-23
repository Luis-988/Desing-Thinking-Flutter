import 'package:roble/roble.dart';

/// Único punto que habla con Roble para cuentas y sesión.
class AuthRemoteDataSource {
  final RobleApiDataBase _db;

  AuthRemoteDataSource(this._db);

  Future<bool> restoreSession() => _db.restoreSession();

  Future<Map<String, dynamic>> currentUser() => _db.currentUser();

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required Map<String, dynamic> extra,
  }) =>
      _db.register(email: email, password: password, name: name, extra: extra);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      _db.login(email: email, password: password);

  Future<void> logout() => _db.logout();
}
