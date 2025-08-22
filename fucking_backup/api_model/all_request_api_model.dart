// // To parse this JSON data, do
// //
// //     final allRequestDataModel = allRequestDataModelFromJson(jsonString);
//
// import 'dart:convert';
//
// AllRequestDataModel allRequestDataModelFromJson(String str) => AllRequestDataModel.fromJson(json.decode(str));
//
// String allRequestDataModelToJson(AllRequestDataModel data) => json.encode(data.toJson());
//
// class AllRequestDataModel {
//   int? responseCode;
//   bool? result;
//   String? message;
//   int? driverWaitTime;
//   List<ReuqestList>? reuqestList;
//
//   AllRequestDataModel({
//     this.responseCode,
//     this.result,
//     this.message,
//     this.driverWaitTime,
//     this.reuqestList,
//   });
//
//   factory AllRequestDataModel.fromJson(Map<String, dynamic> json) => AllRequestDataModel(
//     responseCode: json["ResponseCode"],
//     result: json["Result"],
//     message: json["message"],
//     driverWaitTime: json["driver_wait_time"],
//     reuqestList: json["Reuqest_list"] == null ? [] : List<ReuqestList>.from(json["Reuqest_list"]!.map((x) => ReuqestList.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "ResponseCode": responseCode,
//     "Result": result,
//     "message": message,
//     "driver_wait_time": driverWaitTime,
//     "Reuqest_list": reuqestList == null ? [] : List<dynamic>.from(reuqestList!.map((x) => x.toJson())),
//   };
// }
//
// class ReuqestList {
//   int? id;
//   String? dId;
//   num? price;
//   String? status;
//   num? finalPrice;
//   num? paidAmount;
//   num? couponAmount;
//   num? addiTimePrice;
//   num? platformFee;
//   num? weatherPrice;
//   num? walletPrice;
//   num? totHour;
//   num? totMinute;
//   String? mRole;
//   String? vehicleName;
//   String? pName;
//   String? profileImage;
//   String? vehicleImage;
//   String? firstName;
//   String? lastName;
//   String? primaryCcode;
//   String? primaryPhoneNo;
//   String? language;
//   String? vehicleNumber;
//   String? carColor;
//   int? totReview;
//   double? avgStar;
//   List<int>? driverIdList;
//   String? otp;
//   int? addiTime;
//   String? startTime;
//   int? totDrop;
//   RunTime? runTime;
//   Drop? pickup;
//   Drop? drop;
//   List<dynamic>? dropList;
//
//   ReuqestList({
//     this.id,
//     this.dId,
//     this.price,
//     this.status,
//     this.finalPrice,
//     this.paidAmount,
//     this.couponAmount,
//     this.addiTimePrice,
//     this.platformFee,
//     this.weatherPrice,
//     this.walletPrice,
//     this.totHour,
//     this.totMinute,
//     this.mRole,
//     this.vehicleName,
//     this.pName,
//     this.profileImage,
//     this.vehicleImage,
//     this.firstName,
//     this.lastName,
//     this.primaryCcode,
//     this.primaryPhoneNo,
//     this.language,
//     this.vehicleNumber,
//     this.carColor,
//     this.totReview,
//     this.avgStar,
//     this.driverIdList,
//     this.otp,
//     this.addiTime,
//     this.startTime,
//     this.totDrop,
//     this.runTime,
//     this.pickup,
//     this.drop,
//     this.dropList,
//   });
//
//   factory ReuqestList.fromJson(Map<String, dynamic> json) => ReuqestList(
//     id: json["id"],
//     dId: json["d_id"],
//     price: json["price"],
//     status: json["status"],
//     finalPrice: json["final_price"],
//     paidAmount: json["paid_amount"],
//     couponAmount: json["coupon_amount"],
//     addiTimePrice: json["addi_time_price"],
//     platformFee: json["platform_fee"],
//     weatherPrice: json["weather_price"],
//     walletPrice: json["wallet_price"],
//     totHour: json["tot_hour"],
//     totMinute: json["tot_minute"],
//     mRole: json["m_role"],
//     vehicleName: json["vehicle_name"],
//     pName: json["p_name"],
//     profileImage: json["profile_image"],
//     vehicleImage: json["vehicle_image"],
//     firstName: json["first_name"],
//     lastName: json["last_name"],
//     primaryCcode: json["primary_ccode"],
//     primaryPhoneNo: json["primary_phoneNo"],
//     language: json["language"],
//     vehicleNumber: json["vehicle_number"],
//     carColor: json["car_color"],
//     totReview: json["tot_review"],
//     avgStar: json["avg_star"]?.toDouble(),
//     driverIdList: json["driver_id_list"] == null ? [] : List<int>.from(json["driver_id_list"]!.map((x) => x)),
//     otp: json["otp"],
//     addiTime: json["addi_time"],
//     startTime: json["start_time"],
//     totDrop: json["tot_drop"],
//     runTime: json["run_time"] == null ? null : RunTime.fromJson(json["run_time"]),
//     pickup: json["pickup"] == null ? null : Drop.fromJson(json["pickup"]),
//     drop: json["drop"] == null ? null : Drop.fromJson(json["drop"]),
//     dropList: json["drop_list"] == null ? [] : List<dynamic>.from(json["drop_list"]!.map((x) => x)),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "d_id": dId,
//     "price": price,
//     "status": status,
//     "final_price": finalPrice,
//     "paid_amount": paidAmount,
//     "coupon_amount": couponAmount,
//     "addi_time_price": addiTimePrice,
//     "platform_fee": platformFee,
//     "weather_price": weatherPrice,
//     "wallet_price": walletPrice,
//     "tot_hour": totHour,
//     "tot_minute": totMinute,
//     "m_role": mRole,
//     "vehicle_name": vehicleName,
//     "p_name": pName,
//     "profile_image": profileImage,
//     "vehicle_image": vehicleImage,
//     "first_name": firstName,
//     "last_name": lastName,
//     "primary_ccode": primaryCcode,
//     "primary_phoneNo": primaryPhoneNo,
//     "language": language,
//     "vehicle_number": vehicleNumber,
//     "car_color": carColor,
//     "tot_review": totReview,
//     "avg_star": avgStar,
//     "driver_id_list": driverIdList == null ? [] : List<dynamic>.from(driverIdList!.map((x) => x)),
//     "otp": otp,
//     "addi_time": addiTime,
//     "start_time": startTime,
//     "tot_drop": totDrop,
//     "run_time": runTime?.toJson(),
//     "pickup": pickup?.toJson(),
//     "drop": drop?.toJson(),
//     "drop_list": dropList == null ? [] : List<dynamic>.from(dropList!.map((x) => x)),
//   };
// }
//
// class Drop {
//   String? title;
//   String? subtitle;
//   String? latitude;
//   String? longitude;
//
//   Drop({
//     this.title,
//     this.subtitle,
//     this.latitude,
//     this.longitude,
//   });
//
//   factory Drop.fromJson(Map<String, dynamic> json) => Drop(
//     title: json["title"],
//     subtitle: json["subtitle"],
//     latitude: json["latitude"],
//     longitude: json["longitude"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "title": title,
//     "subtitle": subtitle,
//     "latitude": latitude,
//     "longitude": longitude,
//   };
// }
//
// class RunTime {
//   int? hour;
//   int? minute;
//   int? second;
//   int? status;
//
//   RunTime({
//     this.hour,
//     this.minute,
//     this.second,
//     this.status,
//   });
//
//   factory RunTime.fromJson(Map<String, dynamic> json) => RunTime(
//     hour: json["hour"],
//     minute: json["minute"],
//     second: json["second"],
//     status: json["status"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "hour": hour,
//     "minute": minute,
//     "second": second,
//     "status": status,
//   };
// }








// To parse this JSON data, do
//
//     final allRequestDataModel = allRequestDataModelFromJson(jsonString);

import 'dart:convert';

AllRequestDataModel allRequestDataModelFromJson(String str) => AllRequestDataModel.fromJson(json.decode(str));

String allRequestDataModelToJson(AllRequestDataModel data) => json.encode(data.toJson());

class AllRequestDataModel {
  int? responseCode;
  bool? result;
  String? message;
  int? driverWaitTime;
  List<ReuqestList>? reuqestList;

  AllRequestDataModel({
    this.responseCode,
    this.result,
    this.message,
    this.driverWaitTime,
    this.reuqestList,
  });

  factory AllRequestDataModel.fromJson(Map<String, dynamic> json) => AllRequestDataModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    driverWaitTime: json["driver_wait_time"],
    reuqestList: json["Reuqest_list"] == null ? [] : List<ReuqestList>.from(json["Reuqest_list"]!.map((x) => ReuqestList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "driver_wait_time": driverWaitTime,
    "Reuqest_list": reuqestList == null ? [] : List<dynamic>.from(reuqestList!.map((x) => x.toJson())),
  };
}

class ReuqestList {
  int? id;
  String? dId;
  num? price;
  String? status;
  num? finalPrice;
  num? paidAmount;
  num? couponAmount;
  num? addiTimePrice;
  num? platformFee;
  num? weatherPrice;
  num? walletPrice;
  num? totHour;
  num? totMinute;
  String? mRole;
  String? vehicleName;
  String? pName;
  String? profileImage;
  String? vehicleImage;
  String? firstName;
  String? lastName;
  String? primaryCcode;
  String? primaryPhoneNo;
  String? language;
  String? vehicleNumber;
  String? carColor;
  num? totReview;
  num? avgStar;
  List<int>? driverIdList;
  String? otp;
  String? latitude;
  String? longitude;
  String? mapImg;
  num? addiTime;
  String? startTime;
  num? totDrop;
  RunTime? runTime;
  Drop? pickup;
  Drop? drop;
  List<dynamic>? dropList;

  ReuqestList({
    this.id,
    this.dId,
    this.price,
    this.status,
    this.finalPrice,
    this.paidAmount,
    this.couponAmount,
    this.addiTimePrice,
    this.platformFee,
    this.weatherPrice,
    this.walletPrice,
    this.totHour,
    this.totMinute,
    this.mRole,
    this.vehicleName,
    this.pName,
    this.profileImage,
    this.vehicleImage,
    this.firstName,
    this.lastName,
    this.primaryCcode,
    this.primaryPhoneNo,
    this.language,
    this.vehicleNumber,
    this.carColor,
    this.totReview,
    this.avgStar,
    this.driverIdList,
    this.otp,
    this.latitude,
    this.longitude,
    this.mapImg,
    this.addiTime,
    this.startTime,
    this.totDrop,
    this.runTime,
    this.pickup,
    this.drop,
    this.dropList,
  });

  factory ReuqestList.fromJson(Map<String, dynamic> json) => ReuqestList(
    id: json["id"],
    dId: json["d_id"],
    price: json["price"],
    status: json["status"],
    finalPrice: json["final_price"],
    paidAmount: json["paid_amount"],
    couponAmount: json["coupon_amount"],
    addiTimePrice: json["addi_time_price"],
    platformFee: json["platform_fee"],
    weatherPrice: json["weather_price"],
    walletPrice: json["wallet_price"],
    totHour: json["tot_hour"],
    totMinute: json["tot_minute"],
    mRole: json["m_role"],
    vehicleName: json["vehicle_name"],
    pName: json["p_name"],
    profileImage: json["profile_image"],
    vehicleImage: json["vehicle_image"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    primaryCcode: json["primary_ccode"],
    primaryPhoneNo: json["primary_phoneNo"],
    language: json["language"],
    vehicleNumber: json["vehicle_number"],
    carColor: json["car_color"],
    totReview: json["tot_review"],
    avgStar: json["avg_star"],
    driverIdList: json["driver_id_list"] == null ? [] : List<int>.from(json["driver_id_list"]!.map((x) => x)),
    otp: json["otp"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    mapImg: json["map_img"],
    addiTime: json["addi_time"],
    startTime: json["start_time"],
    totDrop: json["tot_drop"],
    runTime: json["run_time"] == null ? null : RunTime.fromJson(json["run_time"]),
    pickup: json["pickup"] == null ? null : Drop.fromJson(json["pickup"]),
    drop: json["drop"] == null ? null : Drop.fromJson(json["drop"]),
    dropList: json["drop_list"] == null ? [] : List<dynamic>.from(json["drop_list"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "d_id": dId,
    "price": price,
    "status": status,
    "final_price": finalPrice,
    "paid_amount": paidAmount,
    "coupon_amount": couponAmount,
    "addi_time_price": addiTimePrice,
    "platform_fee": platformFee,
    "weather_price": weatherPrice,
    "wallet_price": walletPrice,
    "tot_hour": totHour,
    "tot_minute": totMinute,
    "m_role": mRole,
    "vehicle_name": vehicleName,
    "p_name": pName,
    "profile_image": profileImage,
    "vehicle_image": vehicleImage,
    "first_name": firstName,
    "last_name": lastName,
    "primary_ccode": primaryCcode,
    "primary_phoneNo": primaryPhoneNo,
    "language": language,
    "vehicle_number": vehicleNumber,
    "car_color": carColor,
    "tot_review": totReview,
    "avg_star": avgStar,
    "driver_id_list": driverIdList == null ? [] : List<dynamic>.from(driverIdList!.map((x) => x)),
    "otp": otp,
    "latitude": latitude,
    "longitude": longitude,
    "map_img": mapImg,
    "addi_time": addiTime,
    "start_time": startTime,
    "tot_drop": totDrop,
    "run_time": runTime?.toJson(),
    "pickup": pickup?.toJson(),
    "drop": drop?.toJson(),
    "drop_list": dropList == null ? [] : List<dynamic>.from(dropList!.map((x) => x)),
  };
}

class Drop {
  String? title;
  String? subtitle;
  String? latitude;
  String? longitude;

  Drop({
    this.title,
    this.subtitle,
    this.latitude,
    this.longitude,
  });

  factory Drop.fromJson(Map<String, dynamic> json) => Drop(
    title: json["title"],
    subtitle: json["subtitle"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "subtitle": subtitle,
    "latitude": latitude,
    "longitude": longitude,
  };
}

class RunTime {
  int? hour;
  int? minute;
  int? second;
  int? status;

  RunTime({
    this.hour,
    this.minute,
    this.second,
    this.status,
  });

  factory RunTime.fromJson(Map<String, dynamic> json) => RunTime(
    hour: json["hour"],
    minute: json["minute"],
    second: json["second"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "hour": hour,
    "minute": minute,
    "second": second,
    "status": status,
  };
}
