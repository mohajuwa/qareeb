// lib/auth_screen/splase_screen.dart - FIXED VERSION
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_screen/map_screen.dart';
import '../app_screen/permisiion_scren.dart';
import '../common_code/colore_screen.dart';
import '../services/socket_service.dart';
import 'onbording_screen.dart';

class Splase_Screen extends StatefulWidget {
  const Splase_Screen({super.key});

  @override
  State<Splase_Screen> createState() => _Splase_ScreenState();
}

class _Splase_ScreenState extends State<Splase_Screen> {
  bool? isLoggedIn;
  LocationPermission? permission;
  ColorNotifier notifier = ColorNotifier();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // ✅ MAIN INITIALIZATION METHOD
  Future<void> _initializeApp() async {
    try {
      // Step 1: Get color theme
      await _getColorTheme();

      // Step 2: Check login status
      await _checkLoginStatus();

      // Step 3: Initialize socket if user is logged in
      if (isLoggedIn == false) {
        // User IS logged in (remember the logic is reversed)
        await _initializeSocket();
      }

      // Step 4: Navigate after delay
      Timer(const Duration(seconds: 3), () {
        _navigateToNextScreen();
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error in splash initialization: $e");
      }
      // Fallback navigation after delay
      Timer(const Duration(seconds: 3), () {
        _navigateToNextScreen();
      });
    }
  }

  // ✅ GET COLOR THEME
  Future<void> _getColorTheme() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? previousState = prefs.getBool("isDark");

      if (previousState == null) {
        notifier.isAvailable(false);
      } else {
        notifier.isAvailable(previousState);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting color theme: $e");
      }
      notifier.isAvailable(false); // Default to light mode
    }
  }

  // ✅ CHECK LOGIN STATUS
  Future<void> _checkLoginStatus() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // ⚠️ IMPORTANT: The logic is reversed in this app
      // UserLogin = true means NOT logged in
      // UserLogin = false means logged in
      setState(() {
        isLoggedIn =
            prefs.getBool("UserLogin") ?? true; // Default to NOT logged in
      });

      if (kDebugMode) {
        print(
            "Login status check - isLoggedIn: $isLoggedIn (true = NOT logged in)");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error checking login status: $e");
      }
      setState(() {
        isLoggedIn = true; // Default to NOT logged in on error
      });
    }
  }

  // ✅ INITIALIZE SOCKET FOR LOGGED IN USERS
  Future<void> _initializeSocket() async {
    try {
      final socketService = Get.find<SocketService>();

      if (kDebugMode) {
        print("Initializing socket for logged in user...");
      }

      // Connect socket with timeout
      await socketService.connect().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) {
            print(
                "Socket connection timeout during splash - proceeding anyway");
          }
        },
      );

      if (kDebugMode) {
        print("Socket initialization completed: ${socketService.isConnected}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Socket initialization error: $e - proceeding anyway");
      }
      // Don't block navigation if socket fails
    }
  }

  // ✅ NAVIGATE TO APPROPRIATE SCREEN
  Future<void> _navigateToNextScreen() async {
    try {
      if (isLoggedIn == true) {
        // User is NOT logged in - go to onboarding
        if (kDebugMode) {
          print("User not logged in - navigating to onboarding");
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      } else {
        // User IS logged in - check permissions then go to map
        if (kDebugMode) {
          print("User logged in - checking permissions");
        }

        await _checkPermissionsAndNavigate();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Navigation error: $e");
      }
      // Fallback to onboarding
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  // ✅ CHECK LOCATION PERMISSIONS
  Future<void> _checkPermissionsAndNavigate() async {
    try {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print("Location permission denied - navigating to permission screen");
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PermissionScreen()),
          (route) => false,
        );
      } else {
        if (kDebugMode) {
          print("Location permission granted - navigating to map screen");
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(selectvihical: false),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Permission check error: $e");
      }

      // Fallback to permission screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PermissionScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Scaffold(
      backgroundColor: notifier.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show loading indicator
            if (isLoggedIn == null) const CircularProgressIndicator(),

            // Show app logo
            AnimatedOpacity(
              opacity: isLoggedIn != null ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 500),
              child: notifier.isDark == true
                  ? SvgPicture.asset(
                      "assets/svgpicture/app_logo_light.svg",
                      height: 250,
                      width: 250,
                    )
                  : SvgPicture.asset(
                      "assets/svgpicture/app_logo_dark.svg",
                      height: 250,
                      width: 250,
                    ),
            ),

            const SizedBox(height: 20),

            // Debug info (only in debug mode)
            if (kDebugMode && isLoggedIn != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Login Status: ${isLoggedIn == true ? 'Not Logged In' : 'Logged In'}",
                  style: TextStyle(
                    color: notifier.textColor?.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
