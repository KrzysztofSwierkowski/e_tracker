import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_mqtt/provider_ui.dart';

import 'MqttConnect.dart';
import 'client_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

final Completer<GoogleMapController> _controller = Completer();
String google_api_key = "AIzaSyDA60M1bFZGiO_tFqTfiQUbrvCIyZ5u3NI";
bool provider = false;

class _HomePageState extends State<HomePage> {
  MqttConnect mqttConnect = MqttConnect();
  final String pubTopic = "test";
  String _getMessange = '';
  ProviderUI providerUI = ProviderUI();
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    getCurrentLocation();
    setupMqttClient();
    setupUpdatesListener();
    _getNewMessange();
    super.initState();
  }

  List<LatLng> polylineCoordinates = [];

  LocationData? currentLocation;

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );
    location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 10000, distanceFilter: 5);
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;

        latitude = newLoc.latitude!;
        longitude = newLoc.longitude!;

        onChanged: (currentLocation) {
          setState(() {
            _sendMessage();
          });

        };

        setState(() {
          // _sendMessage();
        });
      },
    );
  }

  static final LatLng _kMapCenter =
      LatLng(50.90360846121795, 15.720444222654319);

  // static final CameraPosition _kInitialPosition =
  //     CameraPosition(target: _kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);

  void _sendMessage() => setState(() {
        getCurrentLocation();
        mqttConnect.publishMessage(pubTopic, '$latitude,$longitude');
      });

  void _subscribeMessange() => setState(() {
        mqttConnect.subscribe(pubTopic);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mqtt Home'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(children: <Widget>[
                      Checkbox(
                        checkColor: Colors.redAccent,
                        value: provider,
                        onChanged: (bool? value) {
                          for (int i = 0; i < 50; i++) {
                            print('test $i');
                          }

                          //_sendMessage();
                          setState(() {
                            _sendMessage();
                            provider = value!;
                          });
                        },
                      ),
                      SelectionContainer.disabled(
                          child: Text('GPS provider $_getMessange')),
                    ]),
                    Text(providerUI.getMessange),
                    ElevatedButton(
                      onPressed: () {
                        getCurrentLocation();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ClientUi()),
                        );
                      },
                      child: const Text('ClientApp'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
    mqttConnect.subscribe(pubTopic);
  }

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
    mqttConnect.disconnect();
    super.dispose();
  }
}
