// ignore_for_file: unnecessary_import

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import '../app_screen/map_screen.dart';
import '../api_code/my_ride_detail_api.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> makePdf() async {
  MyRideDetailApiController myRideDetailApiController =
      Get.put(MyRideDetailApiController());

  // final pdf = Document();
  final pdf = pw.Document();
  // final netImage = await networkImage('${config().baseUrl}/${data1?.tickethistory[0].busImg}');
  // final netImage1 = await networkImage('${data1?.tickethistory[0].qrcode}');
  // final imageLogo = MemoryImage((await rootBundle.load('assets/Group 3.png')).buffer.asUint8List());
  // final imageLogo1 = MemoryImage((await rootBundle.load('assets/Auto Layout Horizontal.png')).buffer.asUint8List());
  // final imageLogo2 = MemoryImage((await rootBundle.load('assets/Rectangle_2.png')).buffer.asUint8List());

  pdf.addPage(MultiPage(
    build: (context) {
      return [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            pw.Container(
              color: PdfColors.white,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Column(
                        //   children: [
                        //     Container(
                        //       height: 20,
                        //       width: 20,
                        //       decoration: BoxDecoration(
                        //           color: PdfColors.grey,
                        //           shape: BoxShape.circle
                        //       ),
                        //       child: Center(child: Container(
                        //         height: 10,
                        //         width: 10,
                        //         decoration: const BoxDecoration(
                        //             color: PdfColors.green,
                        //             shape: BoxShape.circle
                        //         ),
                        //       )),
                        //     ),
                        //   ],
                        // ),
                        //  SizedBox(width: 10,),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pickup",
                                style: const TextStyle(
                                    color: PdfColors.green, fontSize: 16),
                              ),
                              Text(
                                  "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.pickup!.title}",
                                  style: const TextStyle(fontSize: 18),
                                  maxLines: 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                      // physics: const NeverScrollableScrollPhysics(),
                      // // scrollDirection: NeverScrollableScrollPhysics(),
                      // shrinkWrap: true,
                      // clipBehavior: Clip.none,
                      itemCount: myRideDetailApiController
                          .myRideDetailApiModel!.reuqestList!.drop!.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            // Column(
                            //   children: [
                            //     Container(
                            //       height: 8,
                            //       width: 2,
                            //       decoration: const BoxDecoration(
                            //           color: PdfColors.grey,
                            //           borderRadius: BorderRadius.all(Radius.circular(10))
                            //       ),
                            //     ),
                            //      SizedBox(height: 2,),
                            //     Container(
                            //       height: 8,
                            //       width: 2,
                            //       decoration: const BoxDecoration(
                            //           color: PdfColors.grey,
                            //           borderRadius: BorderRadius.all(Radius.circular(10))
                            //       ),
                            //     ),
                            //      SizedBox(height: 2,),
                            //     Container(
                            //       height: 8,
                            //       width: 2,
                            //       decoration:  BoxDecoration(
                            //           color: PdfColors.grey,
                            //           borderRadius: BorderRadius.all(Radius.circular(10))
                            //       ),
                            //     ),
                            //      SizedBox(height: 2,),
                            //     Container(
                            //       height: 20,
                            //       width: 20,
                            //       decoration: BoxDecoration(
                            //           color: PdfColors.grey,
                            //           shape: BoxShape.circle
                            //       ),
                            //       child: Center(child: Container(
                            //         height: 10,
                            //         width: 10,
                            //         decoration:  BoxDecoration(
                            //             color: PdfColors.red,
                            //             shape: BoxShape.circle
                            //         ),
                            //       )),
                            //     ),
                            //
                            //   ],
                            // ),
                            // SizedBox(width: 10,),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Destination",
                                      style: const TextStyle(
                                          color: PdfColors.red, fontSize: 16),
                                    ),
                                    Text(
                                      "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.drop![index].title}",
                                      style: const TextStyle(fontSize: 18),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "RIDE DETAIL",
                      style: const TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Text(
                          "Ride Type :",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.mRole}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Car Type :",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.vehicleName}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "hours / minit :",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.totHour} hours ${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.totMinute} minit",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Date & Time :",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.startTime}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PAYMENT",
                      style: const TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Text(
                          "Ride Fair :",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "$globalcurrency${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.price}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Promo :",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "$globalcurrency${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.couponAmount}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "PlatformFee :",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "$globalcurrency${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.platformFee}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Weather Price :",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "$globalcurrency${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.weatherPrice}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Additional Time Charge (${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.addiTime} mint) :",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "$globalcurrency${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.addiTimePrice}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Wallet",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "$globalcurrency${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.walletPrice}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        myRideDetailApiController.myRideDetailApiModel!
                                    .reuqestList!.paidAmount ==
                                0
                            ? Text(
                                "Payment pay (${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.pName})",
                                style: const TextStyle(fontSize: 18),
                              )
                            : Text(
                                "Payment pay (${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.pName})",
                                style: const TextStyle(fontSize: 18),
                              ),
                        Spacer(),
                        Text(
                          "$globalcurrency${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.paidAmount}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Total :",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          "$globalcurrency${myRideDetailApiController.myRideDetailApiModel!.reuqestList!.finalPrice}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        )
      ];
    },
  ));
  return pdf.save();
}
