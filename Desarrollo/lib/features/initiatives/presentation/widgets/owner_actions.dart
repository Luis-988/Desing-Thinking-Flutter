import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snack.dart';
import '../../domain/entities/initiative.dart';
import '../pages/publish_initiative_page.dart';
import '../providers/initiatives_controller.dart';

enum _OwnerAction { edit, togglePopular, delete }

/// Menú del líder sobre sus iniciativas: editar, destacar o eliminar.
class OwnerActions extends StatelessWidget {
  final Initiative initiative;

  const OwnerActions({super.key, required this.initiative});

  Future<void> _togglePopular(BuildContext context) async {
    try {
      await context.read<InitiativesController>().togglePopular(initiative);
    } catch (e) {
      if (context.mounted) showAppSnack(context, messageOf(e));
    }
  }

  Future<void> _delete(BuildContext context) async {
    final controller = context.read<InitiativesController>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar iniciativa'),
        content: Text('¿Quieres eliminar "${initiative.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerFg,
              minimumSize: const Size(110, 44),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await controller.delete(initiative);
      messenger.showSnackBar(
        const SnackBar(content: Text('Iniciativa eliminada.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(messageOf(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_OwnerAction>(
      tooltip: 'Opciones de la iniciativa',
      icon: const Icon(Icons.more_vert, color: AppColors.navy),
      onSelected: (action) {
        switch (action) {
          case _OwnerAction.edit:
            openPublishPage(context, initiative: initiative);
          case _OwnerAction.togglePopular:
            _togglePopular(context);
          case _OwnerAction.delete:
            _delete(context);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: _OwnerAction.edit, child: Text('Editar')),
        PopupMenuItem(
          value: _OwnerAction.togglePopular,
          child: Text(
            initiative.isPopularManually
                ? 'Quitar marca de popular'
                : 'Marcar como popular',
          ),
        ),
        const PopupMenuItem(
          value: _OwnerAction.delete,
          child: Text('Eliminar', style: TextStyle(color: AppColors.dangerFg)),
        ),
      ],
    );
  }
}
