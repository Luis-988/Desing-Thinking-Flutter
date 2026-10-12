// Pruebas de la app. Usan repositorios falsos (en memoria) gracias a la
// arquitectura limpia, así no dependen de internet ni de Roble.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:desing_thinking_flutter/core/di/injection.dart';
import 'package:desing_thinking_flutter/features/auth/domain/entities/auth_result.dart';
import 'package:desing_thinking_flutter/features/auth/domain/entities/profile_user.dart';
import 'package:desing_thinking_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/entities/initiative.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/entities/initiative_application.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/repositories/initiative_repository.dart';
import 'package:desing_thinking_flutter/features/initiatives/presentation/pages/publish_initiative_page.dart';
import 'package:desing_thinking_flutter/main.dart';

class FakeAuthRepository implements AuthRepository {
  final Map<String, (String password, ProfileUser user)> _users = {};

  @override
  Future<ProfileUser?> restoreSession() async => null;

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String program,
    required String semester,
    required String password,
  }) async {
    if (_users.containsKey(email)) {
      return const AuthResult.failure('Ya existe una cuenta con ese correo.');
    }
    final user = ProfileUser(
      name: name,
      email: email,
      program: program,
      semester: semester,
    );
    _users[email] = (password, user);
    return AuthResult.success(user);
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final entry = _users[email];
    if (entry == null || entry.$1 != password) {
      return const AuthResult.failure('El correo o la contraseña no son correctos.');
    }
    return AuthResult.success(entry.$2);
  }

  @override
  Future<void> logout() async {}
}

class FakeInitiativeRepository implements InitiativeRepository {
  final List<Initiative> initiatives = [
    Initiative(
      id: 'unisports',
      title: 'Unisports',
      categories: ['Ingeniería', 'Tecnología'],
      description: 'Plataforma deportiva universitaria.',
      leader: 'Equipo Uninorte',
      isPopularManually: false,
      isActive: true,
      roles: const [
        InitiativeRole(name: 'Diseñador UX/UI', description: 'Diseñar pantallas.'),
      ],
    ),
  ];
  final List<InitiativeApplication> applications = [];

  @override
  Future<List<Initiative>> getInitiatives() async => List.of(initiatives);

  @override
  Future<Initiative> createInitiative(Initiative initiative) async {
    initiative.isMine = true;
    initiatives.add(initiative);
    return initiative;
  }

  @override
  Future<void> updateInitiative(Initiative initiative) async {}

  @override
  Future<void> deleteInitiative(Initiative initiative) async =>
      initiatives.removeWhere((item) => item.id == initiative.id);

  @override
  Future<void> saveViews(Initiative initiative) async {}

  @override
  Future<List<InitiativeApplication>> getApplications() async =>
      List.of(applications);

  @override
  Future<InitiativeApplication> submitApplication(
    InitiativeApplication application,
  ) async {
    application.isMine = true;
    applications.add(application);
    return application;
  }

  @override
  Future<void> updateApplicationStatus(
    InitiativeApplication application,
    ApplicationStatus status,
  ) async {}
}

void main() {
  setUp(() {
    Injection.init(
      authRepository: FakeAuthRepository(),
      initiativeRepository: FakeInitiativeRepository(),
    );
  });

  testWidgets('muestra el home de iniciativas', (WidgetTester tester) async {
    await tester.pumpWidget(const UninorteInnovacionApp());
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

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
