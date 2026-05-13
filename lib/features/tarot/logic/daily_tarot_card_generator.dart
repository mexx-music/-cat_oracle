import '../data/demo_tarot_cards.dart';
import '../models/tarot_card.dart';

TarotCard generateDailyTarotCard() {
  return generateDailyTarotCardForDate(DateTime.now());
}

TarotCard generateDailyTarotCardForDate(DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final daySeed =
      normalizedDate.year * 10000 +
      normalizedDate.month * 100 +
      normalizedDate.day;
  final index = daySeed % demoTarotCards.length;
  return demoTarotCards[index];
}
