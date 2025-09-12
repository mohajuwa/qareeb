import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/network_service.dart';
import 'package:qareeb/services/routes.dart';
import 'auth_screen/splase_screen.dart';
import 'common_code/colore_screen.dart';
import 'common_code/language_translate.dart';
import 'package:flutter/foundation.dart';
import 'package:qareeb/services/running_ride_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NetworkService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // Only need one observer
    WidgetsBinding.instance.addObserver(this);

    // Start monitoring once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) print("🚀 App initialized, starting RunningRideMonitor");
      RunningRideMonitor.instance.startMonitoring();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RunningRideMonitor.instance.stopMonitoring();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        if (kDebugMode) print("📱 App resumed - checking for running rides");
        RunningRideMonitor.instance.checkNow();
        break;
      case AppLifecycleState.detached:
        if (kDebugMode) print("📱 App detached - stopping monitor");
        RunningRideMonitor.instance.stopMonitoring();
        break;
      default:
        break;
    }
  }

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
        locale: const Locale('ur', 'arabic'),
        getPages: AppRoutes.getPages,
        theme: ThemeData(
          fontFamily: 'Khebrat',
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
