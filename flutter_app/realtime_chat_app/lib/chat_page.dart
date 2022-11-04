import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:realtime_chat_app/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class APIConstants {
  static const String socketServerURL =
      "https://real-time-chat-97.herokuapp.com";
  // "https://nodejs-chat-socketio.herokuapp.com";
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  IO.Socket? socketIO;
  List<String>? messages;
  double? height, width;
  TextEditingController? textController;
  ScrollController? scrollController;

  @override
  void dispose() {
    socketIO?.disconnect();
    socketIO?.dispose();
    super.dispose();
  }

  getMessage() {
    // socketIO?.on('receive_message', (newMessage) {
    //   Map<String, dynamic> data = jsonDecode(newMessage);

    //   print("Data : $newMessage");
    //   messages?.add(data['messages']);
    //   scrollController?.animateTo(
    //     scrollController!.position.maxScrollExtent,
    //     duration: Duration(milliseconds: 600),
    //     curve: Curves.ease,
    //   );
    // });
    socketIO?.on('receive_message', (newMessage) {
      Map<String, dynamic> data = jsonDecode(newMessage);

      print("Data : $newMessage");
      // messages?.add(data['messages']);

      messages?.add("value");
      // messages?.add(jsonEncode(data));
      setState(() {});
      scrollController?.animateTo(
        scrollController!.position.maxScrollExtent,
        duration: Duration(milliseconds: 600),
        curve: Curves.ease,
      );
    });
  }

  @override
  void initState() {
    messages = [];
    textController = TextEditingController();
    scrollController = ScrollController();
    initSocket();
    getMessage();
  }

  initSocket() {
    socketIO = IO.io(APIConstants.socketServerURL, <String, dynamic>{
      'autoConnect': true,
      'transports': ['websocket'],
    });
    socketIO?.connect();
    Map testing = {"messages": "test", "id": 1};
    socketIO?.emit("send_message", jsonEncode(testing));
    // socketIO?.emit("joinRoom", jsonEncode(testing));
    socketIO?.onConnect((_) {
      print("Connection Established");
    });
    socketIO?.onDisconnect((_) => print('Connection Disconnection'));
    socketIO?.onConnectError((err) => print("Connect Error $err"));
    socketIO?.onError((err) => print("Error $err"));
  }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.only(bottom: 20.0, left: 20.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          messages![index],
          style: TextStyle(color: Colors.white, fontSize: 15.0),
        ),
      ),
    );
  }

  Widget buildMessageList() {
    return Container(
      height: height! * 0.8,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages!.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: width! * 0.7,
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(left: 40.0),
      child: TextField(
        decoration: InputDecoration.collapsed(
          hintText: 'Send a message...',
        ),
        controller: textController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      onPressed: () {
        if (textController!.text.isNotEmpty) {
          sendMessage();
          // socketIO.sendMessage(
          //     'send_message', json.encode({'message': textController.text}));
          this.setState(() => messages?.add(textController!.text));
          textController!.text = '';
          scrollController?.animateTo(
            scrollController!.position.maxScrollExtent,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        }
      },
      child: const Icon(
        Icons.send,
        size: 30,
      ),
    );
  }

  sendMessage() {
    String message = textController!.text.trim();
    if (message.isEmpty) return;
    Map messageMap = {
      'id': 1,
      'messages': message,
      // 'senderId': userId,
      // 'receiverId': receiverId,
      // 'time': DateTime.now().millisecondsSinceEpoch,
    };

    socketIO?.emit('send_message', jsonEncode(messageMap));
    // socketIO?.emit('joinRoom', jsonEncode(messageMap));
  }

  Widget buildInputArea() {
    return Container(
      height: height! * 0.1,
      width: width,
      child: Row(
        children: <Widget>[
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height! * 0.1),
            buildMessageList(),
            buildInputArea(),
          ],
        ),
      ),
    );
  }
}
