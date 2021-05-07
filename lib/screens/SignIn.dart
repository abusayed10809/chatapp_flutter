import 'package:chatapplication/screens/ChatScreen.dart';
import 'package:chatapplication/screens/SignUp.dart';
import 'package:chatapplication/services/Auth.dart';
import 'package:chatapplication/widgets/Widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  bool isLoading = false;

  AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
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
                    emailTextFormField(_emailController, globalFontSize*10),

                    passwordTextFormField(_passwordController, globalFontSize*10),
                  ],
                ),
              ),

              Container(
                height: height*0.07,
                width: width,
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: globalFontSize*8,
                    color: Colors.blue
                  ),
                ),
              ),

              GestureDetector(
                onTap: (){
                  signInUser();
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
                    'Sign In',
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
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: globalFontSize*10,
                        color: Colors.white
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: Text(
                        "Register Now",
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

  signInUser() {
    if(_formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      _authService.signInWithEmailPassword(email, password).then((value){
        if(value!=null){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen()));
        }
        else{
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }
}
