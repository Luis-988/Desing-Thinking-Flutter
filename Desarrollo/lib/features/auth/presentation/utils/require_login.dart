import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_snack.dart';
import '../pages/auth_page.dart';
import '../providers/session_controller.dart';

/// Devuelve `true` si hay sesión. Si no, avisa y ofrece ir a iniciar sesión.
bool requireLogin(BuildContext context, String action) {
  final session = context.read<SessionController>();
  if (session.isAuthenticated) return true;
  final navigator = Navigator.of(context);
  showAppSnack(
    context,
    'Inicia sesión para $action.',
    action: SnackBarAction(
      label: 'Entrar',
      onPressed: () => navigator.push(
        MaterialPageRoute<void>(builder: (_) => const AuthPage()),
      ),
    ),
  );
  return false;
}
