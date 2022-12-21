import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_mqtt/constans.dart' as Constans;

import 'mqtt_connect.dart';

class Provider extends StatefulWidget {
  const Provider({super.key});

  @override
  _ProviderState createState() => _ProviderState();
}

class _ProviderState extends State<Provider> {
  //constructors
  MqttConnect mqttConnect = MqttConnect();

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
        image: DecorationImage(
            image: AssetImage("assets/inapp.png"), fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: Column(children: <Widget>[
          Container(
            child: currentLocation == null
                ? const CircularProgressIndicator()
                : Column(children: [
                    const Center(child: Text("Dane GPS objektu:")),
                    Center(
                        child:
                            Text("longitude :${currentLocation?.longitude}")),
                    Center(
                        child: Text("latitude : ${currentLocation?.latitude}"))
                  ]),
          ),
          TextField(
            controller: getDeviceNameController,
            decoration: InputDecoration(
              hintText: 'Wpisz nazwę swojego urządzenia',
              suffixIcon: IconButton(
                onPressed: getDeviceNameController.clear,
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
            child: OutlinedButton(
                child: const Text('Udostępnij lokalizację'),
                onPressed: () {
                  _sendDeviceNameMessage();
                  _addDeviceToTopicAndDevicesLists();
                }),
          ),
        ]),
      ),
    );
  }

  void sendLocalizationMessage() {
    if (mqttConnect.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      mqttConnect.publishMessage(getDeviceNameController.text,
          '{\"latitude\":${currentLocation!.latitude.toString()},\"longitude\":${currentLocation!.longitude.toString()},"idGPS": \"${getDeviceNameController.text}\"}');
    } else {
      setupMqttClient();
    }
  }

  void _sendDeviceNameMessage() {
    if (mqttConnect.client.connectionStatus!.state ==
        MqttConnectionState.connected) {
      mqttConnect.publishMessage(Constans.topic,
          getDeviceNameController.text);
    } else {
      setupMqttClient();
    }
  }

  void subscribeMessange() {
    mqttConnect.subscribe(Constans.topic);
  }

  Future<void> _addDeviceToTopicAndDevicesLists() async {
     Constans.topicList.add(getDeviceNameController.text);
    Constans.deviceIDList.add(getDeviceNameController.text);
  }

  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
    mqttConnect.subscribe(Constans.topic);
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

//todo: implement wantKeepAlive
//todo: implement constants variable class
//todo: implement logging system
