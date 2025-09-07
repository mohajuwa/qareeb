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

class _LanguageScreenState extends State<LanguageScreen>
    with TickerProviderStateMixin {
  int value = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Only Arabic and English
  List languageimage = [
    'assets/L-Arabic.png',
    'assets/L-English.png',
  ];

  List languagetext = [
    'العربية',
    'English',
  ];

  // Proper locale codes that match what we set
  List<Locale> languageLocales = [
    const Locale('ur', 'arabic'), // Arabic
    const Locale('en', 'US'), // English
  ];

  language1 language11 = Get.put(language1());

  fun() {
    print("Current locale: ${Get.locale}");

    // Check current locale and set the correct selection
    for (int a = 0; a < languageLocales.length; a++) {
      print("Checking: ${languageLocales[a]}");

      // Compare language codes properly
      if (Get.locale != null &&
          Get.locale!.languageCode == languageLocales[a].languageCode) {
        setState(() {
          value = a;
          print("Selected language index: $a");
        });
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    fun();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  ColorNotifier notifier = ColorNotifier();

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: notifier.textColor),
        title: Text(
          'Language'.tr,
          style: TextStyle(
            color: notifier.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text
              Text(
                'Choose your preferred language'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: notifier.textColor.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              // Language Options - FIXED: itemCount now matches array length
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: languagetext.length, // FIXED: was 8, now 2
                  itemBuilder: (context, index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200 + (index * 100)),
                      curve: Curves.easeOutBack,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          splashColor: theamcolore.withOpacity(0.1),
                          highlightColor: theamcolore.withOpacity(0.05),
                          onTap: () {
                            setState(() {
                              value = index;
                            });

                            // Handle RTL for Arabic
                            if (index == 0) {
                              // Arabic
                              setState(() {
                                rtl = true;
                                print(
                                    "++++++++++Arabic selected+++++++++++${rtl}");
                              });
                            } else {
                              // English
                              setState(() {
                                rtl = false;
                                print(
                                    "+++++++++++English selected++++++++++${rtl}");
                              });
                            }

                            // Update locale and go back
                            switch (index) {
                              case 0:
                                Get.updateLocale(const Locale('ur', 'arabic'));
                                break;
                              case 1:
                                Get.updateLocale(const Locale('en', 'US'));
                                break;
                            }

                            // Delay to show selection animation then go back
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              Get.back();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: value == index
                                  ? theamcolore.withOpacity(0.1)
                                  : notifier.containercolore,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: value == index
                                    ? theamcolore
                                    : Colors.grey.withOpacity(0.2),
                                width: value == index ? 2 : 1,
                              ),
                              boxShadow: [
                                if (value == index)
                                  BoxShadow(
                                    color: theamcolore.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Language Flag/Icon
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      languageimage[index],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // Fallback icon if image not found
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: theamcolore.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.language,
                                            color: theamcolore,
                                            size: 24,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Language Name
                                Expanded(
                                  child: Text(
                                    languagetext[index],
                                    style: TextStyle(
                                      fontWeight: value == index
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: 18,
                                      color: value == index
                                          ? theamcolore
                                          : notifier.textColor,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),

                                // Selection Indicator
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: value == index
                                        ? theamcolore
                                        : Colors.grey.withOpacity(0.3),
                                    border: Border.all(
                                      color: value == index
                                          ? theamcolore
                                          : Colors.grey.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: value == index
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                            key: ValueKey('selected'),
                                          )
                                        : const SizedBox(
                                            key: ValueKey('unselected'),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Info Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theamcolore.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theamcolore.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theamcolore,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'App will restart to apply language changes'.tr,
                        style: TextStyle(
                          color: theamcolore,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
