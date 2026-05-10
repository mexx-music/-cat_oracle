import 'package:flutter/material.dart';

import '../features/hand_scan/presentation/pages/hand_scan_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/oracle/presentation/pages/oracle_result_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String handScan = '/hand-scan';
  static const String oracleResult = '/oracle-result';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    late final Widget page;

    switch (settings.name) {
      case home:
        page = const HomePage();
        break;
      case handScan:
        page = const HandScanPage();
        break;
      case oracleResult:
        page = const OracleResultPage();
        break;
      default:
        return null;
    }

    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
