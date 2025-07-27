// To parse this JSON data, do
//
//     final homeMapApiModel = homeMapApiModelFromJson(jsonString);

import 'dart:convert';

HomeMapApiModel homeMapApiModelFromJson(String str) => HomeMapApiModel.fromJson(json.decode(str));

String homeMapApiModelToJson(HomeMapApiModel data) => json.encode(data.toJson());

class HomeMapApiModel {
  int? responseCode;
  bool? result;
  String? message;
  int? zoneId;
  List<int>? driverid;
  List<ListElement>? list;

  HomeMapApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.zoneId,
    this.driverid,
    this.list,
  });

  factory HomeMapApiModel.fromJson(Map<String, dynamic> json) => HomeMapApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    zoneId: json["zone_id"],
    driverid: json["driverid"] == null ? [] : List<int>.from(json["driverid"]!.map((x) => x)),
    list: json["list"] == null ? [] : List<ListElement>.from(json["list"]!.map((x) => ListElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "zone_id": zoneId,
    "driverid": driverid == null ? [] : List<dynamic>.from(driverid!.map((x) => x)),
    "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
  };
}

class ListElement {
  int? id;
  String? image;
  String? name;
  String? description;
  String? latitude;
  String? longitude;

  ListElement({
    this.id,
    this.image,
    this.name,
    this.description,
    this.latitude,
    this.longitude,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
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
