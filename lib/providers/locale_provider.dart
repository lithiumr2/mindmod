import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/translations.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('en') {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('language_code');
    if (saved != null && saved != 'system') {
      state = saved;
    } else {
      _setSystemLocale();
    }
  }

  void _setSystemLocale() {
    final sysLang = ui.PlatformDispatcher.instance.locale.languageCode;
    if (['en', 'es', 'ru'].contains(sysLang)) {
      state = sysLang;
    } else {
      state = 'en'; // default
    }
  }

  void setLocale(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    if (lang == 'system') {
      await prefs.setString('language_code', 'system');
      _setSystemLocale();
    } else {
      await prefs.setString('language_code', lang);
      state = lang;
    }
  }

  String tr(String key) {
    final map = translations[state] ?? translations['en']!;
    return map[key] ?? translations['en']![key] ?? key;
  }
}
