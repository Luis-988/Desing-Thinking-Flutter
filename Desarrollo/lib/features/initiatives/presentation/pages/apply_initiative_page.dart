import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_snack.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../domain/entities/initiative.dart';
import '../../domain/entities/initiative_application.dart';
import '../providers/initiatives_controller.dart';
import 'application_sent_page.dart';

/// Formulario de postulación. Los datos del perfil vienen precargados.
class ApplyInitiativePage extends StatefulWidget {
  final String initiativeId;
  final String roleName;

  const ApplyInitiativePage({
    super.key,
    required this.initiativeId,
    required this.roleName,
  });

  @override
  State<ApplyInitiativePage> createState() => _ApplyInitiativePageState();
}

class _ApplyInitiativePageState extends State<ApplyInitiativePage> {
  static const _maxMessage = 300;

  late final TextEditingController _name;
  late final TextEditingController _program;
  late final TextEditingController _semester;
  final _skills = TextEditingController();
  final _message = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<SessionController>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _program = TextEditingController(text: user?.program ?? '');
    _semester = TextEditingController(text: user?.semester ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _program.dispose();
    _semester.dispose();
    _skills.dispose();
    _message.dispose();
    super.dispose();
  }

  bool get _isComplete =>
      _name.text.trim().isNotEmpty &&
      _program.text.trim().isNotEmpty &&
      _semester.text.trim().isNotEmpty &&
      _skills.text.trim().isNotEmpty &&
      _message.text.trim().isNotEmpty;

  InitiativeApplication _build() => InitiativeApplication(
    id: '',
    initiativeId: widget.initiativeId,
    applicantName: _name.text.trim(),
    program: _program.text.trim(),
    semester: _semester.text.trim(),
    roleName: widget.roleName,
    skills: _skills.text.trim(),
    message: _message.text.trim(),
  );

  Future<void> _review(Initiative initiative) async {
    if (!_isComplete) {
      showAppSnack(context, 'Completa todos los datos para continuar.');
      return;
    }
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ConfirmSheet(
        initiativeTitle: initiative.title,
        roleName: widget.roleName,
      ),
    );
    if (confirmed == true) await _send(initiative);
  }

  Future<void> _send(Initiative initiative) async {
    setState(() => _isSending = true);
    try {
      await context.read<InitiativesController>().apply(_build());
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ApplicationSentPage(
            initiativeTitle: initiative.title,
            roleName: widget.roleName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      showAppSnack(context, messageOf(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final initiative = context
        .watch<InitiativesController>()
        .initiativeById(widget.initiativeId);

    if (initiative == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Postulación')),
        body: const Center(child: Text('Esta iniciativa ya no existe.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Postulación')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Postularme a ${widget.roleName}',
            style: AppText.screenTitle,
          ),
          const SizedBox(height: 6),
          const Text(
            'Revisa tu perfil y cuéntale al líder por qué quieres sumarte.',
            style: AppText.body,
          ),
          const SizedBox(height: 18),
          _ContextCard(
            initiativeTitle: initiative.title,
            roleName: widget.roleName,
          ),
          const SizedBox(height: 24),
          const Text('TU PERFIL', style: AppText.label),
          const SizedBox(height: 10),
          _field(_name, 'Nombre completo', 'Ej. Laura Castillo'),
          _field(_program, 'Programa académico', 'Ej. Diseño Industrial'),
          _field(_semester, 'Semestre', 'Ej. 6'),
          _field(
            _skills,
            'Habilidades relevantes',
            'Ej. Figma, UX Research, Prototipado',
          ),
          const SizedBox(height: 12),
          const Text('MENSAJE PARA EL LÍDER', style: AppText.label),
          const SizedBox(height: 10),
          TextField(
            controller: _message,
            maxLines: 5,
            maxLength: _maxMessage,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText:
                  'Cuéntanos por qué te interesa participar y qué puedes aportar al proyecto.',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSending ? null : () => _review(initiative),
            child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Revisar y enviar'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  final String initiativeTitle;
  final String roleName;

  const _ContextCard({required this.initiativeTitle, required this.roleName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _row('Iniciativa', initiativeTitle),
          const SizedBox(height: 8),
          _row('Rol', roleName),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 84, child: Text(label, style: AppText.caption)),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    ],
  );
}

class _ConfirmSheet extends StatelessWidget {
  final String initiativeTitle;
  final String roleName;

  const _ConfirmSheet({required this.initiativeTitle, required this.roleName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Enviar tu postulación?', style: AppText.sectionTitle),
            const SizedBox(height: 6),
            const Text(
              'Revisa los datos antes de confirmar.',
              style: AppText.body,
            ),
            const SizedBox(height: 16),
            _ContextCard(initiativeTitle: initiativeTitle, roleName: roleName),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Enviar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
