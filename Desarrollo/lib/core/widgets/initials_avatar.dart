import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Círculo con las iniciales de una persona.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const InitialsAvatar({super.key, required this.name, this.radius = 20});

  static String initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.secondary,
      child: Text(
        initialsOf(name),
        style: TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.72,
        ),
      ),
    );
  }
}
