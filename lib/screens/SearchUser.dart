import 'package:chatapplication/constants/Config.dart';
import 'package:chatapplication/providerModel/ChatRoomId.dart';
import 'package:chatapplication/screens/ConversationScreen.dart';
import 'package:chatapplication/services/DatabaseService.dart';
import 'package:chatapplication/widgets/Widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class SearchUser extends StatefulWidget {
  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {

  ChatApplicationConfig _appConfig = ChatApplicationConfig();
  DatabaseService _databaseService = DatabaseService();

  TextEditingController _searchUserController = TextEditingController();
  String searchNameString = "";

  String currentUser = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final globalFontSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: appBarMain(context),
      resizeToAvoidBottomInset: false,

      body: Container(
        width: width,
        height: height*0.9,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                // color: Colors.grey[850],
                width: width,
                height: height*0.1,
                padding: EdgeInsets.symmetric(vertical: height*0.02),
                child: Container(
                  width: width,
                  padding: EdgeInsets.symmetric(horizontal: width*0.05),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: width*0.025),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.1),
                        border: Border.all(color: Colors.grey)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: TextField(
                            controller: _searchUserController,
                            onChanged: (value){
                              setState(() {
                                searchNameString = _searchUserController.text.trim();
                              });
                            },
                            style: TextStyle(
                              fontSize: globalFontSize*12,
                              color: Colors.white
                            ),
                            decoration: InputDecoration(
                                hintText: "Search User",
                                hintStyle: TextStyle(
                                  color: Colors.white54,
                                ),
                                border: InputBorder.none,
                            ),
                            cursorColor: Colors.white,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            child: Icon(Icons.search, color: Colors.white,),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: height*0.8,
                width: width,
                child: searchStreamBuilder(context)
              ),
            ],
          ),
        ),
      ),
    );
  }


  StreamBuilder searchStreamBuilder(BuildContext context){
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final globalFontSize = MediaQuery.of(context).textScaleFactor;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(_appConfig.userCollection).where(_appConfig.searchName, arrayContains: searchNameString).snapshots(),
      builder: (context, snapShot){
        if(snapShot.hasError){
          return errorTextCenter("Error fetching data");
        }
        else{
          switch(snapShot.connectionState){
            case ConnectionState.waiting:
              return circularProgress();
            case ConnectionState.none:
              return errorTextCenter("Connection error");
            case ConnectionState.done:
              return messageTextCenter("Data fetched successfully");
            default:
              return ListView(
                children: snapShot.data.docs.map((DocumentSnapshot documentSnapshot){
                  String userListUid = documentSnapshot.data()[_appConfig.userUid];
                  return (currentUser!=userListUid) ?
                  Container(
                    height: height*0.1,
                    width: width,
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
                    child: Row(
                      children: [
                        Container(
                          width: width*0.5,
                          padding: EdgeInsets.only(left: width*0.1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                documentSnapshot.data()[_appConfig.userName],
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),

                              Text(
                                documentSnapshot.data()[_appConfig.userEmail],
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                  fontSize: globalFontSize*8
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: width*0.12),
                          width: width*0.5,
                          color: Colors.black,
                          child: GestureDetector(
                            onTap: () async{
                              bool check = await checkChatRoomExist(userListUid);
                              if(check!=true){
                                await createChatRoomSendUser(currentUser, userListUid);
                              }
                              else{
                                Fluttertoast.showToast(
                                  msg: "User already added to chatroom",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              }
                            },
                            child: Container(
                              height: height*0.05,
                              width: width*0.25,
                              alignment: Alignment.center,
                              child: Text(
                                'Message',
                                style: TextStyle(
                                  fontSize: globalFontSize*10,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.lightBlue,
                                borderRadius: BorderRadius.circular(width*0.1)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) : Container(color: Colors.blue,);
                }).toList(),
              );
          }
        }
      },
    );
  }

  Future createChatRoomSendUser(currentUser, userListUid) async{
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(_appConfig.userCollection)
    .doc(currentUser).get();
    String currentUserName = (documentSnapshot.data()[_appConfig.userName]);

    DocumentSnapshot documentSnapshotSecond = await FirebaseFirestore.instance.collection(_appConfig.userCollection)
        .doc(userListUid).get();
    String receiverUserName = (documentSnapshotSecond.data()[_appConfig.userName]);

    List<String> userName = [];
    userName.add(currentUserName);
    userName.add(receiverUserName);

    String documentId = currentUser+userListUid;
    List<String> userId = [];
    userId.add(currentUser);
    userId.add(userListUid);

    Provider.of<ChatRoomId>(context, listen: false).setChatRoomInfo(documentId, currentUser, userListUid);

    Map<String, dynamic> chatRoomMap = {
      _appConfig.chatRoomId: documentId,
      _appConfig.chatUsers: userId,
      _appConfig.chatUserNames: userName
    };

    _databaseService.createChatRoom(documentId, chatRoomMap);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ConversationScreen()));
  }

  Future<bool> checkChatRoomExist(userListUid) async {
    DocumentSnapshot checkOne = await FirebaseFirestore.instance.collection(_appConfig.chatRoomCollection).doc(currentUser+userListUid).get();
    DocumentSnapshot checkTwo = await FirebaseFirestore.instance.collection(_appConfig.chatRoomCollection).doc(userListUid+currentUser).get();
    bool chatRoomAlreadyExist = false;
    if(checkOne.exists || checkTwo.exists){
      chatRoomAlreadyExist = true;
    }
    return chatRoomAlreadyExist;
  }
}
