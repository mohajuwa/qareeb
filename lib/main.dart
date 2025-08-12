import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/controllers/language_controller.dart';
import 'auth_screen/splase_screen.dart';
import 'common_code/colore_screen.dart';
import 'app/bindings/initial_binding.dart';
import 'common_code/language_translate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print("🚀 App starting...");
  }

  final languageController = Get.put(LanguageController());
  await languageController.loadLocale();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorNotifier()),
      ],
      child: GetBuilder<LanguageController>(
        builder: (_) => GetMaterialApp(
          title: "Qareeb",
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: languageController.locale,
          fallbackLocale: const Locale('en'),
          theme: ThemeData(
            fontFamily: 'Khebrat',
            useMaterial3: false,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            dividerColor: Colors.transparent,
          ),
          initialBinding: InitialBinding(),
          home: const Splase_Screen(),
          unknownRoute: GetPage(
            name: '/unknown',
            page: () => const Splase_Screen(),
          ),
          routingCallback: kDebugMode
              ? (routing) {
                  if (kDebugMode) {
                    print("🧭 Route change: ${routing?.current}");
                  }
                }
              : null,
        ),
      ),
    );
  }
}
