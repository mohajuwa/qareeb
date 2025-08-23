// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../common_code/colore_screen.dart';
import '../common_code/languge_controller.dart';

bool rtl = false;

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int value = 0;
  List languageimage = [
    'assets/L-Arabic.png',
    'assets/L-English.png',
  ];

  List languagetext = [
    'Arabic',
    'English',
  ];

  List languagetext1 = [
    'ur_arabic',
    'en_English',
  ];

  language1 language11 = Get.put(language1());

  fun() {
    for (int a = 0; a < languagetext1.length; a++) {
      print(languagetext1[a]);
      print(Get.locale);
      if (languagetext1[a].toString().compareTo(Get.locale.toString()) == 0) {
        setState(() {
          value = a;
        });
      } else {}
    }
  }

  @override
  void initState() {
    fun();
    // TODO: implement initState
    super.initState();
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
        // automaticallyImplyLeading: false,
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
            height: 610,
            decoration: BoxDecoration(
              // color: notifier.languagecontainercolore,
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
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              value = index;
                            });

                            if (index == 2) {
                              setState(() {
                                rtl = true;
                                print("++++++++++if+++++++++++${rtl}");
                              });
                            } else {
                              setState(() {
                                rtl = false;
                                print("+++++++++++else++++++++++${rtl}");
                              });
                            }

                            switch (index) {
                              case 0:
                                Get.updateLocale(const Locale('ur', 'arabic'));
                                Get.back();
                                // homeController.setselectpage(0);
                                break;
                              case 1:
                                Get.updateLocale(const Locale('en', 'English'));
                                Get.back();
                                // homeController.setselectpage(0);
                                break;
                            }
                          },
                          // onTap: () {},
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
          value = index;
          setState(() {
            value = index;

            switch (index) {
              case 0:
                Get.updateLocale(const Locale('en', 'English'));
                Get.back();
                break;
              case 1:
                Get.updateLocale(const Locale('en', 'spanse'));
                Get.back();
                break;
              case 2:
                Get.updateLocale(const Locale('en', 'arabic'));
                Get.back();
                break;
              case 3:
                Get.updateLocale(const Locale('en', 'Hindi'));
                Get.back();
                break;
              case 4:
                Get.updateLocale(const Locale('en', 'Gujarati'));
                Get.back();
                break;
              case 5:
                Get.updateLocale(const Locale('en', 'African'));
                Get.back();
                break;
              case 6:
                Get.updateLocale(const Locale('en', 'Bangali'));
                Get.back();
                break;
              case 7:
                Get.updateLocale(const Locale('en', 'Indonesiya'));
                Get.back();
            }
          });
        },
        // onPressed: () {
        //
        // },
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
