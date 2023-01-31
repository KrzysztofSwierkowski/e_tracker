import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_mqtt/constans.dart' as Constans;
import 'package:phone_mqtt/database/testdb.dart';
import 'package:phone_mqtt/provider.dart';

import 'constans.dart';
import 'gpsHandle/device_information.dart';
import 'gpsHandle/gps_devices_list.dart';
import 'mqtt_connect.dart';

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
  GpsDevicesList gpsDevicesList = GpsDevicesList();
  TestDB testDB = TestDB();

  //init a variable

  String _getMessange = '';

  //String _reciveTopic = '';
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  @override
  void initState() {
    setupMqttClient();
    getLastKnownMarkerlocation();
    _getNewMessange();
    getNewMarkerLocation(_getMessange);
    // getCurrentLocation(_getMessange);
    setState(() {});
    super.initState();
  }

// method that converts the received data to the LocationData object,
// and then updates the currentLocation variable. Next to the method
// send new camera and marker position by googleMapController
  void getViewOnSelectedMarker(String newLocationData) async {
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
    getNewMarkerLocation(_getMessange);
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1F22),
        //image: DecorationImage(
        //  image: AssetImage("assets/HomeBackground.png"), fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 500,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black26,
                    width: 5.0,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  color: const Color(0xFF3A3A3A),
                ),
                child: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(50.328724908216365, 18.607050171081905),
                    zoom: 18,
                  ),
                  myLocationEnabled: true,
                  trafficEnabled: true,
                  markers: Set<Marker>.of(Constans.markers.values),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    setState(() {});
                  },
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 25),
                    child:
                        // currentLocation == null
                        //     ? const CircularProgressIndicator()
                        //     :
                        Column(children: [
                      // const Center(child: Text("Dane GPS obiektu:")),
                      // Center(
                      //     child:
                      //         Text("longitude :${currentLocation?.longitude}")),
                      // Center(
                      //     child:
                      //         Text("latitude : ${currentLocation?.latitude}")),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black26,
                                width: 5.0,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              color: const Color(0xFF3A3A3A),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(Icons.share_location_outlined,
                                        color: Colors.green, size: 42),
                                    onPressed: _reconnect,
                                  ),
                                  Text("Ponów śledzenie",
                                      style: whiteHintTextStyle15px),
                                ]),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black26,
                                width: 5.0,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              color: const Color(0xFF3A3A3A),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(Icons.gps_off_outlined,
                                      color: Colors.red, size: 42),
                                  onPressed: _cancelPositioning,
                                ),
                                Text("Zakończ śledzenie",
                                    textAlign: TextAlign.justify,
                                    style: whiteHintTextStyle15px),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                        child: Text(
                          "Lista urządzeń:",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xffffffff),
                            shadows: <Shadow>[
                              Shadow(
                                //offset: Offset(3.0, 10.0),
                                blurRadius: 15.0,
                                color: Color.fromARGB(255, 255, 248, 0),
                              ),
                              Shadow(
                                // offset: Offset(3.0, 10.0),
                                blurRadius: 8.0,
                                color: Color.fromARGB(125, 255, 248, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: Constans.deviceIDList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.85,
                                        //height: 60,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black26,
                                            width: 5.0,
                                          ),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(25),
                                              bottomLeft: Radius.circular(25)),
                                          color: const Color(0xFF3A3A3A),
                                        ),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton(
                                                child: Text(
                                                  "ID GPS: \"${Constans.deviceIDList[index]}\"",
                                                  style: whiteHintTextStyle15px,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DeviceInformation(
                                                                deviceId: Constans
                                                                        .deviceIDList[
                                                                    index])),
                                                  );
                                                  _animateMapCameraToMarker(
                                                      MarkerId(
                                                          Constans.deviceIDList[
                                                              index]));
                                                  setState(() {});
                                                },
                                              ),
                                            ])),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      //height: 60,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black26,
                                          width: 5.0,
                                        ),
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(25),
                                            bottomRight: Radius.circular(25)),
                                        color: const Color(0xFF3A3A3A),
                                      ),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.place,
                                                  color: Colors.red, size: 35),
                                              tooltip: 'Pokaż na mapie',
                                              onPressed: () {
                                                setState(() {
                                                  GpsDevicesListState()
                                                      .addMarkerToMap(Constans
                                                          .deviceIDList[index]);
                                                  _animateMapCameraToMarker(
                                                      MarkerId(
                                                          Constans.deviceIDList[
                                                              index]));
                                                  print(Constans
                                                      .deviceIDList[index]);
                                                });
                                              },
                                            ),
                                          ]),
                                    ),
                                  ]),
                            ]);
                          }),
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
    for (var i = 0; i < Constans.topicList.length; i++) {
      mqttConnect.subscribe(Constans.topic);
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
        if (c[0].topic == Constans.topic) {
          Constans.deviceIDList.add(MqttPublishPayload.bytesToStringAsString(
              recMess.payload.message));
          Constans.topicList.add(MqttPublishPayload.bytesToStringAsString(
              recMess.payload.message));
          mqttConnect.subscribe(MqttPublishPayload.bytesToStringAsString(
              recMess.payload.message));
        } else {
          //_reciveTopic = c[0].topic;
          _getMessange =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        }
      });
    });
  }

  void _cancelPositioning() => {mqttConnect.disconnect()};

  void _reconnect() => {setupMqttClient(), _getNewMessange()};

  void getLastKnownMarkerlocation() async {
    for (int i = 0; i < Constans.deviceIDList.length; i++) {
      testDB.getLastKnownLocalization(Constans.deviceIDList[i]);
      LocationData newLocation = LocationData.fromMap({
        'latitude': Constans.lastKnownLocation['latitude'],
        'longitude': Constans.lastKnownLocation['longitude'],
      });
      print(
          "Position ======== latitude: ${newLocation.latitude} ========longitude:  ${newLocation.longitude}================ID:  ${Constans.deviceIDList[i]}");

      final MarkerId markerId = MarkerId(Constans.deviceIDList[i]);
      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(newLocation.latitude!, newLocation.longitude!),
        infoWindow: InfoWindow(title: Constans.deviceIDList[i], snippet: '*'),
      );

      setState(() {
        Constans.markers[markerId] = marker;
      });



    }
  }

  void getNewMarkerLocation(String getMessange) async {
    if (getMessange.isNotEmpty) {
      Map<String, dynamic> jsonInput = jsonDecode(getMessange);
      LocationData newLocation = LocationData.fromMap({
        'latitude': jsonInput['latitude'],
        'longitude': jsonInput['longitude'],
      });
      Map<String, dynamic> jsonInput2 = jsonDecode(getMessange);
      final String markerIdVal = jsonInput2['idGPS'];
      testDB.saveData(
          newLocation.latitude!, newLocation.longitude!, markerIdVal);
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

  Future<void> _unSubscribeAllTopics() async {
    for (var i = 0; i < Constans.topicList.length; i++) {
      mqttConnect.client.unsubscribe(Constans.topicList[i]);
    }
  }

  Future<void> _animateMapCameraToMarker(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final LatLng currentPosition = marker.position;
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(CameraUpdate.newLatLng(currentPosition));
  }

  //Ends Connection
  @override
  void dispose() {
    super.dispose();
    mqttConnect.disconnect();
    _unSubscribeAllTopics();
    // super.dispose();
  }

  // allows it to run in the background
  @override
// TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

//todo create a class with constant values
