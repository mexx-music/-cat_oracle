import 'package:cat_oracle/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_routes.dart';
import '../../../../core/locale_controller.dart';
import '../../../../services/onboarding_service.dart';
import '../../../../services/oracle_session_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                _SettingsHeader(l10n: l10n),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SectionLabel(l10n.settingsLanguageLabel),
                        const SizedBox(height: 8),
                        _LanguageToggle(l10n: l10n),
                        const SizedBox(height: 24),
                        _SectionLabel(l10n.settingsActionsLabel),
                        const SizedBox(height: 8),
                        _ActionTile(
                          icon: Icons.auto_stories_rounded,
                          label: l10n.settingsResetOnboarding,
                          onTap: () async {
                            await OnboardingService.resetOnboarding();
                            if (!context.mounted) return;
                            Navigator.of(context).pushNamed(AppRoutes.onboarding);
                          },
                        ),
                        const SizedBox(height: 10),
                        _ActionTile(
                          icon: Icons.refresh_rounded,
                          label: l10n.settingsResetSession,
                          isDanger: true,
                          onTap: () => _confirmResetSession(context, l10n),
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(l10n.settingsDisclaimerLabel),
                        const SizedBox(height: 8),
                        _DisclaimerBox(text: l10n.settingsDisclaimerText),
                        const SizedBox(height: 24),
                        _SectionLabel(l10n.settingsAppInfoLabel),
                        const SizedBox(height: 8),
                        _InfoBox(l10n: l10n),
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

  Future<void> _confirmResetSession(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0F2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          l10n.settingsResetSession,
          style: const TextStyle(color: Color(0xFFFFE9B0)),
        ),
        content: Text(
          l10n.settingsResetSessionConfirm,
          style: const TextStyle(color: Color(0xCCE6DDF8), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.settingsCancelButton,
              style: const TextStyle(color: Color(0x88E6DDF8)),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB23B3B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.settingsResetButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    OracleSessionService.instance.clearAll();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsResetSessionDone),
        backgroundColor: const Color(0xFF2A1A3A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0x33FFFFFF),
              foregroundColor: const Color(0xFFF3DFA3),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.settingsTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFFFFE9B0),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Language toggle ──────────────────────────────────────────────────────────

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final controller = LocaleScope.of(context);
    final current = controller.locale.languageCode;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x3A1A0F30),
        border: Border.all(color: const Color(0x77DAB86E), width: 0.8),
      ),
      child: Row(
        children: [
          _LangOption(
            label: 'Deutsch',
            flag: '🇩🇪',
            selected: current == 'de',
            onTap: () => controller.setLocale(const Locale('de')),
          ),
          Container(width: 0.8, height: 52, color: const Color(0x44DAB86E)),
          _LangOption(
            label: 'English',
            flag: '🇬🇧',
            selected: current == 'en',
            onTap: () => controller.setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected ? const Color(0x44DAB86E) : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFFFFE9B0)
                      : const Color(0x88E6DDF8),
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Color(0xFFDAB86E),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Action tile ───────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final color =
        isDanger ? const Color(0xFFE07070) : const Color(0xFFE6DDF8);
    final borderColor =
        isDanger ? const Color(0x55E07070) : const Color(0x55DAB86E);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0x2A1A0F30),
          border: Border.all(color: borderColor, width: 0.8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Disclaimer box ────────────────────────────────────────────────────────────

class _DisclaimerBox extends StatelessWidget {
  const _DisclaimerBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0x2A1A0F30),
        border: Border.all(color: const Color(0x44DAB86E), width: 0.8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xCCE6DDF8),
          height: 1.6,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

// ── App info box ───────────────────────────────────────────────────────────────

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0x2A1A0F30),
        border: Border.all(color: const Color(0x44DAB86E), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFFFFE9B0),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsAppVersion,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0x88E6DDF8),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: const Color(0xAADAB86E),
        letterSpacing: 1.6,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
