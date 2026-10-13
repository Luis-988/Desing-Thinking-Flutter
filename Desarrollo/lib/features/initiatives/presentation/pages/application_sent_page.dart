import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/presentation/providers/home_tab_controller.dart';
import '../../domain/entities/initiative_application.dart';
import '../widgets/status_pill.dart';
import 'my_applications_page.dart';

/// Confirmación mostrada tras enviar una postulación.
class ApplicationSentPage extends StatelessWidget {
  final String initiativeTitle;
  final String roleName;

  const ApplicationSentPage({
    super.key,
    required this.initiativeTitle,
    required this.roleName,
  });

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final tabs = context.read<HomeTabController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: AppColors.successFg,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Postulación enviada!',
                style: AppText.screenTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'El líder revisará tu perfil y te responderá por aquí.',
                style: AppText.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('INICIATIVA', style: AppText.label),
                      const SizedBox(height: 2),
                      Text(initiativeTitle, style: AppText.sectionTitle),
                      const SizedBox(height: 12),
                      const Text('ROL', style: AppText.label),
                      const SizedBox(height: 2),
                      Text(roleName, style: AppText.sectionTitle),
                      const SizedBox(height: 12),
                      const StatusPill(ApplicationStatus.pending),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  navigator.popUntil((route) => route.isFirst);
                  navigator.push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MyApplicationsPage(),
                    ),
                  );
                },
                child: const Text('Ver el estado de mis postulaciones'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  navigator.popUntil((route) => route.isFirst);
                  tabs.go(HomeTabs.explore);
                },
                child: const Text('Seguir explorando'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
