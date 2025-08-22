
import 'package:get/get.dart';
import '../ui/map/map3d_screen.dart';
import '../ui/app_root.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();
  static const INITIAL = Routes.ROOT;

  static final routes = <GetPage>[
    GetPage(name: Routes.ROOT, page: () => const AppRoot()),
    GetPage(name: Routes.MAP3D, page: () => const Map3DScreen()),
  ];
}
