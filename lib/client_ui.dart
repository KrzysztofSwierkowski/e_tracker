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

class _ClientUiState extends State<ClientUi>
    with AutomaticKeepAliveClientMixin {
  MqttConnect mqttConnect = MqttConnect();


  final String pubTopic = "test";
  String _getMessange = '';
  double a = 0.0;
  double b = 0.0;

  // 15.720458902487849

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
    location.enableBackgroundMode(enable: true);
    location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 5000, distanceFilter: 5);
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );
    GoogleMapController googleMapController = await _controller.future;
    Completer<GoogleMapController> _controllerMap = Completer();

    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target: LatLng(
                a = newLoc.latitude!,
                b = newLoc.longitude!,
              ),
              zoom: 18,
            ),
          ),
        );
        setState(() {
        });
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
    super.build(context);
    return Scaffold(
    body:

    GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: LatLng(50.9227, 15.7674),
          zoom: 18,
        ),
        myLocationEnabled: true,
        trafficEnabled: true,
      markers: currentLocation == null ? Set() : [
        Marker(
            markerId: MarkerId("1"),
            position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!)
        )
      ].toSet(),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
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
    // mqttConnect.disconnect();
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
