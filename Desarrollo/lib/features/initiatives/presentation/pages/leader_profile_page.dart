import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../providers/initiatives_controller.dart';
import '../widgets/initiative_card.dart';

/// Perfil público del líder: sus iniciativas y cifras de actividad.
///
/// Los datos académicos solo se muestran cuando el líder es el usuario con
/// sesión iniciada; el resto llegará cuando Roble exponga perfiles.
class LeaderProfilePage extends StatelessWidget {
  final String leaderName;

  const LeaderProfilePage({super.key, required this.leaderName});

  @override
  Widget build(BuildContext context) {
    final initiatives = context
        .watch<InitiativesController>()
        .activeInitiatives
        .where((item) => item.leader == leaderName)
        .toList();
    final user = context.watch<SessionController>().user;

    final totalViews = initiatives.fold(0, (sum, item) => sum + item.views);
    final totalSlots = initiatives.fold(0, (sum, item) => sum + item.openSlots);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil del líder')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(child: InitialsAvatar(name: leaderName, radius: 40)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              leaderName,
              style: AppText.screenTitle,
              textAlign: TextAlign.center,
            ),
          ),
          if (user != null && user.name == leaderName) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${user.program} · ${user.semester}',
                style: AppText.body,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              _Metric(value: '${initiatives.length}', label: 'Iniciativas'),
              const SizedBox(width: 10),
              _Metric(value: '$totalViews', label: 'Visitas'),
              const SizedBox(width: 10),
              _Metric(value: '$totalSlots', label: 'Plazas'),
            ],
          ),
          const SizedBox(height: 28),
          const Text('Iniciativas activas', style: AppText.sectionTitle),
          const SizedBox(height: 12),
          if (initiatives.isEmpty)
            const Text(
              'Este líder no tiene iniciativas activas por ahora.',
              style: AppText.body,
            ),
          for (final initiative in initiatives)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InitiativeCard(initiative: initiative),
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;

  const _Metric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
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
