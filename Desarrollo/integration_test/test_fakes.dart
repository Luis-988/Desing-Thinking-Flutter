import 'package:desing_thinking_flutter/features/auth/domain/entities/auth_result.dart';
import 'package:desing_thinking_flutter/features/auth/domain/entities/profile_user.dart';
import 'package:desing_thinking_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/entities/initiative.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/entities/initiative_application.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/entities/project_activity.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/repositories/initiative_repository.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/repositories/project_activity_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<ProfileUser?> restoreSession() async => null;

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String program,
    required String semester,
    required String password,
  }) async => const AuthResult.failure('No implementado en la prueba.');

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async => const AuthResult.failure('No implementado en la prueba.');

  @override
  Future<void> logout() async {}
}

class FakeInitiativeRepository implements InitiativeRepository {
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

  @override
  Future<List<Initiative>> getInitiatives() async => List.of(initiatives);

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
  Future<List<InitiativeApplication>> getApplications() async => [];

  @override
  Future<InitiativeApplication> submitApplication(
    InitiativeApplication application,
  ) async => application;

  @override
  Future<void> updateApplicationStatus(
    InitiativeApplication application,
    ApplicationStatus status,
  ) async {}
}

class FakeProjectActivityRepository implements ProjectActivityRepository {
  final List<ProjectActivity> activities = [];

  @override
  Future<List<ProjectActivity>> getActivities(String initiativeId) async =>
      activities
          .where((activity) => activity.initiativeId == initiativeId)
          .toList();

  @override
  Future<ProjectActivity> createActivity(ProjectActivity activity) async {
    activities.add(activity);
    return activity;
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
