import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  var locale = const Locale('en');
  static const String _langKey = 'selectedLanguage';

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString(_langKey);
    if (code != null) {
      locale = Locale(code);
      update();
    }
  }

  Future<void> changeLocale(String code) async {
    locale = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
    Get.updateLocale(locale);
    update();
  }
}
