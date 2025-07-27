// To parse this JSON data, do
//
//     final vihicalCalculateModel = vihicalCalculateModelFromJson(jsonString);

import 'dart:convert';

VihicalCalculateModel vihicalCalculateModelFromJson(String str) => VihicalCalculateModel.fromJson(json.decode(str));

String vihicalCalculateModelToJson(VihicalCalculateModel data) => json.encode(data.toJson());

class VihicalCalculateModel {
  int? responseCode;
  bool? result;
  String? message;
  List<int>? driverId;
  List<Caldriver>? caldriver;

  VihicalCalculateModel({
    this.responseCode,
    this.result,
    this.message,
    this.driverId,
    this.caldriver,
  });

  factory VihicalCalculateModel.fromJson(Map<String, dynamic> json) => VihicalCalculateModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    driverId: json["driver_id"] == null ? [] : List<int>.from(json["driver_id"]!.map((x) => x)),
    caldriver: json["caldriver"] == null ? [] : List<Caldriver>.from(json["caldriver"]!.map((x) => Caldriver.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "driver_id": driverId == null ? [] : List<dynamic>.from(driverId!.map((x) => x)),
    "caldriver": caldriver == null ? [] : List<dynamic>.from(caldriver!.map((x) => x.toJson())),
  };
}

class Caldriver {
  int? id;
  String? image;
  String? name;
  String? description;
  String? latitude;
  String? longitude;

  Caldriver({
    this.id,
    this.image,
    this.name,
    this.description,
    this.latitude,
    this.longitude,
  });

  factory Caldriver.fromJson(Map<String, dynamic> json) => Caldriver(
    id: json["id"],
    image: json["image"],
    name: json["name"],
    description: json["description"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "name": name,
    "description": description,
    "latitude": latitude,
    "longitude": longitude,
  };
}
