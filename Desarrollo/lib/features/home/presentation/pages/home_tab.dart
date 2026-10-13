import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../../initiatives/domain/entities/initiative.dart';
import '../../../initiatives/presentation/pages/publish_initiative_page.dart';
import '../../../initiatives/presentation/providers/initiatives_controller.dart';
import '../../../initiatives/presentation/widgets/initiative_card.dart';
import '../providers/home_tab_controller.dart';

/// Pestaña Inicio: resumen de la plataforma y accesos rápidos.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InitiativesController>();
    final user = context.watch<SessionController>().user;
    final firstName = user?.name.trim().split(RegExp(r'\s+')).first;

    return Column(
      children: [
        ScreenHeader(
          icon: Icons.home_outlined,
          title: 'Inicio',
          subtitle: firstName == null || firstName.isEmpty
              ? 'Innovación Uninorte'
              : 'Hola, $firstName · ¿qué vas a crear hoy?',
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                const _HeroCard(),
                const SizedBox(height: 18),
                ..._content(context, controller),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _content(BuildContext context, InitiativesController controller) {
    if (controller.isLoading && controller.initiatives.isEmpty) {
      return const [SkeletonList(count: 2)];
    }
    if (controller.error != null && controller.initiatives.isEmpty) {
      return [
        SizedBox(
          height: 320,
          child: ErrorState(message: controller.error!, onRetry: controller.load),
        ),
      ];
    }

    final popular = controller.popularInitiatives;
    final recent = controller.recentInitiatives;
    final demand = _roleDemand(controller.activeInitiatives);

    return [
      Row(
        children: [
          _StatTile(
            icon: Icons.lightbulb_outline,
            value: '${controller.activeInitiatives.length}',
            label: 'Iniciativas',
          ),
          const SizedBox(width: 10),
          _StatTile(
            icon: Icons.group_add_outlined,
            value: '${controller.openSlotsCount}',
            label: 'Plazas abiertas',
          ),
          const SizedBox(width: 10),
          _StatTile(
            icon: Icons.send_outlined,
            value: '${controller.myApplications.length}',
            label: 'Mis postulaciones',
          ),
        ],
      ),
      if (popular.isNotEmpty) ...[
        const SizedBox(height: 28),
        const _SectionTitle(title: 'Más populares', icon: Icons.local_fire_department),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: popular.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) =>
                CompactInitiativeCard(initiative: popular[index]),
          ),
        ),
      ],
      if (demand.isNotEmpty) ...[
        const SizedBox(height: 28),
        const _SectionTitle(title: 'Roles más buscados', icon: Icons.work_outline),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in demand)
              ActionChip(
                backgroundColor: AppColors.violetBg,
                side: BorderSide.none,
                label: Text(
                  '${entry.key} · ${entry.value}',
                  style: const TextStyle(
                    color: AppColors.violetFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  controller.setFilter(entry.key);
                  context.read<HomeTabController>().go(HomeTabs.explore);
                },
              ),
          ],
        ),
      ],
      const SizedBox(height: 28),
      _SectionTitle(
        title: 'Recién publicadas',
        icon: Icons.schedule,
        actionLabel: 'Ver todas',
        onAction: () => context.read<HomeTabController>().go(HomeTabs.explore),
      ),
      const SizedBox(height: 12),
      if (recent.isEmpty)
        const Text('Aún no hay iniciativas publicadas.', style: AppText.body),
      for (final initiative in recent)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InitiativeCard(initiative: initiative),
        ),
    ];
  }

  /// Cuenta plazas abiertas por rol y devuelve las 5 con más demanda.
  List<MapEntry<String, int>> _roleDemand(List<Initiative> initiatives) {
    final totals = <String, int>{};
    for (final initiative in initiatives) {
      for (final role in initiative.roles) {
        totals[role.name] = (totals[role.name] ?? 0) + role.slots;
      }
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Encuentra a tu equipo de innovación',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Descubre proyectos de la universidad, súmate con tu perfil o publica tu propia idea.',
            style: TextStyle(color: Color(0xFFD3DEF2), fontSize: 15, height: 1.45),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      context.read<HomeTabController>().go(HomeTabs.explore),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    minimumSize: const Size(0, 46),
                  ),
                  child: const Text('Explorar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => openPublishPage(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    minimumSize: const Size(0, 46),
                  ),
                  child: const Text('Publicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.navy, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionTitle({
    required this.title,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.orange),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: AppText.sectionTitle)),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}
