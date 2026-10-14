import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../../initiatives/presentation/providers/initiatives_controller.dart';
import '../../../initiatives/presentation/widgets/initiative_card.dart';
import '../providers/home_tab_controller.dart';
import '../widgets/home_hero_card.dart';
import '../widgets/home_overview_strip.dart';
import '../widgets/home_section_title.dart';

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
          logoAsset: 'assets/images/innovation_hub_mark.png',
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
                HomeHeroCard(
                  onExplore: () =>
                      context.read<HomeTabController>().go(HomeTabs.explore),
                ),
                const SizedBox(height: 18),
                ..._content(context, controller),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _content(
    BuildContext context,
    InitiativesController controller,
  ) {
    if (controller.isLoading && controller.initiatives.isEmpty) {
      return const [SkeletonList(count: 2)];
    }
    if (controller.error != null && controller.initiatives.isEmpty) {
      return [
        SizedBox(
          height: 320,
          child: ErrorState(
            message: controller.error!,
            onRetry: controller.load,
          ),
        ),
      ];
    }

    final popular = controller.popularInitiatives;
    final recommended = controller.recommendedInitiatives;
    final recent = controller.recentInitiatives;
    final demand = controller.roleDemand;

    return [
      HomeOverviewStrip(
        initiatives: controller.activeInitiatives.length,
        openSlots: controller.openSlotsCount,
        applications: controller.myApplications.length,
      ),
      if (popular.isNotEmpty) ...[
        const SizedBox(height: 28),
        const HomeSectionTitle(
          title: 'Más populares',
          icon: Icons.local_fire_department,
        ),
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
      if (recommended.isNotEmpty) ...[
        const SizedBox(height: 28),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            initiallyExpanded: false,
            leading: const Icon(Icons.auto_awesome, color: AppColors.orange),
            title: const Text(
              'Descubre proyectos para ti',
              style: AppText.sectionTitle,
            ),
            subtitle: const Text(
              'Recomendaciones con oportunidades abiertas',
              style: AppText.caption,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            children: [
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommended.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, index) =>
                      CompactInitiativeCard(initiative: recommended[index]),
                ),
              ),
            ],
          ),
        ),
      ],
      if (demand.isNotEmpty) ...[
        const SizedBox(height: 28),
        const HomeSectionTitle(
          title: 'Roles más buscados',
          icon: Icons.work_outline,
        ),
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
                  '${entry.role} · ${entry.openSlots}',
                  style: const TextStyle(
                    color: AppColors.violetFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  controller.setFilter(entry.role);
                  context.read<HomeTabController>().go(HomeTabs.explore);
                },
              ),
          ],
        ),
      ],
      const SizedBox(height: 28),
      HomeSectionTitle(
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
}
