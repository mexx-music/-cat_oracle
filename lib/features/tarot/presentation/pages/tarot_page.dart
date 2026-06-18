import 'dart:math';

import 'package:flutter/material.dart';

import 'package:cat_oracle/gen_l10n/app_localizations.dart';

import '../../data/demo_tarot_cards.dart';
import '../../logic/daily_tarot_card_generator.dart';
import '../../models/tarot_card.dart';

const Map<String, List<String>> _cardThemes = {
  'Die Katze': ['Leichtigkeit', 'Vertrauen', 'Neugier', 'Anfang', 'Mut'],
  'Der Magier': ['Fokus', 'Gestaltungskraft', 'Schöpfung', 'Wille', 'Klarheit'],
  'Die Hohepriesterin': ['Intuition', 'Stille', 'inneres Wissen', 'Weisheit', 'Grenzen'],
  'Die Herrscherin': ['Fülle', 'Wachstum', 'Sinnlichkeit', 'Schöpfung', 'Natur'],
  'Der Herrscher': ['Struktur', 'Stabilität', 'Ordnung', 'Verantwortung', 'Klarheit'],
  'Der Hierophant': ['Tradition', 'Gemeinschaft', 'Wissen', 'Führung', 'Überlieferung'],
  'Die Liebenden': ['Begegnung', 'Wahl', 'Verbindung', 'Harmonie', 'Aufrichtigkeit'],
  'Der Wagen': ['Entschlossenheit', 'Richtung', 'Fokus', 'Bewegung', 'Kontrolle'],
  'Die Stärke': ['Mut', 'Geduld', 'Gelassenheit', 'sanfte Kraft', 'Selbstvertrauen'],
  'Die Einsiedlerin': ['Rückzug', 'inneres Licht', 'Stille', 'Klärung', 'Einkehr'],
  'Das Rad': ['Wandel', 'Rhythmus', 'Zyklus', 'Perspektivwechsel', 'Fluss'],
  'Die Gerechtigkeit': ['Abwägen', 'Ehrlichkeit', 'Ausgleich', 'Entscheidung', 'Klarheit'],
  'Der Gehängte': ['Pause', 'Loslassen', 'neue Perspektive', 'Geduld', 'Innehalten'],
  'Die Wandlung': ['Transformation', 'Loslassen', 'Übergang', 'Erneuerung', 'Neubeginn'],
  'Die Mäßigung': ['Balance', 'Integration', 'Geduld', 'Fließen', 'Harmonie'],
  'Der Teufel': ['Erkenntnis', 'Bewusstsein', 'Befreiung', 'Bindung', 'Schatten'],
  'Der Turm': ['Umbruch', 'Ehrlichkeit', 'Befreiung', 'Loslassen', 'Wandel'],
  'Der Stern': ['Zuversicht', 'Hoffnung', 'Erneuerung', 'Klarheit', 'Leichtigkeit'],
  'Der Mond': ['Intuition', 'Tiefe', 'Ahnung', 'Unsicherheit', 'innere Welt'],
  'Die Sonne': ['Freude', 'Wärme', 'Klarheit', 'Sichtbarkeit', 'Vitalität'],
  'Das Gericht': ['Erneuerung', 'Erwachen', 'Selbstreflexion', 'Befreiung', 'Ruf'],
  'Die Welt': ['Vollendung', 'Ankommen', 'Ganzheit', 'Erfüllung', 'Abschluss'],
};

String _t(TarotCard card, int index) {
  final themes = _cardThemes[card.name];
  if (themes == null || themes.isEmpty) return card.name;
  return themes[index % themes.length];
}

class TarotPage extends StatelessWidget {
  const TarotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dailyCard = generateDailyTarotCard();
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding.vertical;
    final contentTopSpacing = (screenHeight * 0.18)
        .clamp(96.0, 180.0)
        .toDouble();

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/tarotcat.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x3307040D),
                  Color(0x220C0814),
                  Color(0xAA100A1A),
                  Color(0xE00B0612),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - safePadding - 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x33FFFFFF),
                          foregroundColor: const Color(0xFFF3E6BD),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🃏 ${l10n.tarotTitle}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: const Color(0xFFFFF2CC),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tarotSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFD8C8F7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: contentTopSpacing),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0x3E120F1F),
                        border: Border.all(
                          color: const Color(0x88DAB86E),
                          width: 1.1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x54120F1E),
                            blurRadius: 26,
                            offset: Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Color(0x1F7A4DCC),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        l10n.tarotTeaserText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFF1E9FF),
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              _showDailyTarotDialog(context, dailyCard),
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: const Color(0x32150F24),
                                border: Border.all(
                                  color: const Color(0x88DAB86E),
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40100D1B),
                                    blurRadius: 18,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '🃏 ${l10n.tarotDailyCard}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: const Color(0xFFFFE4A6),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  _TarotCardImagePreview(card: dailyCard),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${dailyCard.symbol} ${dailyCard.name}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: const Color(0xFFFFE9B0),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    dailyCard.meaning,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: const Color(0xFFF1E9FF),
                                          height: 1.45,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0x24130F1F),
                                      border: Border.all(
                                        color: const Color(0x44D0B16F),
                                      ),
                                    ),
                                    child: Text(
                                      dailyCard.catMessage,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: const Color(0xE8F1E9FF),
                                            height: 1.45,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 46,
                                    child: OutlinedButton(
                                      onPressed: () => _showDailyTarotDialog(
                                        context,
                                        dailyCard,
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFFEADBAF,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0x66D5B46B),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(l10n.tarotOpenDailyCard),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final card = demoTarotCards[
                                Random().nextInt(demoTarotCards.length)];
                            _showDrawnCardDialog(context, card);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0x2B161126),
                              border: Border.all(
                                color: const Color(0x66D5B46B),
                                width: 0.9,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40100D1B),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Color(0x182F1F4F),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              leading: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0x33432D63),
                                  border: Border.all(
                                    color: const Color(0x73E1C27A),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.shuffle_rounded,
                                  size: 20,
                                  color: Color(0xFFFFD98A),
                                ),
                              ),
                              title: Text(
                                l10n.tarotDrawCard,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: const Color(0xFFF4E9FF),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFFE5D0A0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TarotOptionTile(
                      title: l10n.tarotThreeCardSpread,
                      onTap: () => _showThreeCardSpreadDialog(context),
                    ),
                    const SizedBox(height: 12),
                    _TarotOptionTile(
                      title: '❤️ ${l10n.tarotLoveRelationships}',
                      onTap: () => _showLoveSpreadDialog(context),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0x2D160F25),
                        border: Border.all(
                          color: const Color(0x88DABA72),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        l10n.tarotComingSoon,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFFFFECB8),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showDailyTarotDialog(BuildContext context, TarotCard card) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: const Color(0xFF140F1F),
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x88DAB86E), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40100D1B),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🃏 ${l10n.tarotDailyCard}',
                  style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _TarotCardImagePreview(card: card),
                const SizedBox(height: 12),
                Text(
                  card.name,
                  style: Theme.of(dialogContext).textTheme.titleMedium
                      ?.copyWith(
                        color: const Color(0xFFF4E9FF),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.tarotMajorArcana,
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD8C8F7),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.symbol,
                  style: Theme.of(dialogContext).textTheme.headlineSmall
                      ?.copyWith(color: const Color(0xFFFFD98A)),
                ),
                const SizedBox(height: 12),
                Text(
                  card.meaning,
                  style: Theme.of(dialogContext).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFF1E9FF),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0x24130F1F),
                    border: Border.all(color: const Color(0x44D0B16F)),
                  ),
                  child: Text(
                    card.catMessage,
                    style: Theme.of(dialogContext).textTheme.bodyMedium
                        ?.copyWith(
                          color: const Color(0xE8F1E9FF),
                          height: 1.45,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.tarotDailyRenewHint,
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD8C8F7),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.tarotClose),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _showDrawnCardDialog(BuildContext context, TarotCard card) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: const Color(0xFF140F1F),
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x88DAB86E), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40100D1B),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🃏 ${l10n.tarotDrawnCardTitle}',
                  style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _TarotCardImagePreview(card: card),
                const SizedBox(height: 12),
                Text(
                  card.name,
                  style: Theme.of(dialogContext).textTheme.titleMedium
                      ?.copyWith(
                        color: const Color(0xFFF4E9FF),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.tarotMajorArcana,
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD8C8F7),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.symbol,
                  style: Theme.of(dialogContext).textTheme.headlineSmall
                      ?.copyWith(color: const Color(0xFFFFD98A)),
                ),
                const SizedBox(height: 12),
                Text(
                  card.meaning,
                  style: Theme.of(dialogContext).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFF1E9FF),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0x24130F1F),
                    border: Border.all(color: const Color(0x44D0B16F)),
                  ),
                  child: Text(
                    card.catMessage,
                    style: Theme.of(dialogContext).textTheme.bodyMedium
                        ?.copyWith(
                          color: const Color(0xE8F1E9FF),
                          height: 1.45,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.tarotClose),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _composeThreeCardReading(
  TarotCard past,
  TarotCard present,
  TarotCard impulse,
) {
  final pastIdx = demoTarotCards.indexOf(past);
  final presentIdx = demoTarotCards.indexOf(present);
  final impulseIdx = demoTarotCards.indexOf(impulse);
  final variant = (pastIdx + presentIdx * 7 + impulseIdx * 13).abs() % 4;

  switch (variant) {
    case 0:
      return '${past.name} ist nicht einfach eine Karte der Vergangenheit – sie ist ein Resonanzraum. '
          '${_t(past, 0)} und ${_t(past, 1)} wirken noch nach, auch wenn der Moment selbst vergangen ist. '
          '${present.name} antwortet auf diesen Nachhall mit ${_t(present, 0)} – einer Qualität, die im Jetzt '
          'besonders sichtbar wird, und die sich, wenn man genau hinsieht, auch als ${_t(present, 1)} zeigen kann. '
          'Was zwischen diesen beiden Karten liegt, ist kein Bruch, sondern ein fließender Übergang: '
          '${past.name} hat etwas in Bewegung gesetzt, das ${present.name} weiterführt. '
          '${impulse.name} tritt als dritte Stimme hinzu und bringt ${_t(impulse, 0)} ins Gespräch – '
          'keinen Befehl, sondern ein sanftes Signal. '
          'Zusammen erzählen diese drei Karten von einer inneren Bewegung, die von ${_t(past, 0)} über '
          '${_t(present, 0)} hin zu ${_t(impulse, 0)} führt. '
          'Das ist keine Vorhersage. '
          'Es ist eine Einladung, genauer hinzuschauen, was gerade in dir in Bewegung ist.';
    case 1:
      return 'Drei Karten, drei Stimmen – und alle sprechen gleichzeitig. '
          '${past.name} trägt ${_t(past, 0)} in sich: etwas, das nachwirkt, '
          'vielleicht ohne dass man es bewusst benennen kann. '
          'Dass ${present.name} jetzt erscheint, ist kein Zufall – ${_t(present, 0)} und ${_t(present, 1)} '
          'sind genau die Qualitäten, die gebraucht werden, um das zu verarbeiten, was ${past.name} hinterlassen hat. '
          '${impulse.name} schließt den Bogen nicht, sondern öffnet ihn: ${_t(impulse, 0)} deutet auf eine '
          'Möglichkeit hin, die noch nicht vollständig ergriffen wurde. '
          'Auffällig ist, wie gut diese drei Karten aufeinander hören – '
          'sie widersprechen sich nicht, sie ergänzen sich. '
          'Das ist eine Einladung, die Verbindung zwischen ${_t(past, 0)}, ${_t(present, 0)} und '
          '${_t(impulse, 0)} selbst weiterzudenken und dabei ehrlich zu bleiben.';
    case 2:
      return '${past.name} bringt ${_t(past, 0)} mit – eine Energie, die nicht einfach verschwindet, '
          'weil ein Tag vergeht. '
          'Sie hat den Boden geformt, auf dem ${present.name} jetzt steht. '
          'Und ${present.name} steht tatsächlich: ${_t(present, 0)} ist die Qualität des gegenwärtigen Moments, '
          'und darin steckt auch ${_t(present, 1)}, wenn man bereit ist, genauer hinzuschauen. '
          'Das Verhältnis zwischen diesen beiden Karten ist eines der Kontinuität – '
          'nicht der Wiederholung, sondern der Weiterentwicklung. '
          '${impulse.name} erscheint als Antwort auf beide – auf das, was war, und auf das, was jetzt ist. '
          '${_t(impulse, 0)} ist der Ton, den diese Karte anschlägt: '
          'nicht als Forderung, sondern als stille Möglichkeit. '
          'Vielleicht lohnt sich die Frage: Wie viel von ${_t(past, 0)} ist noch spürbar, '
          'und wie viel Raum lässt du ${_t(impulse, 0)} bereits?';
    default:
      return 'Madame Gatto legt die Karten und schweigt einen Moment. '
          '${past.name} – ${_t(past, 0)} und ${_t(past, 1)}, die noch nachwirken. '
          '${present.name} – ${_t(present, 0)} und ${_t(present, 1)}, die jetzt gefragt sind. '
          '${impulse.name} – ${_t(impulse, 0)}, das sich ankündigt. '
          'Sie murmelt: Selten liegen drei Karten so kohärent beieinander. '
          'Was ${past.name} hinterlassen hat, ist nicht verloren – es ist in ${present.name} übergegangen, '
          'und ${impulse.name} zeigt, wohin dieser Übergang führen kann. '
          'Das ist kein Versprechen und keine Warnung. '
          'Es ist das, was die Karten flüstern, wenn man lange genug stillhält. '
          'Madame Gatto legt die Hand auf den Tisch und nickt: Diese Legung lohnt sich, mehrmals zu lesen.';
  }
}

Future<void> _showThreeCardSpreadDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final shuffled = List.of(demoTarotCards)..shuffle(Random());
  final cards = shuffled.take(3).toList();
  final positions = [l10n.tarotPast, l10n.tarotPresent, l10n.tarotImpulse];

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (_, t, child) => Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.88 + 0.12 * t, child: child),
        ),
        child: Dialog(
          backgroundColor: const Color(0xFF140F1F),
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x88DAB86E), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40100D1B),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🃏 ${l10n.tarotThreeCardSpread}',
                    style: Theme.of(dialogContext).textTheme.titleLarge
                        ?.copyWith(
                          color: const Color(0xFFFFE9B0),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final w = constraints.maxWidth;
                      if (w >= 360) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0; i < 3; i++) ...[
                                if (i > 0) const SizedBox(width: 10),
                                Expanded(
                                  child: _SpreadCardTile(
                                    position: positions[i],
                                    card: cards[i],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      } else {
                        final cardWidth = (w * 0.78).clamp(160.0, 260.0);
                        return SizedBox(
                          height: 420,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (int i = 0; i < 3; i++) ...[
                                  if (i > 0) const SizedBox(width: 10),
                                  SizedBox(
                                    width: cardWidth,
                                    child: _SpreadCardTile(
                                      position: positions[i],
                                      card: cards[i],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0x44DAB86E), thickness: 0.8),
                  const SizedBox(height: 14),
                  Text(
                    '✨ ${l10n.tarotOverallReading}',
                    style: Theme.of(dialogContext).textTheme.titleSmall
                        ?.copyWith(
                          color: const Color(0xFFFFE9B0),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0x2A130F1F),
                      border: Border.all(color: const Color(0x66DAB86E)),
                    ),
                    child: Text(
                      _composeThreeCardReading(cards[0], cards[1], cards[2]),
                      style: Theme.of(dialogContext).textTheme.bodyMedium
                          ?.copyWith(
                            color: const Color(0xFFF1E9FF),
                            height: 1.55,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(l10n.tarotClose),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

String _composeLoveReading(
  TarotCard self,
  TarotCard connection,
  TarotCard impulse,
) {
  final selfIdx = demoTarotCards.indexOf(self);
  final connectionIdx = demoTarotCards.indexOf(connection);
  final impulseIdx = demoTarotCards.indexOf(impulse);
  final variant = (selfIdx * 3 + connectionIdx * 11 + impulseIdx * 7).abs() % 4;

  switch (variant) {
    case 0:
      return '${self.name} beschreibt, wer du in diesem Moment in Beziehungen bist – '
          'mit ${_t(self, 0)} als der Energie, die du in Begegnungen mitbringst. '
          'Das ist weder Urteil noch Bestätigung; es ist einfach, was gerade da ist. '
          '${connection.name} zeigt, welche Qualität in einer Verbindung lebendig sein kann: '
          '${_t(connection, 0)} und ${_t(connection, 1)} – beides Aspekte, die echte Nähe erst möglich machen. '
          'Interessant ist, wie ${self.name} und ${connection.name} miteinander in Beziehung stehen: '
          '${_t(self, 0)} muss nicht identisch mit ${_t(connection, 0)} sein, um eine Brücke zu bilden. '
          '${impulse.name} tritt als dritte Stimme hinzu und bringt ${_t(impulse, 0)} ins Gespräch – '
          'eine Einladung, die weder Ungeduld noch Angst verlangt, sondern Aufmerksamkeit. '
          'Echte Verbindung entsteht nicht dadurch, dass man die perfekte Begegnung findet, '
          'sondern dadurch, dass man selbst anwesend und aufrichtig ist. '
          'Diese drei Karten erzählen genau davon.';
    case 1:
      return 'Drei Karten, die gemeinsam von Verbindung sprechen – und jede auf ihre eigene Art. '
          '${self.name} bringt ${_t(self, 0)} mit: das ist deine Haltung, dein Ausgangspunkt, '
          'das, was du in Begegnungen verkörperst, bewusst oder unbewusst. '
          '${connection.name} spricht von ${_t(connection, 0)} und ${_t(connection, 1)} – nicht als Versprechen, '
          'sondern als Qualität, die möglich ist, wenn beide Seiten bereit sind, hinzuhören. '
          'Dass ${impulse.name} hier erscheint, ist bedeutsam: ${_t(impulse, 0)} ist der Impuls, '
          'der gerade am deutlichsten klingt. '
          'Madame Gatto beobachtet diese Konstellation und sagt ruhig: Wenn ${_t(self, 0)} auf '
          '${_t(connection, 0)} trifft, entsteht etwas – keine Garantie, aber eine echte Möglichkeit. '
          'Was ${impulse.name} hinzufügt, ist ${_t(impulse, 0)}: die Erinnerung daran, '
          'dass Verbindung Zeit und inneren Raum braucht. '
          'Diese Legung erzählt weniger von dem, was fehlt, '
          'als von dem, was bereits da ist und gesehen werden möchte.';
    case 2:
      return '${self.name} ist der Ausgangspunkt dieser Legung: ${_t(self, 0)} beschreibt '
          'deine innere Haltung gegenüber Nähe, Verbindung und dem Wahrnehmen anderer. '
          '${connection.name} antwortet darauf mit ${_t(connection, 0)} – und wer die Karte länger betrachtet, '
          'entdeckt auch ${_t(connection, 1)} darin. '
          'Das Gespräch zwischen ${self.name} und ${connection.name} ist eigentlich das Herzstück dieser Legung: '
          'nicht jede Karte einzeln, sondern das, was zwischen ihnen entsteht. '
          '${impulse.name} tritt als Impuls hinzu: ${_t(impulse, 0)} erscheint als das, '
          'was vielleicht noch mehr Raum verdient – in dir selbst und im Miteinander. '
          'Echte Nähe braucht keine Vollständigkeit. '
          'Sie braucht Aufrichtigkeit und die Bereitschaft, gesehen zu werden. '
          'Diese drei Karten beschreiben den Weg von ${_t(self, 0)} über ${_t(connection, 0)} '
          'hin zu ${_t(impulse, 0)} – und dieser Weg beginnt innen.';
    default:
      return 'Madame Gatto legt die Karten für Liebe und Verbindung – und nimmt sich bewusst Zeit. '
          '${self.name} erscheint als erstes: ${_t(self, 0)}, das zeigt, wer du in Begegnungen bist. '
          '${connection.name} folgt: ${_t(connection, 0)} und ${_t(connection, 1)} – '
          'das Feld, in dem echte Verbindung entstehen kann, wenn beide Seiten offen sind. '
          'Und schließlich ${impulse.name}: ${_t(impulse, 0)}, '
          'der leise, aber bestimmte Impuls, der gerade klingt. '
          'Madame Gatto bemerkt: Diese drei Karten harmonieren auf ungewöhnliche Weise miteinander. '
          '${self.name} legt etwas offen, was ${connection.name} aufnimmt – '
          'und ${impulse.name} erinnert daran, was dabei nicht verloren gehen sollte. '
          '${_t(impulse, 0)} ist kein Hindernis. '
          'Es ist eine Einladung. '
          'Verbindung, die auch die eigene Stimme einschließt, ist tiefer und echter. '
          'Diese Legung zeigt einen Weg dorthin – weder kurz noch einfach, aber aufrichtig.';
  }
}

Future<void> _showLoveSpreadDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final shuffled = List.of(demoTarotCards)..shuffle(Random());
  final cards = shuffled.take(3).toList();
  final positions = [l10n.tarotSelf, l10n.tarotConnection, l10n.tarotImpulse];

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (_, t, child) => Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.88 + 0.12 * t, child: child),
        ),
        child: Dialog(
          backgroundColor: const Color(0xFF140F1F),
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x88DAB86E), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40100D1B),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '❤️ ${l10n.tarotLoveRelationships}',
                    style: Theme.of(dialogContext).textTheme.titleLarge
                        ?.copyWith(
                          color: const Color(0xFFFFE9B0),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final w = constraints.maxWidth;
                      if (w >= 360) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0; i < 3; i++) ...[
                                if (i > 0) const SizedBox(width: 10),
                                Expanded(
                                  child: _SpreadCardTile(
                                    position: positions[i],
                                    card: cards[i],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      } else {
                        final cardWidth = (w * 0.78).clamp(160.0, 260.0);
                        return SizedBox(
                          height: 420,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (int i = 0; i < 3; i++) ...[
                                  if (i > 0) const SizedBox(width: 10),
                                  SizedBox(
                                    width: cardWidth,
                                    child: _SpreadCardTile(
                                      position: positions[i],
                                      card: cards[i],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0x44DAB86E), thickness: 0.8),
                  const SizedBox(height: 14),
                  Text(
                    '❤️ ${l10n.tarotLoveReading}',
                    style: Theme.of(dialogContext).textTheme.titleSmall
                        ?.copyWith(
                          color: const Color(0xFFFFE9B0),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0x2A130F1F),
                      border: Border.all(color: const Color(0x66DAB86E)),
                    ),
                    child: Text(
                      _composeLoveReading(cards[0], cards[1], cards[2]),
                      style: Theme.of(dialogContext).textTheme.bodyMedium
                          ?.copyWith(
                            color: const Color(0xFFF1E9FF),
                            height: 1.55,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(l10n.tarotClose),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _SpreadCardTile extends StatelessWidget {
  const _SpreadCardTile({required this.position, required this.card});

  final String position;
  final TarotCard card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0x2A150F24),
        border: Border.all(color: const Color(0x77DAB86E), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3A100D1B),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
              color: Color(0x44321A4A),
            ),
            child: Text(
              position,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFFD8C8F7),
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _TarotCardImagePreview(card: card, height: 160),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFFF4E9FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.tarotMajorArcana,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFD8C8F7),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  card.meaning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD4C8F0),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarotOptionTile extends StatelessWidget {
  const _TarotOptionTile({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x2B161126),
        border: Border.all(color: const Color(0x66D5B46B), width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40100D1B),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x182F1F4F),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x33432D63),
            border: Border.all(color: const Color(0x73E1C27A)),
          ),
          child: const Icon(
            Icons.style_rounded,
            size: 20,
            color: Color(0xFFFFD98A),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFFF4E9FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFFE5D0A0),
        ),
      ),
    );

    if (onTap == null) return tile;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: tile,
        ),
      ),
    );
  }
}

class _TarotCardImagePreview extends StatelessWidget {
  const _TarotCardImagePreview({required this.card, this.height = 360});

  final TarotCard card;
  final double height;

  @override
  Widget build(BuildContext context) {
    final assetPath = card.imageAsset;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x402B1A46), Color(0x3224133A)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x66D5B46B), width: 0.9),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A7A4DCC),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: assetPath == null
              ? _TarotImageFallback(symbol: card.symbol)
              : Image.asset(
                  assetPath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return _TarotImageFallback(symbol: card.symbol);
                  },
                ),
        ),
      ),
    );
  }
}

class _TarotImageFallback extends StatelessWidget {
  const _TarotImageFallback({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x38211436), Color(0x5010091E)],
        ),
      ),
      child: Center(
        child: Text(
          '$symbol  🃏',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFFFFE9B0),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
