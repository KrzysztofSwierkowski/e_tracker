import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phone_mqtt/constans.dart' as Constans;
import '../constans.dart';
import '../mqtt_connect.dart';
import 'gps_device_controller.dart';
import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_mqtt/provider.dart';


class GpsDevicesList extends StatefulWidget {
  const GpsDevicesList({super.key});

  @override
  _GpsDevicesListState createState() => _GpsDevicesListState();
}

class _GpsDevicesListState extends State<GpsDevicesList> {
  List<String> items = Constans.deviceIDList;
  GpsDeviceController gpsDeviceController = GpsDeviceController();

  //create a new instance of the used class
  MqttConnect mqttConnect = MqttConnect();
  Provider provider = const Provider();


  //init a variable

  String _getMessange = '';
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;


  @override
  void initState() {
    setupMqttClient();
    _getNewMessange();
    getNewMarkerLocation(_getMessange);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    getNewMarkerLocation(_getMessange);
    return Material(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.fromLTRB(0, 35, 0, 0)),
            const Text("Lista zapisanych Id urządzeń:"),
            const Text("Przesuń w lewo by usunąć"),
            const Padding(padding: EdgeInsets.fromLTRB(0, 35, 0, 0)),
            Container(
              child: items.isNotEmpty
                  ? ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    onDismissed: (DismissDirection direction) {
                      gpsDeviceController.saveDeviceIDList();
                      setState(() {
                        _remove(items[index]);
                        items.removeAt(index);
                      });
                    },
                    secondaryBackground: Container(
                      color: Colors.red,
                      child: const Center(
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    background: Container(),
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    child: ListTile(
                      leading: const Icon(Icons.list),
                      title: Text(items[index]),
                      subtitle: Row(children: <Widget>[
                        OutlinedButton(
                            child: Text('Dodaj do mapy'),
                            onPressed: () {
                              _add(index, items[index]);
                            }),
                        OutlinedButton(
                            child: Text('Usuń z mapy'),
                            onPressed: () {
                              _remove(items[index]);
                            }),
                      ]),
                    ),
                  );
                },
              )
                  : const Center(child: Text('Brak urządzeń')),
            ),
          ],
        ),
      ),
    );
  }

  MarkerId? selectedMarker;

  LatLng? markerPosition;
  
  String userPositionMarkerId = Constans.topic;
  
  void _addPhone(){
    if (!Constans.deviceIDList.contains(Constans.topic)) {
      _add(items.length, Constans.topic);
    }
  }

  void _add(int _markerIdCounter, String idMarkerValue) {
    final int markerCount = items.length;

    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = idMarkerValue;
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    String topicLongLat = "gpsDevice/$idMarkerValue/longLat";
    Constans.topicList.add(topicLongLat);
    mqttConnect.subscribe(topicLongLat);
    gpsDeviceController.saveDeviceIDList();
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(50.9227, 15.7674),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
    );

    setState(() {
      markers[markerId] = marker;
    });
    // todo add Map topic and location
  }

  void _remove(markerId) {
    setState(() {
      if (markers.containsKey(markerId)) {
        markers.remove(markerId);
      }
    });
  }


  // ----------------------------------------------------------------
  // connect to the mqttserver
  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
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


// new location data for the markers:

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
        markers[markerId] = marker;
      });
      // todo add Map topic and location
      //todo null exeption handling


    }
  }
}