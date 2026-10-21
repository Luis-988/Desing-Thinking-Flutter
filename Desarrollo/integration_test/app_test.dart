import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:desing_thinking_flutter/core/di/injection.dart';
import 'package:desing_thinking_flutter/main.dart';

import 'test_fakes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Injection.init(
      authRepository: FakeAuthRepository(),
      initiativeRepository: FakeInitiativeRepository(),
      projectActivityRepository: FakeProjectActivityRepository(),
    );
  });

  testWidgets('la app abre en Inicio con la barra de navegación', (
    tester,
  ) async {
    await tester.pumpWidget(const UninorteInnovacionApp(useGoogleFonts: false));
    await tester.pumpAndSettle();

    expect(find.text('Explorar'), findsWidgets);
    expect(find.text('Comunidad'), findsWidgets);
    expect(find.text('Perfil'), findsWidgets);
  });

  testWidgets('desde Explorar se ven las iniciativas', (tester) async {
    await tester.pumpWidget(const UninorteInnovacionApp(useGoogleFonts: false));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();

    expect(find.text('2 iniciativas activas'), findsOneWidget);
  });
}
