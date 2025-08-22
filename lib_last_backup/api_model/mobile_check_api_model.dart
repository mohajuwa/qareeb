// To parse this JSON data, do
//
//     final mobilcheckModel = mobilcheckModelFromJson(jsonString);

import 'dart:convert';

MobilcheckModel mobilcheckModelFromJson(String str) => MobilcheckModel.fromJson(json.decode(str));

String mobilcheckModelToJson(MobilcheckModel data) => json.encode(data.toJson());

class MobilcheckModel {
  int? responseCode;
  bool? result;
  String? message;

  MobilcheckModel({
    this.responseCode,
    this.result,
    this.message,
  });

  factory MobilcheckModel.fromJson(Map<String, dynamic> json) => MobilcheckModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
  };
}
