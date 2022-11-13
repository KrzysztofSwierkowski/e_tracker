import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_connect.dart';


class Provider extends StatefulWidget {
  const Provider({super.key});

  @override
  _ProviderState createState() => _ProviderState();
}

class _ProviderState extends State<Provider> {

  MqttConnect mqttConnect = MqttConnect();
  final String pubTopic = "test";
  String getMessange = '';
  double a = 0.0;
  double b = 0.0;

  LocationData? currentLocation;

  void getCurrentLocation() async {
    Location location = Location();
    location.enableBackgroundMode(enable: true);
    location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 5000, distanceFilter: 5);
    location.getLocation().then(
          (location) {
        currentLocation = location;
      },
    );

   // GoogleMapController googleMapController = await _controller.future;
    Completer<GoogleMapController> _controllerMap = Completer();

    location.onLocationChanged.listen(
          (newLoc) {
        currentLocation = newLoc;
        // googleMapController.animateCamera(
        //   CameraUpdate.newCameraPosition(
        //     CameraPosition(
        //       bearing: 0,
        //       target: LatLng(
        //         a = newLoc.latitude!,
        //         b = newLoc.longitude!,
        //       ),
        //       zoom: 18,
        //     ),
        //   ),
        // );
        currentLocation!.longitude;
        setState(() {
          sendMessage();
        });

      },


    );
  }

  @override
  void initState() {
    setupMqttClient();
    setupUpdatesListener();
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }



  void sendMessage() {
    if (mqttConnect.client.connectionStatus!.state == MqttConnectionState.connected) {
      mqttConnect.publishMessage(pubTopic, "$currentLocation");
    }else{
      setupMqttClient();
    }

  }

  void subscribeMessange() {

    mqttConnect.subscribe(pubTopic);
  }



  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
    mqttConnect.subscribe(pubTopic);
  }

  void getNewMessange() {
    mqttConnect
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      late final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      getMessange = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    });
  }

  void setupUpdatesListener() {
    mqttConnect
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
    });
  }

@override
void dispose() {
//  mqttConnect.disconnect();
  super.dispose();
}


}
