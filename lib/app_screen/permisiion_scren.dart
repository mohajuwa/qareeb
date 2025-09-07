import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import '../common_code/push_notification.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with TickerProviderStateMixin {
  var decodeUid;
  LocationPermission? permission;
  ColorNotifier notifier = ColorNotifier();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _loadUserData();

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  _loadUserData() async {
    final preferences = await SharedPreferences.getInstance();
    final uid = preferences.getString("userLogin");
    if (uid != null) {
      decodeUid = jsonDecode(uid);
      if (kDebugMode) {
        print("Login ID: ${decodeUid["id"]}");
      }
    }
  }

  Future<void> _requestLocation() async {
    try {
      // Check current permission status
      permission = await Geolocator.checkPermission();
      if (kDebugMode) print("Current permission: $permission");

      // If denied, request permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (kDebugMode) print("Requested permission: $permission");
      }

      // Handle different permission states
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Permission granted - show notification bottom sheet
        if (kDebugMode) print("Location permission granted");
        _showNotificationBottomSheet();
      } else if (permission == LocationPermission.deniedForever) {
        // Permission permanently denied - show settings dialog
        if (kDebugMode) print("Location permission denied forever");
        _showSettingsDialog();
      } else if (permission == LocationPermission.denied) {
        // Permission denied this time - show retry option
        if (kDebugMode) print("Location permission denied");
        _showRetryDialog();
      }
    } catch (e) {
      if (kDebugMode) print("Error requesting location permission: $e");
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error requesting location permission: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Permission Required"),
        content: Text(
          "Location permission is permanently denied. Please enable it in device settings to use this feature.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Permission Needed"),
        content: Text(
          "We need location permission to provide you with the best ride experience. Would you like to try again?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestLocation();
            },
            child: Text("Try Again"),
          ),
        ],
      ),
    );
  }

  void _showNotificationBottomSheet() {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        decoration: BoxDecoration(
          color: notifier.containercolore,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 24),

                // Header with icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theamcolore.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: theamcolore,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                _buildHeader(),
                const SizedBox(height: 24),

                // Feature cards
                _buildFeatureCard(
                  Icons.location_on,
                  "Real-time Captain updates".tr,
                  "Get notified about captain's allocation, arrival and more"
                      .tr,
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  Icons.local_offer,
                  "Offer and news",
                  "Be the first to know about our offers and new features".tr,
                ),
                const SizedBox(height: 32),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Stay Connected".tr,
          style: TextStyle(
            color: notifier.textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Allow Notifications and on-ride alerts".tr,
          style: TextStyle(
            color: notifier.textColor.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.textColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notifier.textColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theamcolore.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theamcolore,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: notifier.textColor.withOpacity(0.6),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theamcolore.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CommonButton(
            containcolore: theamcolore,
            onPressed1: () => _handleNotificationAllow(),
            context: context,
            txt1: "Allow".tr,
          ),
        ),
        const SizedBox(height: 12),
        CommonOutLineButton(
          bordercolore: Colors.grey,
          onPressed1: () => Get.back(),
          context: context,
          txt1: "Maybe, later".tr,
        ),
      ],
    );
  }

  void _handleNotificationAllow() {
    initPlatformState();
    if (decodeUid != null) {
      final sendTags = {
        'subscription_user_Type': 'customer',
        'Login_ID': decodeUid["id"].toString()
      };
      OneSignal.User.addTags(sendTags);
    }
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    return Scaffold(
      backgroundColor: notifier.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Animated Lottie
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theamcolore.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Lottie.asset(
                    "assets/lottie/location_permission.json",
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Animated content
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Main title
                      Text(
                        "Location permission not enabled".tr,
                        style: TextStyle(
                          color: notifier.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        "Sharing Location permission helps us improve your ride booking and pickup experience"
                            .tr,
                        style: TextStyle(
                          color: notifier.textColor.withOpacity(0.7),
                          fontSize: 16,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Benefits section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: notifier.textColor.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: notifier.textColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildBenefit(
                              Icons.my_location,
                              "Accurate pickup location",
                              "We'll find you faster",
                            ),
                            const SizedBox(height: 16),
                            _buildBenefit(
                              Icons.route,
                              "Better route suggestions",
                              "Optimized travel experience",
                            ),
                            const SizedBox(height: 16),
                            _buildBenefit(
                              Icons.security,
                              "Enhanced safety",
                              "Your trips are tracked securely",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Bottom buttons
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theamcolore.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CommonButton(
                          containcolore: theamcolore,
                          onPressed1: _requestLocation,
                          context: context,
                          txt1: "Allow Permission".tr,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CommonOutLineButton(
                        bordercolore: Colors.grey,
                        onPressed1: () {},
                        context: context,
                        txt1: "Enter pickup manually".tr,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theamcolore.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theamcolore,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: notifier.textColor.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
