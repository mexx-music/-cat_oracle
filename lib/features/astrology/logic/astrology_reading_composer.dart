import 'package:cat_oracle/features/astrology/models/zodiac_sign.dart';

String composeDemoAstrologyReading({
  required ZodiacSign sunSign,
  ZodiacSign? moonSign,
  ZodiacSign? ascendant,
}) {
  final sunText =
      _sunMelody[sunSign] ??
      'Dein Sonnenzeichen trägt die Grundmelodie deiner Energie mit stiller Klarheit.';
  final moonText = moonSign == null
      ? 'Dein Mondzeichen bleibt vorerst offen und erinnert daran, achtsam auf deine innere Stimmung zu hören.'
      : (_moonImpulse[moonSign] ??
            'Dein Mondzeichen zeigt eine feine, ruhige Innenseite, die Wärme und Intuition verbindet.');
  final ascText = ascendant == null
      ? 'Dein Aszendent wird später ergänzt und lässt bis dahin Raum für eine offene, sanfte Außenwirkung.'
      : (_ascendantAura[ascendant] ??
            'Dein Aszendent beschreibt eine klare und freundliche Präsenz im Kontakt mit der Welt.');

  return '$sunText $moonText $ascText';
}

const Map<ZodiacSign, String> _sunMelody = {
  ZodiacSign.aries:
      'Dein Sonnenzeichen Widder trägt eine mutige Grundenergie, die Bewegung und frische Impulse liebt.',
  ZodiacSign.taurus:
      'Dein Sonnenzeichen Stier gibt deiner Energie Ruhe, Beständigkeit und einen Sinn für das Schöne.',
  ZodiacSign.gemini:
      'Dein Sonnenzeichen Zwillinge schenkt dir geistige Beweglichkeit, Neugier und leichte Kommunikation.',
  ZodiacSign.cancer:
      'Dein Sonnenzeichen Krebs verankert Wärme, Fürsorge und eine feinfühlige innere Tiefe.',
  ZodiacSign.leo:
      'Dein Sonnenzeichen Löwe strahlt Herzenskraft, kreative Präsenz und natürliche Großzügigkeit aus.',
  ZodiacSign.virgo:
      'Dein Sonnenzeichen Jungfrau bringt Klarheit, Sorgfalt und ein gutes Gespür für stimmige Details.',
  ZodiacSign.libra:
      'Dein Sonnenzeichen Waage betont Harmonie, Ästhetik und einen diplomatischen Blick auf Beziehungen.',
  ZodiacSign.scorpio:
      'Dein Sonnenzeichen Skorpion gibt Intensität, Tiefe und einen scharfen Instinkt für Echtheit.',
  ZodiacSign.sagittarius:
      'Dein Sonnenzeichen Schütze öffnet den Blick für Sinn, Weite und inspirierende Perspektiven.',
  ZodiacSign.capricorn:
      'Dein Sonnenzeichen Steinbock bringt Fokus, Verlässlichkeit und eine ruhige Zielkraft mit.',
  ZodiacSign.aquarius:
      'Dein Sonnenzeichen Wassermann stärkt Eigenständigkeit, Ideenreichtum und den Mut zum Neuen.',
  ZodiacSign.pisces:
      'Dein Sonnenzeichen Fische verbindet Sensibilität, Fantasie und eine weiche intuitive Wahrnehmung.',
};

const Map<ZodiacSign, String> _moonImpulse = {
  ZodiacSign.aries:
      'Dein Mondzeichen Widder zeigt Gefühle direkt und lebendig, mit schneller innerer Reaktion.',
  ZodiacSign.taurus:
      'Dein Mondzeichen Stier sucht emotional Ruhe, Sicherheit und sanfte Sinnlichkeit.',
  ZodiacSign.gemini:
      'Dein Mondzeichen Zwillinge verarbeitet Gefühle über Gedanken, Austausch und Bewegung.',
  ZodiacSign.cancer:
      'Dein Mondzeichen Krebs fühlt tief und beschützend, mit starkem Wunsch nach Geborgenheit.',
  ZodiacSign.leo:
      'Dein Mondzeichen Löwe erlebt Emotionen warmherzig, stolz und mit offenem Herzen.',
  ZodiacSign.virgo:
      'Dein Mondzeichen Jungfrau ordnet Gefühle achtsam und sucht innere Stimmigkeit.',
  ZodiacSign.libra:
      'Dein Mondzeichen Waage spürt Harmoniebedürfnis und feine Resonanz in Beziehungen.',
  ZodiacSign.scorpio:
      'Dein Mondzeichen Skorpion erlebt Emotionen intensiv und mit tiefer Ehrlichkeit.',
  ZodiacSign.sagittarius:
      'Dein Mondzeichen Schütze hält Gefühle in Bewegung und sucht weite, helle Perspektiven.',
  ZodiacSign.capricorn:
      'Dein Mondzeichen Steinbock zeigt emotionale Reife, Struktur und verlässliche Haltung.',
  ZodiacSign.aquarius:
      'Dein Mondzeichen Wassermann fühlt eigenständig und betrachtet Emotionen oft aus innerer Distanz.',
  ZodiacSign.pisces:
      'Dein Mondzeichen Fische nimmt Stimmungen fein auf und verbindet Mitgefühl mit Intuition.',
};

const Map<ZodiacSign, String> _ascendantAura = {
  ZodiacSign.aries:
      'Dein Aszendent Widder wirkt nach außen direkt, initiativ und klar in der Ausstrahlung.',
  ZodiacSign.taurus:
      'Dein Aszendent Stier zeigt nach außen Ruhe, Präsenz und beständige Bodenhaftung.',
  ZodiacSign.gemini:
      'Dein Aszendent Zwillinge wirkt offen, kommunikativ und geistig wach.',
  ZodiacSign.cancer:
      'Dein Aszendent Krebs erscheint zugewandt, schützend und emotional aufmerksam.',
  ZodiacSign.leo:
      'Dein Aszendent Löwe strahlt Wärme, Würde und kreative Sichtbarkeit aus.',
  ZodiacSign.virgo:
      'Dein Aszendent Jungfrau wirkt präzise, freundlich und verlässlich strukturiert.',
  ZodiacSign.libra:
      'Dein Aszendent Waage zeigt Charme, Ausgleich und ein feines Gefühl für Kontakt.',
  ZodiacSign.scorpio:
      'Dein Aszendent Skorpion wirkt konzentriert, intensiv und magnetisch präsent.',
  ZodiacSign.sagittarius:
      'Dein Aszendent Schütze erscheint offen, inspirierend und zuversichtlich.',
  ZodiacSign.capricorn:
      'Dein Aszendent Steinbock wirkt souverän, klar und verantwortungsbewusst.',
  ZodiacSign.aquarius:
      'Dein Aszendent Wassermann zeigt Originalität, Unabhängigkeit und frische Perspektiven.',
  ZodiacSign.pisces:
      'Dein Aszendent Fische wirkt weich, empathisch und poetisch durchlässig.',
};
