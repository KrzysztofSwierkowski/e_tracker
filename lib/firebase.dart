import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'auth/auth.dart';

final AuthService _auth = AuthService();

class DBWrapper extends StatefulWidget {
  const DBWrapper({super.key});

  @override
  _DBWrapperState createState() => _DBWrapperState();
}

class _DBWrapperState extends State<DBWrapper> {
  FirebaseDatabase database = FirebaseDatabase.instance;


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
            child: Text('database'),
          ),
        ]),
      ),
    );
  }
}


