import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:desing_thinking_flutter/features/initiatives/domain/entities/initiative_application.dart';
import 'package:desing_thinking_flutter/features/initiatives/presentation/widgets/status_pill.dart';

Widget wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('StatusPill', () {
    testWidgets('muestra Pendiente con ícono de reloj', (tester) async {
      await tester.pumpWidget(
        wrap(const StatusPill(ApplicationStatus.pending)),
      );

      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('muestra Aceptada con ícono de check', (tester) async {
      await tester.pumpWidget(
        wrap(const StatusPill(ApplicationStatus.accepted)),
      );

      expect(find.text('Aceptada'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('muestra Rechazada con ícono de cancelar', (tester) async {
      await tester.pumpWidget(
        wrap(const StatusPill(ApplicationStatus.rejected)),
      );

      expect(find.text('Rechazada'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('se encuentra por tipo', (tester) async {
      await tester.pumpWidget(
        wrap(const StatusPill(ApplicationStatus.pending)),
      );

      expect(find.byType(StatusPill), findsOneWidget);
    });
  });
}
