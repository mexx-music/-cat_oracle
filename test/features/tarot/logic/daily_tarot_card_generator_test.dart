import 'package:cat_oracle/features/tarot/logic/daily_tarot_card_generator.dart';
import 'package:cat_oracle/features/tarot/models/tarot_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generateDailyTarotCard', () {
    test('gibt immer TarotCard zuruck', () {
      final result = generateDailyTarotCard();

      expect(result, isA<TarotCard>());
    });

    test('gleicher Tag liefert gleiche Karte', () {
      final first = generateDailyTarotCardForDate(DateTime(2026, 5, 13));
      final second = generateDailyTarotCardForDate(DateTime(2026, 5, 13));

      expect(first.name, second.name);
      expect(first.symbol, second.symbol);
      expect(first.meaning, second.meaning);
      expect(first.catMessage, second.catMessage);
    });

    test('keine leeren Texte', () {
      final result = generateDailyTarotCardForDate(DateTime(2026, 7, 21));

      expect(result.name.trim(), isNotEmpty);
      expect(result.symbol.trim(), isNotEmpty);
      expect(result.meaning.trim(), isNotEmpty);
      expect(result.catMessage.trim(), isNotEmpty);
    });
  });
}
