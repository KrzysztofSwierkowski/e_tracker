import 'package:flutter/material.dart';
import 'package:phone_mqtt/constans.dart' as Constans;
import 'package:phone_mqtt/gpsHandle/gps_device_controller.dart';

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
  GpsDeviceController gpsDeviceController = GpsDeviceController();

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
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        color: Color(0xff000000),
        //image: DecorationImage(
        //  image: AssetImage("assets/HomeBackground.png"), fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
                child: ElevatedButton(
                    style: Constans.yellowButtonStyle,
                    onPressed: () async {
                      await _auth.signOut();
                    },
                    child: const Text(
                      'Wyloguj',
                      style: Constans.blackTextStyleForYellowButton,
                    )),
              ),
            ),
            const SelectionContainer.disabled(
                child: Text(
              'Wpisz numer subskrybowanego urządzenia:',
              style: Constans.whiteTextStyle,
            )),
            //Row(children: [
            TextField(
              style: Constans.whiteTextStyle,
              controller: getIdGpsController,
              decoration: InputDecoration(
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintText: 'Wpisz ID nowego urządzenia',
                hintStyle: Constans.whiteHintTextStyle15px,
                suffixIcon: IconButton(
                  onPressed: getIdGpsController.clear,
                  icon: Icon(Icons.clear),
                ),
              ),
            ),
            ElevatedButton(
                style: Constans.yellowButtonStyle,
                onPressed: () async {
                  getIdGpsController.clear;
                  Constans.deviceIDList.add(getIdGpsController.text);
                  gpsDeviceController.saveDeviceIDList();
                  getIdGpsController.clear();
                },
                child: const Text(
                  'Dodaj',
                  style: Constans.blackTextStyleForYellowButton,
                )),
            const SelectionContainer.disabled(
                child: Text(
              'IP MQTT:',
              style: Constans.whiteTextStyle,
            )),
            //Row(children: [
            TextField(
              style: Constans.whiteTextStyle,
              controller: getIpMqttBroker,
              decoration: InputDecoration(
                hintText: 'Wpisz IP brokera MQTT',
                hintStyle: Constans.whiteHintTextStyle15px,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                suffixIcon: IconButton(
                  onPressed: getIpMqttBroker.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            ElevatedButton(
                style: Constans.yellowButtonStyle,
                onPressed: () async {
                  Constans.ipBroker = getIpMqttBroker.text;
                  getIpMqttBroker.clear();
                },
                child: const Text(
                  'Dodaj',
                  style: Constans.blackTextStyleForYellowButton,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
              child: ElevatedButton(
                  style: Constans.yellowButtonStyle,
                  onPressed: () async {
                    _DisplayGpsList(context);
                  },
                  child: const Text(
                    'Pokaż liste urządzeń',
                    style: Constans.blackTextStyleForYellowButton,
                  )),
            ),
            //]),
          ]),
        ),
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
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GpsDevicesList()),
      );
    }
    if (!mounted) return;
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () => Navigator.pop(context, 'OK'),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("brak dodatkowych urządzeń"),
      content: const Text("Aby zobaczyć urządzenia najpierw je dodaj!"),
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
