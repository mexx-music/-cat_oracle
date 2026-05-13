import '../models/zodiac_sign.dart';

String generateDailyZodiacOracle({required ZodiacSign sign}) {
  return generateDailyZodiacOracleForDate(sign: sign, date: DateTime.now());
}

String generateDailyZodiacOracleForDate({
  required ZodiacSign sign,
  required DateTime date,
}) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final daySeed =
      normalizedDate.year * 10000 +
      normalizedDate.month * 100 +
      normalizedDate.day;
  final messages = _dailyMessagesBySign[sign]!;
  final index = (daySeed + sign.index * 17) % messages.length;
  return messages[index];
}

const Map<ZodiacSign, List<String>> _dailyMessagesBySign = {
  ZodiacSign.aries: [
    'Widder: Heute tragt deine Energie einen stillen Funken von Mut. Madame Gatto spurt Bewegung hinter deinen Gedanken.',
    'Widder: Ein warmer Impuls begleitet dich durch den Tag. Mit sanfter Entschlossenheit wirkt alles klarer und leichter.',
    'Widder: Deine innere Flamme leuchtet heute elegant, nicht laut. Vertraue dem ersten Schritt und bleibe zugleich weich.',
  ],
  ZodiacSign.taurus: [
    'Stier: Heute ruht eine samtige Ruhe auf deinem Herzen. Madame Gatto erinnert dich an die Kraft geduldiger Schritte.',
    'Stier: Ein leiser Glanz liegt uber deinen Gewohnheiten. Was du liebevoll pflegst, fuhlt sich heute besonders stimmig an.',
    'Stier: Deine Bestaendigkeit wirkt heute wie ein warmer Anker. In der Langsamkeit offenbart sich feine Magie.',
  ],
  ZodiacSign.gemini: [
    'Zwillinge: Heute tanzen Ideen wie Lichtreflexe um dich. Madame Gatto ladt dich ein, mit spielerischer Klarheit zu horen.',
    'Zwillinge: Ein zarter Wind aus Neugier bewegt deine Gedanken. Worte konnen heute Brucken aus Sanftheit bauen.',
    'Zwillinge: Deine Vielseitigkeit klingt heute harmonisch statt hektisch. Folge dem Gesprach, das dein Inneres beruhigt.',
  ],
  ZodiacSign.cancer: [
    'Krebs: Heute spricht dein Gefuhl in warmen, klaren Bildern. Madame Gatto erkennt Schutz und Zartlichkeit in deiner Aura.',
    'Krebs: Ein stilles Leuchten begleitet deine Nahe zu dir selbst. Was dir vertraut ist, schenkt dir heute besondere Tiefe.',
    'Krebs: Deine Sensibilitat wirkt heute wie ein kostbarer Kompass. In weichen Grenzen entsteht elegante Ruhe.',
  ],
  ZodiacSign.leo: [
    'Lowe: Heute strahlt dein Herz mit ruhiger Wurde. Madame Gatto sieht Glanz, der nicht fordert, sondern inspiriert.',
    'Lowe: Ein warmer Sonnenfaden zieht sich durch deinen Tag. Deine Prasenz wirkt freundlich, klar und aufrichtend.',
    'Lowe: Deine Kreativitat zeigt heute eine sanfte Koniglichkeit. Lass Freude leuchten, ohne sie zu erzwingen.',
  ],
  ZodiacSign.virgo: [
    'Jungfrau: Heute offenbart sich Schonheit im feinen Detail. Madame Gatto flustert, dass Achtsamkeit heute pure Eleganz ist.',
    'Jungfrau: Ein klarer Rhythmus fuhrt dich durch kleine Aufgaben. In der Sorgfalt liegt heute ein stiller Zauber.',
    'Jungfrau: Deine ruhige Ordnung schenkt dem Tag Weite. Was du mit Liebe strukturierst, atmet leichter.',
  ],
  ZodiacSign.libra: [
    'Waage: Heute liegt ein goldener Hauch von Harmonie in der Luft. Madame Gatto erinnert dich an die Kunst des Ausgleichs.',
    'Waage: Deine Feinheit fur Beziehungen wirkt heute besonders warm. Freundliche Worte tragen einen leisen Glanz.',
    'Waage: Eleganz entsteht heute aus kleinen Entscheidungen. Folge dem, was sich innen und aussen stimmig anfuhlt.',
  ],
  ZodiacSign.scorpio: [
    'Skorpion: Heute bewegt sich Tiefe wie dunkler Samt durch deinen Tag. Madame Gatto erkennt stille Kraft in deinem Blick.',
    'Skorpion: Ein geheimnisvoller Ton begleitet deine Intuition. Was du achtsam fuhlst, gewinnt heute an Klarheit.',
    'Skorpion: Deine Intensitat wirkt heute gesammelt und edel. In der Stille zeigt sich, was wirklich wesentlich ist.',
  ],
  ZodiacSign.sagittarius: [
    'Schutze: Heute schimmert Weite hinter deinen Gedanken. Madame Gatto ladt dich ein, Sinn mit Leichtigkeit zu suchen.',
    'Schutze: Ein heller Funke von Zuversicht begleitet deinen Weg. Offenheit wirkt heute wie eine warme Laterne.',
    'Schutze: Deine Freiheit liebt heute sanfte Orientierung. Folge dem Impuls, der dein Herz ruhiger und weiter macht.',
  ],
  ZodiacSign.capricorn: [
    'Steinbock: Heute klingt deine innere Haltung klar und beruhigend. Madame Gatto sieht Wurde in jedem achtsamen Schritt.',
    'Steinbock: Ein stiller Bergwind bringt Struktur in den Tag. Was du traegst, darf heute leichter und eleganter werden.',
    'Steinbock: Deine Verlasslichkeit leuchtet heute warm statt streng. In ruhiger Disziplin liegt feine Magie.',
  ],
  ZodiacSign.aquarius: [
    'Wassermann: Heute glitzert Originalitat wie Sternenstaub um dich. Madame Gatto freut sich uber deinen freien, klaren Geist.',
    'Wassermann: Ein frischer Gedanke bringt sanfte Bewegung in Bekanntes. Deine Eigenart wirkt heute besonders freundlich.',
    'Wassermann: Zwischen Weite und Nahe findest du heute einen eleganten Ton. Lass Inspiration leise Gestalt annehmen.',
  ],
  ZodiacSign.pisces: [
    'Fische: Heute schwingt eine traumige Ruhe durch dein Inneres. Madame Gatto spurt Poesie in deinen feinen Antennen.',
    'Fische: Ein silberner Hauch von Intuition begleitet deine Schritte. Was du still wahrnimmst, tragt heute besonderen Glanz.',
    'Fische: Deine Empfindsamkeit wirkt heute wie sanftes Wasserlicht. In Hingabe ohne Eile entsteht tiefe Harmonie.',
  ],
};
