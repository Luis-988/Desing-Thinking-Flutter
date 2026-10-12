import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/initiative.dart';

class PublishInitiativePage extends StatefulWidget {
  final Initiative? initiative;
  final String leaderName;

  const PublishInitiativePage({
    super.key,
    this.initiative,
    this.leaderName = 'Tú',
  });

  @override
  State<PublishInitiativePage> createState() => _PublishInitiativePageState();
}

class _PublishInitiativePageState extends State<PublishInitiativePage> {
  int step = 0;
  bool isPopularManually = false;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final List<String> selectedCategories = [];
  String? selectedRole;
  final roleDescriptionController = TextEditingController();
  final List<InitiativeRole> selectedRoles = [];

  final List<String> categories = const [
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

  @override
  void initState() {
    super.initState();
    final initiative = widget.initiative;
    if (initiative != null) {
      titleController.text = initiative.title;
      descriptionController.text = initiative.description;
      selectedCategories.addAll(initiative.categories);
      isPopularManually = initiative.isPopularManually;
      selectedRoles.addAll(initiative.roles);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    roleDescriptionController.dispose();
    super.dispose();
  }

  void _addRole() {
    final roleDescription = roleDescriptionController.text.trim();
    if (selectedRole == null || roleDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona una vacante y describe lo que se requiere.',
          ),
        ),
      );
      return;
    }
    if (selectedRoles.any((role) => role.name == selectedRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esa vacante ya está agregada.')),
      );
      return;
    }
    setState(() {
      selectedRoles.add(
        InitiativeRole(name: selectedRole!, description: roleDescription),
      );
      selectedRole = null;
      roleDescriptionController.clear();
    });
  }

  bool _validateCurrentStep() {
    if (step == 0) {
      if (titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escribe el título del proyecto.')),
        );
        return false;
      }
      if (descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escribe una descripción del proyecto.'),
          ),
        );
        return false;
      }
    }

    if (step == 1 && selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos una categoría.')),
      );
      return false;
    }

    if (step == 2) {
      if (selectedRole != null ||
          roleDescriptionController.text.trim().isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presiona + para agregar la vacante.')),
        );
        return false;
      }
      if (selectedRoles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agrega al menos una vacante.')),
        );
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initiative == null
              ? 'Publicar nuevo proyecto'
              : 'Editar proyecto',
        ),
      ),
      body: Stepper(
        currentStep: step,
        onStepContinue: () {
          if (!_validateCurrentStep()) return;
          if (step < 2) {
            setState(() => step++);
          } else {
            final title = titleController.text.trim();

            Navigator.pop(
              context,
              widget.initiative == null
                  ? Initiative(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      categories: List.of(selectedCategories),
                      description: descriptionController.text.trim(),
                      leader: widget.leaderName,
                      isPopularManually: isPopularManually,
                      isActive: true,
                      roles: List.of(selectedRoles),
                    )
                  : (widget.initiative!
                      ..title = title
                      ..categories = List.of(selectedCategories)
                      ..description = descriptionController.text.trim()
                      ..roles = List.of(selectedRoles)
                      ..isPopularManually = isPopularManually),
            );
          }
        },
        onStepCancel: () => setState(() => step > 0 ? step-- : step),
        controlsBuilder: (context, details) => Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navy,
                foregroundColor: Colors.white,
              ),
              onPressed: details.onStepContinue,
              child: Text(step == 2 ? 'Publicar' : 'Siguiente'),
            ),
            if (step > 0)
              TextButton(
                onPressed: details.onStepCancel,
                child: const Text('Atrás'),
              ),
          ],
        ),
        steps: [
          Step(
            title: const Text('Información general'),
            content: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del proyecto',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: '¿Qué problema busca resolver este proyecto?',
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Facultad o categorías'),
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey(selectedCategories.join('|')),
                  decoration: const InputDecoration(
                    labelText: 'Agregar categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .where(
                        (category) => !selectedCategories.contains(category),
                      )
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null || selectedCategories.contains(value)) {
                      return;
                    }
                    setState(() {
                      selectedCategories.add(value);
                    });
                  },
                  hint: const Text('Selecciona una categoría'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: selectedCategories
                        .map(
                          (category) => InputChip(
                            label: Text(category),
                            onDeleted: () => setState(
                              () => selectedCategories.remove(category),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Marcar como popular'),
                  subtitle: Text('También podrás cambiarlo después.'),
                  value: isPopularManually,
                  onChanged: (value) =>
                      setState(() => isPopularManually = value),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Vacantes'),
            content: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(labelText: 'Vacante'),
                        items:
                            const [
                                  'Diseñador UX/UI',
                                  'Desarrollador Frontend',
                                  'Desarrollador Backend',
                                  'Marketing',
                                  'Investigador',
                                  'Product Manager',
                                  'Data Analyst',
                                ]
                                .map(
                                  (role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) =>
                            setState(() => selectedRole = value),
                        hint: const Text('Selecciona'),
                      ),
                    ),
                    IconButton(
                      onPressed: _addRole,
                      tooltip: 'Agregar vacante',
                      icon: const Icon(Icons.add_circle),
                      color: AppTheme.navy,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: roleDescriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Qué se requiere',
                    hintText: 'Describe brevemente el perfil o aporte esperado',
                  ),
                ),
                const SizedBox(height: 12),
                ...selectedRoles.map(
                  (role) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(role.name),
                    subtitle: Text(role.description),
                    trailing: IconButton(
                      onPressed: () =>
                          setState(() => selectedRoles.remove(role)),
                      tooltip: 'Quitar vacante',
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
