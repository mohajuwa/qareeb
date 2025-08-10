import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/controllers/app_controller.dart';
import 'auth_screen/splase_screen.dart';
import 'common_code/colore_screen.dart';
import 'common_code/language_translate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppController
  Get.put(AppController(), permanent: true);

  runApp(MyApp());
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
        locale: const Locale('ur', 'arabic'), // Arabic as default
        theme: ThemeData(
          fontFamily: 'Khebrat', // Khebrat for Arabic default
          useMaterial3: false,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          dividerColor: Colors.transparent,
        ),
        home: const Splase_Screen(),
      ),
    );
  }
}
