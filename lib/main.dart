import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'auth_screen/splase_screen.dart';
import 'providers/dynamic_fields_state.dart';
import 'providers/socket_service.dart';
import 'providers/ride_request_state.dart';
import 'providers/map_state.dart';
import 'providers/location_state.dart';
import 'providers/pricing_state.dart';
import 'providers/timer_state.dart';
import 'common_code/language_translate.dart';

Future<void> main() async {
  Get.put(SocketService());

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
        ChangeNotifierProvider(create: (_) => SocketService()),
        ChangeNotifierProvider(create: (_) => RideRequestState()),
        ChangeNotifierProvider(create: (_) => MapState()),
        ChangeNotifierProvider(create: (_) => LocationState()),
        ChangeNotifierProvider(create: (_) => PricingState()),
        ChangeNotifierProvider(create: (_) => TimerState()),
        ChangeNotifierProvider(
            create: (_) => DynamicFieldsState()), // ✅ Add this
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
