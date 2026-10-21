import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Cabecera azul con el nombre de la sección, para que cada pestaña se
/// identifique de inmediato (Inicio, Explorar, Mis iniciativas…).
class ScreenHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? logoAsset;

  const ScreenHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.logoAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Row(
            children: [
              Container(
                width: logoAsset == null ? 44 : 64,
                height: logoAsset == null ? 44 : 64,
                decoration: BoxDecoration(
                  color: logoAsset == null
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: logoAsset == null
                    ? Icon(icon, color: Colors.white, size: 24)
                    : Padding(
                        padding: const EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            logoAsset!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                Icon(icon, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Color(0xFFD3DEF2),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              IconButton(
                tooltip: 'Abrir menú',
                onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
