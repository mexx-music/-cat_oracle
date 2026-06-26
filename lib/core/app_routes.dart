import 'package:flutter/material.dart';

import '../features/hand_scan/presentation/pages/hand_scan_page.dart';
import '../features/astrology/presentation/pages/astrology_input_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/oracle/presentation/pages/grand_reading_page.dart';
import '../features/oracle/presentation/pages/oracle_result_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/tarot/presentation/pages/tarot_page.dart';
import '../features/graphology/presentation/pages/graphology_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String settings = '/settings';
  static const String handScan = '/hand-scan';
  static const String oracleResult = '/oracle-result';
  static const String astrology = '/astrology';
  static const String tarot = '/tarot';
  static const String graphology = '/graphology';
  static const String grandReading = '/grand-reading';

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    late final Widget page;

    switch (routeSettings.name) {
      case home:
        page = const HomePage();
        break;
      case handScan:
        page = const HandScanPage();
        break;
      case oracleResult:
        page = const OracleResultPage();
        break;
      case astrology:
        page = const AstrologyInputPage();
        break;
      case tarot:
        page = const TarotPage();
        break;
      case graphology:
        page = const GraphologyPage();
        break;
      case grandReading:
        page = const GrandReadingPage();
        break;
      case onboarding:
        page = const OnboardingPage();
        break;
      case settings:
        page = const SettingsPage();
        break;
      default:
        return null;
    }

    return MaterialPageRoute<void>(builder: (_) => page, settings: routeSettings);
  }
}
