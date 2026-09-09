// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:desing_thinking_flutter/main.dart';

void main() {
  testWidgets('muestra el home de iniciativas', (WidgetTester tester) async {
    await tester.pumpWidget(const UninorteInnovacionApp());

    expect(find.text('Sistema de Innovación'), findsOneWidget);
    expect(find.text('Explora iniciativas'), findsOneWidget);
    expect(find.text('Unisports'), findsOneWidget);
    expect(find.text('Publicar'), findsOneWidget);
  });
}
