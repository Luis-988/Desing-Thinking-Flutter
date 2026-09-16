import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/initiative.dart';

class InitiativeDetailPage extends StatefulWidget {
  final Initiative initiative;
  final List<InitiativeApplication> applications;
  final ValueChanged<InitiativeApplication> onApplicationSubmitted;

  const InitiativeDetailPage({
    super.key,
    required this.initiative,
    this.applications = const [],
    required this.onApplicationSubmitted,
  });

  @override
  State<InitiativeDetailPage> createState() => _InitiativeDetailPageState();
}

class _InitiativeDetailPageState extends State<InitiativeDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.initiative.registerView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ficha de iniciativa')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.initiative.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '${widget.initiative.categories.join(' · ')} • Liderado por ${widget.initiative.leader}',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.initiative.views} visitas',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 20),
          Text(widget.initiative.description),
          const SizedBox(height: 20),
          const Text(
            'Vacantes disponibles',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ...widget.initiative.roles.map(
            (role) => ListTile(
              title: Text(role.name),
              subtitle: Text(role.description),
              trailing: _roleAction(role.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleAction(String roleName) {
    final application = widget.applications
        .where((item) => item.roleName == roleName && item.applicantName == 'Tú')
        .firstOrNull;
    if (application == null) {
      return ElevatedButton(
        onPressed: () => _apply(roleName),
        child: const Text('Postular'),
      );
    }
    return Chip(
      label: Text(_statusLabel(application.status)),
      backgroundColor: _statusColor(application.status),
    );
  }

  String _statusLabel(ApplicationStatus status) => switch (status) {
    ApplicationStatus.pending => 'Pendiente',
    ApplicationStatus.accepted => 'Aceptada',
    ApplicationStatus.rejected => 'Rechazada',
  };

  Color _statusColor(ApplicationStatus status) => switch (status) {
    ApplicationStatus.pending => const Color(0xFFFFF1CC),
    ApplicationStatus.accepted => const Color(0xFFD9F8E7),
    ApplicationStatus.rejected => const Color(0xFFFDE2E1),
  };

  void _apply(String role) {
    Navigator.push<InitiativeApplication>(
      context,
      MaterialPageRoute(
        builder: (_) => ApplyInitiativePage(
          initiative: widget.initiative,
          roleName: role,
        ),
      ),
    ).then((application) {
      if (application != null && mounted) {
        widget.onApplicationSubmitted(application);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Postulación enviada con éxito!')),
        );
      }
    });
  }
}

class ApplyInitiativePage extends StatefulWidget {
  final Initiative initiative;
  final String roleName;

  const ApplyInitiativePage({
    super.key,
    required this.initiative,
    required this.roleName,
  });

  @override
  State<ApplyInitiativePage> createState() => _ApplyInitiativePageState();
}

class _ApplyInitiativePageState extends State<ApplyInitiativePage> {
  final nameController = TextEditingController();
  final programController = TextEditingController();
  final semesterController = TextEditingController();
  final skillsController = TextEditingController();
  final messageController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    programController.dispose();
    semesterController.dispose();
    skillsController.dispose();
    messageController.dispose();
    super.dispose();
  }

  bool _hasCompleteProfile() {
    return nameController.text.trim().isNotEmpty &&
        programController.text.trim().isNotEmpty &&
        semesterController.text.trim().isNotEmpty &&
        skillsController.text.trim().isNotEmpty &&
        messageController.text.trim().isNotEmpty;
  }

  void _reviewApplication() {
    if (!_hasCompleteProfile()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los datos para continuar.')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Quieres enviar tu postulación?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Revisa los datos antes de confirmar.',
              style: TextStyle(color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 16),
            _contextCard(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.pop(context, _buildApplication());
                    },
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.navy),
                    child: const Text('Enviar postulación'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InitiativeApplication _buildApplication() => InitiativeApplication(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    initiativeId: widget.initiative.id,
    applicantName: nameController.text.trim(),
    program: programController.text.trim(),
    semester: semesterController.text.trim(),
    roleName: widget.roleName,
    skills: skillsController.text.trim(),
    message: messageController.text.trim(),
  );

  Widget _contextCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFEEF2F8),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        _contextRow('Iniciativa:', widget.initiative.title),
        const SizedBox(height: 8),
        _contextRow('Rol:', widget.roleName),
      ],
    ),
  );

  Widget _contextRow(String label, String value) => Row(
    children: [
      SizedBox(
        width: 82,
        child: Text(label, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13)),
      ),
      Expanded(
        child: Text(value, style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postulación')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          Text(
            'Postularme a ${widget.roleName}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
          ),
          const SizedBox(height: 5),
          const Text(
            'Completa tu perfil y envía tu postulación.',
            style: TextStyle(color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 18),
          _contextCard(),
          const SizedBox(height: 24),
          _sectionLabel('TU PERFIL'),
          _field(nameController, 'Nombre completo', 'Ej. Laura Castillo'),
          _field(programController, 'Programa académico', 'Ej. Diseño Industrial'),
          _field(semesterController, 'Semestre', 'Ej. 6to semestre'),
          _field(skillsController, 'Habilidades relevantes', 'Ej. Figma, UX Research, Prototipado'),
          const SizedBox(height: 12),
          _sectionLabel('MENSAJE PARA EL LÍDER'),
          TextField(
            controller: messageController,
            maxLines: 5,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: 'Cuéntanos por qué te interesa participar y qué puedes aportar al proyecto.',
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _reviewApplication,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.navy,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Revisar y enviar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _field(TextEditingController controller, String label, String hint) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
    ),
  );
}

class PublishInitiativePage extends StatefulWidget {
  final Initiative? initiative;

  const PublishInitiativePage({super.key, this.initiative});

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
        const SnackBar(content: Text('Selecciona una vacante y describe lo que se requiere.')),
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
          const SnackBar(content: Text('Escribe una descripción del proyecto.')),
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
      if (selectedRole != null || roleDescriptionController.text.trim().isNotEmpty) {
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
          widget.initiative == null ? 'Publicar nuevo proyecto' : 'Editar proyecto',
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
                      leader: 'Tú',
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
                  decoration: const InputDecoration(labelText: 'Nombre del proyecto'),
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
                  decoration: const InputDecoration(
                    labelText: 'Agregar categoría',
                    border: OutlineInputBorder(),
                  ),
                    items: categories
                      .where((category) => !selectedCategories.contains(category))
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
                        decoration: const InputDecoration(
                          labelText: 'Vacante',
                        ),
                        items: const [
                          'Diseñador UX/UI',
                          'Desarrollador Frontend',
                          'Desarrollador Backend',
                          'Marketing',
                          'Investigador',
                          'Product Manager',
                          'Data Analyst',
                        ].map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ),
                        ).toList(),
                        onChanged: (value) => setState(() => selectedRole = value),
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
                      onPressed: () => setState(() => selectedRoles.remove(role)),
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
