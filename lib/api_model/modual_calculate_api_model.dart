// To parse this JSON data, do
//
//     final modualCalculateApiModel = modualCalculateApiModelFromJson(jsonString);

import 'dart:convert';

ModualCalculateApiModel modualCalculateApiModelFromJson(String str) =>
    ModualCalculateApiModel.fromJson(json.decode(str));

String modualCalculateApiModelToJson(ModualCalculateApiModel data) =>
    json.encode(data.toJson());

class ModualCalculateApiModel {
  int? responseCode;
  bool? result;
  String? message;
  List<Caldriver>? caldriver;

  ModualCalculateApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.caldriver,
  });

  factory ModualCalculateApiModel.fromJson(Map<String, dynamic> json) =>
      ModualCalculateApiModel(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        message: json["message"],
        caldriver: json["caldriver"] == null
            ? []
            : List<Caldriver>.from(
                json["caldriver"]!.map((x) => Caldriver.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "message": message,
        "caldriver": caldriver == null
            ? []
            : List<dynamic>.from(caldriver!.map((x) => x.toJson())),
      };
}

class Caldriver {
  int? id;
  String? image;
  String? mapImg;
  String? name;
  String? description;
  String? minKmDistance;
  String? minKmPrice;
  String? afterKmPrice;
  String? comissionRate;
  String? comissionType;
  String? extraCharge;
  String? passengerCapacity;
  String? bidding;
  String? whetherCharge;
  String? status;
  String? minimumFare;
  String? maximumFare;
  dynamic driPicTime;
  String? driPicDrop;
  num? dropPrice;
  num? dropHour;
  num? dropTime;
  num? dropKm;

  Caldriver({
    this.id,
    this.image,
    this.mapImg,
    this.name,
    this.description,
    this.minKmDistance,
    this.minKmPrice,
    this.afterKmPrice,
    this.comissionRate,
    this.comissionType,
    this.extraCharge,
    this.passengerCapacity,
    this.bidding,
    this.whetherCharge,
    this.status,
    this.minimumFare,
    this.maximumFare,
    this.driPicTime,
    this.driPicDrop,
    this.dropPrice,
    this.dropHour,
    this.dropTime,
    this.dropKm,
  });

  factory Caldriver.fromJson(Map<String, dynamic> json) => Caldriver(
        id: json["id"],
        image: json["image"],
        mapImg: json["map_img"],
        name: json["name"],
        description: json["description"],
        minKmDistance: json["min_km_distance"],
        minKmPrice: json["min_km_price"],
        afterKmPrice: json["after_km_price"],
        comissionRate: json["comission_rate"],
        comissionType: json["comission_type"],
        extraCharge: json["extra_charge"],
        passengerCapacity: json["passenger_capacity"],
        bidding: json["bidding"],
        whetherCharge: json["whether_charge"],
        status: json["status"],
        minimumFare: json["minimum_fare"],
        maximumFare: json["maximum_fare"],
        driPicTime: (json["dri_pic_time"] is num)
            ? json["dri_pic_time"].toDouble()
            : double.tryParse(json["dri_pic_time"].toString()) ?? 0.0,
        driPicDrop: json["dri_pic_drop"],
        dropPrice: (json["drop_price"] is num)
            ? json["drop_price"].toDouble()
            : double.tryParse(json["drop_price"].toString()) ?? 0.0,
        dropHour: (json["drop_hour"] is num)
            ? json["drop_hour"].toDouble()
            : double.tryParse(json["drop_hour"].toString()) ?? 0.0,
        dropTime: (json["drop_time"] is num)
            ? json["drop_time"].toDouble()
            : double.tryParse(json["drop_time"].toString()) ?? 0.0,
        dropKm: (json["drop_km"] is num)
            ? json["drop_km"].toDouble()
            : double.tryParse(json["drop_km"].toString()) ?? 0.0,
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "map_img": mapImg,
        "name": name,
        "description": description,
        "min_km_distance": minKmDistance,
        "min_km_price": minKmPrice,
        "after_km_price": afterKmPrice,
        "comission_rate": comissionRate,
        "comission_type": comissionType,
        "extra_charge": extraCharge,
        "passenger_capacity": passengerCapacity,
        "bidding": bidding,
        "whether_charge": whetherCharge,
        "status": status,
        "minimum_fare": minimumFare,
        "maximum_fare": maximumFare,
        "dri_pic_time": driPicTime,
        "dri_pic_drop": driPicDrop,
        "drop_price": dropPrice,
        "drop_hour": dropHour,
        "drop_time": dropTime,
        "drop_km": dropKm,
      };
}
