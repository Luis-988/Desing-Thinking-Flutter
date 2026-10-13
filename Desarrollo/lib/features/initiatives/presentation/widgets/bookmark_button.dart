import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/initiatives_controller.dart';

/// Botón para guardar o quitar una iniciativa de Guardados.
class BookmarkButton extends StatelessWidget {
  final String initiativeId;

  const BookmarkButton({super.key, required this.initiativeId});

  @override
  Widget build(BuildContext context) {
    final saved = context.select<InitiativesController, bool>(
      (controller) => controller.isSaved(initiativeId),
    );
    return IconButton(
      onPressed: () =>
          context.read<InitiativesController>().toggleSaved(initiativeId),
      tooltip: saved ? 'Quitar de guardados' : 'Guardar iniciativa',
      icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
      color: AppColors.navy,
    );
  }
}
