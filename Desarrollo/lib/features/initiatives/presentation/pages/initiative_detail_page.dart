import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../home/presentation/providers/home_tab_controller.dart';
import '../../domain/entities/initiative.dart';
import '../../domain/entities/initiative_application.dart';
import '../providers/initiatives_controller.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/status_pill.dart';
import 'leader_profile_page.dart';
import 'project_workspace_page.dart';
import 'role_detail_page.dart';

/// Abre la ficha de una iniciativa.
void openInitiative(BuildContext context, String initiativeId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => InitiativeDetailPage(initiativeId: initiativeId),
    ),
  );
}

class InitiativeDetailPage extends StatefulWidget {
  final String initiativeId;

  const InitiativeDetailPage({super.key, required this.initiativeId});

  @override
  State<InitiativeDetailPage> createState() => _InitiativeDetailPageState();
}

class _InitiativeDetailPageState extends State<InitiativeDetailPage> {
  @override
  void initState() {
    super.initState();
    // Se difiere para no notificar a los oyentes durante la construcción.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InitiativesController>().registerView(widget.initiativeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InitiativesController>();
    final initiative = controller.initiativeById(widget.initiativeId);
    final isAcceptedMember = controller.applications.any(
      (application) =>
          application.isMine &&
          application.initiativeId == widget.initiativeId &&
          application.status == ApplicationStatus.accepted,
    );

    if (initiative == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Iniciativa')),
        body: const EmptyState(
          icon: Icons.search_off,
          title: 'Esta iniciativa ya no está disponible',
          message: 'Puede que el líder la haya eliminado.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha de iniciativa'),
        actions: [BookmarkButton(initiativeId: initiative.id)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _Header(initiative: initiative),
          if (initiative.isMine || isAcceptedMember) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => openProjectWorkspace(context, initiative.id),
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Ver ruta de trabajo'),
            ),
          ],
          const SizedBox(height: 16),
          _LeaderTile(initiative: initiative),
          const SizedBox(height: 16),
          _StatsRow(initiative: initiative),
          if (initiative.isMine) ...[
            const SizedBox(height: 16),
            _OwnerBanner(pending: controller.pendingReceivedCount),
          ],
          const SizedBox(height: 24),
          const Text('Acerca del proyecto', style: AppText.sectionTitle),
          const SizedBox(height: 8),
          Text(initiative.description, style: AppText.bodyLarge),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Vacantes disponibles',
                  style: AppText.sectionTitle,
                ),
              ),
              AppTag.violet('${initiative.roles.length} roles'),
            ],
          ),
          const SizedBox(height: 12),
          if (initiative.roles.isEmpty)
            const Text(
              'Esta iniciativa aún no tiene vacantes publicadas.',
              style: AppText.body,
            ),
          for (final role in initiative.roles)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RoleCard(initiative: initiative, role: role),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Initiative initiative;

  const _Header({required this.initiative});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (initiative.isPopular)
              const AppTag.accent(
                'MÁS POPULAR',
                icon: Icons.local_fire_department,
              ),
            if (initiative.openSlots == 0)
              const AppTag.warning(
                'PROYECTO LLENO · TRABAJO INICIADO',
                icon: Icons.groups_outlined,
              )
            else if (initiative.isActive)
              const AppTag.success('Activa'),
          ],
        ),
        if (initiative.isPopular || initiative.isActive)
          const SizedBox(height: 10),
        Text(
          initiative.title,
          style: AppText.screenTitle.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final c in initiative.categories) AppTag(c)],
        ),
      ],
    );
  }
}

class _LeaderTile extends StatelessWidget {
  final Initiative initiative;

  const _LeaderTile({required this.initiative});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LeaderProfilePage(leaderName: initiative.leader),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              InitialsAvatar(name: initiative.leader, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LÍDER DEL PROYECTO', style: AppText.label),
                    const SizedBox(height: 2),
                    Text(
                      initiative.leader,
                      style: AppText.sectionTitle.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Initiative initiative;

  const _StatsRow({required this.initiative});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(
          icon: Icons.visibility_outlined,
          value: '${initiative.views}',
          label: 'Visitas',
        ),
        const SizedBox(width: 10),
        _StatBox(
          icon: Icons.group_add_outlined,
          value: '${initiative.openSlots}',
          label: 'Plazas',
        ),
        const SizedBox(width: 10),
        _StatBox(
          icon: Icons.work_outline,
          value: '${initiative.roles.length}',
          label: 'Roles',
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.navy, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            Text(label, style: AppText.caption),
          ],
        ),
      ),
    );
  }
}

class _OwnerBanner extends StatelessWidget {
  final int pending;

  const _OwnerBanner({required this.pending});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.infoFg, size: 20),
              SizedBox(width: 8),
              Text(
                'Esta es tu iniciativa',
                style: TextStyle(
                  color: AppColors.infoFg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            pending == 0
                ? 'Aún no tienes postulaciones pendientes por revisar.'
                : 'Tienes $pending ${pending == 1 ? 'postulación pendiente' : 'postulaciones pendientes'} por revisar.',
            style: AppText.body,
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.read<HomeTabController>().go(HomeTabs.myInitiatives);
            },
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
            child: const Text('Ir a Mis iniciativas'),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final Initiative initiative;
  final InitiativeRole role;

  const _RoleCard({required this.initiative, required this.role});

  @override
  Widget build(BuildContext context) {
    final application = context.watch<InitiativesController>().myApplicationFor(
      initiative.id,
      role.name,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RoleDetailPage(
              initiativeId: initiative.id,
              roleName: role.name,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      role.name,
                      style: AppText.sectionTitle.copyWith(fontSize: 16),
                    ),
                  ),
                  AppTag(
                    '${role.slots} ${role.slots == 1 ? 'plaza' : 'plazas'}',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                role.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.body,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (application != null)
                    StatusPill(application.status)
                  else
                    const Text(
                      'Ver detalle del rol',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: AppColors.navy,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
