import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../home/presentation/providers/home_tab_controller.dart';
import '../../../initiatives/presentation/pages/my_applications_page.dart';
import '../../../initiatives/presentation/providers/initiatives_controller.dart';
import '../providers/session_controller.dart';
import 'auth_page.dart';

/// Pestaña Perfil: datos del estudiante y su actividad.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user;

    return Column(
      children: [
        ScreenHeader(
          icon: Icons.person_outline,
          title: 'Perfil',
          subtitle: user == null ? 'Tu cuenta de innovación' : user.email,
        ),
        Expanded(
          child: user == null
              ? const _GuestProfile()
              : _UserProfile(
                  name: user.name,
                  program: user.program,
                  semester: user.semester,
                ),
        ),
      ],
    );
  }
}

class _UserProfile extends StatelessWidget {
  final String name;
  final String program;
  final String semester;

  const _UserProfile({
    required this.name,
    required this.program,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    final initiatives = context.watch<InitiativesController>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Center(child: InitialsAvatar(name: name, radius: 40)),
        const SizedBox(height: 12),
        Center(
          child: Text(
            name,
            style: AppText.screenTitle,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        const Text('Información académica', style: AppText.sectionTitle),
        const SizedBox(height: 10),
        _InfoCard(
          children: [
            _InfoRow(
              icon: Icons.school_outlined,
              label: 'Programa académico',
              value: program.isEmpty ? 'No indicado' : program,
            ),
            const Divider(height: 1),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Semestre',
              value: semester.isEmpty ? 'No indicado' : semester,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Mi actividad', style: AppText.sectionTitle),
        const SizedBox(height: 10),
        _InfoCard(
          children: [
            _ActionRow(
              icon: Icons.send_outlined,
              title: 'Mis postulaciones',
              trailing: '${initiatives.myApplications.length}',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MyApplicationsPage(),
                ),
              ),
            ),
            const Divider(height: 1),
            _ActionRow(
              icon: Icons.rocket_launch_outlined,
              title: 'Mis iniciativas',
              trailing: '${initiatives.myInitiatives.length}',
              onTap: () =>
                  context.read<HomeTabController>().go(HomeTabs.myInitiatives),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Preferencias', style: AppText.sectionTitle),
        const SizedBox(height: 10),
        _InfoCard(
          children: [
            Consumer<ThemeController>(
              builder: (context, theme, _) => SwitchListTile(
                secondary: Icon(
                  theme.isDark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  color: AppColors.navy,
                ),
                title: const Text('Modo oscuro'),
                subtitle: Text(
                  theme.isDark ? 'Tema oscuro activado' : 'Usar tema claro',
                ),
                value: theme.isDark,
                onChanged: (_) => theme.toggle(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: () => context.read<SessionController>().logout(),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.dangerFg,
            side: const BorderSide(color: AppColors.dangerFg),
          ),
        ),
      ],
    );
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  void _open(BuildContext context, {required bool register}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AuthPage(startInRegisterMode: register),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 42,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 18),
            const Text('Tu perfil', style: AppText.screenTitle),
            const SizedBox(height: 8),
            const Text(
              'Inicia sesión para postularte a iniciativas y gestionar tus proyectos.',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _open(context, register: false),
              icon: const Icon(Icons.login),
              label: const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _open(context, register: true),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Card(child: Column(children: children));
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.navy),
      title: Text(label, style: AppText.caption),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.navy),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trailing, style: AppText.sectionTitle.copyWith(fontSize: 16)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
