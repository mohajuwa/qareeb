// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../common_code/colore_screen.dart';
import '../common_code/languge_controller.dart'; // Assuming this controller exists

bool rtl = false;

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int value = 0;
  final List languageimage = [
    'assets/L-English.png',
    'assets/L-Arabic.png',
  ];

  final List languagetext = [
    'English',
    'Arabic',
  ];

  final List<Locale> locales = [
    const Locale('en', 'US'),
    const Locale('ar', 'YE'),
  ];

  language1 language11 = Get.put(language1());

  void updateCurrentLocale() {
    final currentLocale = Get.locale;
    int newIndex = locales.indexWhere(
        (locale) => locale.languageCode == currentLocale?.languageCode);
    if (newIndex != -1) {
      setState(() {
        value = newIndex;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    updateCurrentLocale();
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: notifier.textColor),
        title: Text('Language'.tr,
            style: TextStyle(
                color: notifier.textColor,
                fontFamily: "SofiaProBold",
                fontSize: 18)),
      ),
      backgroundColor: notifier.background,
      body: Column(
        children: [
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15), topLeft: Radius.circular(15)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: languagetext.length, // Corrected itemCount
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              value = index;
                            });

                            // Update locale based on the selected index
                            if (index >= 0 && index < locales.length) {
                              Get.updateLocale(locales[index]);
                              // Get.back();
                            }
                          },
                          child: Container(
                            height: 60,
                            width: Get.width,
                            margin: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: value == index
                                      ? theamcolore
                                      : Colors.transparent,
                                ),
                                color: notifier.languagecontainercolore,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 45,
                                        width: 60,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: Center(
                                          child: Container(
                                            height: 32,
                                            width: 32,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              image: AssetImage(
                                                  languageimage[index]),
                                            )),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(languagetext[index],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: notifier.textColor)),
                                        ],
                                      ),
                                      const Spacer(),
                                      CheckboxListTile(index),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                ]),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget CheckboxListTile(int index) {
    return SizedBox(
      height: 24,
      width: 24,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            value = index;
          });
          if (index >= 0 && index < locales.length) {
            Get.updateLocale(locales[index]);
            // Get.back();
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xffEEEEEE),
          side: BorderSide(
            color: (value == index) ? Colors.transparent : Colors.transparent,
            width: (value == index) ? 2 : 2,
          ),
          padding: const EdgeInsets.all(0),
        ),
        child: Center(
            child: Icon(
          Icons.check,
          color: value == index ? Colors.black : Colors.transparent,
          size: 18,
        )),
      ),
    );
  }
}
