import 'package:flutter/material.dart';
import 'package:qareeb/common_code/colore_screen.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  primaryColor: theamcolore,
  colorScheme: ColorScheme.fromSeed(seedColor: theamcolore),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: theamcolore,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: theamcolore,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: theamcolore),
  ),
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: ColorScheme.fromSeed(seedColor: theamcolore, brightness: Brightness.dark),
  primaryColor: theamcolore,
  scaffoldBackgroundColor: Color(0xFF0B0B0B),
  appBarTheme: AppBarTheme(backgroundColor: Color(0xFF0B0B0B)),
);
