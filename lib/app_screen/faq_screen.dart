import 'package:qareeb/common_code/custom_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../common_code/colore_screen.dart';
import '../api_code/faq_api_controller.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  FaqApiController faqApiController = Get.put(FaqApiController());

  @override
  void initState() {
    // TODO: implement initState
    faqApiController.faqlistapi(context);
    super.initState();
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      // backgroundColor: const Color(0xffF5F5F5),
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: theamcolore,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text('Faq List'.tr,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: GetBuilder<FaqApiController>(
        builder: (faqApiController) {
          return faqApiController.isLoading
              ? const Center(
                  child: CustomLoadingWidget(),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              width: 5,
                            );
                          },
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount:
                              faqApiController.faqApiiimodel!.faqList!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              // color: const Color(0xffEEEEEE),
                              color: notifier.languagecontainercolore,
                              margin: const EdgeInsets.all(10),
                              child: ExpansionTile(
                                collapsedIconColor: notifier.textColor,
                                iconColor: notifier.textColor,
                                textColor: const Color(0xff7D2AFF),
                                // collapsedTextColor: Color(0xff7D2AFF),
                                // backgroundColor: Color(0xff7D2AFF),
                                title: Text(
                                    '${faqApiController.faqApiiimodel!.faqList![index].title}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: notifier.textColor)),
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 17,
                                      ),
                                      Expanded(
                                          child: Text(
                                        '${faqApiController.faqApiiimodel!.faqList![index].description}',
                                        style: TextStyle(
                                            color: notifier.textColor),
                                      )),
                                      const SizedBox(
                                        width: 17,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
