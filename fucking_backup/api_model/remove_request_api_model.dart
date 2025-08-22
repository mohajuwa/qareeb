// To parse this JSON data, do
//
//     final removeVihicalRequest = removeVihicalRequestFromJson(jsonString);

import 'dart:convert';

RemoveVihicalRequest removeVihicalRequestFromJson(String str) => RemoveVihicalRequest.fromJson(json.decode(str));

String removeVihicalRequestToJson(RemoveVihicalRequest data) => json.encode(data.toJson());

class RemoveVihicalRequest {
  int? responseCode;
  bool? result;
  String? message;
  int? id;

  RemoveVihicalRequest({
    this.responseCode,
    this.result,
    this.message,
    this.id,
  });

  factory RemoveVihicalRequest.fromJson(Map<String, dynamic> json) => RemoveVihicalRequest(
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
