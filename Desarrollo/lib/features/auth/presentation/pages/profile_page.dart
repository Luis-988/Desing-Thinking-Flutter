import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/profile_user.dart';

class ProfilePage extends StatelessWidget {
  final ProfileUser? user;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onLogin,
    required this.onRegister,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    if (currentUser == null) {
      return _GuestProfile(onLogin: onLogin, onRegister: onRegister);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        const Text(
          'Mi perfil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 22),
        Center(
          child: CircleAvatar(
            radius: 38,
            backgroundColor: const Color(0xFFE4ECF8),
            child: Text(
              _initials(currentUser.name),
              style: const TextStyle(
                color: AppTheme.navy,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            currentUser.name,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            currentUser.email,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Información académica',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _InfoTile(
          icon: Icons.school_outlined,
          label: 'Programa académico',
          value: currentUser.program,
        ),
        _InfoTile(
          icon: Icons.calendar_today_outlined,
          label: 'Semestre',
          value: currentUser.semester,
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB42318),
            side: const BorderSide(color: Color(0xFFB42318)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _GuestProfile extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _GuestProfile({required this.onLogin, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 58, color: AppTheme.navy),
            const SizedBox(height: 16),
            const Text(
              'Tu perfil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Inicia sesión para postularte a iniciativas y gestionar tus proyectos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onLogin,
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sesión'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRegister,
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Crear cuenta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.navy),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
