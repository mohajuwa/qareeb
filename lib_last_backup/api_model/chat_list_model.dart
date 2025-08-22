// To parse this JSON data, do
//
//     final chatListApiModel = chatListApiModelFromJson(jsonString);

import 'dart:convert';

ChatListApiModel chatListApiModelFromJson(String str) => ChatListApiModel.fromJson(json.decode(str));

String chatListApiModelToJson(ChatListApiModel data) => json.encode(data.toJson());

class ChatListApiModel {
  int? responseCode;
  bool? result;
  String? message;
  UserData? userData;
  List<ChatList>? chatList;

  ChatListApiModel({
    this.responseCode,
    this.result,
    this.message,
    this.userData,
    this.chatList,
  });

  factory ChatListApiModel.fromJson(Map<String, dynamic> json) => ChatListApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    message: json["message"],
    userData: json["user_data"] == null ? null : UserData.fromJson(json["user_data"]),
    chatList: json["chat_list"] == null ? [] : List<ChatList>.from(json["chat_list"]!.map((x) => ChatList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "message": message,
    "user_data": userData?.toJson(),
    "chat_list": chatList == null ? [] : List<dynamic>.from(chatList!.map((x) => x.toJson())),
  };
}

class ChatList {
  String? date;
  List<Chat>? chat;

  ChatList({
    this.date,
    this.chat,
  });

  factory ChatList.fromJson(Map<String, dynamic> json) => ChatList(
    date: json["date"],
    chat: json["chat"] == null ? [] : List<Chat>.from(json["chat"]!.map((x) => Chat.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "chat": chat == null ? [] : List<dynamic>.from(chat!.map((x) => x.toJson())),
  };
}

class Chat {
  int? id;
  String? date;
  String? message;
  int? status;

  Chat({
    this.id,
    this.date,
    this.message,
    this.status,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json["id"],
    date: json["date"],
    message: json["message"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date,
    "message": message,
    "status": status,
  };
}

class UserData {
  int? id;
  String? profileImage;
  String? firstName;
  String? lastName;

  UserData({
    this.id,
    this.profileImage,
    this.firstName,
    this.lastName,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["id"],
    profileImage: json["profile_image"],
    firstName: json["first_name"],
    lastName: json["last_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "profile_image": profileImage,
    "first_name": firstName,
    "last_name": lastName,
  };
}
