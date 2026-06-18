import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';
const _kSupportedCodes = ['de', 'en'];

class LocaleController extends ChangeNotifier {
  Locale _locale;

  LocaleController._(this._locale);

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    _persist(locale);
  }

  static Future<LocaleController> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLocaleKey);
    final Locale locale;
    if (saved != null && _kSupportedCodes.contains(saved)) {
      locale = Locale(saved);
    } else {
      final system = PlatformDispatcher.instance.locale.languageCode;
      locale = Locale(_kSupportedCodes.contains(system) ? system : 'de');
    }
    return LocaleController._(locale);
  }

  Future<void> _persist(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LocaleScope>()!.notifier!;
}
