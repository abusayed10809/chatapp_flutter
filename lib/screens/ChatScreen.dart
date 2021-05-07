import 'package:chatapplication/constants/Config.dart';
import 'package:chatapplication/providerModel/ChatRoomId.dart';
import 'package:chatapplication/screens/ConversationScreen.dart';
import 'package:chatapplication/screens/SearchUser.dart';
import 'package:chatapplication/screens/SignIn.dart';
import 'package:chatapplication/services/Auth.dart';
import 'package:chatapplication/widgets/Widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  AuthService _authService = AuthService();
  ChatApplicationConfig _appConfig = ChatApplicationConfig();

  String _user = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final globalFontSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ChatApp',
          style: TextStyle(
            fontSize: globalFontSize * 12,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              _authService.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => SignIn()));
            },
            child: Container(
              margin: EdgeInsets.only(right: width * 0.025),
              child: Icon(
                Icons.logout,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        height: height * 0.9,
        width: width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: height*0.9,
                width: width,
                child: chatRoomStreamBuilder(context)
              ),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.search,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchUser()));
        },
      ),
    );
  }

  StreamBuilder chatRoomStreamBuilder(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final globalFontSize = MediaQuery.of(context).textScaleFactor;

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(_appConfig.chatRoomCollection)
            .where(_appConfig.chatUsers, arrayContains: _user)
            .snapshots(),
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
                  children: snapShot.data.docs.map((DocumentSnapshot documentSnapshot){
                    String chatRoomId = documentSnapshot.data()[_appConfig.chatRoomId];
                    String receiverName = "";
                    String receiverUserId = "";
                    if(documentSnapshot.data()[_appConfig.chatUsers][0] == _user){
                      receiverName = documentSnapshot.data()[_appConfig.chatUserNames][1];
                      receiverUserId = documentSnapshot.data()[_appConfig.chatUsers][1];
                    }
                    else{
                      receiverName = documentSnapshot.data()[_appConfig.chatUserNames][0];
                      receiverUserId = documentSnapshot.data()[_appConfig.chatUsers][0];
                    }

                    return GestureDetector(
                      onTap: (){
                        Provider.of<ChatRoomId>(context, listen: false).setChatRoomInfo(chatRoomId, _user, receiverUserId);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationScreen()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.black,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.lightBlueAccent,
                              blurRadius: 2.0,
                              spreadRadius: 0.0,
                              offset: Offset(2.0, 0.0), // shadow direction: bottom right
                            )
                          ],
                        ),
                        height: height*0.1,
                        width: width,
                        child: Row(
                          children: [
                            Container(
                              width: width*0.3,
                              child: CircleAvatar(
                                radius: width*0.07,
                                child: Icon(
                                  Icons.person
                                ),
                              ),
                            ),
                            Container(
                              width: width*0.7,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                receiverName,
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
            }
          }
        });
  }
}
