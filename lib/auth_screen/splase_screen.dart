// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_screen/map_screen.dart';
import '../app_screen/permisiion_scren.dart';
import '../common_code/colore_screen.dart';
import 'onbording_screen.dart';

class Splase_Screen extends StatefulWidget {
  const Splase_Screen({super.key});

  @override
  State<Splase_Screen> createState() => _Splase_ScreenState();
}

class _Splase_ScreenState extends State<Splase_Screen> {
  bool? isLogin;

  @override
  void initState() {
    super.initState();
    fun();
    getColor();
  }

  getColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("isDark");
    if (previusstate == null) {
      notifier.isAvailable(false);
    } else {
      notifier.isAvailable(previusstate);
    }
  }

  LocationPermission? permission;
  Future fun() async {
    getDataFromLocal().then((value) async {
      if (isLogin!) {
        Timer(const Duration(seconds: 3), () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => OnboardingScreen(),
              ),
              (route) => false);
        });
      } else {
        permission = await Geolocator.checkPermission();
        Timer(const Duration(seconds: 3), () {
          if (permission == LocationPermission.denied) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => PermissionScreen(),
                ),
                (route) => false);
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(
                    selectvihical: false,
                  ),
                ),
                (route) => false);
          }
        });
      }
    });

    // Timer(const Duration(seconds: 3), () {
    //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => OnboardingScreen(),), (route) => false);
    // });
  }

  Future getDataFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLogin = prefs.getBool("UserLogin") ?? true;
    });
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            darkMode == true
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
          ],
        ),
      ),
    );
  }

  // Future getDataFromLocal() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     isLogin = prefs.getBool("UserLogin") ?? true;
  //   });
  // }
}
