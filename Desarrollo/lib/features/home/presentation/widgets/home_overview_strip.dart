import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeOverviewStrip extends StatelessWidget {
  final int initiatives;
  final int openSlots;
  final int applications;

  const HomeOverviewStrip({
    super.key,
    required this.initiatives,
    required this.openSlots,
    required this.applications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          _OverviewItem(
            icon: Icons.lightbulb_outline,
            value: '$initiatives',
            label: 'proyectos activos',
          ),
          const _OverviewDivider(),
          _OverviewItem(
            icon: Icons.group_add_outlined,
            value: '$openSlots',
            label: 'plazas abiertas',
          ),
          const _OverviewDivider(),
          _OverviewItem(
            icon: Icons.send_outlined,
            value: '$applications',
            label: 'postulaciones',
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _OverviewItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.navy),
          const SizedBox(width: 6),
          Flexible(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' $label',
                    style: AppText.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewDivider extends StatelessWidget {
  const _OverviewDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}
