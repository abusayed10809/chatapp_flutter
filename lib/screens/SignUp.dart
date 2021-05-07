import 'package:chatapplication/constants/Config.dart';
import 'package:chatapplication/screens/ChatScreen.dart';
import 'package:chatapplication/screens/SignIn.dart';
import 'package:chatapplication/services/Auth.dart';
import 'package:chatapplication/services/DatabaseService.dart';
import 'package:chatapplication/widgets/Widgets.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  AuthService _authService = AuthService();
  DatabaseService _databaseService = DatabaseService();
  ChatApplicationConfig _appConfig = ChatApplicationConfig();

  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final globalFontSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        width: width,
        height: height*0.9,
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.symmetric(horizontal: width*0.05),
        child: isLoading==true ? Center(
          child: CircularProgressIndicator(),
        ) : SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: hintTextInputDecoration('UserName'),
                      style: simpleTextStyle(globalFontSize*10),
                      controller: _userNameController,
                      validator: (value){
                        if(value.trim().length < 4){
                          return 'UserName must be at-least 4 character.';
                        }
                        else if(value.trim().length > 10){
                          return "UserName must be under 10 character";
                        }
                        else{
                          return null;
                        }
                      },
                    ),

                    emailTextFormField(_emailController, globalFontSize*10),

                    passwordTextFormField(_passwordController, globalFontSize*10),
                  ],
                ),
              ),

              Container(
                height: height*0.07,
                width: width,
                alignment: Alignment.centerRight,
              ),

              GestureDetector(
                onTap: (){
                  _signUpWithEmailPassword();
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.blue[700]
                        ]
                    ),
                    borderRadius: BorderRadius.circular(width*0.1),
                  ),
                  width: width,
                  height: height*0.06,
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: globalFontSize*11,
                        color: Colors.white
                    ),
                  ),
                ),
              ),

              Container(
                height: height*0.025,
              ),


              Container(
                width: width,
                height: height*0.07,
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                          fontSize: globalFontSize*10,
                          color: Colors.white
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                      },
                      child: Text(
                        "Sign In?",
                        style: TextStyle(
                            fontSize: globalFontSize*10,
                            color: Colors.blue,
                            decoration: TextDecoration.underline
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: height*0.15,
              )
            ],
          ),
        ),
      ),
    );
  }

  _signUpWithEmailPassword() {
    if(_formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });
      String userName = _userNameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      List<String> searchName = setSearchParam(userName);

      _authService.signUpWithEmailPassword(email, password).then((userModel){
        if(userModel!=null){
          String userUid = userModel.userId;
          Map<String, dynamic> userInfoMap = {
            _appConfig.userName: userName,
            _appConfig.userEmail: email,
            _appConfig.password: password,
            _appConfig.userUid: userUid,
            _appConfig.searchName: searchName,
          };
          _databaseService.uploadUserInfo(userInfoMap).then((value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen()));
          });
        }
        else{
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  List<String> setSearchParam(String userName) {
    List<String> caseSearchList = [];
    String temp = "";
    caseSearchList.add(temp);
    for (int i = 0; i < userName.length; i++) {
      temp = temp + userName[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }
}
