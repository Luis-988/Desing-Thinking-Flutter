import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../initiatives/presentation/pages/publish_initiative_page.dart';

class HomeHeroCard extends StatelessWidget {
  final VoidCallback onExplore;

  const HomeHeroCard({super.key, required this.onExplore});

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
            style: TextStyle(
              color: Color(0xFFD3DEF2),
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onExplore,
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
