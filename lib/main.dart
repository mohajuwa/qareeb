// ✅ FIXED - main.dart with proper Provider setup
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ✅ IMPORT ALL PROVIDERS
import 'package:qareeb/providers/location_state.dart';
import 'package:qareeb/providers/map_state.dart';
import 'package:qareeb/providers/pricing_state.dart';
import 'package:qareeb/providers/ride_request_state.dart';
import 'package:qareeb/providers/timer_state.dart';

// ✅ IMPORT COMMON CODE
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:qareeb/common_code/socket_service.dart';
import 'package:qareeb/common_code/language_translate.dart';

// ✅ IMPORT SCREENS
import 'package:qareeb/auth_screen/splase_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize SocketService
  Get.put(SocketService());

  // ✅ Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ WRAP WITH MULTIPROVIDER - THIS FIXES THE PROVIDER ERROR
    return MultiProvider(
      providers: [
        // ✅ UI Theme Provider
        ChangeNotifierProvider(create: (_) => ColorNotifier()),

        // ✅ Location and Map Providers
        ChangeNotifierProvider(create: (_) => LocationState()),
        ChangeNotifierProvider(create: (_) => MapState()),

        // ✅ Ride and Pricing Providers
        ChangeNotifierProvider(create: (_) => RideRequestState()),
        ChangeNotifierProvider(create: (_) => PricingState()),

        // ✅ Timer Provider
        ChangeNotifierProvider(create: (_) => TimerState()),
      ],
      child: GetMaterialApp(
        title: 'Qareeb',
        debugShowCheckedModeBanner: false,

        // ✅ Localization setup
        translations: AppTranslations(),
        locale: const Locale('ur', 'arabic'), // Arabic as default
        fallbackLocale: const Locale('en', 'US'),

        // ✅ Material app configuration
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Khebrat',
        ),

        // ✅ Start with splash screen
        home: const Splase_Screen(),

        // ✅ GetX configuration
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),

        // ✅ Error handling
        unknownRoute: GetPage(
          name: '/error',
          page: () => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        ),
      ),
    );
  }
}
