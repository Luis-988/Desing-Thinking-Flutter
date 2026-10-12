import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/entities/profile_user.dart';
import 'features/initiatives/presentation/pages/feed_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Injection.init();
  final user = await Injection.restoreSession();
  runApp(UninorteInnovacionApp(initialUser: user));
}

class UninorteInnovacionApp extends StatelessWidget {
  final ProfileUser? initialUser;

  const UninorteInnovacionApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innovación Uninorte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const _NoStretchScrollBehavior(),
      home: FeedPage(initialUser: initialUser),
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
