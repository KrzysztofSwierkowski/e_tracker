import 'package:flutter/material.dart';

import 'auth/auth.dart';

final AuthService _auth = AuthService();

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Singout = Material(
    elevation: 5.0,
    borderRadius: BorderRadius.circular(30.0),
    child: OutlinedButton(
        onPressed: () async {
          await _auth.signOut();
        },
        child: Text('Wyloguj')),
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/inapp.png"), fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: Column(children: [
          Center(
            child: Container(child: Singout),
          ),
        ]),
      ),
    );
  }
}

//todo theme changer (dark/white)
//todo account menager
