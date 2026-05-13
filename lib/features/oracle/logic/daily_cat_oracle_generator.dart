import 'package:cat_oracle/features/oracle/models/daily_cat_oracle.dart';

DailyCatOracle generateDailyCatOracle() {
  return generateDailyCatOracleForDate(DateTime.now());
}

DailyCatOracle generateDailyCatOracleForDate(DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final daySeed =
      normalizedDate.year * 10000 +
      normalizedDate.month * 100 +
      normalizedDate.day;

  final index = daySeed % _dailyMessages.length;
  final mood = _moods[daySeed % _moods.length];

  return DailyCatOracle(
    title: 'Tages-Orakel',
    message: _dailyMessages[index],
    mood: mood,
    createdAt: normalizedDate,
  );
}

const List<String> _moods = [
  'calm',
  'mysterious',
  'energetic',
  'dreamy',
  'intuitive',
];

const List<String> _dailyMessages = [
  'Die Sterne bewegen sich heute leise um deine Gedanken. Madame Gatto spürt Ruhe zwischen den Zeilen.',
  'Ein feiner Glanz begleitet deine Schritte. Die Katze erinnert dich daran, mit weichem Blick wahrzunehmen.',
  'Zwischen Stille und Bewegung liegt heute ein besonderer Takt. Folge ihm mit sanfter Entschlossenheit.',
  'Madame Gatto sieht eine elegante Klarheit in deiner Stimmung. Kleine Gesten tragen heute große Bedeutung.',
  'Ein geheimnisvoller Funke tanzt durch den Tag. Halte Raum fur Intuition und stille Zeichen.',
  'Die Nachtkatze flüstert: Balance entsteht heute aus Geduld, nicht aus Eile.',
  'In deiner Aura liegt ein warmer Ton, der Begegnungen weicher und aufrichtiger wirken lasst.',
  'Die Sterne zeichnen heute einen stillen Kreis um dein Herz. Atme tief und vertraue deinem inneren Rhythmus.',
  'Madame Gatto erkennt heute kreative Schwingungen. Ein kleiner Impuls kann viel Licht entfalten.',
  'Der Tag tragt eine ruhige Magie. Aufmerksamkeit fur Details macht Unsichtbares sichtbar.',
  'Ein samtiger Hauch von Neugier begleitet dich. Offene Fragen durfen heute elegant offen bleiben.',
  'Die kosmische Katze deutet auf innere Harmonie: Was dir gut tut, zeigt sich heute besonders klar.',
];
