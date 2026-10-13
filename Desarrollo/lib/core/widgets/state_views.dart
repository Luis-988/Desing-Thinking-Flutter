import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Pantalla vacía con icono, mensaje y acción opcional.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.navy),
            ),
            const SizedBox(height: 18),
            Text(title, style: AppText.sectionTitle, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: AppText.body, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error con botón de reintento.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'No pudimos cargar la información',
      message: message,
      actionLabel: 'Reintentar',
      onAction: onRetry,
    );
  }
}

/// Esqueletos animados mientras se cargan las tarjetas.
class SkeletonList extends StatefulWidget {
  final int count;

  const SkeletonList({super.key, this.count = 3});

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Column(
        children: List.generate(
          widget.count,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: _SkeletonCard(),
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  Widget _bar(double width, {double height = 12}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.border,
      borderRadius: BorderRadius.circular(6),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(180, height: 18),
            const SizedBox(height: 12),
            Row(children: [_bar(70, height: 22), const SizedBox(width: 8), _bar(90, height: 22)]),
            const SizedBox(height: 14),
            _bar(double.infinity),
            const SizedBox(height: 8),
            _bar(double.infinity),
            const SizedBox(height: 8),
            _bar(140),
            const SizedBox(height: 16),
            _bar(double.infinity, height: 40),
          ],
        ),
      ),
    );
  }
}
