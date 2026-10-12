import 'package:flutter/material.dart';

import '../../domain/entities/initiative.dart';
import '../../domain/entities/initiative_application.dart';
import 'apply_initiative_page.dart';

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
        .where(
          (item) =>
              item.roleName == roleName &&
              (item.isMine || item.applicantName == 'Tú'),
        )
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
        builder: (_) =>
            ApplyInitiativePage(initiative: widget.initiative, roleName: role),
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
