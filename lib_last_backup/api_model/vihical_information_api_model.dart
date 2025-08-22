// To parse this JSON data, do
//
//     final vihicalInFormationApiModel = vihicalInFormationApiModelFromJson(jsonString);

import 'dart:convert';

VihicalInFormationApiModel vihicalInFormationApiModelFromJson(String str) => VihicalInFormationApiModel.fromJson(json.decode(str));

String vihicalInFormationApiModelToJson(VihicalInFormationApiModel data) => json.encode(data.toJson());

class VihicalInFormationApiModel {
  int? responseCode;
  bool? result;
  String? message;
  Vehicle? vehicle;

  VihicalInFormationApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.vehicle,
  });

  factory VihicalInFormationApiModel.fromJson(Map<String, dynamic> json) => VihicalInFormationApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    vehicle: json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "vehicle": vehicle?.toJson(),
  };
}

class Vehicle {
  int? id;
  String? image;
  String? name;
  String? description;
  String? passengerCapacity;

  Vehicle({
    this.id,
    this.image,
    this.name,
    this.description,
    this.passengerCapacity,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json["id"],
    image: json["image"],
    name: json["name"],
    description: json["description"],
    passengerCapacity: json["passenger_capacity"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "name": name,
    "description": description,
    "passenger_capacity": passengerCapacity,
  };
}
