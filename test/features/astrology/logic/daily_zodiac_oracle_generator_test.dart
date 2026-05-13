import 'package:cat_oracle/features/astrology/logic/daily_zodiac_oracle_generator.dart';
import 'package:cat_oracle/features/astrology/models/zodiac_sign.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generateDailyZodiacOracle', () {
    test('liefert nie leeren Text', () {
      for (final sign in ZodiacSign.values) {
        final result = generateDailyZodiacOracleForDate(
          sign: sign,
          date: DateTime(2026, 5, 13),
        );
        expect(result.trim(), isNotEmpty);
      }
    });

    test('gleiches Zeichen + gleicher Tag = gleiches Ergebnis', () {
      final first = generateDailyZodiacOracleForDate(
        sign: ZodiacSign.aries,
        date: DateTime(2026, 5, 13),
      );
      final second = generateDailyZodiacOracleForDate(
        sign: ZodiacSign.aries,
        date: DateTime(2026, 5, 13),
      );

      expect(first, second);
    });

    test('unterschiedliche Zeichen liefern unterschiedliche Ergebnisse', () {
      final aries = generateDailyZodiacOracleForDate(
        sign: ZodiacSign.aries,
        date: DateTime(2026, 5, 13),
      );
      final taurus = generateDailyZodiacOracleForDate(
        sign: ZodiacSign.taurus,
        date: DateTime(2026, 5, 13),
      );

      expect(aries, isNot(equals(taurus)));
    });
  });
}
