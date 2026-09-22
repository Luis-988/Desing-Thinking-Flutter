// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:desing_thinking_flutter/main.dart';
import 'package:desing_thinking_flutter/features/initiatives/pages/initiative_pages.dart';
import 'package:desing_thinking_flutter/features/initiatives/models/initiative.dart';

void main() {
  testWidgets('muestra el home de iniciativas', (WidgetTester tester) async {
    await tester.pumpWidget(const UninorteInnovacionApp());

    expect(find.text('Sistema de Innovación'), findsOneWidget);
    expect(find.text('Explora proyectos'), findsOneWidget);
    expect(find.text('Unisports'), findsOneWidget);
    expect(find.text('Publicar proyecto'), findsOneWidget);
  });

  testWidgets('permite escoger una facultad sin crashear', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PublishInitiativePage()));

    await tester.enterText(find.byType(TextField).at(0), 'Proyecto de prueba');
    await tester.enterText(find.byType(TextField).at(1), 'Descripción de prueba');
    await tester.tap(find.text('Siguiente').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ingeniería').last);
    await tester.pumpAndSettle();

    expect(find.text('Ingeniería'), findsOneWidget);
  });

  test('marca una iniciativa como popular al alcanzar diez visitas', () {
    final initiative = Initiative(
      id: 'popular-test',
      title: 'Proyecto de prueba',
      categories: const ['Tecnología'],
      description: 'Descripción de prueba',
      leader: 'Equipo de prueba',
      isPopularManually: false,
      isActive: true,
      roles: const [],
    );

    for (var visit = 0; visit < 9; visit++) {
      initiative.registerView();
    }
    expect(initiative.isPopular, isFalse);

    initiative.registerView();
    expect(initiative.isPopular, isTrue);
  });

  testWidgets('permite crear cuenta, cerrar sesión e iniciar sesión', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UninorteInnovacionApp());

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Ana Torres');
    await tester.enterText(fields.at(1), 'ana@uninorte.edu.co');
    await tester.enterText(fields.at(2), 'Diseño Industrial');
    await tester.enterText(fields.at(3), '6');
    await tester.enterText(fields.at(4), 'secreto123');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Ana Torres'), findsOneWidget);
    expect(find.text('ana@uninorte.edu.co'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    final logoutButton = find.byType(OutlinedButton).last;
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'ana@uninorte.edu.co');
    await tester.enterText(find.byType(TextField).at(1), 'secreto123');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Ana Torres'), findsOneWidget);
  });
}
