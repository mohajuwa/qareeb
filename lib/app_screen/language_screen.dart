// lib/app_screen/language_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../common_code/colore_screen.dart';

bool rtl = false;

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int value = 0;

  List languageimage = [
    'assets/L-English.png',
    'assets/L-Arabic.png',
  ];

  List languagetext = [
    'English',
    'Arabic',
  ];

  List languagetext1 = [
    'en_English',
    'ur_arabic',
  ];

  @override
  void initState() {
    super.initState();
    // Set current language selection
    String currentLocale = Get.locale.toString();
    if (currentLocale.contains('ur') || currentLocale.contains('arabic')) {
      value = 1; // Arabic
    } else {
      value = 0; // English
    }
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
        title: Text(
          'Language'.tr,
          style: TextStyle(
            color: notifier.textColor,
            fontFamily: "SofiaProBold",
            fontSize: 18,
          ),
        ),
      ),
      backgroundColor: notifier.background,
      body: Column(
        children: [
          Container(
            height: 300,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                topLeft: Radius.circular(15),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: ListView.builder(
                itemCount: 2, // Only English and Arabic
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        value = index;
                      });

                      if (index == 1) {
                        // Arabic selected
                        setState(() {
                          rtl = true;
                        });
                        Get.updateLocale(const Locale('ur', 'arabic'));
                        Get.changeTheme(ThemeData(
                          fontFamily: 'Khebrat',
                          useMaterial3: false,
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          dividerColor: Colors.transparent,
                        ));
                      } else {
                        // English selected
                        setState(() {
                          rtl = false;
                        });
                        Get.updateLocale(const Locale('en', 'English'));
                        Get.changeTheme(ThemeData(
                          fontFamily: 'Khebrat',
                          useMaterial3: false,
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          dividerColor: Colors.transparent,
                        ));
                      }
                      Get.back();
                    },
                    child: Container(
                      height: 60,
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: value == index
                              ? Colors.blue
                              : Colors.grey.withOpacity(0.4),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        color: notifier.containercolore,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(languageimage[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              languagetext[index],
                              style: TextStyle(
                                color: notifier.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (value == index)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.blue,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
