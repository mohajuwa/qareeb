import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/controllers/language_controller.dart';
import '../common_code/colore_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int value = 0;
  final LanguageController languageController = Get.find();

  final List<String> languageImages = [
    'assets/L-English.png',
    'assets/L-Arabic.png',
  ];

  final List<String> languageText = [
    'English',
    'Arabic',
  ];

  final List<String> languageCodes = [
    'en',
    'ar',
  ];

  ColorNotifier notifier = ColorNotifier();

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    await languageController.loadLocale();
    setState(() {
      String currentLang = languageController.locale.languageCode;
      value = (currentLang == 'ar') ? 1 : 0;
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: ListView.builder(
          itemCount: languageText.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                setState(() => value = index);
                await languageController.changeLocale(languageCodes[index]);
                Get.back();
              },
              child: Container(
                height: 60,
                width: Get.width,
                margin: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: value == index
                        ? theamcolore
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
                            image: AssetImage(languageImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        languageText[index],
                        style: TextStyle(
                          color: notifier.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (value == index)
                        Icon(Icons.check_circle, color: theamcolore, size: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
