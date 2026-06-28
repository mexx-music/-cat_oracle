import 'dart:math';

import '../models/palm_trait.dart';
import '../models/palmistry_analysis_profile.dart';
import '../../hand_scan/models/scanned_hand.dart';
import '../../hand_scan/logic/palm_line_classifier.dart';
import '../../hand_scan/logic/palm_line_extractor.dart';

// ── Trait library ──────────────────────────────────────────────────────────

const Map<LifeLine, PalmTrait> _lifeLineTraits = {
  LifeLine.short: PalmTrait(
    title: 'Kurze Lebenslinie',
    symbol: '🌱',
    meaning:
        'Eine kurze Lebenslinie kann symbolisch für Konzentration auf das '
        'Wesentliche stehen. Madame Gatto sieht darin keinen Mangel, '
        'sondern ein Zeichen, dass diese Person ihre Energie gezielt einsetzt '
        'und wenig verschwendet.',
    catMessage:
        'Madame Gatto sagt: Nicht die Länge eines Weges zählt, sondern die Tiefe, mit der er gegangen wird.',
  ),
  LifeLine.medium: PalmTrait(
    title: 'Mittlere Lebenslinie',
    symbol: '🌿',
    meaning:
        'Eine ausgeglichene Lebenslinie wirkt stetig und verlässlich. '
        'Madame Gatto sieht hier jemanden, der seinen Rhythmus kennt '
        'und weder zu viel noch zu wenig von sich verlangt.',
    catMessage:
        'Madame Gatto nickt: Wer im eigenen Tempo läuft, kommt am weitesten.',
  ),
  LifeLine.long: PalmTrait(
    title: 'Lange Lebenslinie',
    symbol: '🌳',
    meaning:
        'Eine tiefe, lange Lebenslinie spricht symbolisch von Ausdauer '
        'und einer verwurzelten inneren Kraft. Madame Gatto sieht hier '
        'jemanden, der auch in unruhigen Zeiten seinen Boden findet.',
    catMessage:
        'Madame Gatto sagt: Tiefe Wurzeln halten auch im stärksten Sturm.',
  ),
};

const Map<HeartLine, PalmTrait> _heartLineTraits = {
  HeartLine.soft: PalmTrait(
    title: 'Sanfte Herzlinie',
    symbol: '🌸',
    meaning:
        'Eine weiche Herzlinie deutet symbolisch auf Feingefühl und '
        'emotionale Aufmerksamkeit hin. Madame Gatto sieht hier eine Person, '
        'die anderen sehr genau zuhört – und dabei oft mehr wahrnimmt, '
        'als ausgesprochen wird.',
    catMessage:
        'Madame Gatto flüstert: Die sanftesten Herzen tragen oft die größte Stärke.',
  ),
  HeartLine.balanced: PalmTrait(
    title: 'Ausgeglichene Herzlinie',
    symbol: '💛',
    meaning:
        'Eine ausgeglichene Herzlinie kann auf eine gesunde Balance '
        'zwischen Geben und Nehmen hindeuten. Madame Gatto sieht hier '
        'jemanden, der Verbindungen schätzt, ohne sich dabei zu verlieren.',
    catMessage:
        'Madame Gatto lächelt: Echte Verbindung entsteht, wenn beide ankommen dürfen.',
  ),
  HeartLine.deep: PalmTrait(
    title: 'Tiefe Herzlinie',
    symbol: '💜',
    meaning:
        'Eine tiefe, deutliche Herzlinie spricht von Intensität und dem '
        'Wunsch nach echter Nähe. Madame Gatto sieht hier jemanden, '
        'der in Beziehungen nicht an der Oberfläche bleibt.',
    catMessage:
        'Madame Gatto sagt: Wer tief fühlt, kennt Freude und Schmerz auf eine Weise, die andere kaum ahnen.',
  ),
};

const Map<HeadLine, PalmTrait> _headLineTraits = {
  HeadLine.straight: PalmTrait(
    title: 'Gerade Kopflinie',
    symbol: '🔷',
    meaning:
        'Eine gerade Kopflinie wirkt analytisch und klar. '
        'Madame Gatto sieht hier einen Geist, der strukturiert vorgeht, '
        'gerne Fakten sammelt und erst dann entscheidet, wenn das Bild vollständig ist.',
    catMessage:
        'Madame Gatto sagt: Klarheit ist ein Geschenk – und du weißt, es zu nutzen.',
  ),
  HeadLine.curved: PalmTrait(
    title: 'Geschwungene Kopflinie',
    symbol: '🌀',
    meaning:
        'Eine geschwungene Kopflinie deutet symbolisch auf Kreativität '
        'und Vorstellungskraft hin. Madame Gatto sieht hier jemanden, '
        'der ungewöhnliche Verbindungen erkennt und im Alltag '
        'einen Hauch von Besonderem findet.',
    catMessage:
        'Madame Gatto murmelt: Die schönsten Lösungen kommen oft auf verschlungenen Wegen.',
  ),
  HeadLine.mixed: PalmTrait(
    title: 'Gemischte Kopflinie',
    symbol: '✦',
    meaning:
        'Eine gemischte Kopflinie kann auf Vielseitigkeit und '
        'Anpassungsfähigkeit hindeuten. Madame Gatto sieht hier jemanden, '
        'der je nach Situation zwischen Logik und Intuition wechseln kann – '
        'eine seltene Gabe.',
    catMessage:
        'Madame Gatto nickt: Wer beides kennt, muss sich nicht entscheiden.',
  ),
};

const Map<FateLine, PalmTrait> _fateLineTraits = {
  FateLine.faint: PalmTrait(
    title: 'Schwache Schicksalslinie',
    symbol: '🌫️',
    meaning:
        'Eine kaum sichtbare Schicksalslinie muss kein Mangel sein. '
        'Madame Gatto sieht darin oft innere Freiheit – '
        'jemanden, der seinen Weg weniger durch äußere Strukturen '
        'als durch eigene Entscheidungen gestaltet.',
    catMessage:
        'Madame Gatto lächelt: Wer keinen vorgeschriebenen Pfad hat, kann jeden Weg wählen.',
  ),
  FateLine.visible: PalmTrait(
    title: 'Sichtbare Schicksalslinie',
    symbol: '🛤️',
    meaning:
        'Eine deutliche Schicksalslinie kann auf Beständigkeit und '
        'einen erkennbaren Lebensweg hindeuten. Madame Gatto sieht hier '
        'jemanden, dem Kontinuität wichtig ist und der Entscheidungen '
        'mit Bedacht trifft.',
    catMessage: 'Madame Gatto sagt: Wer seinen Weg kennt, geht ihn mit Würde.',
  ),
  FateLine.strong: PalmTrait(
    title: 'Starke Schicksalslinie',
    symbol: '⚡',
    meaning:
        'Eine tiefe, klar gezeichnete Schicksalslinie spricht symbolisch '
        'von Zielstrebigkeit und innerer Ausrichtung. Madame Gatto sieht '
        'hier jemanden, der weiß, wohin er möchte – und sich davon '
        'kaum ablenken lässt.',
    catMessage:
        'Madame Gatto nickt: Diese Linie zeigt Haltung. Das ist selten.',
  ),
};

const Map<MountVenus, String> _mountVenusDescriptions = {
  MountVenus.flat:
      'Der flache Venushügel deutet auf innere Konzentration hin – '
      'jemanden, der seine Energie bewusst dosiert.',
  MountVenus.balanced:
      'Ein ausgewogener Venushügel spricht von einer gesunden Balance '
      'zwischen Nähe und Eigenraum.',
  MountVenus.full:
      'Ein voller Venushügel kann auf Wärme, Lebensfreude und '
      'eine offene Herzlichkeit hindeuten.',
};

const Map<HandShape, String> _handShapeDescriptions = {
  HandShape.earth:
      'Die Erdhand steht symbolisch für Verlässlichkeit, Ausdauer '
      'und eine tiefe Verbundenheit mit dem, was wirklich zählt.',
  HandShape.air:
      'Die Lufthand spricht von Neugier, Kommunikationsfreude '
      'und einem wachen, vernetzenden Geist.',
  HandShape.water:
      'Die Wasserhand steht für Feingefühl, Intuition '
      'und die Fähigkeit, Stimmungen tief wahrzunehmen.',
  HandShape.fire:
      'Die Feuerhand spricht von Energie, Leidenschaft '
      'und einer Lebendigkeit, die andere ansteckt.',
};

// ── Public API ─────────────────────────────────────────────────────────────

/// Deterministic profile from image path — same path → same result.
PalmistryAnalysisProfile profileFromImagePath(
  String imagePath, {
  ScannedHand scannedHand = ScannedHand.unknown,
}) {
  int seed = 0;
  for (final c in imagePath.codeUnits) {
    seed = seed * 31 + c;
  }
  final r = Random(seed.abs());
  return PalmistryAnalysisProfile(
    lifeLine: LifeLine.values[r.nextInt(LifeLine.values.length)],
    heartLine: HeartLine.values[r.nextInt(HeartLine.values.length)],
    headLine: HeadLine.values[r.nextInt(HeadLine.values.length)],
    fateLine: FateLine.values[r.nextInt(FateLine.values.length)],
    mountVenus: MountVenus.values[r.nextInt(MountVenus.values.length)],
    handShape: HandShape.values[r.nextInt(HandShape.values.length)],
    scannedHand: scannedHand,
  );
}

/// Returns the 4 main line traits as display cards.
List<PalmTrait> traitsFromProfile(PalmistryAnalysisProfile profile) {
  return [
    _lifeLineTraits[profile.lifeLine]!,
    _heartLineTraits[profile.heartLine]!,
    _headLineTraits[profile.headLine]!,
    _fateLineTraits[profile.fateLine]!,
  ];
}

/// Madame Gatto overall reading referencing the specific profile.
String readingFromProfile(PalmistryAnalysisProfile profile) {
  final lifeTitle = _lifeLineTraits[profile.lifeLine]!.title;
  final heartTitle = _heartLineTraits[profile.heartLine]!.title;
  final headTitle = _headLineTraits[profile.headLine]!.title;
  final fateTitle = _fateLineTraits[profile.fateLine]!.title;
  final venusDesc = _mountVenusDescriptions[profile.mountVenus]!;
  final handDesc = _handShapeDescriptions[profile.handShape]!;

  final variant =
      (profile.lifeLine.index * 5 +
          profile.heartLine.index * 4 +
          profile.headLine.index * 3 +
          profile.fateLine.index) %
      4;

  switch (variant) {
    case 0:
      return 'Madame Gatto legt die Pfote behutsam auf das Bild und beginnt zu lesen. '
          '$lifeTitle und $heartTitle sprechen zuerst – sie zeigen, '
          'wie viel Kraft hier fließt und wohin das Herz ausgerichtet ist. '
          '$headTitle ergänzt: hier denkt jemand auf eine bestimmte Art, '
          'die zur Energie der Lebens- und Herzlinie passt. '
          '$fateTitle schließt das Bild ab und zeigt, wie bewusst '
          'dieser Mensch seinen Weg wählt. '
          '$venusDesc '
          '$handDesc '
          'Madame Gatto hebt die Pfote und sagt leise: Diese Hand hat viel zu erzählen.';
    case 1:
      return 'Drei Linien fallen Madame Gatto sofort auf: '
          '$lifeTitle, $headTitle und $heartTitle. '
          'Gemeinsam erzählen sie von einem Menschen, der Kraft, Geist und Gefühl '
          'auf eine sehr eigene Weise verbindet. '
          '$fateTitle fügt die Richtung hinzu: wohin bewegt sich diese Person, '
          'wenn sie frei entscheiden kann? '
          '$venusDesc '
          '$handDesc '
          'Madame Gatto nickt bedächtig: In dieser Hand liegt eine Geschichte, '
          'die noch nicht zu Ende geschrieben ist.';
    case 2:
      return 'Madame Gatto betrachtet die vier Hauptlinien schweigend. '
          '$heartTitle ist das erste, was ihr ins Auge fällt – '
          'das Herz spricht zuerst, immer. '
          '$lifeTitle zeigt die Grundenergie, aus der alles andere wächst. '
          '$headTitle verrät, wie diese Energie gedacht und geformt wird. '
          '$fateTitle schließt das Bild ab: Wie viel Linie, wie viel Weg, '
          'wie viel bewusste Wahl. '
          '$venusDesc '
          '$handDesc '
          'Madame Gatto legt das Bild zurück: Diese Deutung ist ein Spiegel, kein Urteil.';
    default:
      return 'Madame Gatto nimmt sich Zeit. '
          '$lifeTitle – das ist der Atem dieser Hand, der erste Eindruck. '
          'Dann $fateTitle: wie klar oder offen der Weg erscheint. '
          '$heartTitle spricht von der Wärme, die hinter allem liegt. '
          'Und $headTitle zeigt, mit welcher Denkweise diese Person '
          'ihre Welt ordnet. '
          '$venusDesc '
          '$handDesc '
          'Madame Gatto sagt schließlich: '
          'Jede Hand ist einzigartig. Diese hier trägt eine stille Stärke in sich.';
  }
}

// ── Extraction-based profile ──────────────────────────────────────────────────

/// Derives a [PalmistryAnalysisProfile] from a real [PalmLineExtractionResult].
///
/// When the extraction is too weak (low edge count or confidence < 0.15) the
/// function falls back to the deterministic seed-based [profileFromImagePath].
///
/// Life line length:
///   arc_length_ratio < 0.38 → short, < 0.62 → medium, ≥ 0.62 → long
///
/// Heart line depth: mapped from the classifier confidence score.
///
/// Head line curvature: arc_length / chord_length ratio.
///   < 1.18 → straight, < 1.50 → mixed, ≥ 1.50 → curved
///
/// Fate line strength: mapped from the classifier confidence score.
PalmistryAnalysisProfile profileFromExtraction(
  PalmLineExtractionResult extraction, {
  String fallbackSeed = '',
  ScannedHand scannedHand = ScannedHand.unknown,
}) {
  final effectiveHand = scannedHand == ScannedHand.unknown
      ? extraction.scannedHand
      : scannedHand;
  if (!extraction.hasRealData || extraction.confidence < 0.15) {
    return profileFromImagePath(
      fallbackSeed.isEmpty ? 'default_fallback' : fallbackSeed,
      scannedHand: effectiveHand,
    );
  }

  final c = PalmLineClassifier.classify(extraction);

  // ── Life line ──────────────────────────────────────────────────────────────
  final LifeLine lifeLine;
  if (c.lifeLineConfidence < 0.25) {
    lifeLine = _seedPick(LifeLine.values, fallbackSeed, 0);
  } else {
    final r = c.lifeLineLengthRatio;
    lifeLine = r < 0.38
        ? LifeLine.short
        : r < 0.62
        ? LifeLine.medium
        : LifeLine.long;
  }

  // ── Heart line ─────────────────────────────────────────────────────────────
  final HeartLine heartLine;
  if (c.heartLineConfidence < 0.25) {
    heartLine = _seedPick(HeartLine.values, fallbackSeed, 1);
  } else {
    heartLine = c.heartLineConfidence > 0.60
        ? HeartLine.deep
        : c.heartLineConfidence > 0.38
        ? HeartLine.balanced
        : HeartLine.soft;
  }

  // ── Head line ──────────────────────────────────────────────────────────────
  final HeadLine headLine;
  if (c.headLineConfidence < 0.25) {
    headLine = _seedPick(HeadLine.values, fallbackSeed, 2);
  } else {
    headLine = c.headLineCurvature < 1.18
        ? HeadLine.straight
        : c.headLineCurvature < 1.50
        ? HeadLine.mixed
        : HeadLine.curved;
  }

  // ── Fate line ──────────────────────────────────────────────────────────────
  final FateLine fateLine;
  if (c.fateLineConfidence < 0.20) {
    fateLine = FateLine.faint;
  } else if (c.fateLineConfidence < 0.52) {
    fateLine = FateLine.visible;
  } else {
    fateLine = FateLine.strong;
  }

  // ── Mount Venus: proxy from edge density ───────────────────────────────────
  final area = max(1, extraction.imageWidth * extraction.imageHeight);
  final density = extraction.edgePointCount / area.toDouble();
  final MountVenus mountVenus = density < 0.005
      ? MountVenus.flat
      : density < 0.012
      ? MountVenus.balanced
      : MountVenus.full;

  // ── Hand shape: proxy from image aspect ratio ──────────────────────────────
  final aspect =
      extraction.imageWidth / max(1, extraction.imageHeight).toDouble();
  final HandShape handShape = aspect < 0.75
      ? HandShape.water
      : aspect < 0.90
      ? HandShape.earth
      : aspect < 1.10
      ? HandShape.air
      : HandShape.fire;

  return PalmistryAnalysisProfile(
    lifeLine: lifeLine,
    heartLine: heartLine,
    headLine: headLine,
    fateLine: fateLine,
    mountVenus: mountVenus,
    handShape: handShape,
    scannedHand: effectiveHand,
  );
}

/// Like [profileFromExtraction] but accepts an already-computed
/// [PalmLineClassificationResult].  Use this when the classification was
/// modified after extraction (e.g. life line path extended by continuation).
PalmistryAnalysisProfile profileFromClassification(
  PalmLineClassificationResult c,
  PalmLineExtractionResult extraction, {
  String fallbackSeed = '',
  ScannedHand scannedHand = ScannedHand.unknown,
}) {
  final effectiveHand = scannedHand == ScannedHand.unknown
      ? extraction.scannedHand
      : scannedHand;
  // ── Life line ──────────────────────────────────────────────────────────────
  final LifeLine lifeLine;
  if (c.lifeLineConfidence < 0.25) {
    lifeLine = _seedPick(LifeLine.values, fallbackSeed, 0);
  } else {
    final r = c.lifeLineLengthRatio;
    lifeLine = r < 0.38
        ? LifeLine.short
        : r < 0.62
        ? LifeLine.medium
        : LifeLine.long;
  }

  // ── Heart line ─────────────────────────────────────────────────────────────
  final HeartLine heartLine;
  if (c.heartLineConfidence < 0.25) {
    heartLine = _seedPick(HeartLine.values, fallbackSeed, 1);
  } else {
    heartLine = c.heartLineConfidence > 0.60
        ? HeartLine.deep
        : c.heartLineConfidence > 0.38
        ? HeartLine.balanced
        : HeartLine.soft;
  }

  // ── Head line ──────────────────────────────────────────────────────────────
  final HeadLine headLine;
  if (c.headLineConfidence < 0.25) {
    headLine = _seedPick(HeadLine.values, fallbackSeed, 2);
  } else {
    headLine = c.headLineCurvature < 1.18
        ? HeadLine.straight
        : c.headLineCurvature < 1.50
        ? HeadLine.mixed
        : HeadLine.curved;
  }

  // ── Fate line ──────────────────────────────────────────────────────────────
  final FateLine fateLine;
  if (c.fateLineConfidence < 0.20) {
    fateLine = FateLine.faint;
  } else if (c.fateLineConfidence < 0.52) {
    fateLine = FateLine.visible;
  } else {
    fateLine = FateLine.strong;
  }

  // ── Mount Venus: edge density proxy ───────────────────────────────────────
  final area = max(1, extraction.imageWidth * extraction.imageHeight);
  final density = extraction.edgePointCount / area.toDouble();
  final MountVenus mountVenus = density < 0.005
      ? MountVenus.flat
      : density < 0.012
      ? MountVenus.balanced
      : MountVenus.full;

  // ── Hand shape: aspect ratio proxy ────────────────────────────────────────
  final aspect =
      extraction.imageWidth / max(1, extraction.imageHeight).toDouble();
  final HandShape handShape = aspect < 0.75
      ? HandShape.water
      : aspect < 0.90
      ? HandShape.earth
      : aspect < 1.10
      ? HandShape.air
      : HandShape.fire;

  return PalmistryAnalysisProfile(
    lifeLine: lifeLine,
    heartLine: heartLine,
    headLine: headLine,
    fateLine: fateLine,
    mountVenus: mountVenus,
    handShape: handShape,
    scannedHand: effectiveHand,
  );
}

/// Picks a value from [values] deterministically based on [seed] + [offset].
/// Used as a seeded fallback when a specific line confidence is too low.
T _seedPick<T>(List<T> values, String seed, int offset) {
  var h = 0;
  for (final cu in seed.codeUnits) {
    h = h * 31 + cu;
  }
  return values[(h.abs() + offset) % values.length];
}
