import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_snack.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../../auth/presentation/utils/require_login.dart';
import '../../domain/entities/initiative.dart';
import '../providers/initiatives_controller.dart';

/// Asistente de 3 pasos para publicar o editar una iniciativa.
class PublishInitiativePage extends StatefulWidget {
  /// Si se recibe, la pantalla funciona en modo edición.
  final Initiative? initiative;

  const PublishInitiativePage({super.key, this.initiative});

  @override
  State<PublishInitiativePage> createState() => _PublishInitiativePageState();
}

class _PublishInitiativePageState extends State<PublishInitiativePage> {
  static const _stepTitles = ['Información general', 'Categorías', 'Vacantes'];

  static const _categories = [
    'Ingeniería',
    'Diseño',
    'Sostenibilidad',
    'Salud',
    'Tecnología',
    'Educación',
    'Negocios',
    'Emprendimiento',
    'Investigación',
    'Impacto social',
  ];

  static const _roleOptions = [
    'Diseñador UX/UI',
    'Desarrollador Frontend',
    'Desarrollador Backend',
    'Marketing',
    'Investigador',
    'Product Manager',
    'Data Analyst',
  ];

  int _step = 0;
  bool _isSaving = false;
  bool _isPopular = false;

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _roleDescription = TextEditingController();
  final _roleSkills = TextEditingController();
  final List<String> _selectedCategories = [];
  final List<InitiativeRole> _roles = [];
  String? _roleName;
  int _roleSlots = 1;

  bool get _isEditing => widget.initiative != null;

  @override
  void initState() {
    super.initState();
    final initiative = widget.initiative;
    if (initiative != null) {
      _title.text = initiative.title;
      _description.text = initiative.description;
      _selectedCategories.addAll(initiative.categories);
      _roles.addAll(initiative.roles);
      _isPopular = initiative.isPopularManually;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _roleDescription.dispose();
    _roleSkills.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------- validación

  bool get _hasUnaddedRole =>
      _roleName != null ||
      _roleDescription.text.trim().isNotEmpty ||
      _roleSkills.text.trim().isNotEmpty;

  String? _validateStep() {
    switch (_step) {
      case 0:
        if (_title.text.trim().isEmpty) return 'Escribe el título del proyecto.';
        if (_description.text.trim().isEmpty) {
          return 'Escribe una descripción del proyecto.';
        }
      case 1:
        if (_selectedCategories.isEmpty) return 'Elige al menos una categoría.';
      case 2:
        if (_hasUnaddedRole) {
          return 'Presiona "Agregar vacante" para guardar la que estás editando.';
        }
        if (_roles.isEmpty) return 'Agrega al menos una vacante.';
    }
    return null;
  }

  void _addRole() {
    final description = _roleDescription.text.trim();
    if (_roleName == null || description.isEmpty) {
      showAppSnack(
        context,
        'Selecciona una vacante y describe lo que se requiere.',
      );
      return;
    }
    if (_roles.any((role) => role.name == _roleName)) {
      showAppSnack(context, 'Esa vacante ya está agregada.');
      return;
    }
    final skills = _roleSkills.text
        .split(',')
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();
    setState(() {
      _roles.add(
        InitiativeRole(
          name: _roleName!,
          description: description,
          slots: _roleSlots,
          skills: skills,
        ),
      );
      _roleName = null;
      _roleSlots = 1;
      _roleDescription.clear();
      _roleSkills.clear();
    });
  }

  // ------------------------------------------------------------------ envío

  Future<void> _next() async {
    final error = _validateStep();
    if (error != null) {
      showAppSnack(context, error);
      return;
    }
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    await _save();
  }

  Future<void> _save() async {
    final controller = context.read<InitiativesController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final leader = context.read<SessionController>().user?.name ?? 'Tú';
    final base = widget.initiative;

    setState(() => _isSaving = true);
    try {
      if (base == null) {
        await controller.create(
          Initiative(
            id: '',
            title: _title.text.trim(),
            categories: List.of(_selectedCategories),
            description: _description.text.trim(),
            leader: leader,
            isPopularManually: _isPopular,
            isActive: true,
            roles: List.of(_roles),
          ),
        );
      } else {
        await controller.update(
          base.copyWith(
            title: _title.text.trim(),
            categories: List.of(_selectedCategories),
            description: _description.text.trim(),
            isPopularManually: _isPopular,
            roles: List.of(_roles),
          ),
        );
      }
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Cambios guardados.' : '¡Proyecto publicado!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showAppSnack(context, messageOf(e));
    }
  }

  // --------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar proyecto' : 'Publicar nuevo proyecto'),
      ),
      body: Column(
        children: [
          _Progress(step: _step, titles: _stepTitles),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                if (_step == 0) ..._stepGeneral(),
                if (_step == 1) ..._stepCategories(),
                if (_step == 2) ..._stepRoles(),
              ],
            ),
          ),
          _BottomBar(
            step: _step,
            isSaving: _isSaving,
            isEditing: _isEditing,
            onBack: () => setState(() => _step--),
            onNext: _next,
          ),
        ],
      ),
    );
  }

  List<Widget> _stepGeneral() => [
    const Text('Cuéntanos sobre tu proyecto', style: AppText.sectionTitle),
    const SizedBox(height: 4),
    const Text(
      'Un buen título y una descripción clara atraen a más personas.',
      style: AppText.body,
    ),
    const SizedBox(height: 18),
    TextField(
      controller: _title,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(labelText: 'Nombre del proyecto'),
    ),
    const SizedBox(height: 14),
    TextField(
      controller: _description,
      maxLines: 6,
      maxLength: 600,
      decoration: const InputDecoration(
        labelText: 'Descripción',
        hintText: '¿Qué problema busca resolver este proyecto?',
        alignLabelWithHint: true,
      ),
    ),
  ];

  List<Widget> _stepCategories() => [
    const Text('¿En qué áreas encaja?', style: AppText.sectionTitle),
    const SizedBox(height: 4),
    const Text('Elige una o varias categorías.', style: AppText.body),
    const SizedBox(height: 16),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in _categories)
          FilterChip(
            label: Text(category),
            selected: _selectedCategories.contains(category),
            showCheckmark: false,
            selectedColor: AppColors.navy,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: _selectedCategories.contains(category)
                  ? AppColors.navy
                  : AppColors.border,
            ),
            labelStyle: TextStyle(
              fontSize: 14,
              color: _selectedCategories.contains(category)
                  ? Colors.white
                  : AppColors.navy,
            ),
            onSelected: (selected) => setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            }),
          ),
      ],
    ),
    const SizedBox(height: 16),
    SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Destacar como popular'),
      subtitle: const Text('También podrás cambiarlo después.'),
      value: _isPopular,
      onChanged: (value) => setState(() => _isPopular = value),
    ),
  ];

  List<Widget> _stepRoles() => [
    const Text('¿A quién necesitas?', style: AppText.sectionTitle),
    const SizedBox(height: 4),
    const Text(
      'Agrega las vacantes que quieres cubrir con tu equipo.',
      style: AppText.body,
    ),
    const SizedBox(height: 16),
    Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey(_roleName ?? 'none'),
              initialValue: _roleName,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Vacante'),
              hint: const Text('Selecciona'),
              items: [
                for (final role in _roleOptions)
                  DropdownMenuItem(value: role, child: Text(role)),
              ],
              onChanged: (value) => setState(() => _roleName = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roleDescription,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Qué se requiere',
                hintText: 'Describe el perfil o aporte esperado',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roleSkills,
              decoration: const InputDecoration(
                labelText: 'Habilidades (opcional)',
                hintText: 'Separadas por comas: Figma, Flutter',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Plazas', style: AppText.body)),
                IconButton.outlined(
                  tooltip: 'Menos plazas',
                  onPressed: _roleSlots > 1
                      ? () => setState(() => _roleSlots--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$_roleSlots',
                    textAlign: TextAlign.center,
                    style: AppText.sectionTitle,
                  ),
                ),
                IconButton.outlined(
                  tooltip: 'Más plazas',
                  onPressed: _roleSlots < 10
                      ? () => setState(() => _roleSlots++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addRole,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Agregar vacante'),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 18),
    if (_roles.isNotEmpty) ...[
      Text('Vacantes agregadas (${_roles.length})', style: AppText.label),
      const SizedBox(height: 8),
    ],
    for (final role in _roles)
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: ListTile(
            title: Text(
              '${role.name} · ${role.slots} ${role.slots == 1 ? 'plaza' : 'plazas'}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(role.description),
            trailing: IconButton(
              tooltip: 'Quitar vacante',
              icon: const Icon(Icons.delete_outline),
              color: AppColors.dangerFg,
              onPressed: () => setState(() => _roles.remove(role)),
            ),
          ),
        ),
      ),
  ];
}

class _Progress extends StatelessWidget {
  final int step;
  final List<String> titles;

  const _Progress({required this.step, required this.titles});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASO ${step + 1} DE ${titles.length} · ${titles[step].toUpperCase()}',
            style: AppText.label.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (step + 1) / titles.length,
              minHeight: 6,
              backgroundColor: AppColors.secondary,
              color: AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int step;
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomBar({
    required this.step,
    required this.isSaving,
    required this.isEditing,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = step == 2;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            if (step > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving ? null : onBack,
                  child: const Text('Atrás'),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: isSaving ? null : onNext,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isLast
                            ? (isEditing ? 'Guardar cambios' : 'Publicar')
                            : 'Siguiente',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Abre el asistente de publicación (exige sesión al crear una nueva).
void openPublishPage(BuildContext context, {Initiative? initiative}) {
  if (initiative == null && !_ensureLogin(context)) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PublishInitiativePage(initiative: initiative),
    ),
  );
}

bool _ensureLogin(BuildContext context) =>
    requireLogin(context, 'publicar un proyecto');
