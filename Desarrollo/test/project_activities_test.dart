import 'package:flutter_test/flutter_test.dart';
import 'package:desing_thinking_flutter/core/error/app_exception.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/entities/project_activity.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/repositories/project_activity_repository.dart';
import 'package:desing_thinking_flutter/features/initiatives/data/models/project_activity_model.dart';
import 'package:desing_thinking_flutter/features/initiatives/presentation/providers/project_activities_controller.dart';

class _ActivityRepository implements ProjectActivityRepository {
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
    activities[index] = activity;
  }

  @override
  Future<void> deleteActivity(ProjectActivity activity) async {
    activities.removeWhere((item) => item.id == activity.id);
  }
}

void main() {
  late _ActivityRepository repository;
  late ProjectActivitiesController controller;

  setUp(() {
    repository = _ActivityRepository();
    controller = ProjectActivitiesController(repository);
  });

  tearDown(() => controller.dispose());

  final activity = ProjectActivity(
    id: 'activity-1',
    initiativeId: 'initiative-1',
    title: 'Preparar entrevistas',
    description: '',
    dueDate: DateTime(2026, 10, 14),
  );

  test('serializa las actividades para guardarlas en la iniciativa de Roble', () {
    final stored = ProjectActivityModel.toRow(activity);
    final restored = ProjectActivityModel.fromStoredJson(stored);

    expect(stored['id'], activity.id);
    expect(restored.initiativeId, activity.initiativeId);
    expect(restored.title, activity.title);
    expect(restored.dueDate, activity.dueDate);
    expect(restored.isCompleted, isFalse);
  });

  test('solo el líder puede crear actividades', () async {
    await expectLater(
      controller.create(activity, isLeader: false),
      throwsA(isA<AppException>()),
    );
    expect(repository.activities, isEmpty);

    await controller.create(activity, isLeader: true);
    expect(controller.activities, [activity]);
  });

  test('solo el líder puede editar una actividad', () async {
    repository.activities.add(activity);
    await controller.load(activity.initiativeId);
    final updated = activity.copyWith(
      title: 'Realizar entrevistas',
      description: 'Entrevistar a tres usuarios',
      dueDate: DateTime(2026, 10, 20),
    );

    await expectLater(
      controller.update(updated, isLeader: false),
      throwsA(isA<AppException>()),
    );
    expect(controller.activities.single.title, activity.title);

    await controller.update(updated, isLeader: true);
    expect(controller.activities.single, updated);
    expect(repository.activities.single, updated);
  });

  test('solo el líder puede eliminar una actividad', () async {
    repository.activities.add(activity);
    await controller.load(activity.initiativeId);

    await expectLater(
      controller.delete(activity, isLeader: false),
      throwsA(isA<AppException>()),
    );
    expect(controller.activities, [activity]);

    await controller.delete(activity, isLeader: true);
    expect(controller.activities, isEmpty);
    expect(repository.activities, isEmpty);
  });

  test('un integrante puede marcar una actividad como realizada', () async {
    repository.activities.add(activity);
    await controller.load(activity.initiativeId);

    await controller.setCompleted(activity, true, isTeamMember: true);

    expect(controller.activities.single.isCompleted, isTrue);
    expect(repository.activities.single.isCompleted, isTrue);
  });

  test('rechaza cambios de estado de alguien que no es del equipo', () async {
    repository.activities.add(activity);
    await controller.load(activity.initiativeId);

    await expectLater(
      controller.setCompleted(activity, true, isTeamMember: false),
      throwsA(isA<AppException>()),
    );
    expect(controller.activities.single.isCompleted, isFalse);
  });
}
