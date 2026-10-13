import 'package:flutter/material.dart';

import '../../../../core/widgets/app_tag.dart';
import '../../domain/entities/initiative_application.dart';

/// Etiqueta de color según el estado de una postulación.
class StatusPill extends StatelessWidget {
  final ApplicationStatus status;

  const StatusPill(this.status, {super.key});

  static String labelOf(ApplicationStatus status) => switch (status) {
    ApplicationStatus.pending => 'Pendiente',
    ApplicationStatus.accepted => 'Aceptada',
    ApplicationStatus.rejected => 'Rechazada',
  };

  @override
  Widget build(BuildContext context) => switch (status) {
    ApplicationStatus.pending => AppTag.warning(
      labelOf(status),
      icon: Icons.schedule,
    ),
    ApplicationStatus.accepted => AppTag.success(
      labelOf(status),
      icon: Icons.check_circle_outline,
    ),
    ApplicationStatus.rejected => AppTag.danger(
      labelOf(status),
      icon: Icons.cancel_outlined,
    ),
  };
}
