import 'package:flutter/material.dart';
import 'package:phone_mqtt/constans.dart' as Constans;

import 'auth/auth.dart';
import 'constans.dart';
import 'gpsHandle/gps_devices_list.dart';

final AuthService _auth = AuthService();

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // var getIdGps;

  final getIdGpsController = TextEditingController();
  final getIpMqttBroker = TextEditingController();

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
              child: const Text('Dodaj')),
          const SelectionContainer.disabled(child: Text('IP MQTT:')),
          //Row(children: [
          TextField(
            controller: getIpMqttBroker,
            decoration: InputDecoration(
              hintText: 'Wpisz IP brokera MQTT',
              suffixIcon: IconButton(
                onPressed: getIdGpsController.clear,
                icon: Icon(Icons.clear),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                Constans.ipBroker = getIpMqttBroker.text;
              },
              child: const Text('Dodaj')),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
            child: ElevatedButton(
                onPressed: () async {
                  _DisplayGpsList(context);
                },
                child: const Text('Pokaż liste urządzeń')),
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

  Future<void> _DisplayGpsList(BuildContext context) async {
    if (deviceIDList.isEmpty) {
      showAlertDialog(context);
      print('List is empty.');
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GpsDevicesList()),
      );
    }
    if (!mounted) return;
  }

  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context, 'OK'),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("brak dodatkowych urządzeń"),
      content: Text("Aby zobaczyć urządzenia najpierw je dodaj!"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}



//todo theme changer (dark/white)
//todo account menager
