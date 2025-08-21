
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../translations/app_translations.dart';
import '../widgets/loading_overlay.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  AppTranslations? _translations;

  @override
  void initState() {
    super.initState();
    AppTranslations.init().then((t) {
      setState(() => _translations = t);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_translations == null) {
      return const MaterialApp(home: LoadingOverlay());
    }
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: _translations,
      locale: const Locale('ar', 'YE'),
      fallbackLocale: const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'YE'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        fontFamily: 'Khebrat',
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const LoadingOverlay(),
    );
  }
}
