import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_mqtt/constans.dart' as Constans;
import 'package:phone_mqtt/gpsHandle/gps_device_controller.dart';

import 'auth/auth.dart';
import 'constans.dart';
import 'gpsHandle/device_information.dart';
import 'gpsHandle/gps_devices_list.dart';
import 'mqtt_connect.dart';

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
  MqttConnect mqttConnect = MqttConnect();

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
        color: Color(0xFF1E1F22),
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
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black26,
                  width: 5.0,
                ),
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xFF3A3A3A),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                child: Column(children: [
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
                ]),
              ),
            ),
            ElevatedButton(
                style: Constans.yellowButtonStyle,
                onPressed: () async {
                  checkContainValueInDeviceIdList();
                },
                child: const Text(
                  'Dodaj',
                  style: Constans.blackTextStyleForYellowButton,
                )),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black26,
                  width: 5.0,
                ),
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xFF3A3A3A),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                child: Column(children: [
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
                ]),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
              child: ElevatedButton(
                  style: Constans.yellowButtonStyle,
                  onPressed: ()  {
                    _unSubscribeAllTopics();
                    mqttConnect.disconnect();
                    Constans.deviceIDList.clear();
                    Constans.topicList.clear();
                    Constans.MarkersOnMap.clear();

                  },
                  child: const Text(
                    'Usuń wszystkie urządzenia',
                    style: Constans.blackTextStyleForYellowButton,
                  )),
            ),
            //]),
          ]),
        ),
      ),
    );
  }



  void checkContainValueInDeviceIdList() {
    if (Constans.deviceIDList.contains(getIdGpsController.text)) {
      _showDialog(context);
      getIdGpsController.clear();
    } else {
      // set up the AlertDialog
      Constans.deviceIDList.add(getIdGpsController.text);
      gpsDeviceController.saveDeviceIDList();
      getIdGpsController.clear();
    }
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

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Uwaga!!"),
          content: new Text("Urządzenie znajduje się już w bazie"),
          actions: <Widget>[
            new ElevatedButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _unSubscribeAllTopics() async {
    for (var i = 0; i < Constans.topicList.length; i++) {
      mqttConnect.client.unsubscribe(Constans.topicList[i]);
    }
  }

  void dispose() {
    getIdGpsController.dispose();
    gpsDeviceController.saveDeviceIDList();
    super.dispose();
  }

}

//todo theme changer (dark/white)
//todo account menager
