// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../api_code/notification_api_controller.dart';
import 'home_screen.dart';
import '../common_code/colore_screen.dart';
import '../common_code/config.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    // TODO: implement initState
    notificationApiController.notificationApi(uid: useridgloable.toString());
    super.initState();
  }

  NotificationApiController notificationApiController =
      Get.put(NotificationApiController());
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
        iconTheme: IconThemeData(
          color: notifier.textColor,
        ),
        title: Text('Notification'.tr,
            style: TextStyle(
                color: notifier.textColor,
                
                fontSize: 18)),
      ),
      backgroundColor: notifier.background,
      body: GetBuilder<NotificationApiController>(
        builder: (notificationApiController) {
          return notificationApiController.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  color: theamcolore,
                ))
              : notificationApiController.notiFicationApiModel!.ndata!.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                            child: Text(
                          "No New Notifications".tr,
                          style: TextStyle(color: notifier.textColor),
                        )),
                        Center(
                            child: Text(
                          "Looks like you haven't received any notification".tr,
                          style: TextStyle(color: notifier.textColor),
                        )),
                      ],
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
                              itemCount: notificationApiController
                                  .notiFicationApiModel!.ndata!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      notificationApiController
                                                  .notiFicationApiModel!
                                                  .ndata![index]
                                                  .image ==
                                              ""
                                          ? const SizedBox()
                                          : Get.bottomSheet(
                                              StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Container(
                                                    // height: 460,
                                                    width: Get.width,
                                                    decoration: BoxDecoration(
                                                      color: notifier
                                                          .containercolore,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(15),
                                                              topRight: Radius
                                                                  .circular(
                                                                      15)),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // SizedBox(height: 20,),
                                                          Row(
                                                            children: [
                                                              // const Spacer(),
                                                              Text(
                                                                  notificationApiController
                                                                      .notiFicationApiModel!
                                                                      .ndata![
                                                                          index]
                                                                      .date
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey)),
                                                            ],
                                                          ),
                                                          Center(
                                                              child: Image(
                                                            image: NetworkImage(
                                                                "${Config.imageurl}${notificationApiController.notiFicationApiModel!.ndata![index].image}"),
                                                            height: 200,
                                                            width: 200,
                                                          )),
                                                          Text(
                                                              notificationApiController
                                                                  .notiFicationApiModel!
                                                                  .ndata![index]
                                                                  .title
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor,
                                                                  fontSize:
                                                                      18)),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                              notificationApiController
                                                                  .notiFicationApiModel!
                                                                  .ndata![index]
                                                                  .description
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey)),
                                                          // SizedBox(height: 20,),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  Colors.grey.withOpacity(0.4)),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          notificationApiController
                                                      .notiFicationApiModel!
                                                      .ndata![index]
                                                      .image ==
                                                  ""
                                              ? const SizedBox()
                                              : Container(
                                                  height: 35,
                                                  width: 35,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: greaycolore),
                                                  child: Image(
                                                      image: NetworkImage(
                                                          "${Config.imageurl}${notificationApiController.notiFicationApiModel!.ndata![index].image}"))),
                                          notificationApiController
                                                      .notiFicationApiModel!
                                                      .ndata![index]
                                                      .image ==
                                                  ""
                                              ? const SizedBox()
                                              : const SizedBox(
                                                  width: 15,
                                                ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                        notificationApiController
                                                            .notiFicationApiModel!
                                                            .ndata![index]
                                                            .title
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: notifier
                                                                .textColor)),
                                                    const Spacer(),
                                                    Flexible(
                                                        child: Text(
                                                            notificationApiController
                                                                .notiFicationApiModel!
                                                                .ndata![index]
                                                                .date
                                                                .toString(),
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis))),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  notificationApiController
                                                      .notiFicationApiModel!
                                                      .ndata![index]
                                                      .description
                                                      .toString(),
                                                  style: TextStyle(
                                                      color:
                                                          notifier.textColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                    );
        },
      ),
    );
  }
}
