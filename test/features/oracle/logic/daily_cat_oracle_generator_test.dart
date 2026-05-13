import 'package:cat_oracle/features/oracle/logic/daily_cat_oracle_generator.dart';
import 'package:cat_oracle/features/oracle/models/daily_cat_oracle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generateDailyCatOracle', () {
    test('gibt immer DailyCatOracle zurück', () {
      final result = generateDailyCatOracle();
      expect(result, isA<DailyCatOracle>());
    });

    test('gleicher Tag liefert gleiches Ergebnis', () {
      final first = generateDailyCatOracleForDate(DateTime(2026, 5, 13));
      final second = generateDailyCatOracleForDate(DateTime(2026, 5, 13));

      expect(first.title, second.title);
      expect(first.message, second.message);
      expect(first.mood, second.mood);
      expect(first.createdAt, second.createdAt);
    });

    test('unterschiedliche Tage liefern potenziell andere Ergebnisse', () {
      final first = generateDailyCatOracleForDate(DateTime(2026, 5, 13));
      final second = generateDailyCatOracleForDate(DateTime(2026, 5, 14));

      final hasDifference =
          first.message != second.message ||
          first.mood != second.mood ||
          first.createdAt != second.createdAt;

      expect(hasDifference, isTrue);
    });

    test('keine leeren Texte', () {
      final result = generateDailyCatOracleForDate(DateTime(2026, 8, 8));

      expect(result.title.trim(), isNotEmpty);
      expect(result.message.trim(), isNotEmpty);
      expect(result.mood.trim(), isNotEmpty);
    });
  });
}
