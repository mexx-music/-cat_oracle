import 'package:flutter_test/flutter_test.dart';
import 'package:cat_oracle/features/astrology/logic/zodiac_calculator.dart';
import 'package:cat_oracle/features/astrology/models/zodiac_sign.dart';

void main() {
  group('ZodiacCalculator', () {
    test('21. März sollte Widder (Aries) sein', () {
      final date = DateTime(2024, 3, 21);
      expect(calculateSunSign(date), ZodiacSign.aries);
    });

    test('19. April sollte Widder (Aries) sein', () {
      final date = DateTime(2024, 4, 19);
      expect(calculateSunSign(date), ZodiacSign.aries);
    });

    test('20. April sollte Stier (Taurus) sein', () {
      final date = DateTime(2024, 4, 20);
      expect(calculateSunSign(date), ZodiacSign.taurus);
    });

    test('22. Dezember sollte Steinbock (Capricorn) sein', () {
      final date = DateTime(2024, 12, 22);
      expect(calculateSunSign(date), ZodiacSign.capricorn);
    });

    test('19. Januar sollte Steinbock (Capricorn) sein', () {
      final date = DateTime(2024, 1, 19);
      expect(calculateSunSign(date), ZodiacSign.capricorn);
    });

    test('20. Januar sollte Wassermann (Aquarius) sein', () {
      final date = DateTime(2024, 1, 20);
      expect(calculateSunSign(date), ZodiacSign.aquarius);
    });

    test('20. März sollte Fische (Pisces) sein', () {
      final date = DateTime(2024, 3, 20);
      expect(calculateSunSign(date), ZodiacSign.pisces);
    });
  });
}
