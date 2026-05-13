import 'package:cat_oracle/features/astrology/logic/moon_sign_calculator.dart';
import 'package:cat_oracle/features/astrology/models/zodiac_sign.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateDemoMoonSign', () {
    test('liefert immer ein ZodiacSign', () {
      final result = calculateDemoMoonSign(DateTime(2024, 5, 13));
      expect(result, isA<ZodiacSign>());
    });

    test('liefert fur gleiche Daten stabile Ergebnisse', () {
      final date = DateTime(1993, 11, 7);
      final first = calculateDemoMoonSign(date);
      final second = calculateDemoMoonSign(date);
      expect(first, second);
    });

    test('liefert fur mehrere Daten deterministische Ergebnisse', () {
      expect(calculateDemoMoonSign(DateTime(2024, 1, 1)), ZodiacSign.aries);
      expect(calculateDemoMoonSign(DateTime(2024, 1, 2)), ZodiacSign.taurus);
      expect(calculateDemoMoonSign(DateTime(2024, 1, 12)), ZodiacSign.pisces);
      expect(calculateDemoMoonSign(DateTime(2024, 1, 13)), ZodiacSign.aries);
      expect(calculateDemoMoonSign(DateTime(2024, 1, 24)), ZodiacSign.pisces);
    });

    test('wirft keine Exceptions', () {
      expect(
        () => calculateDemoMoonSign(DateTime(2024, 12, 31)),
        returnsNormally,
      );
    });
  });
}
