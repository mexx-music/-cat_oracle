import 'package:cat_oracle/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_routes.dart';
import '../../../../services/onboarding_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;
  static const int _pageCount = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pageCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await OnboardingService.setOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLast = _currentPage == _pageCount - 1;

    final pages = [
      _OnboardingSlide(
        emoji: '🐾',
        title: l10n.onboardingPage1Title,
        body: l10n.onboardingPage1Body,
        accentColor: const Color(0xFFDAB86E),
      ),
      _OnboardingSlide(
        emoji: '✋✒️✨🃏',
        title: l10n.onboardingPage2Title,
        body: l10n.onboardingPage2Body,
        accentColor: const Color(0xFFB38FD4),
      ),
      _OnboardingSlide(
        emoji: '🌟',
        title: l10n.onboardingPage3Title,
        body: l10n.onboardingPage3Body,
        accentColor: const Color(0xFF8FC4D4),
      ),
      _OnboardingSlide(
        emoji: '🔮',
        title: l10n.onboardingPage4Title,
        body: l10n.onboardingPage4Body,
        accentColor: const Color(0xFFC4DA8F),
        isDisclaimer: true,
      ),
    ];

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
                  Color(0xD50C0814),
                  Color(0xF0100A1A),
                  Color(0xFF0B0612),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, top: 12),
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(
                        l10n.onboardingSkip,
                        style: const TextStyle(
                          color: Color(0x88E6DDF8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: pages,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 36),
                  child: Column(
                    children: [
                      _PageDots(
                        count: _pageCount,
                        current: _currentPage,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFDAB86E),
                            foregroundColor: const Color(0xFF0B0612),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isLast ? l10n.onboardingBegin : l10n.onboardingNext,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ── Slide ────────────────────────────────────────────────────────────────────

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.emoji,
    required this.title,
    required this.body,
    required this.accentColor,
    this.isDisclaimer = false,
  });

  final String emoji;
  final String title;
  final String body;
  final Color accentColor;
  final bool isDisclaimer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x2A2E1A4A),
              border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 36),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFFFE9B0),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDisclaimer
                  ? const Color(0xCCE6DDF8)
                  : const Color(0xEEE6DDF8),
              height: 1.6,
              fontStyle: isDisclaimer ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page dots ────────────────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: active
                ? const Color(0xFFDAB86E)
                : const Color(0x44DAB86E),
          ),
        );
      }),
    );
  }
}
