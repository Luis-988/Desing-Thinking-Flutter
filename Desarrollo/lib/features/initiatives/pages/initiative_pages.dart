import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/initiative.dart';

class InitiativeDetailPage extends StatefulWidget {
  final Initiative initiative;

  const InitiativeDetailPage({super.key, required this.initiative});

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
              trailing: ElevatedButton(
                onPressed: () => _apply(context, role.name),
                child: const Text('Postular'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _apply(BuildContext context, String role) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Postularme como $role'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(hintText: 'Escribe un mensaje breve'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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
  final categoryController = TextEditingController();
  final roleController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    roleController.dispose();
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
            final category = categoryController.text.trim();
            final role = roleController.text.trim();

            if (title.isEmpty || category.isEmpty || role.isEmpty) {
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
                category: category,
                description: 'Nueva iniciativa publicada por ti.',
                leader: 'Tú',
                isPopularManually: isPopularManually,
                isActive: true,
                roles: [InitiativeRole(name: role, availablePlaces: 1)],
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
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Facultad o categoría',
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
            title: Text('Vacantes'),
            content: TextField(
              controller: roleController,
              decoration: InputDecoration(labelText: 'Roles que buscas'),
            ),
          ),
        ],
      ),
    );
  }
}
