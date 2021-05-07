import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context){
  final globalFontSize = MediaQuery.of(context).textScaleFactor;
  return AppBar(
    title: Text(
      'ChatApp',
      style: TextStyle(
        fontSize: globalFontSize*12,
      ),
    ),
    centerTitle: true,
  );
}

InputDecoration hintTextInputDecoration(String hintText){
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
          color: Colors.white54,
      ),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white)
      ),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38)
      )
  );
}

Widget errorTextCenter(String error){
  return Center(
    child: Text(
      error,
      style: TextStyle(
          color: Colors.red
      ),
    ),
  );
}

Widget messageTextCenter(String error){
  return Center(
    child: Text(
      error,
      style: TextStyle(
          color: Colors.white
      ),
    ),
  );
}

Widget circularProgress(){
  return Center(
      child: CircularProgressIndicator()
  );
}

TextStyle simpleTextStyle(double fontSize){
  return TextStyle(
    fontSize: fontSize,
    color: Colors.white
  );
}

TextFormField emailTextFormField(TextEditingController emailController, double fontSize){
  return TextFormField(
    decoration: hintTextInputDecoration('Email'),
    style: simpleTextStyle(fontSize),
    controller: emailController,
    validator: (value){
      bool valid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
      if(!valid){
        return "Please enter correct email format.";
      }
      return null;
    },
  );
}

TextFormField passwordTextFormField(TextEditingController passwordController, double fontSize){
  return TextFormField(
    decoration: hintTextInputDecoration('Password'),
    style: simpleTextStyle(fontSize),
    obscureText: true,
    controller: passwordController,
    validator: (value){
      if(value.length<6){
        return 'Password must be at least 6 letters.';
      }
      return null;
    },
  );
}
