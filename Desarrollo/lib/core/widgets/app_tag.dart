import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Etiqueta pequeña con fondo de color (categorías, roles, estados).
class AppTag extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;

  const AppTag(
    this.text, {
    super.key,
    this.background = AppColors.secondary,
    this.foreground = AppColors.navy,
    this.icon,
  });

  const AppTag.success(this.text, {super.key, this.icon})
    : background = AppColors.successBg,
      foreground = AppColors.successFg;

  const AppTag.warning(this.text, {super.key, this.icon})
    : background = AppColors.warningBg,
      foreground = AppColors.warningFg;

  const AppTag.danger(this.text, {super.key, this.icon})
    : background = AppColors.dangerBg,
      foreground = AppColors.dangerFg;

  const AppTag.info(this.text, {super.key, this.icon})
    : background = AppColors.infoBg,
      foreground = AppColors.infoFg;

  const AppTag.violet(this.text, {super.key, this.icon})
    : background = AppColors.violetBg,
      foreground = AppColors.violetFg;

  const AppTag.accent(this.text, {super.key, this.icon})
    : background = AppColors.orange,
      foreground = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: AppText.tag.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
