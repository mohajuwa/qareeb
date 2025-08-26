import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'common_code/colore_screen.dart';
import 'common_code/common_button.dart';

class HourliRideScreen extends StatefulWidget {
  const HourliRideScreen({super.key});

  @override
  State<HourliRideScreen> createState() => _HourliRideScreenState();
}

class _HourliRideScreenState extends State<HourliRideScreen> {
  int hourvalue = 1;
  DateTime date = DateTime.now();
  DateTime time = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Image(
                      image: AssetImage("assets/arrow-left.png"),
                      height: 25,
                    )),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "How much time do you need?".tr,
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(
                  height: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (hourvalue > 1) {
                              hourvalue -= 1;
                            }
                            print("///----/:--- $hourvalue");
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: const Center(
                            child: Image(
                              image: AssetImage("assets/minus.png"),
                              color: Colors.black,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "$hourvalue hours",
                        style: const TextStyle(fontSize: 35),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          setState(() {
                            hourvalue += 1;
                            print("////:--- $hourvalue");
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: const Center(
                            child: Image(
                              image: AssetImage("assets/plus.png"),
                              color: Colors.black,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 100,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theamcolore,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          "Leave now".tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 120,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Text("Leave later".tr),
                            const Spacer(),
                            Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                color: theamcolore,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () {
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
                                const Spacer(),
                                Text(
                                  "Departure date".tr,
                                  style: const TextStyle(
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
                                                style: const TextStyle(
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
                                              mode:
                                                  CupertinoDatePickerMode.time,
                                              use24hFormat: true,
                                              onDateTimeChanged:
                                                  (DateTime newTime) {
                                                setState(() => time = newTime);
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
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
                                  txt1: "Next"),
                            )
                          ],
                        ),
                      ));
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Date and Time".tr,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "${date.month}-${date.day}-${date.year} - ${time.hour}:${time.minute}",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
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
              ],
            ),
          ),
          const Spacer(),
          Container(
            // height: 200,
            width: Get.width,
            color: Colors.grey.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Starting at".tr,
                        style: const TextStyle(fontSize: 22, color: Colors.black),
                      ),
                      const Spacer(),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "\$240.30",
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "\$60.08/hour",
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CommonButton(
                      containcolore: theamcolore,
                      onPressed1: () {},
                      context: context,
                      txt1: "Choose a ride".tr),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
