import 'package:flutter/material.dart';
import 'package:phone_mqtt/constans.dart' as Constans;
import 'auth/auth.dart';

final AuthService _auth = AuthService();

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
 // var getIdGps;

  final getIdGpsController = TextEditingController();

  @override
  void initState() {
    super.initState();

  //   getIdGpsController.addListener(_printLatestValue);
   }
  //
  // void _printLatestValue() {
  //   getIdGps = getIdGpsController.text;
  //
  // }

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
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
              child: ElevatedButton(
                  onPressed: () async {
                    await _auth.signOut();
                  },
                  child: const Text('Wyloguj')),
            ),
          ),
          const SelectionContainer.disabled(
              child: Text('Wpisz numer subskrybowanego urządzenia:')),
          //Row(children: [
          TextField(
            controller: getIdGpsController,
            decoration: InputDecoration(
              hintText: 'Wpisz ID nowego urządzenia',
              suffixIcon: IconButton(
                onPressed: getIdGpsController.clear,
                icon: Icon(Icons.clear),
              ),
            ),
          ),
            ElevatedButton(
                onPressed: () async {
                  Constans.deviceIDList.add(getIdGpsController.text);
                },
                child: const Text('Dodaj')
            ),
          //]),
        ]),
      ),
    );
  }

  void dispose() {
    getIdGpsController.dispose();
    super.dispose();
  }
}

//todo theme changer (dark/white)
//todo account menager
