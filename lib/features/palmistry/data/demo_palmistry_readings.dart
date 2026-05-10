import '../models/palm_line_reading.dart';
import '../models/palm_line_type.dart';

const List<PalmLineReading> demoPalmistryReadings = [
  PalmLineReading(
    type: PalmLineType.lifeLine,
    title: 'Lebenslinie',
    summary:
        'Deine Lebenslinie wirkt wie ein warmer Pfad voller stiller Ausdauer. Sie spricht von einer geerdeten Kraft, die sich leise entfaltet und dich mit sanfter Bestimmtheit durch neue Kapitel begleitet.',
    confidence: 0.88,
  ),
  PalmLineReading(
    type: PalmLineType.headLine,
    title: 'Kopflinie',
    summary:
        'Die Kopflinie zeigt einen wachen, feinen Blick fur Zwischentone. Sie steht fur Intuition, Vorstellungskraft und die Gabe, selbst im Gewohnlichen einen Hauch von Magie zu entdecken.',
    confidence: 0.84,
  ),
  PalmLineReading(
    type: PalmLineType.heartLine,
    title: 'Herzlinie',
    summary:
        'Deine Herzlinie tragt eine warme, elegante Note. Sie deutet auf Verbundenheit, Charme und eine weiche innere Starke hin, die Begegnungen tiefer und zugleich leichter wirken lasst.',
    confidence: 0.86,
  ),
  PalmLineReading(
    type: PalmLineType.fateLine,
    title: 'Schicksalslinie',
    summary:
        'Die Schicksalslinie erinnert an eine ruhige Einladung, dem eigenen Rhythmus zu folgen. Sie steht fur Entwicklung mit Haltung, fur Wege mit Bedeutung und fur Entscheidungen, die mit der Zeit klarer leuchten.',
    confidence: 0.81,
  ),
];
