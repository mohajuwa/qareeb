// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/api_code/chat_list_api_controller.dart';
import 'package:qareeb/app_screen/home_screen.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:qareeb/common_code/config.dart';
import '../app_screen/map_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ScrollController _controller;
  TextEditingController messageController = TextEditingController();
  ChatListApiController chatListApiController =
      Get.put(ChatListApiController());

  List messaj = [];

  socketConnect() async {
    setState(() {});

    // Use HTTPS with proper configuration

    socket = IO.io('https://qareeb.modwir.com', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
      'extraHeaders': {'Accept': '*/*'},
      'timeout': 30000,
      'forceNew': true,
    });

    socket.connect();

    _connectSocket();
  }

  _connectSocket() async {
    setState(() {});
    socket.onConnect(
        (data) => print('Connection established Connected driverdetail'));
    socket.onConnectError((data) => print('Connect Error driverdetail: $data'));
    socket.onDisconnect(
        (data) => print('Socket.IO server disconnected driverdetail'));

    print("999999:-- $useridgloable");

    socket.on('New_Chat$useridgloable', (New_Chat) {
      print("???????:-- ($New_Chat)");

      // messaj.add(New_Chat["message"]);
      // print("////:--- ${messaj}");

      chatListApiController.chatlistApi(
          uid: useridgloable.toString(),
          sender_id: useridgloable.toString(),
          recevier_id: driver_id.toString(),
          status: "customer");
    });
  }

  sendmessaj() {
    socket.emit('Send_Chat', {
      'sender_id': useridgloable,
      'recevier_id': driver_id,
      'message': messageController.text.trim(),
      'status': "customer",
    });
    messageController.clear();
  }

  @override
  void initState() {
    _controller = ScrollController();
    socketConnect();
    chatListApiController.chatlistApi(
        uid: useridgloable.toString(),
        sender_id: useridgloable.toString(),
        recevier_id: driver_id.toString(),
        status: "customer");
    super.initState();
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: notifier.background,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: notifier.background,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              size: 20,
              color: notifier.textColor,
            )),
        title: GetBuilder<ChatListApiController>(
          builder: (chatListApiController) {
            return chatListApiController.isLoading
                ? const SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage(
                                    "${Config.imageurl}${chatListApiController.chatListApiModel!.userData!.profileImage}"),
                                fit: BoxFit.cover)),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "${chatListApiController.chatListApiModel!.userData!.firstName} ${chatListApiController.chatListApiModel!.userData!.lastName}",
                        style: TextStyle(
                          color: notifier.textColor,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      const Spacer(),
                    ],
                  );
          },
        ),
      ),
      body: GetBuilder<ChatListApiController>(
        builder: (chatListApiController) {
          return chatListApiController.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  color: theamcolore,
                ))
              : chatListApiController.chatListApiModel!.chatList!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/emptyOrder.png"),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "No Chat Found!".tr,
                            style: TextStyle(
                              color: notifier.textColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Currently you don’t have chat.".tr,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Scrollbar(
                      controller: _controller,
                      child: SingleChildScrollView(
                        controller: _controller,
                        reverse: true,
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  cacheExtent: 99999999,
                                  itemCount: chatListApiController
                                      .chatListApiModel!.chatList!.length,
                                  itemBuilder: (context, index1) {
                                    return Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        Text(
                                          "${chatListApiController.chatListApiModel!.chatList![index1].date}",
                                          style: TextStyle(
                                            color: notifier.textColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        ListView.separated(
                                          shrinkWrap: true,
                                          cacheExtent: 99999999,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 10),
                                          separatorBuilder: (_, index) =>
                                              const SizedBox(
                                            height: 5,
                                          ),
                                          itemCount: chatListApiController
                                              .chatListApiModel!
                                              .chatList![index1]
                                              .chat!
                                              .length,
                                          itemBuilder: (context, index) {
                                            return Wrap(
                                              alignment: chatListApiController
                                                          .chatListApiModel!
                                                          .chatList![index1]
                                                          .chat![index]
                                                          .status ==
                                                      1
                                                  ? WrapAlignment.end
                                                  : WrapAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: chatListApiController
                                                                .chatListApiModel!
                                                                .chatList![
                                                                    index1]
                                                                .chat![index]
                                                                .status ==
                                                            1
                                                        ? theamcolore
                                                        : Colors.grey
                                                            .withOpacity(0.1),
                                                    borderRadius: chatListApiController
                                                                .chatListApiModel!
                                                                .chatList![
                                                                    index1]
                                                                .chat![index]
                                                                .status ==
                                                            1
                                                        ? const BorderRadius.only(
                                                            topLeft: Radius.circular(
                                                                10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10))
                                                        : const BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(10)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 6,
                                                        horizontal: 8),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          chatListApiController
                                                                      .chatListApiModel!
                                                                      .chatList![
                                                                          index1]
                                                                      .chat![
                                                                          index]
                                                                      .status ==
                                                                  1
                                                              ? CrossAxisAlignment
                                                                  .end
                                                              : CrossAxisAlignment
                                                                  .start,
                                                      children: [
                                                        messageController
                                                                    .text !=
                                                                null
                                                            ? Text(
                                                                "${chatListApiController.chatListApiModel!.chatList![index1].chat![index].message}",
                                                                style:
                                                                    TextStyle(
                                                                  color: chatListApiController
                                                                              .chatListApiModel!
                                                                              .chatList![
                                                                                  index1]
                                                                              .chat![
                                                                                  index]
                                                                              .status ==
                                                                          1
                                                                      ? Colors
                                                                          .white
                                                                      : notifier
                                                                          .textColor,
                                                                  fontSize: 16,
                                                                ),
                                                              )
                                                            : Text(
                                                                "${chatListApiController.chatListApiModel!.chatList![index1].chat![index].message}",
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                        const SizedBox(
                                                            height: 6),
                                                        Text(
                                                          "${chatListApiController.chatListApiModel!.chatList![index1].chat![index].date}",
                                                          style: TextStyle(
                                                            color: chatListApiController
                                                                        .chatListApiModel!
                                                                        .chatList![
                                                                            index1]
                                                                        .chat![
                                                                            index]
                                                                        .status ==
                                                                    1
                                                                ? Colors.white
                                                                : notifier
                                                                    .textColor,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
        },
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                      fillColor: Colors.grey.shade300,
                      filled: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {});
                          if (messageController.text.trim().isNotEmpty) {
                            print(
                                "mesjmesjmesj:--- (${messageController.text.trim()})");
                            sendmessaj();
                            chatListApiController.chatlistApi(
                                uid: useridgloable.toString(),
                                sender_id: useridgloable.toString(),
                                recevier_id: driver_id.toString(),
                                status: "customer");
                            setState(() {});
                          } else {
                            print("fffffffffff");
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.black),
                      hintText: "Say Something...".tr,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(65)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(65)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: theamcolore, width: 1.8),
                          borderRadius: BorderRadius.circular(65)),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(65))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
