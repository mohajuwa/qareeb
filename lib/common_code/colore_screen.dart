import 'package:flutter/material.dart';
import '../app_screen/map_screen.dart';

Color theamcolore = const Color(0xff00cdbc);
Color greaycolore = const Color(0xffF6F6F6);

class ColorNotifier with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  // ✅ EXISTING properties (from your original code)
  get background => isDark ? const Color(0xff161616) : Colors.white;
  get textColor => isDark ? Colors.white : Colors.black;
  get containercolore => isDark ? const Color(0xff1C1C1C) : Colors.white;
  get containergreaycolore =>
      isDark ? const Color(0xff1C1C1C) : const Color(0xffF6F6F6);
  get languagecontainercolore =>
      isDark ? const Color(0xff232323) : const Color(0xffEEEEEE);
  get driverlistcolore =>
      isDark ? const Color(0xff232323) : const Color(0xffF6F6F6);

  // ✅ NEW: Missing properties that were causing red lines
  get backgroundallscreenColor =>
      isDark ? const Color(0xff161616) : Colors.white;
  get notificationbackground => isDark ? const Color(0xff1C1C1C) : Colors.white;
  get greentextColor => theamcolore; // Use the theme color

  // Additional useful properties for consistent theming
  get primaryColor => theamcolore;
  get secondaryColor =>
      isDark ? const Color(0xff232323) : const Color(0xffF6F6F6);
  get cardColor => isDark ? const Color(0xff1C1C1C) : Colors.white;
  get dividerColor =>
      isDark ? const Color(0xff232323) : const Color(0xffE0E0E0);
  get shadowColor => isDark ? Colors.black26 : Colors.grey.shade200;
  get borderColor => isDark ? const Color(0xff232323) : const Color(0xffE0E0E0);

  // Status colors
  get successColor => const Color(0xff4CAF50);
  get errorColor => const Color(0xffF44336);
  get warningColor => const Color(0xffFF9800);
  get infoColor => const Color(0xff2196F3);

  // Text color variations
  get primaryTextColor => isDark ? Colors.white : Colors.black;
  get secondaryTextColor => isDark ? Colors.white70 : Colors.black54;
  get hintTextColor => isDark ? Colors.white38 : Colors.black38;

  // Button colors
  get primaryButtonColor => theamcolore;
  get secondaryButtonColor =>
      isDark ? const Color(0xff232323) : const Color(0xffF6F6F6);
  get disabledButtonColor =>
      isDark ? const Color(0xff333333) : const Color(0xffE0E0E0);

  // Input field colors
  get inputFieldColor => isDark ? const Color(0xff1C1C1C) : Colors.white;
  get inputBorderColor =>
      isDark ? const Color(0xff232323) : const Color(0xffE0E0E0);
  get focusedBorderColor => theamcolore;

  // App bar colors
  get appBarColor => isDark ? const Color(0xff1C1C1C) : Colors.white;
  get appBarTextColor => isDark ? Colors.white : Colors.black;

  // Bottom navigation colors
  get bottomNavColor => isDark ? const Color(0xff1C1C1C) : Colors.white;
  get selectedNavColor => theamcolore;
  get unselectedNavColor => isDark ? Colors.white54 : Colors.black54;

  void isAvailable(bool value) {
    _isDark = value;
    darkMode = value;
    notifyListeners();
  }
}
