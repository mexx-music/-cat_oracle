import 'package:flutter/material.dart';

import '../../logic/daily_tarot_card_generator.dart';
import '../../models/tarot_card.dart';

class TarotPage extends StatelessWidget {
  const TarotPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      '🃏 Tarot',
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
                      'Die Karten flüstern',
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
                        'Ziehe später deine Karten und Madame Gatto deutet ihre Symbole.',
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
                                    '🃏 Tageskarte',
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
                                      child: const Text('Tageskarte öffnen'),
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
                    const _TarotOptionTile(title: 'Drei-Karten-Legung'),
                    const SizedBox(height: 12),
                    const _TarotOptionTile(title: 'Liebe & Intuition'),
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
                        'Tarot-Orakel erwacht bald',
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
                  '🃏 Tageskarte',
                  style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  card.name,
                  style: Theme.of(dialogContext).textTheme.titleMedium
                      ?.copyWith(
                        color: const Color(0xFFF4E9FF),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
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
                  'Diese Karte erneuert sich täglich.',
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFD8C8F7),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Schließen'),
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

class _TarotOptionTile extends StatelessWidget {
  const _TarotOptionTile({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
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
  }
}

class _TarotCardImagePreview extends StatelessWidget {
  const _TarotCardImagePreview({required this.card});

  final TarotCard card;

  @override
  Widget build(BuildContext context) {
    final assetPath = card.imageAsset;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x402B1A46), Color(0x3224133A)],
          ),
          border: Border.all(color: const Color(0x66D5B46B), width: 0.9),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A7A4DCC),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: assetPath == null
            ? _TarotImageFallback(symbol: card.symbol)
            : Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _TarotImageFallback(symbol: card.symbol);
                },
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
