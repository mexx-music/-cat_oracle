import 'package:flutter/material.dart';

class OracleResultPage extends StatelessWidget {
  const OracleResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Orakel-Ergebnis')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F0B17),
              const Color(0xFF1A1428),
              colorScheme.primaryContainer.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100,
            ),
            child: Column(
              children: [
                // Hand Reading Section
                _InterpretationCard(
                  title: '✋ Handlinien-Deutung',
                  items: const [
                    _DemoItem(
                      label: 'Lebenslinie',
                      text:
                          'Du lebst mit Wärmherzigkeit und bleibst neugierig wie eine Katze.',
                    ),
                    _DemoItem(
                      label: 'Herzlinie',
                      text:
                          'Dein Herz ist empfänglich für Schönheit und stille Magie.',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Astrology Section
                _InterpretationCard(
                  title: '✨ Astrologie-Deutung',
                  items: const [
                    _DemoItem(
                      label: 'Sternzeichen',
                      text:
                          'Dein Sternzeichen verbindet dich mit einem Tier-Totem voller Kraft.',
                    ),
                    _DemoItem(
                      label: 'Mond-Energie',
                      text:
                          'Die Mondphase unterstützt deine innere Balance und Klarheit.',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Combined Oracle Guidance
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.08),
                        colorScheme.secondary.withValues(alpha: 0.06),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '🐾 Kombinierte Katzen-Orakel-Deutung',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Die Katze verbindet deine Handlinien mit den Sternen und sieht einen Weg voller Neugier, Wärme und leiser Stärke.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Möge diese Deutung dir Klarheit schenken.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Zurück'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InterpretationCard extends StatelessWidget {
  const _InterpretationCard({required this.title, required this.items});

  final String title;
  final List<_DemoItem> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary.withValues(alpha: 0.08),
            colorScheme.tertiary.withValues(alpha: 0.06),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.text,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoItem {
  const _DemoItem({required this.label, required this.text});

  final String label;
  final String text;
}
