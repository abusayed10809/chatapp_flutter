import 'package:chatapplication/constants/Config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class DatabaseService{

  ChatApplicationConfig _appConfig = ChatApplicationConfig();

  // Future getUserByUserName(String userName) async{
  //   FirebaseFirestore.instance.collection(_appConfig.userCollection);
  // }

  Future uploadUserInfo(userInfoMap) async{
    await FirebaseFirestore.instance.collection(_appConfig.userCollection).doc(userInfoMap[_appConfig.userUid]).set(userInfoMap);
  }

  Future createChatRoom(String documentId, chatRoomMap) async{
    await FirebaseFirestore.instance.collection(_appConfig.chatRoomCollection)
        .doc(documentId).set(chatRoomMap).catchError((error){
      Fluttertoast.showToast(
        msg: error.message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    });
  }

  Future<void> sendChatMessage(Map chatMessageMap, String chatRoomId) async{
    await FirebaseFirestore.instance.collection(_appConfig.chatRoomCollection)
        .doc(chatRoomId)
        .collection(_appConfig.chats)
        .doc(chatMessageMap[_appConfig.chatTimeStamp])
        .set(chatMessageMap);
  }


  Stream<QuerySnapshot> getChatMessage(String chatRoomId) {
    return FirebaseFirestore.instance
        .collection(_appConfig.chatRoomCollection)
        .doc(chatRoomId)
        .collection(_appConfig.chats).orderBy(_appConfig.chatTimeStamp, descending: true)
        .snapshots();
  }
}