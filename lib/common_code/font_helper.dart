import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FontHelper {
  // Get font based on current app locale
  static String getCurrentFont({FontWeight? fontWeight}) {
    String currentLanguage = Get.locale?.languageCode ?? 'en';

    if (currentLanguage == 'ar') {
      return 'Khebrat';
    } else {
      // For English, choose based on font weight
      if (fontWeight == FontWeight.bold ||
          fontWeight == FontWeight.w700 ||
          fontWeight == FontWeight.w800 ||
          fontWeight == FontWeight.w900) {
        return 'SofiaProBold';
      } else if (fontWeight == FontWeight.w300 ||
          fontWeight == FontWeight.w200) {
        return 'SofiaProLight';
      } else {
        return 'Khebrat';
      }
    }
  }
}
