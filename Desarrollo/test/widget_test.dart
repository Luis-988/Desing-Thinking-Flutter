import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:desing_thinking_flutter/core/theme/app_theme.dart';
import 'package:desing_thinking_flutter/core/theme/theme_controller.dart';
import 'package:desing_thinking_flutter/core/di/injection.dart';
import 'package:desing_thinking_flutter/core/error/app_exception.dart';
import 'package:desing_thinking_flutter/features/auth/domain/entities/auth_result.dart';
import 'package:desing_thinking_flutter/features/auth/domain/entities/profile_user.dart';
import 'package:desing_thinking_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:desing_thinking_flutter/features/initiatives/data/models/initiative_model.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/entities/initiative.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/entities/initiative_application.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/repositories/initiative_repository.dart';
import 'package:desing_thinking_flutter/features/initiatives/presentation/providers/initiatives_controller.dart';
import 'package:desing_thinking_flutter/main.dart';

class FakeAuthRepository implements AuthRepository {
  final ProfileUser? restoredUser;
  final Map<String, (String password, ProfileUser user)> _users = {};

  FakeAuthRepository({this.restoredUser});

  @override
  Future<ProfileUser?> restoreSession() async => restoredUser;

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String program,
    required String semester,
    required String password,
  }) async {
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
      return const AuthResult.failure(
        'El correo o la contraseña no son correctos.',
      );
    }
    return AuthResult.success(entry.$2);
  }

  @override
  Future<void> logout() async {}
}

class FakeInitiativeRepository implements InitiativeRepository {
  bool failOnLoad = false;

  final List<Initiative> initiatives = [
    const Initiative(
      id: 'unisports',
      title: 'Unisports',
      categories: ['Ingeniería', 'Tecnología'],
      description: 'Plataforma deportiva universitaria.',
      leader: 'Equipo Uninorte',
      isPopularManually: false,
      isActive: true,
      roles: [
        InitiativeRole(
          name: 'Diseñador UX/UI',
          description: 'Diseñar pantallas.',
          slots: 2,
        ),
      ],
    ),
    const Initiative(
      id: 'mine',
      title: 'Proyecto propio',
      categories: ['Educación'],
      description: 'Una idea mía.',
      leader: 'Yo',
      isPopularManually: false,
      isActive: true,
      roles: [InitiativeRole(name: 'Marketing', description: 'Difundir.')],
      isMine: true,
    ),
  ];
  final List<InitiativeApplication> applications = [];

  @override
  Future<List<Initiative>> getInitiatives() async {
    if (failOnLoad) throw const AppException('Sin conexión con Roble.');
    return List.of(initiatives);
  }

  @override
  Future<Initiative> createInitiative(Initiative initiative) async {
    final saved = initiative.copyWith(isMine: true);
    initiatives.add(saved);
    return saved;
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
    final saved = InitiativeApplication(
      id: 'app-${applications.length + 1}',
      initiativeId: application.initiativeId,
      applicantName: application.applicantName,
      program: application.program,
      semester: application.semester,
      roleName: application.roleName,
      skills: application.skills,
      message: application.message,
      isMine: true,
    );
    applications.add(saved);
    return saved;
  }

  @override
  Future<void> updateApplicationStatus(
    InitiativeApplication application,
    ApplicationStatus status,
  ) async {}
}

/// Las listas de Flutter solo construyen lo que cabe en pantalla. Con una
/// pantalla alta de prueba, todas las tarjetas quedan construidas.
void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

InitiativesController buildController(FakeInitiativeRepository repository) {
  Injection.init(
    authRepository: FakeAuthRepository(),
    initiativeRepository: repository,
  );
  return Injection.createInitiativesController();
}

InitiativeApplication sampleApplication({
  String initiativeId = 'unisports',
  String role = 'Diseñador UX/UI',
}) => InitiativeApplication(
  id: '',
  initiativeId: initiativeId,
  applicantName: 'Ana Torres',
  roleName: role,
  message: 'Quiero aportar.',
);

void main() {
  group('Initiative', () {
    test('es popular al alcanzar diez visitas', () {
      const base = Initiative(
        id: 'p',
        title: 'Proyecto',
        categories: ['Tecnología'],
        description: 'Descripción',
        leader: 'Equipo',
        isPopularManually: false,
        isActive: true,
        roles: [],
        views: 9,
      );
      expect(base.isPopular, isFalse);
      expect(base.copyWith(views: 10).isPopular, isTrue);
    });

    test('suma las plazas de todas las vacantes', () {
      const initiative = Initiative(
        id: 'p',
        title: 'Proyecto',
        categories: [],
        description: '',
        leader: 'Equipo',
        isPopularManually: false,
        isActive: true,
        roles: [
          InitiativeRole(name: 'A', description: '', slots: 2),
          InitiativeRole(name: 'B', description: '', slots: 3),
        ],
      );
      expect(initiative.openSlots, 5);
    });
  });

  group('InitiativeModel', () {
    test('conserva plazas y habilidades al ir y volver a Roble', () {
      const initiative = Initiative(
        id: 'x',
        title: 'Proyecto',
        categories: ['Diseño'],
        description: 'Descripción',
        leader: 'Equipo',
        isPopularManually: false,
        isActive: true,
        roles: [
          InitiativeRole(
            name: 'Diseñador UX/UI',
            description: 'Pantallas',
            slots: 2,
            skills: ['Figma', 'Research'],
          ),
        ],
      );
      final row = InitiativeModel.toRow(initiative)..['_id'] = 'x';
      final restored = InitiativeModel.fromRow(row);

      expect(restored.roles.single.slots, 2);
      expect(restored.roles.single.skills, ['Figma', 'Research']);
    });

    test('lee filas antiguas sin plazas ni habilidades', () {
      final restored = InitiativeModel.fromRow({
        '_id': 'old',
        'titulo': 'Antigua',
        'descripcion': 'd',
        'categorias': '["Educación"]',
        'lider': 'vanessa',
        'vacantes': '[{"name":"Desarrollador","description":"Código"}]',
        'visitas': 3,
      });
      expect(restored.roles.single.slots, 1);
      expect(restored.roles.single.skills, isEmpty);
      expect(restored.views, 3);
    });
  });

  group('InitiativesController', () {
    test(
      'carga iniciativas y expone solo las propias en myInitiatives',
      () async {
        final controller = buildController(FakeInitiativeRepository());
        await controller.load();

        expect(controller.isLoading, isFalse);
        expect(controller.initiatives, hasLength(2));
        expect(controller.myInitiatives.single.id, 'mine');
      },
    );

    test('guarda el error cuando la carga falla', () async {
      final controller = buildController(
        FakeInitiativeRepository()..failOnLoad = true,
      );
      await controller.load();

      expect(controller.error, 'Sin conexión con Roble.');
    });

    test('filtra por rol y por texto', () async {
      final controller = buildController(FakeInitiativeRepository());
      await controller.load();

      controller.setFilter('Marketing');
      expect(controller.filteredInitiatives.single.id, 'mine');

      controller.clearFilters();
      controller.setQuery('deportiva');
      expect(controller.filteredInitiatives.single.id, 'unisports');
    });

    test('impide postularse dos veces al mismo rol', () async {
      final controller = buildController(FakeInitiativeRepository());
      await controller.load();

      await controller.apply(sampleApplication());
      expect(controller.myApplications, hasLength(1));
      expect(
        () => controller.apply(sampleApplication()),
        throwsA(isA<AppException>()),
      );
    });

    test('impide postularse a la propia iniciativa', () async {
      final controller = buildController(FakeInitiativeRepository());
      await controller.load();

      expect(
        () => controller.apply(
          sampleApplication(initiativeId: 'mine', role: 'Marketing'),
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('alterna guardados', () async {
      final controller = buildController(FakeInitiativeRepository());
      await controller.load();

      controller.toggleSaved('unisports');
      expect(controller.savedInitiatives.single.id, 'unisports');
      controller.toggleSaved('unisports');
      expect(controller.savedInitiatives, isEmpty);
    });

    test('no cuenta visitas del propio líder', () async {
      final controller = buildController(FakeInitiativeRepository());
      await controller.load();

      await controller.registerView('mine');
      await controller.registerView('unisports');

      expect(controller.initiativeById('mine')!.views, 0);
      expect(controller.initiativeById('unisports')!.views, 1);
    });
  });

  group('App', () {
    setUp(() {
      Injection.init(
        authRepository: FakeAuthRepository(),
        initiativeRepository: FakeInitiativeRepository(),
      );
    });

    testWidgets('abre en Inicio y muestra la barra de navegación', (
      tester,
    ) async {
      useTallScreen(tester);
      await tester.pumpWidget(
        const UninorteInnovacionApp(useGoogleFonts: false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Explorar'), findsWidgets);
      expect(find.text('Mis iniciativas'), findsWidgets);
      expect(find.text('Guardados'), findsWidgets);
      expect(find.text('Perfil'), findsWidgets);
      expect(find.text('Unisports'), findsWidgets);
    });

    testWidgets('Explorar lista las iniciativas', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(
        const UninorteInnovacionApp(useGoogleFonts: false),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search_outlined));
      await tester.pumpAndSettle();

      expect(find.text('2 iniciativas activas'), findsOneWidget);
      expect(find.text('Proyecto propio'), findsWidgets);
    });

    testWidgets('activar modo oscuro no produce errores', (tester) async {
      final controller = ThemeController();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: Consumer<ThemeController>(
            builder: (context, theme, _) => MaterialApp(
              theme: AppTheme.light(useGoogleFonts: false),
              darkTheme: AppTheme.dark(useGoogleFonts: false),
              themeMode: theme.mode,
              home: Scaffold(
                body: SwitchListTile(
                  title: const Text('Modo oscuro'),
                  value: theme.isDark,
                  onChanged: (_) => theme.toggle(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(controller.isDark, isTrue);
      expect(
        Theme.of(tester.element(find.byType(SwitchListTile))).brightness,
        Brightness.dark,
      );
    });

    testWidgets('el perfil autenticado activa el modo oscuro', (tester) async {
      useTallScreen(tester);
      Injection.init(
        authRepository: FakeAuthRepository(
          restoredUser: const ProfileUser(
            name: 'Ana Torres',
            email: 'ana@example.com',
            program: 'Ingeniería',
            semester: '5',
          ),
        ),
        initiativeRepository: FakeInitiativeRepository(),
      );
      await tester.pumpWidget(
        const UninorteInnovacionApp(useGoogleFonts: false),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Perfil').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Tema oscuro activado'), findsOneWidget);
    });
  });
}
