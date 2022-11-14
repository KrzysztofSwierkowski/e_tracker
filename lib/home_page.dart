import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Udostępnianie lokalizacji'),
      ),
      body: Column(
        children: const <Widget>[
          Center(
            child: Text("lokalizacja wybranego urządzenia"),
          ),
        ],
      ),
    );
  }
}
