import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../home/presentation/providers/home_tab_controller.dart';
import '../../domain/entities/initiative_application.dart';
import '../providers/initiatives_controller.dart';
import '../widgets/status_pill.dart';
import 'initiative_detail_page.dart';

/// Estado de las postulaciones que el usuario ha enviado.
class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InitiativesController>();
    final applications = controller.myApplications.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis postulaciones')),
      body: applications.isEmpty
          ? EmptyState(
              icon: Icons.send_outlined,
              title: 'Aún no te has postulado',
              message:
                  'Cuando te postules a un rol, aquí verás si fue aceptada.',
              actionLabel: 'Explorar proyectos',
              onAction: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                context.read<HomeTabController>().go(HomeTabs.explore);
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: applications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final application = applications[index];
                final initiative = controller.initiativeById(
                  application.initiativeId,
                );
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: initiative == null
                        ? null
                        : () => openInitiative(context, initiative.id),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  initiative?.title ?? 'Iniciativa eliminada',
                                  style: AppText.sectionTitle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              StatusPill(application.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(application.roleName, style: AppText.body),
                          const SizedBox(height: 10),
                          Text(
                            _hint(application.status),
                            style: AppText.caption.copyWith(
                              color: AppColors.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _hint(ApplicationStatus status) => switch (status) {
    ApplicationStatus.pending => 'El líder aún no ha respondido.',
    ApplicationStatus.accepted => '¡Hicieron match! Ponte en contacto con el equipo.',
    ApplicationStatus.rejected =>
      'Esta vez no fue posible. Explora otras iniciativas.',
  };
}
