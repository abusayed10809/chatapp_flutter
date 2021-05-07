
import 'dart:async';

import 'package:chatapplication/constants/Config.dart';
import 'package:chatapplication/providerModel/ChatRoomId.dart';
import 'package:chatapplication/services/DatabaseService.dart';
import 'package:chatapplication/widgets/Widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationScreen extends StatefulWidget {
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}


class _ConversationScreenState extends State<ConversationScreen> {
  ChatApplicationConfig _appConfig = ChatApplicationConfig();
  DatabaseService _databaseService = DatabaseService();

  TextEditingController _messageController = TextEditingController();

  String _userId = "";
  String chatRoomId = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userId = FirebaseAuth.instance.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomIdProvider = Provider.of<ChatRoomId>(context);

    setState(() {
      chatRoomId = chatRoomIdProvider.chatRoomId;
    });

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final globalFontSize = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        width: width,
        height: height * 0.895,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  height: height * 0.82,
                  width: width,
                  child: chatStreamBuilder(context)),
              Container(
                height: height * 0.075,
                width: width,
                color: Colors.grey[900],
                child: Row(
                  children: [
                    Container(
                      width: width * 0.8,
                      height: height * 0.075,
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.005, horizontal: width * 0.05),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.03,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width * 0.1),
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          controller: _messageController,
                          cursorColor: Colors.white,
                          style: simpleTextStyle(globalFontSize * 12),
                          decoration: InputDecoration.collapsed(
                              hintText: 'Message...',
                              hintStyle: TextStyle(color: Colors.white54)),
                        ),
                      ),
                    ),
                    Container(
                      width: width * 0.2,
                      height: height * 0.075,
                      child: GestureDetector(
                        onTap: () async {
                          String message = _messageController.text;
                          _messageController.text = "";
                          if (message.trim().isNotEmpty) {
                            await sendMessage(message, context);
                          }
                        },
                        child: Icon(
                          Icons.send_outlined,
                          color: Colors.grey,
                          size: width * 0.08,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage(message, context) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, dynamic> chatMessageMap = {
      _appConfig.chatTimeStamp: timeStamp,
      _appConfig.chatSendBy: _userId,
      _appConfig.chatMessage: message
    };

    await _databaseService.sendChatMessage(chatMessageMap, chatRoomId);
  }

  StreamBuilder chatStreamBuilder(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final globalFontSize = MediaQuery.of(context).textScaleFactor;

    return StreamBuilder<QuerySnapshot>(
        stream: _databaseService.getChatMessage(chatRoomId),
        builder: (context, snapShot) {
          if (snapShot.hasError) {
            return errorTextCenter("Error fetching data");
          }
          else {
            switch (snapShot.connectionState) {
              case ConnectionState.waiting:
                return circularProgress();
              case ConnectionState.none:
                return errorTextCenter("Connection error");
              default:
                return ListView(
                  reverse: true,
                  shrinkWrap: true,
                  children: snapShot.data.docs.map((DocumentSnapshot documentSnapshot){
                    String message = documentSnapshot.data()[_appConfig.chatMessage];
                    String sendBy = documentSnapshot.data()[_appConfig.chatSendBy];
                    String timeStamp = documentSnapshot.data()[_appConfig.chatTimeStamp];
                    bool rightAlign;
                    if(sendBy==_userId){
                      rightAlign=true;
                    }
                    else{
                      rightAlign=false;
                    }

                    return Container(
                      alignment: rightAlign ? Alignment.centerRight : Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(horizontal: width*0.02, vertical: height*0.0015),
                      child: Container(
                        decoration: BoxDecoration(
                          color: rightAlign? Colors.grey[850] : Colors.lightBlue[900],
                          borderRadius: BorderRadius.only(
                            topLeft: rightAlign ? Radius.circular(width*0.05) : Radius.circular(width*0),
                            bottomLeft: Radius.circular(width*0.05),
                            bottomRight: Radius.circular(width*0.05),
                            topRight: !rightAlign ? Radius.circular(width*0.05) : Radius.circular(width*0),
                          ),
                        ),
                        padding: EdgeInsets.all(width*0.03),
                        width: width*0.7,
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                      ),
                    );
                  }).toList(growable: false),
                );
            }
          }
        });
  }
}
