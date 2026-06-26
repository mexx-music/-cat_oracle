import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../core/locale_controller.dart';
import '../gen_l10n/app_localizations.dart';
import '../services/onboarding_service.dart';

class CatOracleApp extends StatefulWidget {
  const CatOracleApp({super.key});

  @override
  State<CatOracleApp> createState() => _CatOracleAppState();
}

class _CatOracleAppState extends State<CatOracleApp> {
  LocaleController? _controller;
  bool? _onboardingSeen;

  @override
  void initState() {
    super.initState();
    _loadStartup();
  }

  Future<void> _loadStartup() async {
    final results = await Future.wait([
      LocaleController.init(),
      OnboardingService.isOnboardingSeen(),
    ]);
    if (!mounted) return;
    setState(() {
      _controller = results[0] as LocaleController;
      _onboardingSeen = results[1] as bool;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || _onboardingSeen == null) {
      return const MaterialApp(
        home: Scaffold(backgroundColor: Color(0xFF0B0612)),
      );
    }
    final initialRoute =
        _onboardingSeen! ? AppRoutes.home : AppRoutes.onboarding;
    return LocaleScope(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (_, __) => MaterialApp(
          locale: controller.locale,
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: initialRoute,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}
