// To parse this JSON data, do
//
//     final homeModel = homeModelFromJson(jsonString);

import 'dart:convert';

HomeModel homeModelFromJson(String str) => HomeModel.fromJson(json.decode(str));

String homeModelToJson(HomeModel data) => json.encode(data.toJson());

class HomeModel {
  int? responseCode;
  bool? result;
  String? message;
  General? general;
  CusRating? cusRating;
  List<CategoryList>? categoryList;
  List<RunnigRide>? runnigRide;

  HomeModel({
    this.responseCode,
    this.result,
    this.message,
    this.general,
    this.cusRating,
    this.categoryList,
    this.runnigRide,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        message: json["message"],
        general:
            json["general"] == null ? null : General.fromJson(json["general"]),
        cusRating: json["cus_rating"] == null
            ? null
            : CusRating.fromJson(json["cus_rating"]),
        categoryList: json["category_list"] == null
            ? []
            : List<CategoryList>.from(
                json["category_list"]!.map((x) => CategoryList.fromJson(x))),
        runnigRide: json["runnig_ride"] == null
            ? []
            : List<RunnigRide>.from(
                json["runnig_ride"]!.map((x) => RunnigRide.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "message": message,
        "general": general?.toJson(),
        "cus_rating": cusRating?.toJson(),
        "category_list": categoryList == null
            ? []
            : List<dynamic>.from(categoryList!.map((x) => x.toJson())),
        "runnig_ride": runnigRide == null
            ? []
            : List<dynamic>.from(runnigRide!.map((x) => x.toJson())),
      };
}

class CategoryList {
  int? id;
  String? image;
  String? name;
  String? description;
  String? bidding;
  String? role;

  CategoryList({
    this.id,
    this.image,
    this.name,
    this.description,
    this.bidding,
    this.role,
  });

  factory CategoryList.fromJson(Map<String, dynamic> json) => CategoryList(
        id: json["id"],
        image: json["image"],
        name: json["name"],
        description: json["description"],
        bidding: json["bidding"],
        role: json["role"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "name": name,
        "description": description,
        "bidding": bidding,
        "role": role,
      };
}

class CusRating {
  int? id;
  num? totReview;
  num? avgStar;

  CusRating({
    this.id,
    this.totReview,
    this.avgStar,
  });

  factory CusRating.fromJson(Map<String, dynamic> json) => CusRating(
        id: json["id"],
        totReview: json["tot_review"],
        avgStar: json["avg_star"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tot_review": totReview,
        "avg_star": avgStar,
      };
}

class General {
  String? siteCurrency;

  General({
    this.siteCurrency,
  });

  factory General.fromJson(Map<String, dynamic> json) => General(
        siteCurrency: json["site_currency"],
      );

  Map<String, dynamic> toJson() => {
        "site_currency": siteCurrency,
      };
}

class RunnigRide {
  int? id;
  String? cId;
  List<int>? dId;
  String? biddingStatus;
  String? biddAutoStatus;
  num? price;
  num? totKm;
  num? totHour;
  num? totMinute;
  String? vehicleid;
  String? paymentId;
  String? status;
  String? mRole;
  String? couponId;
  DateTime? startTime;
  String? minimumFare;
  String? maximumFare;
  DropAdd? pickAdd;
  DropLatlon? pickLatlon;
  DropAdd? dropAdd;
  DropLatlon? dropLatlon;
  List<DropAdd>? dropAddList;
  List<DropLatlon>? dropLatlonList;
  int? biddingRunStatus;
  num? increasedTime;

  RunnigRide({
    this.id,
    this.cId,
    this.dId,
    this.biddingStatus,
    this.biddAutoStatus,
    this.price,
    this.totKm,
    this.totHour,
    this.totMinute,
    this.vehicleid,
    this.paymentId,
    this.status,
    this.mRole,
    this.couponId,
    this.startTime,
    this.minimumFare,
    this.maximumFare,
    this.pickAdd,
    this.pickLatlon,
    this.dropAdd,
    this.dropLatlon,
    this.dropAddList,
    this.dropLatlonList,
    this.biddingRunStatus,
    this.increasedTime,
  });

  factory RunnigRide.fromJson(Map<String, dynamic> json) => RunnigRide(
        id: json["id"],
        cId: json["c_id"],
        dId: json["d_id"] == null
            ? []
            : List<int>.from(json["d_id"]!.map((x) => x)),
        biddingStatus: json["bidding_status"],
        biddAutoStatus: json["bidd_auto_status"],
        price: (json["price"] is num)
            ? json["price"].toDouble()
            : double.tryParse(json["price"].toString()) ?? 0.0,
        totKm: (json["tot_km"] is num)
            ? json["tot_km"].toDouble()
            : double.tryParse(json["tot_km"].toString()) ?? 0.0,
        totHour: (json["tot_hour"] is num)
            ? json["tot_hour"].toDouble()
            : double.tryParse(json["tot_hour"].toString()) ?? 0.0,
        totMinute: (json["tot_minute"] is num)
            ? json["tot_minute"].toDouble()
            : double.tryParse(json["tot_minute"].toString()) ?? 0.0,
        vehicleid: json["vehicleid"],
        paymentId: json["payment_id"],
        status: json["status"],
        mRole: json["m_role"],
        couponId: json["coupon_id"],
        startTime: json["start_time"] == null
            ? null
            : DateTime.parse(json["start_time"]),
        minimumFare: json["minimum_fare"],
        maximumFare: json["maximum_fare"],
        pickAdd: json["pick_add"] == null
            ? null
            : DropAdd.fromJson(json["pick_add"]),
        pickLatlon: json["pick_latlon"] == null
            ? null
            : DropLatlon.fromJson(json["pick_latlon"]),
        dropAdd: json["drop_add"] == null
            ? null
            : DropAdd.fromJson(json["drop_add"]),
        dropLatlon: json["drop_latlon"] == null
            ? null
            : DropLatlon.fromJson(json["drop_latlon"]),
        dropAddList: json["drop_add_list"] == null
            ? []
            : List<DropAdd>.from(
                json["drop_add_list"]!.map((x) => DropAdd.fromJson(x))),
        dropLatlonList: json["drop_latlon_list"] == null
            ? []
            : List<DropLatlon>.from(
                json["drop_latlon_list"]!.map((x) => DropLatlon.fromJson(x))),
        biddingRunStatus: json["bidding_run_status"],
        increasedTime: (json["increased_time"] is num)
            ? json["increased_time"].toDouble()
            : double.tryParse(json["increased_time"].toString()) ?? 0.0,
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "c_id": cId,
        "d_id": dId == null ? [] : List<dynamic>.from(dId!.map((x) => x)),
        "bidding_status": biddingStatus,
        "bidd_auto_status": biddAutoStatus,
        "price": price,
        "tot_km": totKm,
        "tot_hour": totHour,
        "tot_minute": totMinute,
        "vehicleid": vehicleid,
        "payment_id": paymentId,
        "status": status,
        "m_role": mRole,
        "coupon_id": couponId,
        "start_time": startTime?.toIso8601String(),
        "minimum_fare": minimumFare,
        "maximum_fare": maximumFare,
        "pick_add": pickAdd?.toJson(),
        "pick_latlon": pickLatlon?.toJson(),
        "drop_add": dropAdd?.toJson(),
        "drop_latlon": dropLatlon?.toJson(),
        "drop_add_list": dropAddList == null
            ? []
            : List<dynamic>.from(dropAddList!.map((x) => x.toJson())),
        "drop_latlon_list": dropLatlonList == null
            ? []
            : List<dynamic>.from(dropLatlonList!.map((x) => x.toJson())),
        "bidding_run_status": biddingRunStatus,
        "increased_time": increasedTime,
      };
}

class DropAdd {
  String? title;
  String? subtitle;

  DropAdd({
    this.title,
    this.subtitle,
  });

  factory DropAdd.fromJson(Map<String, dynamic> json) => DropAdd(
        title: json["title"],
        subtitle: json["subtitle"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "subtitle": subtitle,
      };
}

class DropLatlon {
  String? latitude;
  String? longitude;

  DropLatlon({
    this.latitude,
    this.longitude,
  });

  factory DropLatlon.fromJson(Map<String, dynamic> json) => DropLatlon(
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}
