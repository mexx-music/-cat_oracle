import 'package:cat_oracle/features/astrology/logic/ascendant_calculator.dart';
import 'package:cat_oracle/features/astrology/models/zodiac_sign.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateDemoAscendant', () {
    test('null birthTime gibt null zurück', () {
      final result = calculateDemoAscendant(
        birthTime: null,
        longitude: 16.3738,
      );

      expect(result, isNull);
    });

    test('null longitude gibt null zurück', () {
      final result = calculateDemoAscendant(
        birthTime: const TimeOfDay(hour: 10, minute: 15),
        longitude: null,
      );

      expect(result, isNull);
    });

    test('gültige Werte geben ZodiacSign zurück', () {
      final result = calculateDemoAscendant(
        birthTime: const TimeOfDay(hour: 10, minute: 15),
        longitude: 16.3738,
      );

      expect(result, isA<ZodiacSign>());
    });

    test('gleiche Eingaben liefern gleiches Ergebnis', () {
      final first = calculateDemoAscendant(
        birthTime: const TimeOfDay(hour: 22, minute: 45),
        longitude: 10.3951,
      );
      final second = calculateDemoAscendant(
        birthTime: const TimeOfDay(hour: 22, minute: 45),
        longitude: 10.3951,
      );

      expect(first, second);
    });
  });
}
