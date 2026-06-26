import 'package:flutter/material.dart';

import '../../../../core/app_routes.dart';
import '../../../../services/oracle_session_service.dart';
import 'package:cat_oracle/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaPadding = MediaQuery.of(context).padding.vertical;
    final heroSpacing = (screenHeight * 0.42).clamp(180.0, 340.0).toDouble();

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/gattofuturo.png',
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - safeAreaPadding - 40,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.settings),
                          icon: const Icon(Icons.settings_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0x33FFFFFF),
                            foregroundColor: const Color(0xFFF3E6BD),
                          ),
                        ),
                      ),
                      SizedBox(height: heroSpacing),
                      Text(
                        l10n.homeTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.homeSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.homeDescription,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _EntryCard(
                        symbol: '✋',
                        title: l10n.homePalmistryTitle,
                        subtitle: l10n.homePalmistrySubtitle,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.handScan);
                        },
                      ),
                      const SizedBox(height: 14),
                      _EntryCard(
                        symbol: '🔮',
                        title: l10n.homeOracleTitle,
                        subtitle: l10n.homeOracleSubtitle,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.oracleResult);
                        },
                      ),
                      const SizedBox(height: 14),
                      _EntryCard(
                        symbol: '✨',
                        title: l10n.homeAstrologyTitle,
                        subtitle: l10n.homeAstrologySubtitle,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.astrology);
                        },
                      ),
                      const SizedBox(height: 14),
                      _EntryCard(
                        symbol: '🃏',
                        imageAsset: 'assets/images/tarot/catjoker.png',
                        title: l10n.homeTarotTitle,
                        subtitle: l10n.homeTarotSubtitle,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.tarot);
                        },
                      ),
                      const SizedBox(height: 14),
                      _EntryCard(
                        symbol: '✒️',
                        title: l10n.homeGraphologyTitle,
                        subtitle: l10n.homeGraphologySubtitle,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.graphology);
                        },
                      ),
                      const SizedBox(height: 14),
                      ListenableBuilder(
                        listenable: OracleSessionService.instance,
                        builder: (_, __) => _GrandReadingCard(l10n: l10n),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrandReadingCard extends StatelessWidget {
  const _GrandReadingCard({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final session = OracleSessionService.instance;
    final count = session.completedCount;
    final String subtitle;
    if (count == 0) {
      subtitle = l10n.homeGrandReadingEmpty;
    } else if (count < 4) {
      subtitle = l10n.homeGrandReadingPartial;
    } else {
      subtitle = l10n.homeGrandReadingReady;
    }

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: count == 0
              ? null
              : () => Navigator.of(context).pushNamed(AppRoutes.grandReading),
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x3A2E1A4A), Color(0x2A1A0F30)],
              ),
              border: Border.all(
                color: count == 0
                    ? const Color(0x44DABA72)
                    : const Color(0xCCDABA72),
                width: count == 4 ? 1.4 : 1.0,
              ),
              boxShadow: count > 0
                  ? const [
                      BoxShadow(
                        color: Color(0x44DAB86E),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: count > 0
                          ? const Color(0x442E1A4A)
                          : const Color(0x1A2E1A4A),
                      border: Border.all(
                        color: count > 0
                            ? const Color(0xAAE3C881)
                            : const Color(0x44E3C881),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '🌟',
                        style: TextStyle(
                          fontSize: 24,
                          color: count == 0
                              ? const Color(0x66FFFFFF)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeGrandReadingTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: count > 0
                                    ? const Color(0xFFFFECB8)
                                    : const Color(0x88FFECB8),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: count > 0
                                    ? Colors.white.withValues(alpha: 0.78)
                                    : Colors.white.withValues(alpha: 0.40),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    count == 0
                        ? Icons.lock_outline_rounded
                        : Icons.chevron_right_rounded,
                    color: count > 0
                        ? const Color(0xFFF1DDA2)
                        : const Color(0x44F1DDA2),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.symbol,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.imageAsset,
  });

  final String symbol;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0x2D160F25),
              border: Border.all(color: const Color(0x88DABA72), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40120D1D),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Color(0x1F8A5CCF),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x33412B60),
                      border: Border.all(color: const Color(0x77E3C881)),
                    ),
                    child: Center(
                      child: imageAsset != null
                          ? ClipOval(
                              child: Image.asset(
                                imageAsset!,
                                width: 54,
                                height: 54,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Text(
                                  symbol,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            )
                          : Text(symbol, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFFFFECB8),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.78),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFF1DDA2),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

