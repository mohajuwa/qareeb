// To parse this JSON data, do
//
//     final faqApiiimodel = faqApiiimodelFromJson(jsonString);

import 'dart:convert';

FaqApiiimodel faqApiiimodelFromJson(String str) => FaqApiiimodel.fromJson(json.decode(str));

String faqApiiimodelToJson(FaqApiiimodel data) => json.encode(data.toJson());

class FaqApiiimodel {
  int? responseCode;
  bool? result;
  String? message;
  List<FaqList>? faqList;

  FaqApiiimodel({
    this.responseCode,
    this.result,
    this.message,
    this.faqList,
  });

  factory FaqApiiimodel.fromJson(Map<String, dynamic> json) => FaqApiiimodel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    faqList: json["faq_list"] == null ? [] : List<FaqList>.from(json["faq_list"]!.map((x) => FaqList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "faq_list": faqList == null ? [] : List<dynamic>.from(faqList!.map((x) => x.toJson())),
  };
}

class FaqList {
  int? id;
  String? title;
  String? description;
  String? status;

  FaqList({
    this.id,
    this.title,
    this.description,
    this.status,
  });

  factory FaqList.fromJson(Map<String, dynamic> json) => FaqList(
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
