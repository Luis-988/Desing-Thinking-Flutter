import 'package:flutter/material.dart';

import '../../../../core/widgets/state_views.dart';
import '../pages/auth_page.dart';

/// Estado vacío que invita a iniciar sesión.
class LoginRequiredState extends StatelessWidget {
  final String message;

  const LoginRequiredState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.lock_outline,
      title: 'Inicia sesión para continuar',
      message: message,
      actionLabel: 'Iniciar sesión',
      onAction: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const AuthPage()),
      ),
    );
  }
}
