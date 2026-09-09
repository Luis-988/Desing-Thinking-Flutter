import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/initiatives/data/initiative_data.dart';
import 'features/initiatives/pages/feed_page.dart';

void main() {
  runApp(const UninorteInnovacionApp());
}

class UninorteInnovacionApp extends StatelessWidget {
  const UninorteInnovacionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innovación Uninorte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const _NoStretchScrollBehavior(),
      home: FeedPage(initiatives: localInitiatives),
    );
  }
}

class _NoStretchScrollBehavior extends MaterialScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
