// To parse this JSON data, do
//
//     final addVihicalCalculateModel = addVihicalCalculateModelFromJson(jsonString);

import 'dart:convert';

AddVihicalCalculateModel addVihicalCalculateModelFromJson(String str) => AddVihicalCalculateModel.fromJson(json.decode(str));

String addVihicalCalculateModelToJson(AddVihicalCalculateModel data) => json.encode(data.toJson());

class AddVihicalCalculateModel {
  int? responseCode;
  bool? result;
  String? message;
  int? id;

  AddVihicalCalculateModel({
    this.responseCode,
    this.result,
    this.message,
    this.id,
  });

  factory AddVihicalCalculateModel.fromJson(Map<String, dynamic> json) => AddVihicalCalculateModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "id": id,
  };
}
