// To parse this JSON data, do
//
//     final smaApiModel = smaApiModelFromJson(jsonString);

import 'dart:convert';

SmaApiModel smaApiModelFromJson(String str) => SmaApiModel.fromJson(json.decode(str));

String smaApiModelToJson(SmaApiModel data) => json.encode(data.toJson());

class SmaApiModel {
  int? responseCode;
  bool? result;
  String? message;

  SmaApiModel({
    this.responseCode,
    this.result,
    this.message,
  });

  factory SmaApiModel.fromJson(Map<String, dynamic> json) => SmaApiModel(
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
