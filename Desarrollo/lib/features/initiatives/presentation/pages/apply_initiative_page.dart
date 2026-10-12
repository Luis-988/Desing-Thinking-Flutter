import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/initiative.dart';
import '../../domain/entities/initiative_application.dart';

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
        const SnackBar(
          content: Text('Completa todos los datos para continuar.'),
        ),
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
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.navy,
                    ),
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
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            color: AppTheme.navy,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
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
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
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
          _field(
            programController,
            'Programa académico',
            'Ej. Diseño Industrial',
          ),
          _field(semesterController, 'Semestre', 'Ej. 6to semestre'),
          _field(
            skillsController,
            'Habilidades relevantes',
            'Ej. Figma, UX Research, Prototipado',
          ),
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

  Widget _field(TextEditingController controller, String label, String hint) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
      );
}
