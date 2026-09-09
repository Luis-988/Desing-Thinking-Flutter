import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/initiative.dart';

class InitiativeDetailPage extends StatelessWidget {
  final Initiative initiative;

  const InitiativeDetailPage({super.key, required this.initiative});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ficha de iniciativa')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            initiative.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '${initiative.category} • Liderado por ${initiative.leader}',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          Text(initiative.description),
          const SizedBox(height: 20),
          const Text(
            'Vacantes disponibles',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ...initiative.roles.map(
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
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Iniciativa publicada!')),
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
        steps: const [
          Step(
            title: Text('Información general'),
            content: TextField(
              decoration: InputDecoration(labelText: 'Nombre de la iniciativa'),
            ),
          ),
          Step(
            title: Text('Categoría'),
            content: TextField(
              decoration: InputDecoration(labelText: 'Facultad o categoría'),
            ),
          ),
          Step(
            title: Text('Vacantes'),
            content: TextField(
              decoration: InputDecoration(labelText: 'Roles que buscas'),
            ),
          ),
        ],
      ),
    );
  }
}
