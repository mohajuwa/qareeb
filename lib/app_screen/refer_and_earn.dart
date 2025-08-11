// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qareeb/app_screen/home_screen.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/common_code/colore_screen.dart';

import '../api_code/refer_and_earn_api.dart';

class ReferAndEarn extends StatefulWidget {
  const ReferAndEarn({super.key});

  @override
  State<ReferAndEarn> createState() => _ReferAndEarnState();
}

class _ReferAndEarnState extends State<ReferAndEarn> {
  PackageInfo? packageInfo;
  String? appName;
  String? packageName;
  // late ByCoinProvider byCoinProvider;

  @override
  void initState() {
    super.initState();
    getPackage();
    referandearnapicontroller.referapi(uid: useridgloable.toString());
  }

  referandearnApiController referandearnapicontroller =
      Get.put(referandearnApiController());

  void getPackage() async {
    //! App details get
    packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo!.appName;
    packageName = packageInfo!.packageName;
  }

  Future<void> share() async {
    print("!!!!!.+_.-.-._+.!!!!!" + appName.toString());
    print("!!!!!.+_.-.-._+.!!!!!" + packageName.toString());

    final String text =
        'Hey! Now use our app to share with your family or friends. '
        'User will get wallet amount on your 1st successful transaction. '
        'Enter my referral code ${referandearnapicontroller.referAndEarnApiModel!.referData!.referralCode} & Enjoy your shopping !!!';

    final String linkUrl =
        'https://play.google.com/store/apps/details?id=$packageName';

    await Share.share(
      '$text\n$linkUrl',
      subject: appName,
    );
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      body: GetBuilder<referandearnApiController>(
        builder: (referandearnapicontroller) {
          return referandearnapicontroller.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  color: theamcolore,
                ))
              : Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: theamcolore,
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40, left: 15),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    "assets/svgpicture/BackIcon.svg",
                                    height: 25,
                                    width: 25,
                                    colorFilter: const ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Refer your friends".tr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 25,
                                                color: Colors.white)),
                                    Text("& Earn Coins!".tr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 25,
                                                color: Colors.white)),
                                  ],
                                ),
                                const Spacer(),
                                Lottie.asset('assets/lottie/referandearn2.json',
                                    height: 170)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: notifier.containercolore,
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                    text: "Invite all your friend to ".tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: notifier.textColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: "Qareeb".tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontSize: 20,
                                            color: theamcolore,
                                            fontWeight: FontWeight.bold)),
                              ])),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.6),
                                          shape: BoxShape.circle),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: "Your referred person gets ".tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: notifier.textColor)),
                                      TextSpan(
                                          text:
                                              "${appController.globalCurrency.value}${referandearnapicontroller.referAndEarnApiModel!.referData!.signupCredit}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: notifier.textColor,
                                                  fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              " coins when they sign up using your code"
                                                  .tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: notifier.textColor)),
                                    ])),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.6),
                                          shape: BoxShape.circle),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: "and you receive ".tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: notifier.textColor)),
                                      TextSpan(
                                          text:
                                              "${appController.globalCurrency.value}${referandearnapicontroller.referAndEarnApiModel!.referData!.referCredit}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: notifier.textColor,
                                                  fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              " coins when the person you referred purchases a membership."
                                                  .tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: notifier.textColor)),
                                    ])),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.6),
                                          shape: BoxShape.circle),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text:
                                              "Start inviting friends today and enjoy the benefits together!"
                                                  .tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: notifier.textColor)),
                                    ])),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 60,
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFe1e9f5),
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 40,
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${referandearnapicontroller.referAndEarnApiModel!.referData!.referralCode}",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: theamcolore),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                              text:
                                                  "${referandearnapicontroller.referAndEarnApiModel!.referData!.referralCode}"),
                                        );
                                      },
                                      child: Image(
                                        image: const AssetImage(
                                            'assets/copyicon.png'),
                                        height: 25,
                                        width: 25,
                                        color: theamcolore,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    // const SizedBox(width: 20,),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 60,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    share();
                                    // await FlutterShare.share(
                                    //     title: '$appName',
                                    //     text: 'Hey! Now use our app to share with your family or friends. User will get wallet coin on your 1st successful transaction. Enter my referral code 100 & Enjoy your day !!!',
                                    //     linkUrl: Platform.isAndroid
                                    //         ? 'https://play.google.com/store/apps/details?id=$packageName'
                                    //         : Platform.isIOS
                                    //         ? 'https://play.google.com/store/apps/details?id=$packageName'
                                    //         : "",
                                    //     chooserTitle: '$appName');
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStatePropertyAll(theamcolore),
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(35)))),
                                  child: Text("Refer a Friend".tr,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white)),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                );
        },
      ),
    );
  }
}
