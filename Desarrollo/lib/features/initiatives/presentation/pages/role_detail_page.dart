import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/utils/require_login.dart';
import '../../domain/entities/initiative.dart';
import '../../domain/entities/initiative_application.dart';
import '../providers/initiatives_controller.dart';
import '../widgets/status_pill.dart';
import 'apply_initiative_page.dart';

/// Detalle de una vacante, con el botón para postularse.
class RoleDetailPage extends StatelessWidget {
  final String initiativeId;
  final String roleName;

  const RoleDetailPage({
    super.key,
    required this.initiativeId,
    required this.roleName,
  });

  InitiativeRole? _findRole(Initiative initiative) {
    for (final role in initiative.roles) {
      if (role.name == roleName) return role;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InitiativesController>();
    final initiative = controller.initiativeById(initiativeId);
    final role = initiative == null ? null : _findRole(initiative);

    if (initiative == null || role == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vacante')),
        body: const EmptyState(
          icon: Icons.search_off,
          title: 'Esta vacante ya no está disponible',
          message: 'El líder pudo haberla modificado o eliminado.',
        ),
      );
    }

    final application = controller.myApplicationFor(initiative.id, role.name);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del rol')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              const AppTag.violet('VACANTE'),
              const SizedBox(width: 6),
              AppTag('${role.slots} ${role.slots == 1 ? 'plaza' : 'plazas'}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(role.name, style: AppText.screenTitle.copyWith(fontSize: 26)),
          const SizedBox(height: 6),
          Text('En ${initiative.title}', style: AppText.body),
          const SizedBox(height: 24),
          const Text('Qué se requiere', style: AppText.sectionTitle),
          const SizedBox(height: 8),
          Text(role.description, style: AppText.bodyLarge),
          if (role.skills.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Habilidades deseadas', style: AppText.sectionTitle),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final skill in role.skills) AppTag.info(skill)],
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.navy),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cuéntale al líder por qué te interesa y qué puedes aportar.',
                    style: AppText.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: _action(context, initiative, role, application),
        ),
      ),
    );
  }

  Widget _action(
    BuildContext context,
    Initiative initiative,
    InitiativeRole role,
    InitiativeApplication? application,
  ) {
    if (initiative.isMine) {
      return const OutlinedButton(
        onPressed: null,
        child: Text('Es tu propia iniciativa'),
      );
    }
    if (application != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Tu postulación:', style: AppText.body),
          const SizedBox(width: 10),
          StatusPill(application.status),
        ],
      );
    }
    return FilledButton(
      onPressed: () {
        if (!requireLogin(context, 'postularte')) return;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ApplyInitiativePage(
              initiativeId: initiative.id,
              roleName: role.name,
            ),
          ),
        );
      },
      child: const Text('Postularme a este rol'),
    );
  }
}
