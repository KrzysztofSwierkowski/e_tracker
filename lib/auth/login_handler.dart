import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';


class LoginHandler extends StatefulWidget {
  const LoginHandler({super.key});


  @override
  _LoginHandlerState createState() => _LoginHandlerState();
}

class _LoginHandlerState extends State<LoginHandler> {

  bool showSignin = true;
  void toggleView(){
    setState(() {
      showSignin = !showSignin;
    });
  }



  @override
  Widget build(BuildContext context) {
    if(showSignin)
    {
      return LoginPage(toggleView : toggleView);
    }else
    {
      return RegisterPage(toggleView : toggleView);
    }
  }
}
