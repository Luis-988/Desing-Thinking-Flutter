import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'package:desing_thinking_flutter/features/initiatives/domain/entities/project_activity.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/repositories/initiative_repository.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/repositories/project_activity_repository.dart';
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

class FakeProjectActivityRepository implements ProjectActivityRepository {
  final List<ProjectActivity> activities = [];
  var _nextId = 1;

  @override
  Future<List<ProjectActivity>> getActivities(String initiativeId) async =>
      activities
          .where((activity) => activity.initiativeId == initiativeId)
          .toList();

  @override
  Future<ProjectActivity> createActivity(ProjectActivity activity) async {
    final saved = ProjectActivity(
      id: 'activity-${_nextId++}',
      initiativeId: activity.initiativeId,
      title: activity.title,
      description: activity.description,
      dueDate: activity.dueDate,
    );
    activities.add(saved);
    return saved;
  }

  @override
  Future<void> updateActivity(ProjectActivity activity) async {
    final index = activities.indexWhere((item) => item.id == activity.id);
    if (index != -1) activities[index] = activity;
  }

  @override
  Future<void> deleteActivity(ProjectActivity activity) async {
    activities.removeWhere((item) => item.id == activity.id);
  }
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
    projectActivityRepository: FakeProjectActivityRepository(),
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

    test('conserva una vacante agotada al recargar', () {
      final restored = InitiativeModel.fromRow({
        '_id': 'full',
        'titulo': 'Equipo completo',
        'descripcion': 'd',
        'categorias': '[]',
        'lider': 'vanessa',
        'vacantes':
            '[{"name":"Desarrollador","description":"Código","slots":0}]',
      });

      expect(restored.roles.single.slots, 0);
      expect(restored.openSlots, 0);
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

    test('expone como equipo solo las postulaciones aceptadas', () async {
      final repository = FakeInitiativeRepository();
      repository.applications.add(
        InitiativeApplication(
          id: 'accepted-1',
          initiativeId: 'mine',
          applicantName: 'Ana Torres',
          roleName: 'Marketing',
          message: 'Quiero aportar.',
          status: ApplicationStatus.accepted,
        ),
      );
      repository.applications.add(
        InitiativeApplication(
          id: 'pending-1',
          initiativeId: 'mine',
          applicantName: 'Luis Pérez',
          roleName: 'Marketing',
          message: 'Me interesa.',
        ),
      );
      final controller = buildController(repository);
      await controller.load();

      expect(controller.acceptedMembersFor('mine'), hasLength(1));
      expect(
        controller.acceptedMembersFor('mine').single.applicantName,
        'Ana Torres',
      );
    });

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

    test('al aceptar una postulación reduce la plaza disponible', () async {
      final controller = buildController(FakeInitiativeRepository());
      await controller.load();

      final application = InitiativeApplication(
        id: 'app-1',
        initiativeId: 'unisports',
        applicantName: 'Ana Torres',
        roleName: 'Diseñador UX/UI',
        message: 'Quiero aportar.',
      );

      await controller.setApplicationStatus(
        application,
        ApplicationStatus.accepted,
      );

      expect(controller.initiativeById('unisports')!.openSlots, 1);
      expect(controller.initiativeById('unisports')!.roles.single.slots, 1);
    });
  });

  group('App', () {
    setUp(() {
      Injection.init(
        authRepository: FakeAuthRepository(),
        initiativeRepository: FakeInitiativeRepository(),
        projectActivityRepository: FakeProjectActivityRepository(),
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

    testWidgets(
      'abre el espacio de trabajo al iniciar una iniciativa completa',
      (tester) async {
        useTallScreen(tester);
        SharedPreferences.setMockInitialValues({});
        final repository = FakeInitiativeRepository();
        final ownIndex = repository.initiatives.indexWhere(
          (initiative) => initiative.isMine,
        );
        repository.initiatives[ownIndex] = repository.initiatives[ownIndex]
            .copyWith(
              roles: [
                const InitiativeRole(
                  name: 'Marketing',
                  description: 'Difusión',
                  slots: 0,
                ),
              ],
            );
        repository.applications.add(
          InitiativeApplication(
            id: 'accepted-workspace',
            initiativeId: repository.initiatives[ownIndex].id,
            applicantName: 'Ana Torres',
            roleName: 'Marketing',
            message: 'Quiero aportar.',
            status: ApplicationStatus.accepted,
          ),
        );
        final projectActivities = FakeProjectActivityRepository();
        Injection.init(
          authRepository: FakeAuthRepository(
            restoredUser: const ProfileUser(
              name: 'Líder del proyecto',
              email: 'lider@example.com',
              program: 'Ingeniería',
              semester: '7',
            ),
          ),
          initiativeRepository: repository,
          projectActivityRepository: projectActivities,
        );

        await tester.pumpWidget(
          const UninorteInnovacionApp(useGoogleFonts: false),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mis iniciativas').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Abrir espacio de trabajo'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Ruta de trabajo'), findsOneWidget);
        expect(find.text('Ana Torres'), findsOneWidget);
        expect(find.text('Comprender a las personas'), findsNothing);
        expect(find.byTooltip('Añadir actividad'), findsOneWidget);

        await tester.tap(find.byTooltip('Añadir actividad'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField).first,
          'Preparar entrevistas',
        );
        await tester.tap(find.text('Añadir').last);
        await tester.pumpAndSettle();

        expect(find.text('Preparar entrevistas'), findsOneWidget);
        expect(projectActivities.activities, hasLength(1));
        expect(find.text('Entrevista 1'), findsNothing);

        await tester.tap(find.byTooltip('Opciones de actividad').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Editar'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField).first,
          'Preparar entrevista con usuarios',
        );
        await tester.tap(find.text('Guardar cambios'));
        await tester.pumpAndSettle();

        expect(find.text('Preparar entrevista con usuarios'), findsOneWidget);
        expect(
          projectActivities.activities.single.title,
          'Preparar entrevista con usuarios',
        );

        await tester.tap(find.byType(Checkbox).first);
        await tester.pumpAndSettle();
        expect(find.text('Realizada'), findsOneWidget);
        expect(projectActivities.activities.single.isCompleted, isTrue);

        await tester.tap(find.byTooltip('Opciones de actividad').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar').last);
        await tester.pumpAndSettle();

        expect(projectActivities.activities, isEmpty);
        expect(find.text('Preparar entrevista con usuarios'), findsNothing);
      },
    );

    testWidgets('un integrante aceptado puede abrir y ver la ruta', (
      tester,
    ) async {
      useTallScreen(tester);
      final repository = FakeInitiativeRepository();
      repository.applications.add(
        InitiativeApplication(
          id: 'accepted-member',
          initiativeId: 'unisports',
          applicantName: 'Ana Torres',
          roleName: 'Diseñador UX/UI',
          message: 'Quiero aportar.',
          status: ApplicationStatus.accepted,
          isMine: true,
        ),
      );
      Injection.init(
        authRepository: FakeAuthRepository(
          restoredUser: const ProfileUser(
            name: 'Ana Torres',
            email: 'ana@example.com',
            program: 'Ingeniería',
            semester: '5',
          ),
        ),
        initiativeRepository: repository,
        projectActivityRepository: FakeProjectActivityRepository(),
      );

      await tester.pumpWidget(
        const UninorteInnovacionApp(useGoogleFonts: false),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Explorar').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unisports').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver ruta de trabajo'));
      await tester.pumpAndSettle();

      expect(find.text('Ruta de trabajo'), findsOneWidget);
      expect(
        find.text('El líder aún no ha añadido actividades para esta semana.'),
        findsOneWidget,
      );
      expect(find.text('Añadir actividad'), findsNothing);
      expect(tester.takeException(), isNull);
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
        projectActivityRepository: FakeProjectActivityRepository(),
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
