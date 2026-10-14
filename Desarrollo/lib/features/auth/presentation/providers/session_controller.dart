import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_result.dart';
import '../../domain/entities/profile_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/restore_session.dart';

enum SessionStatus { unknown, guest, authenticated }

/// Estado de la sesión del estudiante. La UI lo observa con Provider.
class SessionController extends ChangeNotifier {
  final RestoreSession _restoreSession;
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final LogoutUser _logoutUser;

  SessionController({
    required RestoreSession restoreSession,
    required LoginUser loginUser,
    required RegisterUser registerUser,
    required LogoutUser logoutUser,
  }) : _restoreSession = restoreSession,
       _loginUser = loginUser,
       _registerUser = registerUser,
       _logoutUser = logoutUser;

  ProfileUser? _user;
  SessionStatus _status = SessionStatus.unknown;

  ProfileUser? get user => _user;
  SessionStatus get status => _status;
  bool get isAuthenticated => _user != null;

  /// Recupera la sesión guardada (si existe) al abrir la app.
  Future<void> restore() async {
    try {
      _user = await _restoreSession();
    } catch (_) {
      _user = null;
    }
    _status = _user == null ? SessionStatus.guest : SessionStatus.authenticated;
    notifyListeners();
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _loginUser(email: email, password: password);
    _apply(result);
    return result;
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String program,
    required String semester,
    required String password,
  }) async {
    final result = await _registerUser(
      name: name,
      email: email,
      program: program,
      semester: semester,
      password: password,
    );
    _apply(result);
    return result;
  }

  Future<void> logout() async {
    try {
      await _logoutUser();
    } catch (_) {
      // Aunque Roble falle, la sesión local se cierra.
    }
    _user = null;
    _status = SessionStatus.guest;
    notifyListeners();
  }

  void _apply(AuthResult result) {
    final user = result.user;
    if (user == null) return;
    _user = user;
    _status = SessionStatus.authenticated;
    notifyListeners();
  }
}
