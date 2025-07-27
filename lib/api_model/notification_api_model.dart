// To parse this JSON data, do
//
//     final notiFicationApiModel = notiFicationApiModelFromJson(jsonString);

import 'dart:convert';

NotiFicationApiModel notiFicationApiModelFromJson(String str) => NotiFicationApiModel.fromJson(json.decode(str));

String notiFicationApiModelToJson(NotiFicationApiModel data) => json.encode(data.toJson());

class NotiFicationApiModel {
  int? responseCode;
  bool? result;
  String? message;
  List<Ndatum>? ndata;

  NotiFicationApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.ndata,
  });

  factory NotiFicationApiModel.fromJson(Map<String, dynamic> json) => NotiFicationApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    ndata: json["ndata"] == null ? [] : List<Ndatum>.from(json["ndata"]!.map((x) => Ndatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "ndata": ndata == null ? [] : List<dynamic>.from(ndata!.map((x) => x.toJson())),
  };
}

class Ndatum {
  int? id;
  String? image;
  String? title;
  String? description;
  String? date;

  Ndatum({
    this.id,
    this.image,
    this.title,
    this.description,
    this.date,
  });

  factory Ndatum.fromJson(Map<String, dynamic> json) => Ndatum(
    id: json["id"],
    image: json["image"],
    title: json["title"],
    description: json["description"],
    date: json["date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "title": title,
    "description": description,
    "date": date,
  };
}
