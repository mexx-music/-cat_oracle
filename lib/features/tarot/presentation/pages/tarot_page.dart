import 'package:flutter/material.dart';

import 'package:cat_oracle/gen_l10n/app_localizations.dart';

import '../../data/demo_tarot_cards.dart';
import '../../logic/daily_tarot_card_generator.dart';
import '../../models/tarot_card.dart';
import '../widgets/tarot_draw_overlay.dart';

// Alltagssprachliche Bedeutung jeder Karte für eine Situation im Leben.
// Jeder Eintrag ist ein eigenständiger, einfacher Satz, der in jeder Position
// (Vergangenheit oder Gegenwart) verständlich bleibt.
const Map<String, String> _cardEveryday = {
  'Die Katze':
      'Vielleicht hast du Lust, etwas Neues auszuprobieren, ohne lange zu grübeln, ob es perfekt klappt.',
  'Der Magier':
      'Vielleicht spürst du, dass du eine Sache wirklich angehen könntest, wenn du dich darauf konzentrierst.',
  'Die Hohepriesterin':
      'Vielleicht weißt du innerlich schon, was stimmt, auch wenn du es noch nicht laut ausgesprochen hast.',
  'Die Herrscherin':
      'Vielleicht möchtest du dich um etwas kümmern, das dir am Herzen liegt, und es in Ruhe wachsen lassen.',
  'Der Herrscher':
      'Vielleicht suchst du gerade nach etwas Halt und einer klaren Struktur in einer Sache.',
  'Der Hierophant':
      'Vielleicht denkst du über etwas nach, das du so gelernt hast, und fragst dich, ob es noch zu dir passt.',
  'Die Liebenden':
      'Vielleicht steht eine Entscheidung an, bei der dein Herz mitreden möchte.',
  'Der Wagen':
      'Vielleicht möchtest du in einer Sache endlich vorankommen und ein klares Ziel verfolgen.',
  'Die Stärke':
      'Vielleicht brauchst du gerade etwas Geduld mit dir selbst und mit einer Situation.',
  'Die Einsiedlerin':
      'Vielleicht brauchst du einen Moment für dich, um in Ruhe nachzudenken.',
  'Das Rad':
      'Vielleicht merkst du, dass sich gerade etwas verändert, auch wenn du es nicht ganz steuern kannst.',
  'Die Gerechtigkeit':
      'Vielleicht hast du in letzter Zeit versucht, eine Situation möglichst fair zu beurteilen, und lange nach der richtigen Entscheidung gesucht.',
  'Der Gehängte':
      'Vielleicht steckst du in einer Sache fest und kommst mit Anstrengung nicht recht weiter.',
  'Die Wandlung':
      'Vielleicht geht gerade etwas zu Ende, und du spürst, dass etwas Neues Platz braucht.',
  'Die Mäßigung':
      'Vielleicht versuchst du gerade, zwei Dinge unter einen Hut zu bringen und ein gutes Maß zu finden.',
  'Der Teufel':
      'Vielleicht gibt es eine Gewohnheit oder einen Gedanken, der dich mehr festhält, als dir guttut.',
  'Der Turm':
      'Vielleicht ist gerade etwas ins Wanken geraten, mit dem du fest gerechnet hattest.',
  'Der Stern':
      'Vielleicht wünschst du dir gerade etwas Zuversicht und das Gefühl, dass es weitergeht.',
  'Der Mond':
      'Vielleicht ist gerade nicht alles klar, und du bist dir bei einer Sache noch unsicher.',
  'Die Sonne':
      'Vielleicht läuft gerade etwas gut, oder du spürst wieder mehr Freude an einer Sache.',
  'Das Gericht':
      'Vielleicht schaust du auf etwas zurück und überlegst, was du daraus mitnimmst.',
  'Die Welt':
      'Vielleicht hast du etwas zu einem guten Abschluss gebracht oder bist an einem Ziel angekommen.',
};

// Sanfter Vorschlag für den nächsten Schritt – kein Befehl, keine Vorhersage.
const Map<String, String> _cardImpulse = {
  'Die Katze':
      'Manchmal hilft es, einfach den ersten Schritt zu machen und unterwegs zu schauen, wie es sich anfühlt.',
  'Der Magier':
      'Es kann sein, dass du schon alles hast, was du brauchst – du musst es nur bündeln und anfangen.',
  'Die Hohepriesterin':
      'Es kann sich lohnen, kurz still zu werden und auf dein Bauchgefühl zu hören, statt sofort zu handeln.',
  'Die Herrscherin':
      'Es kann guttun, gut für dich zu sorgen und Dingen Zeit zu geben, statt sie zu erzwingen.',
  'Der Herrscher':
      'Es kann helfen, dir ein paar einfache Regeln zu setzen, an denen du dich festhalten kannst.',
  'Der Hierophant':
      'Es kann sich lohnen, Ratschläge anzuhören, am Ende aber selbst zu entscheiden, was für dich stimmt.',
  'Die Liebenden':
      'Es kann helfen, dich für das zu entscheiden, was sich für dich wirklich stimmig anfühlt.',
  'Der Wagen':
      'Es kann helfen, dich auf eine Richtung festzulegen, statt dich von zu vielen Möglichkeiten ablenken zu lassen.',
  'Die Stärke':
      'Es kann sein, dass Ruhe und Gelassenheit dir hier mehr weiterhelfen als Druck oder Härte.',
  'Die Einsiedlerin':
      'Es kann guttun, dir bewusst etwas Zeit allein zu nehmen, bevor du eine Entscheidung triffst.',
  'Das Rad':
      'Es kann leichter sein, mit einer Veränderung mitzugehen, als sich dagegen zu stemmen.',
  'Die Gerechtigkeit':
      'Es kann helfen, ehrlich zu dir selbst zu sein und zu schauen, was wirklich fair ist – auch dir gegenüber.',
  'Der Gehängte':
      'Es kann helfen, kurz innezuhalten und die Sache einmal aus einem anderen Blickwinkel anzusehen.',
  'Die Wandlung':
      'Es kann guttun, etwas loszulassen, das nicht mehr passt, um Raum für Neues zu schaffen.',
  'Die Mäßigung':
      'Es kann helfen, ruhig zu bleiben und nach der gesunden Mitte zu suchen, statt von einem Extrem ins andere zu fallen.',
  'Der Teufel':
      'Es kann befreien, ehrlich hinzuschauen, was dich gerade bindet, und zu prüfen, ob du das so willst.',
  'Der Turm':
      'Es kann sein, dass nach dem ersten Schreck Platz für etwas Ehrlicheres entsteht.',
  'Der Stern':
      'Der Stern erinnert daran, dass nicht jede Antwort sofort gefunden werden muss – manchmal reicht es, dem eigenen Weg etwas Zeit zu geben.',
  'Der Mond':
      'Es kann helfen, nicht alles sofort verstehen zu wollen und auch mal mit Unsicherheit auszuhalten.',
  'Die Sonne':
      'Es kann guttun, dich über das zu freuen, was schön ist, ohne es kleinzureden.',
  'Das Gericht':
      'Es kann helfen, ehrlich auf das Vergangene zu blicken und dann bewusst nach vorn zu schauen.',
  'Die Welt':
      'Es kann guttun, kurz innezuhalten und anzuerkennen, was du schon geschafft hast.',
};

String _everyday(TarotCard card) => _cardEveryday[card.name] ?? card.meaning;
String _impulse(TarotCard card) => _cardImpulse[card.name] ?? card.meaning;

// ---------------------------------------------------------------------------
// Kontext-Thema
// ---------------------------------------------------------------------------

class _TarotTopic {
  const _TarotTopic({
    required this.label,
    required this.name,
    required this.focus,
  });

  final String label; // mit Emoji, für den Button
  final String name;  // ohne Emoji, für den Deutungstext
  final String focus; // Fokus-Satz für Madame Gatto
}

const List<_TarotTopic> _topics = [
  _TarotTopic(
    label: '❤️ Liebe & Beziehung',
    name: 'Liebe & Beziehung',
    focus: 'Nähe, Vertrauen und gegenseitiges Verstehen',
  ),
  _TarotTopic(
    label: '💼 Beruf & Geld',
    name: 'Beruf & Geld',
    focus: 'Entscheidungen, Verantwortung und praktische Schritte',
  ),
  _TarotTopic(
    label: '🏠 Familie & Zuhause',
    name: 'Familie & Zuhause',
    focus: 'Ruhe, Grenzen und Zusammenhalt',
  ),
  _TarotTopic(
    label: '🔄 Veränderung & Entscheidung',
    name: 'Veränderung & Entscheidung',
    focus: 'Klarheit, Loslassen und den nächsten Schritt',
  ),
  _TarotTopic(
    label: '🌙 Allgemeine Reflexion',
    name: 'Allgemeine Reflexion',
    focus: 'innere Orientierung, Ruhe und Selbstvertrauen',
  ),
  _TarotTopic(
    label: '✍️ Etwas anderes',
    name: 'Etwas anderes',
    focus: 'offen betrachten, ohne vorschnell zu urteilen',
  ),
];

Future<_TarotTopic?> _showContextDialog(BuildContext context) {
  return showDialog<_TarotTopic>(
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Was beschäftigt dich gerade?',
                  style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Wähle ein Thema – Madame Gatto richtet ihren Blick dann darauf.',
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD8C8F7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                for (final t in _topics) ...[
                  _TopicTile(
                    topic: t,
                    onTap: () => Navigator.of(dialogContext).pop(t),
                  ),
                  const SizedBox(height: 8),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Abbrechen'),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x55DAB86E),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/tarot/catjoker.png',
                              width: 64,
                              height: 64,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.style_rounded,
                                size: 48,
                                color: Color(0xFFDAB86E),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.tarotTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: const Color(0xFFFFF2CC),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                        ),
                      ],
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
                          onTap: () async {
                            final card = await showTarotDrawOverlay(context);
                            if (card == null || !context.mounted) return;
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
                      title: 'Fünf-Karten-Legung',
                      subtitle: 'Madame Gattos größerer Rat',
                      icon: Icons.auto_awesome_rounded,
                      onTap: () => _showFiveCardSpreadDialog(context),
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
  TarotCard impulse, {
  _TarotTopic? topic,
}) {
  final prefix = topic != null
      ? 'Du hast diese Legung mit dem Thema ${topic.name} geöffnet. '
        'Deshalb schaut Madame Gatto besonders auf ${topic.focus}.\n\n'
      : '';
  final pastIdx = demoTarotCards.indexOf(past);
  final presentIdx = demoTarotCards.indexOf(present);
  final impulseIdx = demoTarotCards.indexOf(impulse);
  final variant = (pastIdx + presentIdx * 7 + impulseIdx * 13).abs() % 4;

  switch (variant) {
    case 0:
      return '$prefix${past.name} steht für die Vergangenheit. ${_everyday(past)} '
          'Das spürst du heute vielleicht noch. '
          'In der Gegenwart zeigt sich ${present.name}. ${_everyday(present)} '
          'Vieles davon hat seinen Ursprung in dem, was vorher war. '
          'Als Anstoß für den nächsten Schritt kommt ${impulse.name} dazu. ${_impulse(impulse)}\n\n'
          'Kurz gesagt:\n'
          'Du hast vermutlich schon eine Weile über etwas nachgedacht. '
          'Die Karten schlagen vor, etwas weniger zu kontrollieren und etwas mehr auf den nächsten Schritt zu vertrauen.';
    case 1:
      return '${prefix}Beginnen wir bei ${past.name} in der Vergangenheit. ${_everyday(past)} '
          'Das hat den Boden für das bereitet, was jetzt da ist. '
          'Heute steht ${present.name} im Mittelpunkt. ${_everyday(present)} '
          'So erklärt sich auch, warum dich gerade dieser eine Gedanke beschäftigt. '
          '${impulse.name} zeigt, was dir als nächstes helfen könnte. ${_impulse(impulse)}\n\n'
          'Kurz gesagt:\n'
          'Was früher passiert ist, wirkt noch in deine Gegenwart hinein. '
          'Die drei Karten erinnern dich daran, dass du den nächsten Schritt selbst in der Hand hast – ohne dich zu hetzen.';
    case 2:
      return '$prefix${past.name} erzählt von dem, was hinter dir liegt. ${_everyday(past)} '
          'Diese Erfahrung trägst du noch mit dir. '
          '${present.name} beschreibt, wo du gerade stehst. ${_everyday(present)} '
          'Das eine geht ziemlich nahtlos in das andere über. '
          'Und ${impulse.name} macht einen Vorschlag für den weiteren Weg. ${_impulse(impulse)}\n\n'
          'Kurz gesagt:\n'
          'Die drei Karten erzählen zusammen eine kleine Geschichte: woher du kommst, wo du stehst und was dir guttun könnte. '
          'Vielleicht darfst du einfach etwas freundlicher mit dir sein.';
    default:
      return '${prefix}Madame Gatto legt drei Karten und schaut in Ruhe. '
          '${past.name} steht für die Vergangenheit. ${_everyday(past)} '
          '${present.name} zeigt die Gegenwart. ${_everyday(present)} '
          'Und ${impulse.name} deutet an, was als nächstes dran sein könnte. ${_impulse(impulse)}\n\n'
          'Kurz gesagt:\n'
          'Madame Gatto würde vermutlich sagen: Nicht jede Tür muss heute geöffnet werden. '
          'Manche zeigen erst morgen, wohin sie führen.';
  }
}

Future<void> _showThreeCardSpreadDialog(BuildContext context) async {
  final topic = await _showContextDialog(context);
  if (topic == null || !context.mounted) return;
  final l10n = AppLocalizations.of(context)!;
  final cards = await showTarotMultiDrawOverlay(
    context,
    count: 3,
    positionLabels: [l10n.tarotPast, l10n.tarotPresent, l10n.tarotImpulse],
  );
  if (cards == null || cards.length < 3 || !context.mounted) return;
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
                      _composeThreeCardReading(
                        cards[0],
                        cards[1],
                        cards[2],
                        topic: topic,
                      ),
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


// ---------------------------------------------------------------------------
// Fünf-Karten-Legung
// ---------------------------------------------------------------------------

String _composeFiveCardReading(
  TarotCard situation,
  TarotCard challenge,
  TarotCard help,
  TarotCard release,
  TarotCard nextStep, {
  _TarotTopic? topic,
}) {
  final prefix = topic != null
      ? 'Du hast diese Legung mit dem Thema ${topic.name} geöffnet. '
        'Deshalb schaut Madame Gatto besonders auf ${topic.focus}.\n\n'
      : '';
  final variant = (demoTarotCards.indexOf(situation) * 2 +
              demoTarotCards.indexOf(challenge) * 5 +
              demoTarotCards.indexOf(help) * 11 +
              demoTarotCards.indexOf(release) * 7 +
              demoTarotCards.indexOf(nextStep) * 3)
          .abs() %
      4;

  switch (variant) {
    case 0:
      return '$prefix${situation.name} beschreibt, womit du es gerade zu tun hast. ${_everyday(situation)} '
          '${challenge.name} zeigt, was dabei erschwerend dazukommt. ${_everyday(challenge)} '
          'Vielleicht erklärt das, warum die Sache sich etwas zäher anfühlt als erwartet. '
          '${help.name} gibt dir etwas an die Hand, das wirklich nützen könnte. ${_impulse(help)} '
          '${release.name} erinnert dich daran, was du gerade nicht mehr brauchst. ${_everyday(release)} '
          'Und ${nextStep.name} deutet an, was als nächstes sinnvoll sein könnte. ${_everyday(nextStep)}\n\n'
          'Kurz gesagt:\n'
          'Fünf Karten, fünf unterschiedliche Blickwinkel – alle auf dich. '
          'Die Karten schlagen vor, bei dem anzufangen, was sich am leichtesten anfühlt.';
    case 1:
      return '${prefix}Diese fünf Karten erzählen zusammen eine Geschichte. '
          '${situation.name} steht am Anfang: ${_everyday(situation)} '
          'Dann taucht ${challenge.name} auf: ${_everyday(challenge)} '
          'Was dabei helfen kann, zeigt ${help.name}. ${_impulse(help)} '
          '${release.name} erinnert daran, was du loslassen dürftest, damit Raum entsteht. ${_everyday(release)} '
          'Den Abschluss macht ${nextStep.name}: ${_everyday(nextStep)}\n\n'
          'Kurz gesagt:\n'
          'Die Karten zeigen nicht, was du tun musst – sie zeigen, was du vielleicht schon weißt. '
          'Vielleicht traust du dir einfach etwas mehr zu.';
    case 2:
      return '${prefix}Manchmal sagen fünf Karten mehr als eine. '
          '${situation.name} ist der Ausgangspunkt: ${_everyday(situation)} '
          'Die Schwierigkeit dabei trägt den Namen ${challenge.name}. ${_everyday(challenge)} '
          'Was helfen kann, zeigt ${help.name}: ${_impulse(help)} '
          '${release.name} schlägt vor, Platz zu schaffen: ${_everyday(release)} '
          'Für den nächsten Schritt schaut Madame Gatto auf ${nextStep.name}: ${_impulse(nextStep)}\n\n'
          'Kurz gesagt:\n'
          'Vielleicht reicht schon ein kleiner Schritt, um das Ganze etwas leichter zu machen. '
          'Die Karten legen einen konkreten Anfang nahe.';
    default:
      return '${prefix}Madame Gatto legt fünf Karten und schaut sie lange an. '
          '${situation.name}: ${_everyday(situation)} '
          '${challenge.name} kommt dazu: ${_everyday(challenge)} '
          '${help.name} zeigt, was die Sache erleichtern kann: ${_impulse(help)} '
          '${release.name} erinnert daran, was du nicht mehr brauchst: ${_everyday(release)} '
          '${nextStep.name} schließt die Legung ab: ${_impulse(nextStep)}\n\n'
          'Kurz gesagt:\n'
          'Madame Gatto würde vermutlich sagen: Fünf Karten sind fünf Möglichkeiten, nicht fünf Aufgaben. '
          'Fang mit der einfachsten an.';
  }
}

Future<void> _showFiveCardSpreadDialog(BuildContext context) async {
  final topic = await _showContextDialog(context);
  if (topic == null || !context.mounted) return;
  final l10n = AppLocalizations.of(context)!;
  const positions = [
    'Situation',
    'Herausforderung',
    'Was hilft',
    'Was loslassen',
    'Nächster Schritt',
  ];
  final cards = await showTarotMultiDrawOverlay(
    context,
    count: 5,
    positionLabels: positions,
  );
  if (cards == null || cards.length < 5 || !context.mounted) return;

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
            horizontal: 16,
            vertical: 20,
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
                    '🃏 Fünf-Karten-Legung',
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
                      if (w >= 560) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0; i < 5; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
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
                        final cardWidth = (w * 0.60).clamp(150.0, 210.0);
                        return SizedBox(
                          height: 330,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (int i = 0; i < 5; i++) ...[
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
                      _composeFiveCardReading(
                        cards[0],
                        cards[1],
                        cards[2],
                        cards[3],
                        cards[4],
                        topic: topic,
                      ),
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
          _TarotCardImagePreview(card: card, height: 200),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.topic, required this.onTap});

  final _TarotTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0x2A150F24),
            border: Border.all(color: const Color(0x66DAB86E)),
          ),
          child: Text(
            topic.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFF1E9FF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _TarotOptionTile extends StatelessWidget {
  const _TarotOptionTile({
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
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
          child: Icon(
            icon ?? Icons.style_rounded,
            size: 20,
            color: const Color(0xFFFFD98A),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFFF4E9FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFD8C8F7),
                ),
              )
            : null,
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
