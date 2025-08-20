import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'map_screen.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import '../common_code/push_notification.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  var decodeUid;
  LocationPermission? permission;
  ColorNotifier notifier = ColorNotifier();

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();

    if (permission != LocationPermission.denied) {
      _showNotificationBottomSheet();
    }
  }

  void _showNotificationBottomSheet() {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: notifier.containercolore,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  height: 4,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                _buildHeader(),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  "assets/svgpicture/image2.svg",
                  "Real-time Captain updates".tr,
                  "Get notified about captain's allocation, arrival and more"
                      .tr,
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  "assets/svgpicture/image3.svg",
                  "Offer and news",
                  "Be the first to know about our offers and new features".tr,
                ),
                const SizedBox(height: 20),
                _buildButtons(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          SvgPicture.asset("assets/svgpicture/image1.svg", height: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Allow Notifications and on-ride alerts".tr,
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String iconPath, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(iconPath, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
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
        CommonButton(
          containcolore: theamcolore,
          onPressed1: () => _handleNotificationAllow(),
          context: context,
          txt1: "Allow".tr,
        ),
        const SizedBox(height: 8),
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
      body: Column(
        children: [
          const SizedBox(height: 40),
          Lottie.asset(
            "assets/lottie/location_permission.json",
            height: 160,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text(
                  "Location permission not enabled".tr,
                  style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sharing Location permission helps us improve your ride booking and pickup experience"
                      .tr,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                CommonButton(
                  containcolore: theamcolore,
                  onPressed1: _requestLocation,
                  context: context,
                  txt1: "Allow Permission".tr,
                ),
                const SizedBox(height: 8),
                CommonOutLineButton(
                  bordercolore: Colors.grey,
                  onPressed1: () {},
                  context: context,
                  txt1: "Enter pickup manually".tr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
