import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_mqtt/constans.dart' as Constans;
import 'package:phone_mqtt/provider.dart';
import 'gpsHandle/gps_devices_list.dart';
import 'mqtt_connect.dart';
import 'package:phone_mqtt/gpsHandle/gps_devices_list.dart' as GpsHandle;

class ClientUi extends StatefulWidget {
  const ClientUi({Key? key}) : super(key: key);

  @override
  _ClientUiState createState() => _ClientUiState();
}

final Completer<GoogleMapController> _controller = Completer();

String google_api_key = Constans.google_api_key;

class _ClientUiState extends State<ClientUi>
    with AutomaticKeepAliveClientMixin {
  //create a new instance of the used class
  MqttConnect mqttConnect = MqttConnect();
  Provider provider = Provider();



  //init a variable

  String _getMessange = '';
  String _reciveTopic = '';
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  @override
  void initState() {
    setupMqttClient();
    _getNewMessange();
    getNewMarkerLocation(_getMessange);
   // getCurrentLocation(_getMessange);
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
   // getCurrentLocation(_getMessange);
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/inapp.png"), fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: Column(
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
                markers: Set<Marker>.of(Constans.markers.values),
                // markers: currentLocation == null
                //     ? Set()
                //     : {
                //         Marker(
                //             markerId: const MarkerId("1"),
                //             position: LatLng(currentLocation!.latitude!,
                //                 currentLocation!.longitude!)),
                //
                //
                //       },
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 25),
                    child:
                        // currentLocation == null
                        //     ? const CircularProgressIndicator()
                        //     :
                        Column(children: [
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
                      ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GpsDevicesList()),
                            );
                          },
                          child: const Text('Pokaż liste urządzeń')),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // connect to the mqttserver
  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
    for (var i=0; i < Constans.topicList.length; i++) {
      mqttConnect.subscribe(Constans.topicList[i]);
    }
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
        _reciveTopic = c[0].topic;
        _getMessange = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      });
    });
  }

  void _cancelPositioning() => {mqttConnect.disconnect()};

  void _reconnect() => {setupMqttClient(), _getNewMessange()};




  void getNewMarkerLocation(String getMessange) async {
    if (getMessange.isNotEmpty) {
      Map<String, dynamic> jsonInput = jsonDecode(getMessange);
      LocationData newLocation = LocationData.fromMap({
        'latitude': jsonInput['latitude'],
        'longitude': jsonInput['longitude'],
      });

      // Example input for device: mqttConnect.publishMessage(topicLongLat,
//           '{\"latitude\":${currentLocation!.latitude.toString()},\"longitude\":${currentLocation!.longitude.toString()},\"idGPS\":${idGPS.toString()}}');
      Map<String, dynamic> jsonInput2 = jsonDecode(getMessange);
      final String markerIdVal = jsonInput2['idGPS'];
      final MarkerId markerId = MarkerId(markerIdVal);
      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(newLocation.latitude!, newLocation.longitude!),
        infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      );

      setState(() {
        Constans.markers[markerId] = marker;
      });
      // todo add Map topic and location
      //todo null exeption handling


    }
  }




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
