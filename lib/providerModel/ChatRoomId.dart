import 'package:flutter/material.dart';

class ChatRoomId with ChangeNotifier{
  String chatRoomId = "";
  String currentUserId = "";
  String receiverUserId = "";

  setChatRoomInfo(String id, String currentUserUid, String receiverUserUid){
    chatRoomId = id;
    currentUserId = currentUserUid;
    receiverUserId = receiverUserUid;
    notifyListeners();
  }
}