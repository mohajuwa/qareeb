// To parse this JSON data, do
//
//     final pageListApiiimodel = pageListApiiimodelFromJson(jsonString);

import 'dart:convert';

PageListApiiimodel pageListApiiimodelFromJson(String str) => PageListApiiimodel.fromJson(json.decode(str));

String pageListApiiimodelToJson(PageListApiiimodel data) => json.encode(data.toJson());

class PageListApiiimodel {
  int? responseCode;
  bool? result;
  String? message;
  List<PagesList>? pagesList;

  PageListApiiimodel({
    this.responseCode,
    this.result,
    this.message,
    this.pagesList,
  });

  factory PageListApiiimodel.fromJson(Map<String, dynamic> json) => PageListApiiimodel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    pagesList: json["pages_list"] == null ? [] : List<PagesList>.from(json["pages_list"]!.map((x) => PagesList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "pages_list": pagesList == null ? [] : List<dynamic>.from(pagesList!.map((x) => x.toJson())),
  };
}

class PagesList {
  int? id;
  String? title;
  String? description;
  String? status;

  PagesList({
    this.id,
    this.title,
    this.description,
    this.status,
  });

  factory PagesList.fromJson(Map<String, dynamic> json) => PagesList(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "status": status,
  };
}
