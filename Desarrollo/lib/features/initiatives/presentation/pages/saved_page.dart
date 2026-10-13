import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../home/presentation/providers/home_tab_controller.dart';
import '../providers/initiatives_controller.dart';
import '../widgets/initiative_card.dart';

/// Pestaña Guardados: iniciativas marcadas para revisar después.
class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<InitiativesController>().savedInitiatives;

    return Column(
      children: [
        ScreenHeader(
          icon: Icons.bookmark_border,
          title: 'Guardados',
          subtitle: saved.isEmpty
              ? 'Tus proyectos favoritos'
              : '${saved.length} ${saved.length == 1 ? 'proyecto guardado' : 'proyectos guardados'}',
        ),
        Expanded(
          child: saved.isEmpty
              ? EmptyState(
                  icon: Icons.bookmark_add_outlined,
                  title: 'Aún no guardas proyectos',
                  message:
                      'Toca el marcador de una iniciativa para tenerla a mano.',
                  actionLabel: 'Explorar proyectos',
                  onAction: () =>
                      context.read<HomeTabController>().go(HomeTabs.explore),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                    for (final initiative in saved)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: InitiativeCard(initiative: initiative),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
