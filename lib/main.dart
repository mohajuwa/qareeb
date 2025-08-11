// lib/main.dart - Fix Arabic error messages
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/controllers/app_controller.dart';
import 'package:qareeb/services/socket_service.dart';
import 'auth_screen/splase_screen.dart';
import 'common_code/colore_screen.dart';
import 'app/theme/app_theme.dart';
import 'app/bindings/initial_binding.dart';
import 'common_code/language_translate.dart';

void main() {
  // ✅ Initialize GetX controllers BEFORE runApp
  Get.put(AppController(), permanent: true);
  Get.put(SocketService(), permanent: true);

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ColorNotifier(),
        ),
      ],
      child: GetMaterialApp(
        title: "Qareeb",
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        // ✅ CHANGE: Default to English to fix Arabic error messages
        locale: const Locale('en', 'English'), // Changed from Arabic to English
        fallbackLocale: const Locale('en', 'English'), // Add fallback
        theme: ThemeData(
          fontFamily: 'Khebrat', // Keep Arabic font for when Arabic is selected
          useMaterial3: false,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          dividerColor: Colors.transparent,
        ),
        home: const Splase_Screen(),
            // Bindings
            initialBinding: InitialBinding(),
      ),
    );
  }
}
