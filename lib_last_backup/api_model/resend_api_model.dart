// To parse this JSON data, do
//
//     final resendRequest = resendRequestFromJson(jsonString);

import 'dart:convert';

ResendRequest resendRequestFromJson(String str) => ResendRequest.fromJson(json.decode(str));

String resendRequestToJson(ResendRequest data) => json.encode(data.toJson());

class ResendRequest {
  int? responseCode;
  bool? result;
  String? message;
  int? id;

  ResendRequest({
    this.responseCode,
    this.result,
    this.message,
    this.id,
  });

  factory ResendRequest.fromJson(Map<String, dynamic> json) => ResendRequest(
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
