import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  final Map<String, Map<String, String>> _keys = {};

  AppTranslations() {
    // Load JSON maps at runtime (synchronously at startup via init())
  }

  static Future<AppTranslations> init() async {
    final t = AppTranslations();
    final ar = await rootBundle.loadString('assets/langs/ar.json');
    final en = await rootBundle.loadString('assets/langs/en.json');
    t._keys['ar_YE'] = Map<String, String>.from(json.decode(ar));
    t._keys['en_US'] = Map<String, String>.from(json.decode(en));
    return t;
  }

  @override
  Map<String, Map<String, String>> get keys => _keys;
}
