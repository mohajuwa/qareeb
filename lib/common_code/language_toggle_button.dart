// Add this widget to your onbording_screen.dart or create a separate file

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/font_helper.dart';

class LanguageToggleButton extends StatefulWidget {
  const LanguageToggleButton({super.key});

  @override
  State<LanguageToggleButton> createState() => _LanguageToggleButtonState();
}

class _LanguageToggleButtonState extends State<LanguageToggleButton> {
  bool isArabic = false;

  @override
  void initState() {
    super.initState();
    // Check current language
    String currentLocale = Get.locale.toString();
    isArabic = currentLocale.contains('ur') || currentLocale.contains('arabic');
  }

  void toggleLanguage() {
    setState(() {
      isArabic = !isArabic;
    });

    if (isArabic) {
      // Switch to Arabic
      Get.updateLocale(const Locale('ur', 'arabic'));
      Get.changeTheme(ThemeData(
        fontFamily: FontHelper.getCurrentFont(),
        useMaterial3: false,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        dividerColor: Colors.transparent,
      ));
    } else {
      // Switch to English
      Get.updateLocale(const Locale('en', 'English'));
      Get.changeTheme(ThemeData(
        fontFamily: FontHelper.getCurrentFont(),
        useMaterial3: false,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        dividerColor: Colors.transparent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleLanguage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic ? 'ع' : 'EN',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.language,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingProvider {
  String get discover => "Welcome to Your Qareeb Ride!";
  String get healthy => "Experience seamless rides with trusted drivers";
  String get order => "Your Journey, Just a Tap Away";
  String get orderthe => "Quick bookings, real-time tracking";
  String get lets => "Wherever You Go, We're Here";
  String get cooking => "Your reliable ride partner";
}

OnboardingProvider provider = OnboardingProvider();
