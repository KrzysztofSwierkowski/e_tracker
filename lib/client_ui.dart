import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_mqtt/provider.dart';

import 'mqtt_connect.dart';

class ClientUi extends StatefulWidget {
  const ClientUi({Key? key}) : super(key: key);

  @override
  _ClientUiState createState() => _ClientUiState();
}

final Completer<GoogleMapController> _controller = Completer();

String google_api_key = "AIzaSyDA60M1bFZGiO_tFqTfiQUbrvCIyZ5u3NI";

class _ClientUiState extends State<ClientUi>
    with AutomaticKeepAliveClientMixin {
  //create a new instance of the used class
  MqttConnect mqttConnect = MqttConnect();
  Provider provider = Provider();

  //init a variable
  final String pubTopic =
      "test"; //todo make variable topic name associated with user
  String _getMessange = '';
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  @override
  void initState() {
    setupMqttClient();
    _getNewMessange();
    getCurrentLocation(_getMessange);
    super.initState();
  }

// method that converts the received data to the LocationData object,
// and then updates the currentLocation variable. Next to the method
// send new camera and marker position by googleMapController
  void getCurrentLocation(String newLocationData) async {
    if (_getMessange.isNotEmpty) {
      Map<String, dynamic> jsonInput = jsonDecode(_getMessange);
      LocationData newLocation = LocationData.fromMap({
        'latitude': jsonInput['latitude'],
        'longitude': jsonInput['longitude'],
      });

      GoogleMapController googleMapController = await _controller.future;
      if (currentLocation != newLocation) {
        currentLocation = newLocation;

        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 16.5,
              target: LatLng(
                newLocation.latitude!,
                newLocation.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    getCurrentLocation(_getMessange);
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 500,
            child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: const CameraPosition(
                target: LatLng(50.9227, 15.7674),
                zoom: 18,
              ),
              myLocationEnabled: true,
              trafficEnabled: true,
              markers: currentLocation == null
                  ? Set()
                  : {
                      Marker(
                          markerId: const MarkerId("1"),
                          position: LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!))
                    },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 25, bottom: 25),
              child: currentLocation == null
                  ? const CircularProgressIndicator()
                  : Column(children: [
                      const Center(child: Text("Dane GPS obiektu:")),
                      Center(
                          child:
                              Text("longitude :${currentLocation?.longitude}")),
                      Center(
                          child:
                              Text("latitude : ${currentLocation?.latitude}")),
                      ElevatedButton(
                          onPressed: _cancelPositioning,
                          child: const Text("Zakończ śledzenie")),
                      ElevatedButton(
                          onPressed: _reconnect,
                          child: const Text("Ponów śledzenie")),
                    ]),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // connect to the mqttserver
  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
    mqttConnect.subscribe(pubTopic);
  }

  // get mqtt stream messange
  void _getNewMessange() {
    mqttConnect
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      late final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      setState(() {
        _getMessange =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      });
    });
  }

  void _cancelPositioning() => {mqttConnect.disconnect()};

  void _reconnect() => {setupMqttClient(), _getNewMessange()};

  //Ends Connection
  @override
  void dispose() {
    mqttConnect.disconnect();
    super.dispose();
  }

  // allows it to run in the background
  @override
// TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

//todo create a class with constant values
