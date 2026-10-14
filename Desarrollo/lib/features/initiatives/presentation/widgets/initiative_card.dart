import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../domain/entities/initiative.dart';
import '../pages/initiative_detail_page.dart';
import 'bookmark_button.dart';

/// Tarjeta completa de una iniciativa (Explorar, Guardados, Mis iniciativas).
class InitiativeCard extends StatelessWidget {
  final Initiative initiative;

  /// Acciones extra para el líder (editar, destacar, eliminar).
  final Widget? ownerActions;

  const InitiativeCard({super.key, required this.initiative, this.ownerActions});

  @override
  Widget build(BuildContext context) {
    final roles = initiative.roles;
    final isAlmostFull = initiative.isActive &&
        initiative.openSlots > 0 &&
        initiative.openSlots <= 1;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openInitiative(context, initiative.id),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (initiative.isPopular)
                    const AppTag.accent('MÁS POPULAR', icon: Icons.local_fire_department),
                  if (isAlmostFull) ...[
                    if (initiative.isPopular) const SizedBox(width: 6),
                    const AppTag.warning('ÚLTIMA PLAZA', icon: Icons.bolt),
                  ],
                  if (initiative.isMine) ...[
                    if (initiative.isPopular) const SizedBox(width: 6),
                    const AppTag('Mi iniciativa'),
                  ],
                  const Spacer(),
                  if (ownerActions != null) ownerActions!,
                  BookmarkButton(initiativeId: initiative.id),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(initiative.title, style: AppText.cardTitle),
                        ),
                        if (initiative.isActive) const AppTag.success('Activa'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        InitialsAvatar(name: initiative.leader, radius: 12),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Liderada por ${initiative.leader}',
                            style: AppText.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (initiative.categories.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final category in initiative.categories)
                            AppTag(category),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      initiative.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _Stat(
                          icon: Icons.visibility_outlined,
                          text:
                              '${initiative.views} ${initiative.views == 1 ? 'visita' : 'visitas'}',
                        ),
                        const SizedBox(width: 16),
                        _Stat(
                          icon: Icons.group_add_outlined,
                          text:
                              '${initiative.openSlots} ${initiative.openSlots == 1 ? 'plaza' : 'plazas'}',
                        ),
                        const Spacer(),
                        Text(
                          initiative.openSlots == 0
                              ? 'Equipo completo'
                              : 'Buscando equipo',
                          style: AppText.caption.copyWith(
                            color: initiative.openSlots == 0
                                ? AppColors.muted
                                : AppColors.successFg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (roles.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text('ROLES DISPONIBLES', style: AppText.label),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final role in roles.take(3)) AppTag.violet(role.name),
                          if (roles.length > 3)
                            AppTag('+${roles.length - 3} más'),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => openInitiative(context, initiative.id),
                      child: const Text('Ver iniciativa'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Stat({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 5),
        Text(text, style: AppText.caption),
      ],
    );
  }
}

/// Versión corta para listas horizontales en Inicio.
class CompactInitiativeCard extends StatelessWidget {
  final Initiative initiative;

  const CompactInitiativeCard({super.key, required this.initiative});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openInitiative(context, initiative.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (initiative.isPopular)
                      const AppTag.accent('POPULAR')
                    else
                      const AppTag.success('Activa'),
                    const Spacer(),
                    Text('${initiative.views} visitas', style: AppText.caption),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  initiative.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.cardTitle,
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    initiative.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body.copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.group_add_outlined,
                      size: 16,
                      color: AppColors.navy,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${initiative.openSlots} ${initiative.openSlots == 1 ? 'plaza' : 'plazas'} abiertas',
                      style: AppText.caption.copyWith(color: AppColors.navy),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
