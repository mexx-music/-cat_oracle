import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../core/locale_controller.dart';
import '../gen_l10n/app_localizations.dart';

class CatOracleApp extends StatefulWidget {
  const CatOracleApp({super.key});

  @override
  State<CatOracleApp> createState() => _CatOracleAppState();
}

class _CatOracleAppState extends State<CatOracleApp> {
  LocaleController? _controller;

  @override
  void initState() {
    super.initState();
    LocaleController.init().then((c) {
      if (mounted) setState(() => _controller = c);
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
    if (controller == null) {
      return const MaterialApp(
        home: Scaffold(backgroundColor: Color(0xFF0B0612)),
      );
    }
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
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}
