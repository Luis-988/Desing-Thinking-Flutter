import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/initiative.dart';
import '../providers/initiatives_controller.dart';
import '../widgets/initiative_card.dart';

/// Pestaña Explorar: búsqueda, filtros y catálogo de iniciativas.
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InitiativesController>();
    final results = controller.filteredInitiatives;
    final hasFilter = controller.filter != InitiativesController.allFilter;

    return Column(
      children: [
        ScreenHeader(
          icon: Icons.explore_outlined,
          title: 'Explorar',
          subtitle:
              '${controller.activeInitiatives.length} iniciativas activas',
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                TextField(
                  controller: _search,
                  onChanged: controller.setQuery,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Busca por nombre, categoría o rol',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Borrar búsqueda',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              controller.setQuery('');
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => _showFilters(context, controller),
                  icon: const Icon(Icons.tune),
                  label: Text(
                    controller.filter == InitiativesController.allFilter
                        ? 'Filtrar por intereses, roles o tipo'
                        : 'Filtro: ${controller.filter}',
                  ),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                if (hasFilter)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        const Text('1 filtro activo', style: AppText.caption),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            _search.clear();
                            controller.clearFilters();
                          },
                          child: const Text('Limpiar filtros'),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),
                ..._body(context, controller, results),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showFilters(
    BuildContext context,
    InitiativesController controller,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _FiltersSheet(controller: controller),
    );
  }

  List<Widget> _body(
    BuildContext context,
    InitiativesController controller,
    List<Initiative> results,
  ) {
    if (controller.isLoading && controller.initiatives.isEmpty) {
      return const [SkeletonList()];
    }
    if (controller.error != null && controller.initiatives.isEmpty) {
      return [
        SizedBox(
          height: 360,
          child: ErrorState(
            message: controller.error!,
            onRetry: controller.load,
          ),
        ),
      ];
    }

    if (results.isEmpty) {
      return [
        const SizedBox(
          height: 320,
          child: EmptyState(
            icon: Icons.search_off,
            title: 'Sin resultados',
            message: 'Prueba con otra búsqueda o limpia los filtros.',
          ),
        ),
      ];
    }
    return [
      Text(
        '${results.length} ${results.length == 1 ? 'resultado' : 'resultados'}',
        style: AppText.caption,
      ),
      const SizedBox(height: 10),
      for (final initiative in results)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InitiativeCard(initiative: initiative),
        ),
    ];
  }
}

class _FiltersSheet extends StatelessWidget {
  final InitiativesController controller;

  const _FiltersSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filtrar iniciativas',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Intereses y tipos de proyecto',
                style: AppText.sectionTitle,
              ),
              const SizedBox(height: 10),
              _FilterChips(
                options: controller.categoryOptions,
                selected: controller.filter,
                onSelected: (value) {
                  controller.setFilter(value);
                  Navigator.pop(context);
                },
              ),
              if (controller.roleOptions.isNotEmpty) ...[
                const SizedBox(height: 22),
                const Text('Roles', style: AppText.sectionTitle),
                const SizedBox(height: 10),
                _FilterChips(
                  options: controller.roleOptions,
                  selected: controller.filter,
                  onSelected: (value) {
                    controller.setFilter(value);
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterChips({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const Text(
        'Todavía no hay opciones disponibles.',
        style: AppText.body,
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option),
            selected: selected == option,
            showCheckmark: false,
            selectedColor: AppColors.navy,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: selected == option ? AppColors.navy : AppColors.border,
            ),
            labelStyle: TextStyle(
              color: selected == option ? Colors.white : AppColors.navy,
            ),
            onSelected: (_) => onSelected(option),
          ),
      ],
    );
  }
}
