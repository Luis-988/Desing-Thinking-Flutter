import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_snack.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../domain/entities/initiative_application.dart';
import '../providers/initiatives_controller.dart';
import 'status_pill.dart';

/// Postulación recibida: el líder puede ver el perfil, aceptar o rechazar.
class ReceivedApplicationCard extends StatelessWidget {
  final InitiativeApplication application;

  const ReceivedApplicationCard({super.key, required this.application});

  Future<void> _decide(BuildContext context, ApplicationStatus status) async {
    try {
      await context.read<InitiativesController>().setApplicationStatus(
        application,
        status,
      );
      if (!context.mounted) return;
      showAppSnack(
        context,
        status == ApplicationStatus.accepted
            ? 'Postulación aceptada. ¡Hicieron match!'
            : 'Postulación rechazada.',
      );
    } catch (e) {
      if (context.mounted) showAppSnack(context, messageOf(e));
    }
  }

  void _showProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ApplicantProfileSheet(application: application),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = application.status == ApplicationStatus.pending;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(name: application.applicantName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.applicantName,
                        style: AppText.sectionTitle.copyWith(fontSize: 16),
                      ),
                      Text(
                        '${application.program} · ${application.semester}',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
                StatusPill(application.status),
              ],
            ),
            const SizedBox(height: 12),
            AppTag.info(application.roleName, icon: Icons.work_outline),
            const SizedBox(height: 14),
            const Text('HABILIDADES', style: AppText.label),
            const SizedBox(height: 4),
            Text(application.skills, style: AppText.body),
            const SizedBox(height: 12),
            const Text('MENSAJE', style: AppText.label),
            const SizedBox(height: 4),
            Text(application.message, style: AppText.body),
            const SizedBox(height: 14),
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showProfile(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Ver perfil'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          _decide(context, ApplicationStatus.accepted),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _decide(context, ApplicationStatus.rejected),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding: EdgeInsets.zero,
                        foregroundColor: AppColors.dangerFg,
                        side: const BorderSide(color: AppColors.dangerFg),
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                ],
              )
            else
              AppTag(
                application.status == ApplicationStatus.accepted
                    ? 'MATCH ACEPTADO'
                    : 'POSTULACIÓN RECHAZADA',
                background: application.status == ApplicationStatus.accepted
                    ? AppColors.successBg
                    : AppColors.dangerBg,
                foreground: application.status == ApplicationStatus.accepted
                    ? AppColors.successFg
                    : AppColors.dangerFg,
              ),
          ],
        ),
      ),
    );
  }
}

/// Hoja inferior con los datos que la persona escribió al postularse.
class ApplicantProfileSheet extends StatelessWidget {
  final InitiativeApplication application;

  const ApplicantProfileSheet({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(name: application.applicantName, radius: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application.applicantName, style: AppText.sectionTitle),
                      Text(
                        '${application.program} · ${application.semester}',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('SE POSTULA A', style: AppText.label),
            const SizedBox(height: 6),
            AppTag.info(application.roleName),
            const SizedBox(height: 16),
            const Text('HABILIDADES', style: AppText.label),
            const SizedBox(height: 4),
            Text(application.skills, style: AppText.bodyLarge),
            const SizedBox(height: 16),
            const Text('MENSAJE', style: AppText.label),
            const SizedBox(height: 4),
            Text(application.message, style: AppText.bodyLarge),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}
