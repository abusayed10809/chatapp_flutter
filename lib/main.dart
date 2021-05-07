import 'package:chatapplication/providerModel/ChatRoomId.dart';
import 'package:chatapplication/screens/ChatScreen.dart';
import 'package:chatapplication/screens/SignIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

User _user;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _user = FirebaseAuth.instance.currentUser;
  // runApp(MyApp());

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ChatRoomId()),
        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black87,
        primaryColor: Colors.lightBlue,
      ),
      home: _user==null ? SignIn() : ChatScreen(),
    );
  }
}


