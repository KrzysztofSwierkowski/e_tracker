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
  MqttConnect mqttConnect = MqttConnect();
  Provider provider = Provider();

  final String pubTopic = "test";
  String _getMessange = '';
  double a = 0.0;
  double b = 0.0;

  @override
  void initState() {
    setupMqttClient();
    setupUpdatesListener();
    _getNewMessange();
    getCurrentLocation(_getMessange);
    super.initState();
  }

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  void getCurrentLocation(String newLocationData) async {
    if (_getMessange.isNotEmpty) {
      Map<String, dynamic> jsonInput = jsonDecode(_getMessange);
      LocationData newLocation = LocationData.fromMap({
        'latitude': jsonInput['latitude'],
        'longitude': jsonInput['longitude'],
      });
//      setState(() {
      //      this.currentLocation = newLocation;
      //  });
      //animateCameraToNewLocation(newLocation);
      print("po obróbce $newLocation");

      // }
      //
      // Future<void> animateCameraToNewLocation(LocationData newLocation) async {
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
        print('Ostatni etap $currentLocation');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    getCurrentLocation(_getMessange);
    return Scaffold(
      body: //SingleChildScrollView(
          //child:
          Column(
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
          Center(child: Text("Dane GPS objektu:")),
          Center(child: Text("longitude :${currentLocation?.longitude}")),
          Center(child: Text("latitude : ${currentLocation?.latitude}"))
        ],
        // ),
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

  @override
// TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

// void getCurrentLocation() async {
//   Location location = Location();
//   location.enableBackgroundMode(enable: true);
//   location.changeSettings(
//       accuracy: LocationAccuracy.high, interval: 5000, distanceFilter: 5);
//   location.getLocation().then(
//         (location) {
//       currentLocation = location;
//     },
//   );
//
//   GoogleMapController googleMapController = await _controller.future;
//   location.onLocationChanged.listen(
//         (newLoc) {
//       currentLocation = newLoc;
//
//       googleMapController.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             zoom: 18.5,
//             target: LatLng(
//               newLoc.latitude!,
//               newLoc.longitude!,
//             ),
//           ),
//         ),
//       );
//       setState(() {});
//     },
//   );
// }
