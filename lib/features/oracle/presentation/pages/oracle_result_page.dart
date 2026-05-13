import 'package:flutter/material.dart';

import '../../../astrology/data/demo_astrology_readings.dart';
import '../../../astrology/models/zodiac_sign.dart';
import '../../../oracle/data/demo_combined_oracle_reading.dart';
import '../../../palmistry/data/demo_palmistry_readings.dart';
import '../../../../services/oracle_session_service.dart';

class OracleResultPage extends StatelessWidget {
  const OracleResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final astrologyProfile = OracleSessionService.instance.astrologyProfile;
    final palmItems =
        (demoPalmistryReadings.isNotEmpty
                ? demoPalmistryReadings
                      .take(2)
                      .map(
                        (reading) => _DemoItem(
                          label: reading.title,
                          text: reading.summary,
                        ),
                      )
                : const [
                    _DemoItem(
                      label: 'Handlinien-Deutung',
                      text:
                          'Die Katze betrachtet deine Linien mit ruhiger Aufmerksamkeit.',
                    ),
                  ])
            .toList();
    final astrologyItems = astrologyProfile == null
        ? (demoAstrologyReadings.isNotEmpty
                  ? demoAstrologyReadings
                        .take(2)
                        .map(
                          (reading) => _DemoItem(
                            label: reading.title,
                            text: reading.summary,
                          ),
                        )
                  : const [
                      _DemoItem(
                        label: 'Astrologie-Deutung',
                        text:
                            'Die Sterne zeigen heute eine sanfte, leuchtende Stimmung.',
                      ),
                    ])
              .toList()
        : [
            _DemoItem(
              label: 'Sonnenzeichen',
              text: _formatZodiacSign(astrologyProfile.sunSign),
            ),
            _DemoItem(
              label: 'Mondzeichen',
              text: astrologyProfile.moonSign == null
                  ? 'später'
                  : _formatZodiacSign(astrologyProfile.moonSign!),
            ),
            _DemoItem(
              label: 'Aszendent',
              text: astrologyProfile.ascendant == null
                  ? 'später'
                  : _formatZodiacSign(astrologyProfile.ascendant!),
            ),
            if (astrologyProfile.birthDate != null)
              _DemoItem(
                label: 'Geburtsdatum',
                text: _formatDate(astrologyProfile.birthDate!),
              ),
            if (astrologyProfile.birthTimeLabel != null)
              _DemoItem(
                label: 'Geburtszeit',
                text: astrologyProfile.birthTimeLabel!,
              ),
            if (astrologyProfile.birthPlaceName != null &&
                astrologyProfile.birthPlaceCountry != null)
              _DemoItem(
                label: 'Geburtsort',
                text:
                    '${astrologyProfile.birthPlaceName}, ${astrologyProfile.birthPlaceCountry}',
              ),
            if (astrologyProfile.latitude != null &&
                astrologyProfile.longitude != null)
              _DemoItem(
                label: 'Koordinaten',
                text:
                    '${astrologyProfile.latitude!.toStringAsFixed(4)} / ${astrologyProfile.longitude!.toStringAsFixed(4)}',
              ),
          ];
    final combinedMessage =
        demoCombinedOracleReading.combinedCatMessage.isNotEmpty
        ? demoCombinedOracleReading.combinedCatMessage
        : 'Die Katze verbindet deine Eindrücke zu einer stillen, warmen Orakel-Botschaft.';

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
                  items: palmItems,
                ),
                const SizedBox(height: 20),
                // Astrology Section
                _InterpretationCard(
                  title: '✨ Astrologie-Deutung',
                  items: astrologyItems,
                ),
                if (astrologyProfile != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: colorScheme.secondary.withValues(alpha: 0.08),
                      border: Border.all(
                        color: colorScheme.secondary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      'Hinweis: Mondzeichen und Aszendent sind aktuell Demo-Werte. Die professionelle Berechnung folgt später.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
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
                        combinedMessage,
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

String _formatZodiacSign(ZodiacSign sign) {
  switch (sign) {
    case ZodiacSign.aries:
      return 'Widder';
    case ZodiacSign.taurus:
      return 'Stier';
    case ZodiacSign.gemini:
      return 'Zwillinge';
    case ZodiacSign.cancer:
      return 'Krebs';
    case ZodiacSign.leo:
      return 'Löwe';
    case ZodiacSign.virgo:
      return 'Jungfrau';
    case ZodiacSign.libra:
      return 'Waage';
    case ZodiacSign.scorpio:
      return 'Skorpion';
    case ZodiacSign.sagittarius:
      return 'Schütze';
    case ZodiacSign.capricorn:
      return 'Steinbock';
    case ZodiacSign.aquarius:
      return 'Wassermann';
    case ZodiacSign.pisces:
      return 'Fische';
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day.$month.$year';
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
