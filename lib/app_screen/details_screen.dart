// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qareeb/app_screen/map_screen.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart';
import 'package:qareeb/common_code/colore_screen.dart';

import '../common_code/common_button.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List grideimage = [
    "assets/bg1.png",
    "assets/bg2.png",
    "assets/bg3.png",
    "assets/bg1.png",
    "assets/bg2.png",
    "assets/bg3.png",
    "assets/bg1.png",
    "assets/bg2.png",
  ];

  List gridetext = [
    "Auto",
    "Ride",
    "Moto",
    "Outstation",
    "Delivery",
    "Auto",
    "Ride",
    "Moto",
  ];

  int select1 = 0;
  int select2 = 0;

  List secoundetext = [
    "Private ride",
    "Parcel",
  ];

  List secoundeimage = [
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRWzRVDCjuw3pWm_iOYDfwakpyk4AG5ag2c0dC56u5TpZd3sKakUE7k_TWXTamtEsYplcI&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0Jw9Ct4k1QPxbdsF5DQpi9tBBYGOlQ5L6HIhg8jStLXuZxl8oaUvX16H_JnUBX6XDCn0&usqp=CAU",
  ];

  DateTime date = DateTime.now();
  DateTime time = DateTime.now();

  // void _showDialog(Widget child) {
  //   showCupertinoModalPopup<void>(
  //     context: context,
  //     builder: (BuildContext context) => Container(
  //       height: 216,
  //       padding: const EdgeInsets.only(top: 6.0),
  //       // The Bottom margin is provided to align the popup above the system
  //       // navigation bar.
  //       margin: EdgeInsets.only(
  //         bottom: MediaQuery.of(context).viewInsets.bottom,
  //       ),
  //       // Provide a background color for the popup.
  //       color: CupertinoColors.systemBackground.resolveFrom(context),
  //       // Use a SafeArea widget to avoid system overlaps.
  //       child: SafeArea(
  //         top: false,
  //         child: child,
  //       ),
  //     ),
  //   );
  // }

  TextEditingController amountcontroller = TextEditingController();
  String mainAmount = "";
  double _currentSliderValue = 0;
  bool light = true;

  void _navigateAndRefresh() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const PickupDropPoint(
                  pagestate: true,
                  bidding: "3",
                )));
    if (result != null && result.shouldRefresh) {
      _refreshPage();
    }
  }

  void _refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: CommonButton(
            containcolore: theamcolore,
            onPressed1: () {},
            context: context,
            txt1: "Find a driver".tr),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(15),
          child: Image(
            image: AssetImage("assets/menu.png"),
            height: 20,
          ),
        ),
        centerTitle: true,
        title: Text(
          "City to city".tr,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: gridetext.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                select1 = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                height: 50,
                                // width: 100,
                                decoration: BoxDecoration(
                                  color: select1 == index
                                      ? theamcolore.withOpacity(0.08)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: select1 == index
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Image(
                                            image: AssetImage(
                                                "${grideimage[index]}"),
                                            height: 40,
                                          ),
                                          select1 == index
                                              ? const SizedBox(
                                                  width: 5,
                                                )
                                              : const SizedBox(),
                                          select1 == index
                                              ? Image(
                                                  image: const AssetImage(
                                                      "assets/info-circle.png"),
                                                  height: 25,
                                                  color: theamcolore,
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text("${gridetext[index]}"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      // _navigateAndRefresh();
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15)),
                        ),
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 750,
                            // color: Colors.red,
                            child: const Column(
                              children: [
                                // _navigateAndRefresh();
                                Expanded(
                                    child: PickupDropPoint(
                                  pagestate: true,
                                  bidding: "3",
                                )),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("From".tr),
                        subtitle: pickupcontroller.text.isEmpty
                            ? SizedBox()
                            : Text("${pickupcontroller.text}"),
                        trailing: Image(
                          image: AssetImage("assets/angle-right-small.png"),
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      // _navigateAndRefresh();
                      showModalBottomSheet(
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15)),
                        ),
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 750,
                            // color: Colors.red,
                            child: const Column(
                              children: [
                                // _navigateAndRefresh();
                                Expanded(
                                    child: PickupDropPoint(
                                  pagestate: true,
                                  bidding: "3",
                                )),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("To".tr),
                        subtitle: dropcontroller.text.isEmpty
                            ? SizedBox()
                            : Text("${dropcontroller.text}"),
                        trailing: Image(
                          image: AssetImage("assets/angle-right-small.png"),
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: 2,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                select2 = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                height: 50,
                                // width: 100,
                                decoration: BoxDecoration(
                                  color: select2 == index
                                      ? theamcolore.withOpacity(0.08)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: select2 == index
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Image(
                                            image: NetworkImage(
                                                "${secoundeimage[index]}"),
                                            height: 40,
                                          ),
                                          select2 == index
                                              ? const SizedBox(
                                                  width: 5,
                                                )
                                              : const SizedBox(),
                                          select2 == index
                                              ? Image(
                                                  image: const AssetImage(
                                                      "assets/info-circle.png"),
                                                  height: 25,
                                                  color: theamcolore,
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text("${secoundetext[index]}"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        // _showDialog(
                        //   CupertinoDatePicker(
                        //     initialDateTime: date,
                        //     mode: CupertinoDatePickerMode.date,
                        //     use24hFormat: true,
                        //     showDayOfWeek: false,
                        //     onDateTimeChanged: (DateTime newDate) {
                        //       setState(() => date = newDate);
                        //     },
                        //   ),
                        // );
                        Get.bottomSheet(Container(
                          height: 300,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  // InkWell(
                                  //     onTap: () {
                                  //       Get.back();
                                  //     },
                                  //     child: Image(image: AssetImage("assets/arrow-left.png"),height: 25,)),
                                  const Spacer(),
                                  Text(
                                    "Departure date".tr,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: const Image(
                                        image: AssetImage("assets/close.png"),
                                        height: 25,
                                      )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              // SizedBox(height: 20,),
                              Expanded(
                                child: CupertinoDatePicker(
                                  initialDateTime: date,
                                  mode: CupertinoDatePickerMode.date,
                                  use24hFormat: true,
                                  showDayOfWeek: false,
                                  onDateTimeChanged: (DateTime newDate) {
                                    setState(() => date = newDate);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CommonButton(
                                    containcolore: theamcolore,
                                    onPressed1: () {
                                      Get.back();
                                      Get.bottomSheet(Container(
                                        height: 450,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(15),
                                              topLeft: Radius.circular(15)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                InkWell(
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    child: const Image(
                                                      image: AssetImage(
                                                          "assets/arrow-left.png"),
                                                      height: 25,
                                                    )),
                                                const Spacer(),
                                                Text(
                                                  "Departure time".tr,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20),
                                                ),
                                                const Spacer(),
                                                InkWell(
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    child: const Image(
                                                      image: AssetImage(
                                                          "assets/close.png"),
                                                      height: 25,
                                                    )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                              ],
                                            ),
                                            // SizedBox(height: 20,),
                                            Expanded(
                                              child: CupertinoDatePicker(
                                                initialDateTime: time,
                                                mode: CupertinoDatePickerMode
                                                    .time,
                                                use24hFormat: true,
                                                onDateTimeChanged:
                                                    (DateTime newTime) {
                                                  setState(
                                                      () => time = newTime);
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: CommonButton(
                                                  containcolore: theamcolore,
                                                  onPressed1: () {
                                                    Get.back();
                                                  },
                                                  context: context,
                                                  txt1: "Done".tr),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  top: 4.0,
                                                  bottom: 8.0,
                                                  right: 8.0),
                                              child: CommonOutLineButton(
                                                  bordercolore: theamcolore,
                                                  onPressed1: () {
                                                    Get.back();
                                                  },
                                                  context: context,
                                                  txt1: "Skip".tr),
                                            ),
                                          ],
                                        ),
                                      ));
                                    },
                                    context: context,
                                    txt1: "Next".tr),
                              )
                            ],
                          ),
                        ));
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "When".tr,
                          style: TextStyle(color: Colors.grey),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "${date.month}-${date.day}-${date.year},${time.hour}:${time.minute}",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                        ),
                        // subtitle: Text("Vishal Nagar,Ashok Nagar,Katargam,Surat"),
                        trailing: const Image(
                          image: AssetImage("assets/angle-right-small.png"),
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Get.bottomSheet(StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              height: 200,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15)),
                              ),
                              child: counterpaggentbottomshhet(),
                            );
                          },
                        )).then(
                          (value) {
                            setState(() {});
                          },
                        );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Number of passengers".tr,
                            style: TextStyle(color: Colors.grey)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text("$passengervalue",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black)),
                        ),
                        trailing: const Image(
                          image: AssetImage("assets/angle-right-small.png"),
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    // height: 30,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: theamcolore.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Text("Recommended fare: ${globalcurrency} 3350".tr)
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Get.bottomSheet(StatefulBuilder(
                        builder: (context, setState) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 400,
                                width: Get.width,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "Set your price".tr,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text("We charge no commission. Full".tr,
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text("amount goes to the captain".tr,
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        // SizedBox(height: 30,),
                                        Center(
                                          child: SizedBox(
                                            width: 150,
                                            child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: amountcontroller,
                                              textAlign: TextAlign.center,
                                              style:
                                                  const TextStyle(fontSize: 30),
                                              onChanged: (value) {
                                                setState(() {
                                                  mainAmount =
                                                      amountcontroller.text;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Text(
                                          "Higher the price,higher the chance of"
                                              .tr,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          "getting a ride".tr,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        // Text("+${_currentSliderValue.round().toString()}",style: TextStyle(color: Colors.black),),
                                        Slider(
                                          value: _currentSliderValue,
                                          max: 100,
                                          min: -100,
                                          divisions: 10,
                                          activeColor: theamcolore,
                                          label: _currentSliderValue
                                              .round()
                                              .toString(),
                                          onChanged: (double value) {
                                            setState(() {
                                              _currentSliderValue = value;

                                              amountcontroller.text =
                                                  mainAmount;

                                              if (_currentSliderValue < 0) {
                                                amountcontroller.text =
                                                    "${double.parse(amountcontroller.text) + _currentSliderValue}";
                                              } else {
                                                amountcontroller.text =
                                                    "${double.parse(amountcontroller.text) + _currentSliderValue}";
                                              }

                                              print(
                                                  "+++++++hhhhh++++:-- ${amountcontroller.text}");
                                            });
                                          },
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: const Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Icon(
                                              Icons.telegram,
                                              size: 30,
                                            ),
                                          ),
                                          title: Text(
                                            "Automatically accept the nearest driver for your fare"
                                                .tr,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),
                                          trailing: SizedBox(
                                            height: 20,
                                            width: 30,
                                            child: Transform.scale(
                                              scale: 0.7,
                                              child: CupertinoSwitch(
                                                // This bool value toggles the switch.
                                                value: light,
                                                activeColor: theamcolore,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    light = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Spacer(),
                                        CommonButton(
                                            containcolore: theamcolore,
                                            onPressed1: () {
                                              Get.back();
                                            },
                                            txt1:
                                                "Book Auto for ${globalcurrency}45",
                                            context: context),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -50,
                                left: 5,
                                child: InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle),
                                      child: const Center(
                                          child: Image(
                                        image:
                                            AssetImage("assets/arrow-left.png"),
                                        height: 20,
                                      ))),
                                ),
                              )
                            ],
                          );
                        },
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Offer your fare".tr),
                        // subtitle: Text("Vishal Nagar,Ashok Nagar,Katargam,Surat"),
                        trailing: Image(
                          image: AssetImage("assets/angle-right-small.png"),
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("Comments".tr),
                      // subtitle: Text("Vishal Nagar,Ashok Nagar,Katargam,Surat"),
                      trailing: Image(
                        image: AssetImage("assets/angle-right-small.png"),
                        height: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

int passengervalue = 1;

class counterpaggentbottomshhet extends StatefulWidget {
  counterpaggentbottomshhet({super.key});

  @override
  State<counterpaggentbottomshhet> createState() =>
      _counterpaggentbottomshhetState();
}

class _counterpaggentbottomshhetState extends State<counterpaggentbottomshhet> {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Spacer(),
                Text(
                  "How many of you will go?".tr,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const Spacer(),
                InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Image(
                      image: AssetImage("assets/close.png"),
                      height: 25,
                    )),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
            const Spacer(),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        if (passengervalue > 1) {
                          passengervalue -= 1;
                        }
                        print("///----/:--- $passengervalue");
                      });
                    },
                    child: const Image(
                      image: AssetImage("assets/minus.png"),
                      height: 30,
                    )),
                const Spacer(),
                Text(
                  "$passengervalue",
                  style: const TextStyle(fontSize: 25),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    setState(() {
                      passengervalue += 1;
                      print("////:--- $passengervalue");
                    });
                  },
                  child: const Image(
                    image: AssetImage("assets/plus.png"),
                    height: 30,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CommonButton(
                  containcolore: theamcolore,
                  onPressed1: () {
                    setState(() {
                      Get.back();
                      // passengervalue = passengervalue;
                    });
                  },
                  context: context,
                  txt1: "Done".tr),
            )
          ],
        );
      },
    );
  }
}
