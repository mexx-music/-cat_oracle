import 'package:cat_oracle/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../services/oracle_session_service.dart';
import '../../logic/grand_oracle_reading_engine.dart';
import '../../models/grand_oracle_reading.dart';

class GrandReadingPage extends StatelessWidget {
  const GrandReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = OracleSessionService.instance;
    final reading = generateGrandReading(session);

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/gattofuturo.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC07040D),
                  Color(0xD00C0814),
                  Color(0xE8100A1A),
                  Color(0xF20B0612),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _PageHeader(reading: reading, l10n: l10n),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProgressRow(reading: reading, l10n: l10n),
                        const SizedBox(height: 20),
                        if (reading.completedModules == 0)
                          _EmptyHint(l10n: l10n)
                        else ...[
                          _ReadingCard(
                            label: l10n.grandReadingMoodLabel,
                            icon: '🌙',
                            text: reading.mood,
                          ),
                          const SizedBox(height: 12),
                          _ReadingCard(
                            label: l10n.grandReadingStrengthsLabel,
                            icon: '⚡',
                            text: reading.strengths,
                          ),
                          const SizedBox(height: 12),
                          _ReadingCard(
                            label: l10n.grandReadingChallengeLabel,
                            icon: '🌀',
                            text: reading.challenge,
                          ),
                          const SizedBox(height: 12),
                          _ReadingCard(
                            label: l10n.grandReadingCatAdviceLabel,
                            icon: '🐾',
                            text: reading.catAdvice,
                            highlight: true,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _SmallCard(
                                  label: l10n.grandReadingLuckySymbolLabel,
                                  content: reading.luckySymbol,
                                  isEmoji: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PawRatingCard(
                                  label: l10n.grandReadingPawRatingLabel,
                                  rating: reading.pawRating,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _ReadingCard(
                            label: l10n.grandReadingSummaryLabel,
                            icon: '✨',
                            text: reading.summaryText,
                          ),
                          const SizedBox(height: 20),
                          _DisclaimerChip(text: l10n.grandReadingDisclaimer),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
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

// ── Header ──────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.reading, required this.l10n});

  final GrandOracleReading reading;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0x33FFFFFF),
                  foregroundColor: const Color(0xFFF3DFA3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.grandReadingTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 48), // balance back button
            ],
          ),
          const SizedBox(height: 6),
          if (reading.isComplete)
            _Badge(text: l10n.grandReadingComplete)
          else
            Text(
              reading.completedModules == 0
                  ? l10n.grandReadingSubtitlePartial
                  : l10n.grandReadingSubtitlePartial,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xAAE6DDF8),
                letterSpacing: 0.6,
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ── Progress row ────────────────────────────────────────────────────────────

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.reading, required this.l10n});

  final GrandOracleReading reading;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final session = OracleSessionService.instance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x33110D1D),
        border: Border.all(color: const Color(0x55DAB86E)),
      ),
      child: Column(
        children: [
          Text(
            l10n.grandReadingProgress(reading.completedModules),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFFFFE9B0),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ModuleDot(label: '🃏', active: session.hasTarot),
              const SizedBox(width: 8),
              _ModuleDot(label: '✨', active: session.hasAstrology),
              const SizedBox(width: 8),
              _ModuleDot(label: '✋', active: session.hasPalmistry),
              const SizedBox(width: 8),
              _ModuleDot(label: '✒️', active: session.hasGraphology),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleDot extends StatelessWidget {
  const _ModuleDot({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? const Color(0x552E1A4A)
            : const Color(0x22110D1D),
        border: Border.all(
          color: active
              ? const Color(0xCCDAB86E)
              : const Color(0x44DAB86E),
          width: active ? 1.5 : 0.8,
        ),
        boxShadow: active
            ? [
                const BoxShadow(
                  color: Color(0x44DAB86E),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 22,
            color: active ? null : const Color(0xFF444444),
          ),
        ),
      ),
    );
  }
}

// ── Empty hint ──────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0x33110D1D),
        border: Border.all(color: const Color(0x55DAB86E)),
      ),
      child: Column(
        children: [
          const Text('🐾', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            l10n.grandReadingEmptyHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFE6DDF8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reading card ────────────────────────────────────────────────────────────

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({
    required this.label,
    required this.icon,
    required this.text,
    this.highlight = false,
  });

  final String label;
  final String icon;
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: highlight
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x552E1A4A), Color(0x3A1A0F30)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x3A1A0F30), Color(0x2A14102A)],
              ),
        border: Border.all(
          color: highlight
              ? const Color(0xAADAB86E)
              : const Color(0x77DAB86E),
          width: highlight ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: highlight
                ? const Color(0x33DAB86E)
                : const Color(0x2A100D1B),
            blurRadius: highlight ? 14 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFDAB86E),
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFF3ECFF),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small cards ─────────────────────────────────────────────────────────────

class _SmallCard extends StatelessWidget {
  const _SmallCard({
    required this.label,
    required this.content,
    this.isEmoji = false,
  });

  final String label;
  final String content;
  final bool isEmoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x3A1A0F30),
        border: Border.all(color: const Color(0x77DAB86E), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFFDAB86E),
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              content,
              style: TextStyle(
                fontSize: isEmoji ? 36 : 24,
                color: const Color(0xFFFFE9B0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PawRatingCard extends StatelessWidget {
  const _PawRatingCard({required this.label, required this.rating});

  final String label;
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x3A1A0F30),
        border: Border.all(color: const Color(0x77DAB86E), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFFDAB86E),
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                return Text(
                  i < rating ? '🐾' : '·',
                  style: TextStyle(
                    fontSize: i < rating ? 20 : 18,
                    color: i < rating
                        ? null
                        : const Color(0x44E6DDF8),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Disclaimer chip ──────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0x44DAB86E),
        border: Border.all(color: const Color(0xAADAB86E)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFFFFE9B0),
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DisclaimerChip extends StatelessWidget {
  const _DisclaimerChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0x2A2E1A4A),
          border: Border.all(color: const Color(0x66DAB86E), width: 0.8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0x99E6DDF8),
            letterSpacing: 0.6,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
