import 'package:flutter_test/flutter_test.dart';

import 'package:desing_thinking_flutter/core/error/app_exception.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/entities/initiative.dart';
import 'package:desing_thinking_flutter/features/initiatives/domain/services/initiative_policy.dart';

Initiative buildInitiative({bool isMine = false, int slots = 2}) => Initiative(
  id: 'unisports',
  title: 'Unisports',
  categories: const ['Tecnología'],
  description: 'Plataforma deportiva universitaria.',
  leader: 'Equipo Uninorte',
  isPopularManually: false,
  isActive: true,
  roles: [
    InitiativeRole(
      name: 'Diseñador UX/UI',
      description: 'Diseñar pantallas.',
      slots: slots,
    ),
    const InitiativeRole(name: 'Marketing', description: 'Difundir.', slots: 3),
  ],
  isMine: isMine,
);

void main() {
  group('InitiativePolicy.requireCanApply', () {
    test('permite postularse a una iniciativa ajena', () {
      expect(
        () => InitiativePolicy.requireCanApply(
          initiative: buildInitiative(),
          alreadyApplied: false,
        ),
        returnsNormally,
      );
    });

    test('impide postularse a la propia iniciativa', () {
      expect(
        () => InitiativePolicy.requireCanApply(
          initiative: buildInitiative(isMine: true),
          alreadyApplied: false,
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('impide postularse dos veces a la misma vacante', () {
      expect(
        () => InitiativePolicy.requireCanApply(
          initiative: buildInitiative(),
          alreadyApplied: true,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('InitiativePolicy.consumeAcceptedRoleSlot', () {
    test('resta una plaza solo a la vacante aceptada', () {
      final updated = InitiativePolicy.consumeAcceptedRoleSlot(
        buildInitiative(slots: 2),
        'Diseñador UX/UI',
      );

      expect(updated.roles[0].slots, 1);
      expect(updated.roles[1].slots, 3);
    });

    test('nunca deja plazas negativas', () {
      final updated = InitiativePolicy.consumeAcceptedRoleSlot(
        buildInitiative(slots: 0),
        'Diseñador UX/UI',
      );

      expect(updated.roles[0].slots, 0);
    });

    test('el total de plazas abiertas baja en uno', () {
      final initiative = buildInitiative(slots: 2);
      final updated = InitiativePolicy.consumeAcceptedRoleSlot(
        initiative,
        'Diseñador UX/UI',
      );

      expect(initiative.openSlots, 5);
      expect(updated.openSlots, 4);
    });
  });
}
