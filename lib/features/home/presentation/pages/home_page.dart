import 'package:flutter/material.dart';

import '../../../../core/app_routes.dart';
import '../../../../core/locale_controller.dart';
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
                        child: _LanguageButton(),
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

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.symbol,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String symbol;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

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
                      child: Text(symbol, style: const TextStyle(fontSize: 24)),
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

class _LanguageButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = LocaleScope.of(context);
    final current = controller.locale.languageCode;
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language_rounded),
      iconColor: const Color(0xFFF3E6BD),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0x33FFFFFF)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: const Locale('de'),
          child: _localeItem('Deutsch', current == 'de'),
        ),
        PopupMenuItem(
          value: const Locale('en'),
          child: _localeItem('English', current == 'en'),
        ),
      ],
      onSelected: controller.setLocale,
    );
  }

  Widget _localeItem(String label, bool selected) => Row(
    children: [
      SizedBox(
        width: 20,
        child: selected
            ? const Icon(Icons.check_rounded, size: 16)
            : null,
      ),
      const SizedBox(width: 8),
      Text(label),
    ],
  );
}
