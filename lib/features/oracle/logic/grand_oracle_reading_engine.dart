import '../../../features/astrology/models/zodiac_sign.dart';
import '../../../features/graphology/models/graphology_profile.dart';
import '../../../features/palmistry/models/palmistry_analysis_profile.dart';
import '../../../services/oracle_session_service.dart';
import '../models/grand_oracle_reading.dart';

// ── Zodiac helpers ──────────────────────────────────────────────────────────

const Map<ZodiacSign, String> _zodiacSymbols = {
  ZodiacSign.aries: '♈',
  ZodiacSign.taurus: '♉',
  ZodiacSign.gemini: '♊',
  ZodiacSign.cancer: '♋',
  ZodiacSign.leo: '♌',
  ZodiacSign.virgo: '♍',
  ZodiacSign.libra: '♎',
  ZodiacSign.scorpio: '♏',
  ZodiacSign.sagittarius: '♐',
  ZodiacSign.capricorn: '♑',
  ZodiacSign.aquarius: '♒',
  ZodiacSign.pisces: '♓',
};

const Map<ZodiacSign, String> _zodiacMoods = {
  ZodiacSign.aries: 'Eine Energie, die vorwärtsdrängt – Aufbruch liegt in der Luft.',
  ZodiacSign.taurus: 'Eine ruhige, erdende Kraft – Beständigkeit und Genuss.',
  ZodiacSign.gemini: 'Leichtigkeit und Neugier – viele Fäden weben sich gerade.',
  ZodiacSign.cancer: 'Tiefe Gefühle und innere Heimat – Verbundenheit prägt den Moment.',
  ZodiacSign.leo: 'Wärme und Ausstrahlung – Großzügigkeit und Herz.',
  ZodiacSign.virgo: 'Klarheit und Aufmerksamkeit – Details tragen Bedeutung.',
  ZodiacSign.libra: 'Balance und Schönheitssinn – Harmonie ist das Leitmotiv.',
  ZodiacSign.scorpio: 'Tiefe und Verwandlung – unter der Oberfläche bewegt sich viel.',
  ZodiacSign.sagittarius: 'Freiheit und Weitsicht – neue Horizonte öffnen sich.',
  ZodiacSign.capricorn: 'Ausdauer und Struktur – mit Geduld entsteht Bleibendes.',
  ZodiacSign.aquarius: 'Unabhängigkeit und Originalität – eigene Wege führen weiter.',
  ZodiacSign.pisces: 'Feingefühl und Träumerei – Intuition ist der beste Kompass.',
};

const Map<ZodiacSign, String> _zodiacLuckySymbols = {
  ZodiacSign.aries: '🔴',
  ZodiacSign.taurus: '🌿',
  ZodiacSign.gemini: '🌬️',
  ZodiacSign.cancer: '🌙',
  ZodiacSign.leo: '☀️',
  ZodiacSign.virgo: '🌾',
  ZodiacSign.libra: '⚖️',
  ZodiacSign.scorpio: '🦂',
  ZodiacSign.sagittarius: '🏹',
  ZodiacSign.capricorn: '🏔️',
  ZodiacSign.aquarius: '⚡',
  ZodiacSign.pisces: '🐟',
};

// ── Tarot mood fragments ────────────────────────────────────────────────────

const Map<String, String> _tarotMoodFragments = {
  'Die Katze': 'Eine spielerische Neugier gibt dem Tag seinen Impuls.',
  'Der Magier': 'Alle Mittel liegen bereit – der Moment gehört dir.',
  'Die Hohepriesterin': 'Stille Weisheit führt sicherer als lautes Handeln.',
  'Die Herrscherin': 'Fürsorge und Schöpferkraft prägen die Stimmung.',
  'Der Herrscher': 'Ordnung und Klarheit geben Halt.',
  'Der Hierophant': 'Überliefertes Wissen bietet Orientierung.',
  'Die Liebenden': 'Das Herz steht im Mittelpunkt aller Entscheidungen.',
  'Der Wagen': 'Zielstrebigkeit und Bewegung treiben voran.',
  'Die Stärke': 'Sanfte Beharrlichkeit übertrifft rohe Kraft.',
  'Die Einsiedlerin': 'Innere Stille ist die tiefste Ressource.',
  'Das Rad': 'Veränderung ist der Motor – das Rad dreht sich.',
  'Die Gerechtigkeit': 'Ausgewogenheit und Fairness prägen den Moment.',
  'Der Gehängte': 'Innehalten bringt mehr als Weitermachen.',
  'Die Wandlung': 'Etwas endet – damit etwas Neues Platz hat.',
  'Die Mäßigung': 'Harmonie entsteht durch das richtige Maß.',
  'Der Teufel': 'Was hält fest? Die Antwort liegt im Loslassen.',
  'Der Turm': 'Was wackelt, darf fallen – dahinter wartet Freiheit.',
  'Der Stern': 'Zuversicht leuchtet durch die Unsicherheit.',
  'Der Mond': 'Das Verborgene darf ans Licht kommen.',
  'Die Sonne': 'Freude und Klarheit bestimmen den Ton.',
  'Das Gericht': 'Reflexion öffnet die nächste Tür.',
  'Die Welt': 'Ein Kreis schließt sich – Vollendung ist spürbar.',
};

// ── Palm strengths ──────────────────────────────────────────────────────────

const Map<LifeLine, String> _lifeLineStrengths = {
  LifeLine.short: 'Fokus und gezielte Energie',
  LifeLine.medium: 'Stetigkeit und verlässlicher Rhythmus',
  LifeLine.long: 'Ausdauer und tief verwurzelte Kraft',
};

const Map<HeartLine, String> _heartLineStrengths = {
  HeartLine.soft: 'Feingefühl und emotionale Achtsamkeit',
  HeartLine.balanced: 'Gesunde Balance zwischen Geben und Nehmen',
  HeartLine.deep: 'Tiefe Verbundenheit und Leidenschaft',
};

const Map<HeadLine, String> _headLineStrengths = {
  HeadLine.straight: 'Analytisches Denken und Klarheit',
  HeadLine.curved: 'Kreativität und Vorstellungskraft',
  HeadLine.mixed: 'Vielseitigkeit zwischen Logik und Intuition',
};

// ── Graphology challenge fragments ─────────────────────────────────────────

const Map<Pressure, String> _pressureChallenges = {
  Pressure.light: 'Die Herausforderung liegt darin, Wichtiges mit mehr Nachdruck zu verfolgen.',
  Pressure.medium: 'Die Herausforderung ist, die eigene Balance aktiv zu halten.',
  Pressure.heavy: 'Die Herausforderung liegt darin, auch einmal loszulassen, statt alles festzuhalten.',
};

const Map<Slant, String> _slantChallenges = {
  Slant.left: 'Es kann helfen, sich mehr dem Außen zuzuwenden und Kontakt zu wagen.',
  Slant.straight: 'Emotionale Offenheit – sich erlauben, berührt zu werden.',
  Slant.right: 'Es kann helfen, auch mal innezuhalten statt immer vorwärts zu drängen.',
};

// ── Lucky symbols fallback ─────────────────────────────────────────────────

const List<String> _palmLuckySymbols = ['🌿', '💧', '🔥', '🌍'];

const List<String> _tarotLuckySymbols = [
  '⭐', '🌟', '✨', '🌙', '☀️', '🌈', '🍀', '🔮',
  '💫', '🌺', '🦋', '🕊️', '🌸', '🌻', '⚡', '🌊',
  '🏔️', '🌾', '🎴', '🃏', '🌿', '💎', '🌙', '🦄',
];

// ── Public API ─────────────────────────────────────────────────────────────

GrandOracleReading generateGrandReading(OracleSessionService session) {
  final count = session.completedCount;
  final title = count == 4
      ? 'Große Lesung vollständig'
      : count == 0
          ? 'Leere Lesung'
          : 'Teil-Lesung ($count/4)';

  return GrandOracleReading(
    title: title,
    mood: _buildMood(session),
    strengths: _buildStrengths(session),
    challenge: _buildChallenge(session),
    catAdvice: _buildCatAdvice(session),
    luckySymbol: _buildLuckySymbol(session),
    pawRating: _computePawRating(session),
    summaryText: _buildSummaryText(session),
    completedModules: count,
  );
}

// ── Component builders ─────────────────────────────────────────────────────

String _buildMood(OracleSessionService s) {
  // Astrology gives the base mood, tarot adds a nuance
  if (s.hasAstrology && s.hasTarot) {
    final sign = s.astrologySessionResult!.profile.sunSign;
    final card = s.lastDrawnTarotCard!;
    final tarotFrag = _tarotMoodFragments[card.name] ??
        'Eine besondere Energie trägt den Moment.';
    final zodiacMood = _zodiacMoods[sign] ?? 'Eine kraftvolle Energie umgibt dich.';
    return '$zodiacMood $tarotFrag';
  }
  if (s.hasAstrology) {
    final sign = s.astrologySessionResult!.profile.sunSign;
    return _zodiacMoods[sign] ??
        'Eine kraftvolle Energie umgibt dich.';
  }
  if (s.hasTarot) {
    return _tarotMoodFragments[s.lastDrawnTarotCard!.name] ??
        'Die Karte trägt ihre eigene, stille Botschaft.';
  }
  return 'Madame Gatto lauscht – die Zeichen formen sich noch.';
}

String _buildStrengths(OracleSessionService s) {
  final parts = <String>[];
  if (s.hasPalmistry) {
    final p = s.palmistryAnalysisProfile!;
    parts.add(_lifeLineStrengths[p.lifeLine] ?? '');
    parts.add(_heartLineStrengths[p.heartLine] ?? '');
    parts.add(_headLineStrengths[p.headLine] ?? '');
  }
  if (s.hasGraphology) {
    final g = s.graphologyProfile!;
    final traits = s.graphologyTraits;
    if (traits != null && traits.isNotEmpty) {
      parts.add(traits.first.title);
    } else {
      // fallback on slant
      const slantStrengths = {
        Slant.left: 'Innere Tiefe und Selbstständigkeit',
        Slant.straight: 'Besonnenheit und innere Balance',
        Slant.right: 'Offenheit und Kontaktfreude',
      };
      parts.add(slantStrengths[g.slant] ?? '');
    }
  }
  if (parts.isEmpty) {
    return 'Madame Gatto erkennt in dir eine Stärke, die noch wartet, benannt zu werden.';
  }
  final filled = parts.where((e) => e.isNotEmpty).toList();
  if (filled.isEmpty) {
    return 'Eine stille innere Kraft, die sich entfalten möchte.';
  }
  if (filled.length == 1) return filled.first;
  if (filled.length == 2) return '${filled[0]} und ${filled[1]}.';
  return '${filled.take(filled.length - 1).join(', ')} sowie ${filled.last}.';
}

String _buildChallenge(OracleSessionService s) {
  if (s.hasGraphology) {
    final g = s.graphologyProfile!;
    final pressureChallenge = _pressureChallenges[g.pressure] ?? '';
    final slantChallenge = _slantChallenges[g.slant] ?? '';
    if (pressureChallenge.isNotEmpty && slantChallenge.isNotEmpty) {
      return '$pressureChallenge $slantChallenge';
    }
    return pressureChallenge.isNotEmpty ? pressureChallenge : slantChallenge;
  }
  if (s.hasPalmistry) {
    final p = s.palmistryAnalysisProfile!;
    const fateLineChallenges = {
      FateLine.faint: 'Die Herausforderung liegt darin, einen klaren Weg zu wählen und ihn zu gehen.',
      FateLine.visible: 'Es gilt, Beständigkeit mit Offenheit für Veränderung zu verbinden.',
      FateLine.strong: 'Die Herausforderung ist, nicht zu starr am Plan festzuhalten.',
    };
    return fateLineChallenges[p.fateLine] ??
        'Madame Gatto sieht eine Herausforderung, die noch ihren Namen sucht.';
  }
  if (s.hasTarot) {
    final card = s.lastDrawnTarotCard!;
    return 'Die Karte „${card.name}" trägt einen Hinweis: ${card.meaning.split('.').first}.';
  }
  return 'Madame Gatto sagt: Jede Reise hat ihre eigene Herausforderung. Sammle weitere Zeichen, um sie zu benennen.';
}

String _buildCatAdvice(OracleSessionService s) {
  if (s.isGrandReadingReady) {
    final count = s.completedCount;
    if (count == 4) {
      final sign = s.hasAstrology
          ? (s.astrologySessionResult!.profile.sunSign)
          : null;
      final card = s.hasTarot ? s.lastDrawnTarotCard!.name : null;
      if (sign != null && card != null) {
        return 'Madame Gatto legt die Pfote auf dein Herz: '
            'Dein Sonnenzeichen ${_zodiacSymbols[sign] ?? ''} und die Karte „$card" '
            'sprechen eine Sprache. Hör hin – nicht mit dem Verstand, sondern mit dem Bauch.';
      }
      return 'Madame Gatto sagt: Du hast alle Zeichen gesammelt. '
          'Jetzt ist die Zeit, ihnen zu vertrauen.';
    }
    if (s.hasAstrology) {
      final reading = s.astrologySessionResult!.composedReading;
      final firstSentence = reading.split('.').first;
      return 'Madame Gatto flüstert: $firstSentence. '
          'Lass diesen Gedanken eine Weile bei dir sein.';
    }
    if (s.hasTarot) {
      final card = s.lastDrawnTarotCard!;
      return 'Madame Gatto lehnt sich vor: „${card.catMessage}"';
    }
    if (s.hasPalmistry) {
      final traits = s.palmistryTraits;
      if (traits != null && traits.isNotEmpty) {
        return 'Madame Gatto sagt: ${traits.first.catMessage}';
      }
    }
    if (s.hasGraphology) {
      final traits = s.graphologyTraits;
      if (traits != null && traits.isNotEmpty) {
        return 'Madame Gatto murmelt: ${traits.first.catMessage}';
      }
    }
  }
  return 'Madame Gatto wartet. Sammle mehr Zeichen, damit die Lesung vollständiger wird.';
}

String _buildLuckySymbol(OracleSessionService s) {
  if (s.hasAstrology) {
    final sign = s.astrologySessionResult!.profile.sunSign;
    return _zodiacLuckySymbols[sign] ?? '✨';
  }
  if (s.hasPalmistry) {
    final p = s.palmistryAnalysisProfile!;
    return _palmLuckySymbols[p.handShape.index % _palmLuckySymbols.length];
  }
  if (s.hasTarot) {
    final card = s.lastDrawnTarotCard!;
    return _tarotLuckySymbols[card.name.length % _tarotLuckySymbols.length];
  }
  if (s.hasGraphology) {
    return '✒️';
  }
  return '🔮';
}

int _computePawRating(OracleSessionService s) {
  // Base: 1 paw per module, bonus paw for 4/4
  final base = s.completedCount;
  if (s.isGrandReadingReady && base == 4) return 5;
  return base.clamp(1, 4);
}

String _buildSummaryText(OracleSessionService s) {
  final count = s.completedCount;

  if (count == 0) {
    return 'Madame Gatto schaut dich nachdenklich an. '
        'Noch kein Zeichen wurde gesammelt. '
        'Besuche Tarot, Astrologie, Handlesen oder Grafologie, '
        'um deine persönliche Große Lesung zu beginnen.';
  }

  final modules = <String>[];
  if (s.hasTarot) modules.add('Tarot');
  if (s.hasAstrology) modules.add('Astrologie');
  if (s.hasPalmistry) modules.add('Handlesen');
  if (s.hasGraphology) modules.add('Grafologie');

  final moduleList = modules.length == 1
      ? modules.first
      : '${modules.take(modules.length - 1).join(', ')} und ${modules.last}';

  if (count == 4) {
    return 'Madame Gatto hat alle vier Zeichen gelesen: $moduleList. '
        'Die Symbole sprechen gemeinsam – '
        'was sie sagen, trägt dich weit über diesen Moment hinaus. '
        'Diese Lesung ist ein Spiegel, kein Urteil.';
  }

  return 'Madame Gatto hat $count von 4 Zeichen gelesen: $moduleList. '
      'Das Bild ist bereits erkennbar – '
      'doch weitere Zeichen würden es noch klarer machen. '
      'Diese Lesung ist symbolisch und zur Unterhaltung gedacht.';
}
