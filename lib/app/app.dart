import 'package:flutter/material.dart';

import '../core/app_routes.dart';
import '../core/app_theme.dart';

class CatOracleApp extends StatelessWidget {
  const CatOracleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Oracle',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
