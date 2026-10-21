import 'package:flutter_test/flutter_test.dart';

import 'package:desing_thinking_flutter/features/initiatives/data/models/json_utils.dart';

void main() {
  group('decodeJsonList', () {
    test('convierte el texto JSON que guarda Roble en una lista', () {
      expect(decodeJsonList('["Tecnología","Salud"]'), ['Tecnología', 'Salud']);
    });

    test('devuelve una lista vacía si el valor es nulo', () {
      expect(decodeJsonList(null), isEmpty);
    });

    test('devuelve una lista vacía si el texto no es JSON', () {
      expect(decodeJsonList('esto no es json'), isEmpty);
    });

    test('acepta una lista que ya viene decodificada', () {
      expect(decodeJsonList(['a', 'b']), ['a', 'b']);
    });
  });

  group('toBool', () {
    test('reconoce true, "true" y 1 como verdadero', () {
      expect(toBool(true), isTrue);
      expect(toBool('true'), isTrue);
      expect(toBool(1), isTrue);
    });

    test('trata false, null y 0 como falso', () {
      expect(toBool(false), isFalse);
      expect(toBool(null), isFalse);
      expect(toBool(0), isFalse);
    });
  });
}
