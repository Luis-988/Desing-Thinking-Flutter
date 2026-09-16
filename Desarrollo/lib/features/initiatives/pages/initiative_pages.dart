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
            '${widget.initiative.category} • Liderado por ${widget.initiative.leader}',
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
              subtitle: Text('${role.availablePlaces} plazas disponibles'),
              trailing: _roleAction(role.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleAction(String roleName) {
    final application = widget.applications
        .where((item) => item.roleName == roleName)
        .firstOrNull;
    if (application == null) {
      return ElevatedButton(
        onPressed: () => _apply(context, roleName),
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

  void _apply(BuildContext context, String role) {
    final messageController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Postularme como $role'),
        content: TextField(
          controller: messageController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Cuéntale al líder por qué haces match con este rol',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onApplicationSubmitted(
                InitiativeApplication(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  initiativeId: widget.initiative.id,
                  applicantName: 'Tú',
                  roleName: role,
                  message: messageController.text.trim().isEmpty
                      ? 'Me interesa aportar a esta iniciativa.'
                      : messageController.text.trim(),
                ),
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Postulación enviada con éxito!'),
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

class PublishInitiativePage extends StatefulWidget {
  const PublishInitiativePage({super.key});

  @override
  State<PublishInitiativePage> createState() => _PublishInitiativePageState();
}

class _PublishInitiativePageState extends State<PublishInitiativePage> {
  int step = 0;
  bool isPopularManually = false;
  final titleController = TextEditingController();
  String? selectedCategory;
  String? selectedRole;

  final List<String> categories = const [
    'Ingeniería',
    'Diseño',
    'Sostenibilidad',
    'Salud',
    'Tecnología',
    'Educación',
    'Negocios',
  ];

  final List<String> roles = const [
    'Diseñador UX/UI',
    'Desarrollador Frontend',
    'Desarrollador Backend',
    'Marketing',
    'Investigador',
    'Product Manager',
    'Data Analyst',
  ];

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar nueva iniciativa')),
      body: Stepper(
        currentStep: step,
        onStepContinue: () {
          if (step < 2) {
            setState(() => step++);
          } else {
            final title = titleController.text.trim();

            if (title.isEmpty || selectedCategory == null || selectedRole == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Completa todos los campos.')),
              );
              return;
            }

            Navigator.pop(
              context,
              Initiative(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                category: selectedCategory!,
                description: 'Nueva iniciativa publicada por ti.',
                leader: 'Tú',
                isPopularManually: isPopularManually,
                isActive: true,
                roles: [InitiativeRole(name: selectedRole!, availablePlaces: 1)],
              ),
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
            title: Text('Información general'),
            content: TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Nombre de la iniciativa'),
            ),
          ),
          Step(
            title: Text('Categoría'),
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Facultad o categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => selectedCategory = value),
                  hint: const Text('Selecciona una categoría'),
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
            title: Text('Vacantes'),
            content: DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Rol que buscas',
                border: OutlineInputBorder(),
              ),
              items: roles
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedRole = value),
              hint: const Text('Selecciona un rol'),
            ),
          ),
        ],
      ),
    );
  }
}
