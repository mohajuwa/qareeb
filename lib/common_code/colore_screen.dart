import 'package:flutter/material.dart';
import 'package:qareeb/common_code/global_variables.dart';

Color theamcolore = const Color(0xff00cdbc);
Color greaycolore = const Color(0xffF6F6F6);

class ColorNotifier with ChangeNotifier {
  get background => isDark ? const Color(0xff161616) : Colors.white;
  get textColor => isDark ? Colors.white : Colors.black;
  get containercolore => isDark ? const Color(0xff1C1C1C) : Colors.white;
  get containergreaycolore =>
      isDark ? const Color(0xff1C1C1C) : const Color(0xffF6F6F6);
  get languagecontainercolore =>
      isDark ? const Color(0xff232323) : const Color(0xffEEEEEE);
  get driverlistcolore =>
      isDark ? const Color(0xff232323) : const Color(0xffF6F6F6);

  // // get backgroundgray => isDark ? const Color(0xff181A20) : const Color(0xffF5F5F5);
  // get backgroundgray => isDark ? const Color(0xff161616) : const Color(0xffF5F5F5);
  // // get containercoloreproper => isDark ? const Color(0xff35383F) :  Colors.white;
  // get containercoloreproper => isDark ? const Color(0xff1C1C1C) :  Colors.white;
  //
  //
  //
  // //language colore
  // get languagecontainercolore => isDark ? const Color(0xff232323) :  const Color(0xffEEEEEE);
  // //fagcontainner colore
  // get fagcontainer => isDark ? const Color(0xff1C1C1C) :  const Color(0xffEEEEEE);
  //
  // //seatcontainercolore
  // // get seatcontainere => isDark ? const Color(0xff181A20) :  const Color(0xffD6C1F9).withOpacity(0.3);
  // get seatcontainere => isDark ? const Color(0xff1C1C1C) :  const Color(0xffD6C1F9).withOpacity(0.3);
  // get seatbordercolore => isDark ? const Color(0xff282828) :   Colors.transparent;
  // get seattextcolore => isDark ? Colors.white :  const Color(0xff7D2AFF);
  //
  // //theam colore
  // get theamcolorelight => isDark ? const Color(0xff6600FF) : const Color(0xff7D2AFF);
  // get appbarcolore => isDark ? const Color(0xff1C1C1C) : const Color(0xff2C2C2C);

  bool _isDark = false;
  bool get isDark => _isDark;

  void isAvailable(bool value) {
    _isDark = value;
    darkMode = value;
    notifyListeners();
  }
}
