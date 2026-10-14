import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Escala tipográfica pensada para legibilidad en móvil: nada por debajo de
/// 12 px y cuerpo de texto de 15–16 px con interlineado amplio.
class AppText {
  AppText._();

  static const screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.55,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 1.5,
  );

  static const caption = TextStyle(
    fontSize: 13,
    height: 1.4,
  );

  /// Etiquetas en mayúsculas como "ROLES DISPONIBLES".
  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.9,
    color: AppColors.muted,
  );

  static const tag = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
}
