import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../../auth/presentation/widgets/login_required_state.dart';
import '../../domain/entities/initiative_application.dart';
import '../providers/initiatives_controller.dart';
import '../widgets/application_card.dart';
import '../widgets/initiative_card.dart';
import '../widgets/owner_actions.dart';
import 'publish_initiative_page.dart';
import 'project_workspace_page.dart';

/// Pestaña Mis iniciativas: lo que publiqué y las postulaciones que recibí.
class MyInitiativesPage extends StatelessWidget {
  const MyInitiativesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<SessionController>().isAuthenticated;
    final controller = context.watch<InitiativesController>();

    return Column(
      children: [
        ScreenHeader(
          icon: Icons.rocket_launch_outlined,
          title: 'Mis iniciativas',
          subtitle: isLoggedIn
              ? '${controller.myInitiatives.length} publicadas · ${controller.pendingReceivedCount} por revisar'
              : 'Gestiona tus proyectos y su equipo',
        ),
        Expanded(
          child: !isLoggedIn
              ? const LoginRequiredState(
                  message: 'Publica proyectos y revisa las postulaciones de tu equipo.',
                )
              : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: AppColors.navy,
                        unselectedLabelColor: AppColors.muted,
                        indicatorColor: AppColors.orange,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        tabs: [
                          const Tab(text: 'Publicadas'),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Recibidas'),
                                if (controller.pendingReceivedCount > 0) ...[
                                  const SizedBox(width: 6),
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: AppColors.orange,
                                    child: Text(
                                      '${controller.pendingReceivedCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Expanded(
                        child: TabBarView(
                          children: [_PublishedTab(), _ReceivedTab()],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _PublishedTab extends StatelessWidget {
  const _PublishedTab();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InitiativesController>();
    final mine = controller.myInitiatives;

    if (controller.isLoading && controller.initiatives.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: SkeletonList(count: 2),
      );
    }
    if (mine.isEmpty) {
      return EmptyState(
        icon: Icons.lightbulb_outline,
        title: 'Aún no has publicado proyectos',
        message:
            'Comparte tu idea y encuentra a las personas que la harán real.',
        actionLabel: 'Publicar proyecto',
        onAction: () => openPublishPage(context),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          OutlinedButton.icon(
            onPressed: () => openPublishPage(context),
            icon: const Icon(Icons.add),
            label: const Text('Publicar otro proyecto'),
          ),
          const SizedBox(height: 16),
          for (final initiative in mine)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InitiativeCard(
                    initiative: initiative,
                    ownerActions: OwnerActions(initiative: initiative),
                    footerAction:
                        initiative.roles.isNotEmpty && initiative.openSlots == 0
                        ? OutlinedButton.icon(
                            onPressed: () =>
                                openProjectWorkspace(context, initiative.id),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Abrir espacio de trabajo'),
                          )
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReceivedTab extends StatelessWidget {
  const _ReceivedTab();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InitiativesController>();
    final received = controller.receivedApplications;

    if (received.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Sin postulaciones por ahora',
        message: 'Cuando alguien se postule a una de tus iniciativas aparecerá aquí.',
      );
    }

    final groups = <String, List<InitiativeApplication>>{};
    for (final application in received) {
      groups.putIfAbsent(application.initiativeId, () => []).add(application);
    }

    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            '${controller.pendingReceivedCount} pendientes · ${received.length} en total',
            style: AppText.caption,
          ),
          const SizedBox(height: 12),
          for (final entry in groups.entries) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    controller.initiativeById(entry.key)?.title ??
                        'Iniciativa eliminada',
                    style: AppText.sectionTitle,
                  ),
                ),
                AppTag('${entry.value.length}'),
              ],
            ),
            const SizedBox(height: 10),
            for (final application in entry.value)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ReceivedApplicationCard(application: application),
              ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
