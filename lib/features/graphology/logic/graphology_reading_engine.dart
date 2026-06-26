import 'dart:math';

import '../models/graphology_profile.dart';
import '../models/graphology_trait.dart';

// ── Trait library ──────────────────────────────────────────────────────────

const Map<LetterSize, GraphologyTrait> _letterSizeTraits = {
  LetterSize.small: GraphologyTrait(
    title: 'Kleine Schrift',
    symbol: '🔬',
    meaning:
        'Kleine Zeichen wirken konzentriert und nach innen gerichtet. '
        'Madame Gatto sieht darin ein feines Gespür für Details – '
        'hier schreibt jemand, der lieber vertieft als überblickt.',
    catMessage:
        'Madame Gatto murmelt: Kleine Schritte hinterlassen manchmal die tiefsten Spuren.',
  ),
  LetterSize.medium: GraphologyTrait(
    title: 'Mittlere Schrift',
    symbol: '📏',
    meaning:
        'Ausgewogene Buchstabengrößen können auf eine gesunde Balance '
        'zwischen Selbst und Umwelt hindeuten – weder zu sehr nach innen '
        'noch nach außen gerichtet. Madame Gatto sieht hier jemanden, '
        'der seinen Platz kennt.',
    catMessage:
        'Madame Gatto nickt bedächtig: Wer die Mitte hält, kommt oft am weitesten.',
  ),
  LetterSize.large: GraphologyTrait(
    title: 'Große Schrift',
    symbol: '📐',
    meaning:
        'Große Buchstaben wirken offen und raumnehmend. '
        'Madame Gatto sieht darin eine Energie, die sich zeigen möchte – '
        'bewusst und mit Freude an der Weite.',
    catMessage:
        'Aurelius schreibt ebenfalls in großen Zügen. Er sagt: Wer Platz nimmt, hat etwas zu sagen.',
  ),
};

const Map<Slant, GraphologyTrait> _slantTraits = {
  Slant.left: GraphologyTrait(
    title: 'Linksneigung',
    symbol: '🌀',
    meaning:
        'Eine Neigung nach links wirkt wie ein Blick ins Innere. '
        'Madame Gatto sieht darin ein feines Gespür für die eigene Welt '
        'und den Wunsch, Dinge zuerst bei sich zu verorten, bevor sie nach '
        'außen treten.',
    catMessage:
        'Madame Gatto flüstert: Auch die schüchternste Katze weiß genau, was sie fühlt.',
  ),
  Slant.straight: GraphologyTrait(
    title: 'Senkrechte Schrift',
    symbol: '🕯️',
    meaning:
        'Aufrecht stehende Buchstaben können auf Ausgeglichenheit und '
        'Selbstkontrolle hindeuten. Madame Gatto sieht hier jemanden, '
        'der Gefühl und Verstand gut zu verbinden weiß.',
    catMessage: 'Madame Gatto sagt: Wer gerade steht, fällt selten um.',
  ),
  Slant.right: GraphologyTrait(
    title: 'Rechtsneigung',
    symbol: '✨',
    meaning:
        'Eine Neigung nach rechts wirkt zugewandt und offen. '
        'Madame Gatto sieht darin eine Energie, die sich zur Welt hin ausstreckt – '
        'neugierig und verbindungswillig.',
    catMessage:
        'Madame Gatto lächelt: Wer sich vorwärts neigt, ist schon auf dem Weg.',
  ),
};

const Map<Baseline, GraphologyTrait> _baselineTraits = {
  Baseline.rising: GraphologyTrait(
    title: 'Steigende Zeile',
    symbol: '🌠',
    meaning:
        'Zeilen, die nach oben driften, sprechen von Aufbruch und einem '
        'Geist, der sich ausstreckt. Madame Gatto sieht hier eine Energie, '
        'die auf Bewegung und Wachstum gerichtet ist.',
    catMessage:
        'Wie neugierige Schnurrhaare, sagt Madame Gatto – immer auf der Suche nach dem Nächsten.',
  ),
  Baseline.straight: GraphologyTrait(
    title: 'Gleichmäßige Zeile',
    symbol: '🌊',
    meaning:
        'Gleichbleibende Zeilen wirken stabil und verlässlich. '
        'Madame Gatto sieht darin jemanden, der auch unter Druck seinen '
        'Rhythmus behält.',
    catMessage:
        'Madame Gatto sagt leise: Wer seinen Rhythmus kennt, braucht keinen Lärm.',
  ),
  Baseline.falling: GraphologyTrait(
    title: 'Fallende Zeile',
    symbol: '🌙',
    meaning:
        'Linien, die sanft abfallen, sprechen von Reflexion und dem '
        'Bewusstsein für das Gewicht des Moments. '
        'Madame Gatto sieht hier kein Zeichen von Schwäche, sondern tiefes Empfinden.',
    catMessage:
        'Aus der Stille entsteht die klarste Kraft, sagt Madame Gatto.',
  ),
};

const Map<Spacing, GraphologyTrait> _spacingTraits = {
  Spacing.narrow: GraphologyTrait(
    title: 'Enge Abstände',
    symbol: '🌿',
    meaning:
        'Eng gesetzte Buchstaben können auf Nähe und Intensität hindeuten – '
        'Madame Gatto sieht hier jemanden, dem Verbindung und Dichte '
        'wichtiger sind als Abstand.',
    catMessage:
        'Madame Gatto sagt: Wer nah schreibt, schreibt oft auch nah am Herzen.',
  ),
  Spacing.normal: GraphologyTrait(
    title: 'Ausgeglichene Abstände',
    symbol: '⚖️',
    meaning:
        'Gleichmäßige Abstände wirken ausgewogen und sozial verträglich. '
        'Madame Gatto sieht hier jemanden, der weiß, wann er Nähe sucht '
        'und wann er Raum lässt.',
    catMessage:
        'Madame Gatto nickt: Balance ist keine Gleichgültigkeit – sie ist Weisheit.',
  ),
  Spacing.wide: GraphologyTrait(
    title: 'Weite Abstände',
    symbol: '🌌',
    meaning:
        'Großzügige Abstände deuten symbolisch auf ein Freiheitsbedürfnis hin. '
        'Madame Gatto sieht darin jemanden, der Raum braucht – '
        'zum Denken, zum Atmen, zum Sein.',
    catMessage:
        'Madame Gatto lächelt: Auch der Mond braucht Dunkelheit, um zu leuchten.',
  ),
};

const Map<Pressure, GraphologyTrait> _pressureTraits = {
  Pressure.light: GraphologyTrait(
    title: 'Leichter Druck',
    symbol: '🌿',
    meaning:
        'Leichte, schwebende Linien wirken feinfühlig und aufmerksam. '
        'Madame Gatto sieht hier jemanden, der die Welt sehr genau wahrnimmt '
        'und seine Worte mit Bedacht wählt.',
    catMessage:
        'Gattos jüngstes Kätzchen hinterlässt leise Abdrücke im Schnee – und wird trotzdem bemerkt.',
  ),
  Pressure.medium: GraphologyTrait(
    title: 'Mittlerer Druck',
    symbol: '💫',
    meaning:
        'Ein ausgeglichener Stiftdruck wirkt beständig und verlässlich. '
        'Madame Gatto sieht darin jemanden, der weder zu viel noch zu wenig '
        'von sich gibt – eine stille Stärke.',
    catMessage:
        'Madame Gatto sagt: Wer gleichmäßig drückt, hält auch gleichmäßig durch.',
  ),
  Pressure.heavy: GraphologyTrait(
    title: 'Starker Druck',
    symbol: '⚡',
    meaning:
        'Ein kräftiger Stift auf dem Papier spricht von Entschlossenheit '
        'und innerer Präsenz. Madame Gatto sieht hier jemanden, der mit '
        'vollem Einsatz bei sich ist – das hinterlässt Spuren, die bleiben.',
    catMessage:
        'Madame Gatto nickt: Ein tiefer Strich ist wie ein Versprechen an sich selbst.',
  ),
};

const Map<Shape, GraphologyTrait> _shapeTraits = {
  Shape.round: GraphologyTrait(
    title: 'Runde Formen',
    symbol: '🌊',
    meaning:
        'Weiche, runde Formen wirken harmonisch und empathisch. '
        'Madame Gatto sieht darin ein feines Gespür für Verbindung – '
        'runde Schrift fließt wie ein ruhiger Fluss, der seinen Weg schon kennt.',
    catMessage:
        'Madame Gatto legt die Hand aufs Papier: Rundungen tragen Wärme, die kein Wort erklären muss.',
  ),
  Shape.mixed: GraphologyTrait(
    title: 'Gemischte Formen',
    symbol: '🍂',
    meaning:
        'Schrift, die zwischen Rund und Eckig wechselt, kann auf '
        'Anpassungsfähigkeit und Vielseitigkeit hindeuten. '
        'Madame Gatto sieht hier jemanden, der je nach Situation '
        'verschiedene Seiten zeigt.',
    catMessage:
        'Madame Gatto sagt: Eine Katze ist manchmal weich, manchmal scharf – das ist keine Widerspruch.',
  ),
  Shape.angular: GraphologyTrait(
    title: 'Eckige Formen',
    symbol: '⚡',
    meaning:
        'Spitze Winkel wirken präzise und analytisch. '
        'Madame Gatto sieht hier einen scharfen Geist, der rasch denkt '
        'und selten zufrieden mit dem Ungefähren ist.',
    catMessage:
        'Selbst Gattos Klauen, sagt sie mit einem Lächeln, sind manchmal das schärfste Werkzeug im Haus.',
  ),
};

const Map<SignatureStyle, GraphologyTrait> _signatureTraits = {
  SignatureStyle.small: GraphologyTrait(
    title: 'Kleine Unterschrift',
    symbol: '🌱',
    meaning:
        'Eine zurückhaltende Unterschrift wirkt bescheiden und aufrichtig. '
        'Madame Gatto sieht darin jemanden, der keinen Auftritt braucht '
        'und dessen Stärke im Stillen liegt.',
    catMessage:
        'Madame Gatto flüstert: Die leisen Stimmen sagen oft das Wichtigste.',
  ),
  SignatureStyle.normal: GraphologyTrait(
    title: 'Ausgeglichene Unterschrift',
    symbol: '🌟',
    meaning:
        'Eine Unterschrift, die zur Schrift passt, kann auf innere Harmonie '
        'und Selbstbewusstsein hindeuten. '
        'Madame Gatto sieht hier jemanden, der sich so zeigt, wie er ist.',
    catMessage: 'Madame Gatto lächelt: Echt sein ist die eleganteste Form der Stärke.',
  ),
  SignatureStyle.dominant: GraphologyTrait(
    title: 'Dominante Unterschrift',
    symbol: '👑',
    meaning:
        'Eine auffällige, große Unterschrift wirkt präsent und ausdrucksstark. '
        'Madame Gatto sieht darin jemanden, der weiß, was er hinterlassen möchte – '
        'und das auch zeigt.',
    catMessage:
        'Madame Gatto nickt: Wer seine Unterschrift mit Nachdruck setzt, meint es ernst.',
  ),
};

// ── Public API ─────────────────────────────────────────────────────────────

/// Deterministic profile from image path — same path → same result.
GraphologyProfile profileFromImagePath(String imagePath) {
  int seed = 0;
  for (final c in imagePath.codeUnits) {
    seed = seed * 31 + c;
  }
  final r = Random(seed.abs());
  return GraphologyProfile(
    letterSize: LetterSize.values[r.nextInt(LetterSize.values.length)],
    slant: Slant.values[r.nextInt(Slant.values.length)],
    baseline: Baseline.values[r.nextInt(Baseline.values.length)],
    spacing: Spacing.values[r.nextInt(Spacing.values.length)],
    pressure: Pressure.values[r.nextInt(Pressure.values.length)],
    shape: Shape.values[r.nextInt(Shape.values.length)],
    signatureStyle:
        SignatureStyle.values[r.nextInt(SignatureStyle.values.length)],
  );
}

/// Returns the 4 most visually prominent traits for display as cards.
List<GraphologyTrait> traitsFromProfile(GraphologyProfile profile) {
  return [
    _letterSizeTraits[profile.letterSize]!,
    _slantTraits[profile.slant]!,
    _pressureTraits[profile.pressure]!,
    _shapeTraits[profile.shape]!,
  ];
}

/// Madame Gatto overall reading that references the specific profile.
String readingFromProfile(GraphologyProfile profile) {
  final sizeTitle = _letterSizeTraits[profile.letterSize]!.title;
  final slantTitle = _slantTraits[profile.slant]!.title;
  final pressureTitle = _pressureTraits[profile.pressure]!.title;
  final shapeTitle = _shapeTraits[profile.shape]!.title;
  final baselineTitle = _baselineTraits[profile.baseline]!.title;
  final spacingTitle = _spacingTraits[profile.spacing]!.title;
  final signatureTitle = _signatureTraits[profile.signatureStyle]!.title;

  final variant =
      (profile.letterSize.index * 7 +
          profile.slant.index * 5 +
          profile.pressure.index * 3 +
          profile.shape.index) %
      4;

  switch (variant) {
    case 0:
      return 'Madame Gatto betrachtet die Schrift einen Moment lang schweigend. '
          '$sizeTitle und $slantTitle sprechen zusammen eine deutliche Sprache – '
          'sie zeigen, wie viel Raum jemand einnimmt und wohin die innere Energie fließt. '
          '$pressureTitle ergänzt das Bild: hier steckt eine Kraft, die sich nicht versteckt. '
          'Und $shapeTitle verrät, wie diese Person mit der Welt in Kontakt tritt – direkt oder fließend. '
          'Die $baselineTitle und $spacingTitle fügen eine weitere Schicht hinzu: Rhythmus und Tempo. '
          'Die $signatureTitle am Ende des Blattes ist der letzte Spiegel. '
          'Madame Gatto legt das Blatt beiseite und sagt leise: Diese Schrift kennt sich gut.';
    case 1:
      return 'Drei Zeichen stechen Madame Gatto sofort ins Auge: '
          '$sizeTitle, $pressureTitle und $shapeTitle. '
          'Sie bilden zusammen ein Bild, das mehr sagt als jedes einzelne Detail. '
          '$slantTitle zeigt, wohin der Blick dieser Person von Natur aus geht – '
          'nach innen, nach außen oder in die ruhige Mitte. '
          'Die $baselineTitle verrät etwas über den Moment, in dem diese Zeilen entstanden sind. '
          'Und die $spacingTitle deutet an, wie viel Raum diese Person anderen – und sich selbst – lässt. '
          'Die $signatureTitle schließt das Bild ab. '
          'Madame Gatto nickt: Selten erzählt eine Schrift so offen von ihrem Ursprung.';
    case 2:
      return 'Madame Gatto legt das Papier auf den Tisch und folgt den Linien mit dem Blick. '
          '$slantTitle und $shapeTitle sind die ersten Zeichen, die sie benennt – '
          'sie sprechen davon, wie jemand mit der Welt in Kontakt tritt. '
          '$pressureTitle zeigt, wie viel innere Energie hinter diesen Worten steckt. '
          '$sizeTitle gibt Aufschluss darüber, wie viel Platz diese Person einnehmen möchte. '
          'Die $baselineTitle zeigt den emotionalen Zustand im Moment des Schreibens. '
          '$spacingTitle und $signatureTitle runden das Bild ab: '
          'wie viel Abstand, wie viel Anspruch, wie viel Präsenz. '
          'Madame Gatto sagt schließlich: Deine Schrift spricht klarer, als du vielleicht denkst.';
    default:
      return 'Madame Gatto nimmt das Blatt in beide Pfoten und schweigt einen Moment. '
          'Dann: $sizeTitle. Das ist das erste, was sie sieht – '
          'eine Entscheidung darüber, wie viel Raum diese Person sich erlaubt. '
          '$slantTitle ergänzt: wohin lehnt sich diese Person, wenn sie schreibt? '
          '$shapeTitle zeigt, wie die innere Welt nach außen geformt wird – '
          'weich fließend oder klar gezeichnet. '
          '$pressureTitle hinterlässt die deutlichste Spur: hier liegt Entschiedenheit. '
          'Die $baselineTitle, $spacingTitle und $signatureTitle sind die feinen Töne. '
          'Madame Gatto legt das Blatt zurück: Diese Deutung ist ein Anfang – kein Urteil.';
  }
}
