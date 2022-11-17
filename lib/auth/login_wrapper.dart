import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../menu.dart';
import '../auth/firebaseuser.dart';
import '../auth/login_handler.dart';

class LoginWrapper extends StatelessWidget {
  const LoginWrapper({super.key});



  @override
  Widget build(BuildContext context) {

    final user = Provider.of<FirebaseUser?>(context);

    if(user == null)
      {
        return LoginHandler();
      } else
        {
          return const Menu();
        }

  }
}
