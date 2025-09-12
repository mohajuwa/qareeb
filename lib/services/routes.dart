import 'package:get/get.dart';
import 'package:qareeb/app_screen/driver_detail_screen.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/app_screen/my_ride_screen.dart';
import 'package:qareeb/app_screen/driver_list_screen.dart';
import 'package:qareeb/app_screen/profile_screen.dart';
import 'package:qareeb/app_screen/ride_complete_payment_screen.dart';
import 'package:qareeb/app_screen/notification_screen.dart';
import 'package:qareeb/app_screen/language_screen.dart';
import 'package:qareeb/app_screen/top_up_screen.dart';
import 'package:qareeb/app_screen/faq_screen.dart';
import 'package:qareeb/app_screen/refer_and_earn.dart';
import 'package:qareeb/auth_screen/splase_screen.dart';
import 'package:qareeb/auth_screen/onbording_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String mapScreen = '/MapScreen';
  static const String myRideScreen = '/MyRideScreen';
  static const String driverListScreen = '/DriverListScreen';
  static const String rideCompletePaymentScreen = '/RideCompletePaymentScreen';
  static const String pickupDropPoint = '/PickupDropPoint';
  static const String profileScreen = '/ProfileScreen';
  static const String homeScreen = '/HomeScreen';
  static const String notificationScreen = '/NotificationScreen';
  static const String languageScreen = '/LanguageScreen';
  static const String topUpScreen = '/TopUpScreen';
  static const String faqScreen = '/FaqScreen';
  static const String referAndEarn = '/ReferAndEarn';

  // GetPages list
  static List<GetPage> getPages = [
    GetPage(
      name: splash,
      page: () => const Splase_Screen(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnbordingScreen(),
    ),
    GetPage(
      name: mapScreen,
      page: () => const MapScreen(selectvihical: false),
    ),
    GetPage(
      name: myRideScreen,
      page: () => const MyRideScreen(),
    ),
    GetPage(
      name: driverListScreen,
      page: () => const DriverListScreen(),
    ),
    GetPage(
      name: rideCompletePaymentScreen,
      page: () => const RideCompletePaymentScreen(),
    ),
    GetPage(
      name: profileScreen,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: notificationScreen,
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: languageScreen,
      page: () => const LanguageScreen(),
    ),
    GetPage(
      name: topUpScreen,
      page: () => const TopUpScreen(),
    ),
    GetPage(
      name: faqScreen,
      page: () => const FaqScreen(),
    ),
    GetPage(
      name: referAndEarn,
      page: () => const ReferAndEarn(),
    ),
  ];
}
