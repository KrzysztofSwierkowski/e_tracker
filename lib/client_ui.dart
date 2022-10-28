import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'MqttConnect.dart';

class ClientUi extends StatefulWidget {
  const ClientUi({Key? key}) : super(key: key);

  @override
  _ClientUiState createState() => _ClientUiState();
}

final Completer<GoogleMapController> _controller = Completer();

String google_api_key = "AIzaSyDA60M1bFZGiO_tFqTfiQUbrvCIyZ5u3NI";

class _ClientUiState extends State<ClientUi> {
  MqttConnect mqttConnect = MqttConnect();
  final String pubTopic = "test";
  String _getMessange = '';
  double a = 0.0;
  double b = 0.0;

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
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen(
          (newLoc) {
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 17,
              target: LatLng(
                a = newLoc.latitude!,
                b = newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      },
    );
  }



  void _sendMessage() => setState(() {
    mqttConnect.publishMessage(pubTopic, "att: $a latt: $b");
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
                    Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Stack(
                        children: [
                          currentLocation == null
                              ? const Center(child: Text("Loading"))
                              : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(currentLocation!.latitude!,
                                  currentLocation!.longitude!),
                            //  zoom: 20,
                            ),
                            markers: {
                              Marker(
                                markerId:
                                const MarkerId("currentLocation"),
                                position: LatLng(
                                    currentLocation!.latitude!,
                                    currentLocation!.longitude!),
                              ),

                            },
                            onMapCreated: (mapController) {
                              _controller.complete(mapController);
                            },
                            polylines: {
                              Polyline(
                                polylineId: const PolylineId("route"),
                                points: polylineCoordinates,
                                color: const Color(0xFF7B61FF),
                                width: 6,
                              ),
                            },
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Below are the test buttons for the Mqtt',
                    ),
                    Text(
                      _getMessange,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _sendMessage();
                      },
                      child: const Text('Send topic'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _subscribeMessange();
                      },
                      child: const Text('Subscribe topic'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _getNewMessange();
                      },
                      child: const Text('Get stream'),
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
