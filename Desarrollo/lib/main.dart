import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/providers/session_controller.dart';
import 'features/home/presentation/pages/home_shell.dart';
import 'features/home/presentation/providers/home_tab_controller.dart';
import 'features/initiatives/presentation/providers/initiatives_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Injection.init();
  runApp(const UninorteInnovacionApp());
}

class UninorteInnovacionApp extends StatelessWidget {
  /// Se desactiva en pruebas para no descargar fuentes de internet.
  final bool useGoogleFonts;

  const UninorteInnovacionApp({super.key, this.useGoogleFonts = true});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionController>(
          create: (_) => Injection.createSessionController()..restore(),
        ),
        ChangeNotifierProxyProvider<SessionController, InitiativesController>(
          create: (_) => Injection.createInitiativesController(),
          update: (_, session, controller) {
            controller!.syncSession(session.status);
            return controller;
          },
        ),
        ChangeNotifierProvider<HomeTabController>(
          create: (_) => HomeTabController(),
        ),
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController(),
        ),
      ],
      child: _ThemedApp(useGoogleFonts: useGoogleFonts),
    );
  }
}

class _ThemedApp extends StatelessWidget {
  final bool useGoogleFonts;

  const _ThemedApp({required this.useGoogleFonts});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeController>().mode;
    return MaterialApp(
      title: 'Innovación Uninorte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(useGoogleFonts: useGoogleFonts),
      darkTheme: AppTheme.dark(useGoogleFonts: useGoogleFonts),
      themeMode: mode,
      scrollBehavior: const _NoStretchScrollBehavior(),
      home: const _AppRoot(),
    );
  }
}

/// Muestra una pantalla de carga hasta saber si hay sesión guardada.
class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final status = context.select<SessionController, SessionStatus>(
      (session) => session.status,
    );
    if (status == SessionStatus.unknown) return const _SplashScreen();
    return const HomeShell();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lightbulb_outline, size: 56, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Innovación Uninorte',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
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
