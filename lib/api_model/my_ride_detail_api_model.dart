// To parse this JSON data, do
//
//     final myRideDetailApiModel = myRideDetailApiModelFromJson(jsonString);

import 'dart:convert';

MyRideDetailApiModel myRideDetailApiModelFromJson(String str) =>
    MyRideDetailApiModel.fromJson(json.decode(str));

String myRideDetailApiModelToJson(MyRideDetailApiModel data) =>
    json.encode(data.toJson());

class MyRideDetailApiModel {
  int? responseCode;
  bool? result;
  String? message;
  ReuqestList? reuqestList;

  MyRideDetailApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.reuqestList,
  });

  factory MyRideDetailApiModel.fromJson(Map<String, dynamic> json) =>
      MyRideDetailApiModel(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        message: json["message"],
        reuqestList: json["Reuqest_list"] == null
            ? null
            : ReuqestList.fromJson(json["Reuqest_list"]),
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "message": message,
        "Reuqest_list": reuqestList?.toJson(),
      };
}

class ReuqestList {
  int? id;
  String? cId;
  String? dId;
  num? price;
  num? finalPrice;
  num? paidAmount;
  num? couponAmount;
  num? addiTimePrice;
  num? platformFee;
  num? weatherPrice;
  num? walletPrice;
  String? status;
  num? totKm;
  num? totHour;
  num? totMinute;
  String? mRole;
  String? vehicleName;
  String? profileImage;
  String? pImage;
  String? pName;
  int? reviewCheck;
  String? cTitle;
  int? addiTime;
  String? startTime;
  RunTime? runTime;
  Pickup? pickup;
  List<Pickup>? drop;

  ReuqestList({
    this.id,
    this.cId,
    this.dId,
    this.price,
    this.finalPrice,
    this.paidAmount,
    this.couponAmount,
    this.addiTimePrice,
    this.platformFee,
    this.weatherPrice,
    this.walletPrice,
    this.status,
    this.totKm,
    this.totHour,
    this.totMinute,
    this.mRole,
    this.vehicleName,
    this.profileImage,
    this.pImage,
    this.pName,
    this.reviewCheck,
    this.cTitle,
    this.addiTime,
    this.startTime,
    this.runTime,
    this.pickup,
    this.drop,
  });

  factory ReuqestList.fromJson(Map<String, dynamic> json) => ReuqestList(
        id: json["id"],
        cId: json["c_id"],
        dId: json["d_id"],
        price: (json["price"] is num)
            ? json["price"].toDouble()
            : double.tryParse(json["price"].toString()) ?? 0.0,
        finalPrice: (json["final_price"] is num)
            ? json["final_price"].toDouble()
            : double.tryParse(json["final_price"].toString()) ?? 0.0,
        paidAmount: (json["paid_amount"] is num)
            ? json["paid_amount"].toDouble()
            : double.tryParse(json["paid_amount"].toString()) ?? 0.0,
        couponAmount: (json["coupon_amount"] is num)
            ? json["coupon_amount"].toDouble()
            : double.tryParse(json["coupon_amount"].toString()) ?? 0.0,
        addiTimePrice: (json["addi_time_price"] is num)
            ? json["addi_time_price"].toDouble()
            : double.tryParse(json["addi_time_price"].toString()) ?? 0.0,
        platformFee: (json["platform_fee"] is num)
            ? json["platform_fee"].toDouble()
            : double.tryParse(json["platform_fee"].toString()) ?? 0.0,
        weatherPrice: (json["weather_price"] is num)
            ? json["weather_price"].toDouble()
            : double.tryParse(json["weather_price"].toString()) ?? 0.0,
        walletPrice: (json["wallet_price"] is num)
            ? json["wallet_price"].toDouble()
            : double.tryParse(json["wallet_price"].toString()) ?? 0.0,
        status: json["status"],
        totKm: (json["tot_km"] is num)
            ? json["tot_km"].toDouble()
            : double.tryParse(json["tot_km"].toString()) ?? 0.0,
        totHour: (json["tot_hour"] is num)
            ? json["tot_hour"].toDouble()
            : double.tryParse(json["tot_hour"].toString()) ?? 0.0,
        totMinute: (json["tot_minute"] is num)
            ? json["tot_minute"].toDouble()
            : double.tryParse(json["tot_minute"].toString()) ?? 0.0,
        mRole: json["m_role"],
        vehicleName: json["vehicle_name"],
        profileImage: json["profile_image"],
        pImage: json["p_image"],
        pName: json["p_name"],
        reviewCheck: json["review_check"],
        cTitle: json["c_title"],
        addiTime: json["addi_time"],
        startTime: json["start_time"],
        runTime: json["run_time"] == null
            ? null
            : RunTime.fromJson(json["run_time"]),
        pickup: json["pickup"] == null ? null : Pickup.fromJson(json["pickup"]),
        drop: json["drop"] == null
            ? []
            : List<Pickup>.from(json["drop"]!.map((x) => Pickup.fromJson(x))),
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "c_id": cId,
        "d_id": dId,
        "price": price,
        "final_price": finalPrice,
        "paid_amount": paidAmount,
        "coupon_amount": couponAmount,
        "addi_time_price": addiTimePrice,
        "platform_fee": platformFee,
        "weather_price": weatherPrice,
        "wallet_price": walletPrice,
        "status": status,
        "tot_km": totKm,
        "tot_hour": totHour,
        "tot_minute": totMinute,
        "m_role": mRole,
        "vehicle_name": vehicleName,
        "profile_image": profileImage,
        "p_image": pImage,
        "p_name": pName,
        "review_check": reviewCheck,
        "c_title": cTitle,
        "addi_time": addiTime,
        "start_time": startTime,
        "run_time": runTime?.toJson(),
        "pickup": pickup?.toJson(),
        "drop": drop == null
            ? []
            : List<dynamic>.from(drop!.map((x) => x.toJson())),
      };
}

class Pickup {
  String? title;
  String? subtitle;
  String? latitude;
  String? longitude;

  Pickup({
    this.title,
    this.subtitle,
    this.latitude,
    this.longitude,
  });

  factory Pickup.fromJson(Map<String, dynamic> json) => Pickup(
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
