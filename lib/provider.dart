import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_mqtt/constans.dart' as Constans;
import 'package:phone_mqtt/gpsHandle/gps_device_controller.dart';

import 'constans.dart';
import 'mqtt_connect.dart';

class Provider extends StatefulWidget {
  const Provider({super.key});

  @override
  _ProviderState createState() => _ProviderState();
}

class _ProviderState extends State<Provider> {
  //constructors
  MqttConnect mqttConnect = MqttConnect();
  GpsDeviceController gpsDeviceController = GpsDeviceController();
  //variables
  String getMessange = '';
  LocationData? currentLocation;

  //Controllers:

  TextEditingController getDeviceNameController = TextEditingController();

  // use location plugin to get location and send by the Mqtt
  void getCurrentLocation() async {
    Location location = Location();

    //check location permission (if permission is not granted app crash)
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.enableBackgroundMode(enable: true);
    location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 5000, distanceFilter: 5);
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        currentLocation!.longitude;
        currentLocation!.speed;
        setState(() {
          sendLocalizationMessage();
        });
      },
    );
  }

  @override
  void initState() {

    setupMqttClient();
    getCurrentLocation();
    super.initState();
  }

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
        child: Column(children: <Widget>[
          const Divider(
            color: Color(0xffFFF800),
            height: 20,
          ),
          Container(
            child: currentLocation == null
                ? const CircularProgressIndicator()
                : Column(children: [
                    const Center(
                        child: Text(
                      "Dane GPS:",
                      style: Constans.whiteTextStyle,
                    )),
                    Center(
                        child: Text(
                      "longitude :${currentLocation?.longitude}",
                      style: Constans.whiteTextStyle,
                    )),

                    Center(
                        child: Text(
                      "latitude : ${currentLocation?.latitude}",
                      style: Constans.whiteTextStyle,
                    )),
              Center(
                  child: Text(
                    "Prędkość : ${(currentLocation!.speed! * 3.6).toStringAsFixed(1)} Km/h",
                    style: Constans.whiteTextStyle,
                  )),
              Center(
                  child: Text(
                    "Wysokość : ${(currentLocation!.altitude! * 3.6).toStringAsFixed(1)} mnpm",
                    style: Constans.whiteTextStyle,
                  )),
              Center(
                  child: Text(
                    "dokładność : ${(currentLocation!.accuracy! * 3.6).toStringAsFixed(1)} m",
                    style: Constans.whiteTextStyle,
                  ))
                  ]),
          ),
          const Divider(
            color: Color(0xffFFF800),
            height: 40,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 25),
            child: TextField(
              style: Constans.whiteTextStyle,
              controller: getDeviceNameController,
              decoration: InputDecoration(
                hintText: 'Wpisz nazwę swojego urządzenia',
                hintStyle: Constans.whiteHintTextStyle15px,
                suffixIcon: IconButton(
                  onPressed: getDeviceNameController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 25),
            child: ElevatedButton(
                style: Constans.yellowButtonStyle,
                child: const Text(
                  'Udostępnij lokalizację',
                  style: Constans.blackTextStyleForYellowButton,
                ),
                onPressed: () {
                  Constans.topicCurrentDeviceName =
                      getDeviceNameController.text;
                  gpsDeviceController.saveCurrentDeviceNameKey();
                  _sendDeviceNameMessage();
                  _addDeviceToTopicAndDevicesLists();
                  getDeviceNameController.clear;
                  setState(() {

                  });
                }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 25),
            child: ElevatedButton(
                style: Constans.yellowButtonStyle,
                child: const Text(
                  'Wyślij lokalizację tylko raz',
                  style: Constans.blackTextStyleForYellowButton,
                ),
                onPressed: () {
                  sendLocalizationMessage();
                  setState(() {

                  });
                }),
          ),
          const Text("Obecna nazwa urządzenia to:",style: whiteTextStyle,),
          Text(Constans.topicCurrentDeviceName, style: whiteTextStyle,)
        ]),
      ),
    );
  }

  void sendLocalizationMessage() {
    if (mqttConnect.client.connectionStatus!.state ==
            MqttConnectionState.connected &&
        Constans.topicCurrentDeviceName != null) {
      mqttConnect.publishMessage(Constans.topicCurrentDeviceName,
          '{\"latitude\":${currentLocation!.latitude.toString()},\"longitude\":${currentLocation!.longitude.toString()},"idGPS": \"${getDeviceNameController.text}\"}');
      mqttConnect.publishMessage("gpsDevice/${Constans.topicCurrentDeviceName}/longLat",
          '{\"latitude\":${currentLocation!.latitude.toString()},\"longitude\":${currentLocation!.longitude.toString()},"idGPS": \"${getDeviceNameController.text}\"}');
    } else {
      setupMqttClient();
    }
  }

  void _sendDeviceNameMessage() {
    if (mqttConnect.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      mqttConnect.publishMessage(
          Constans.topic, Constans.topicCurrentDeviceName);
    } else {
      setupMqttClient();
    }
  }

  Future<void> _addDeviceToTopicAndDevicesLists() async {
    Constans.topicList.add(Constans.topicCurrentDeviceName);
    Constans.deviceIDList.add(Constans.topicCurrentDeviceName);
  }

  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
    mqttConnect.subscribe(Constans.topic);
    mqttConnect.subscribe("gpsDevice/${Constans.topicCurrentDeviceName}/longLat");
  }

  void getNewMessange() {
    mqttConnect
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      late final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      getMessange =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    });
  }

  @override
  void dispose() {
    mqttConnect.disconnect();
    super.dispose();
  }
}

//todo repair add another device