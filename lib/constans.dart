import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//Variables

String idGPS = "";
String topic = FirebaseAuth.instance.currentUser!.uid;
// String topicSpeed = "gpsDevice/GPS001/speed";
// String topicAltitude = "gpsDevice/GPS001/altitude";
// String topicLongLat = "gpsDevice/GPS001/longLat";
// String topicInit = "gpsDevice/GPS001/state";
// String topicIP = "gpsDevice/GPS001/ip";
String topicCurrentDeviceName = "Android";

        //Gps variables:
int BluetoothPowerOn = -1;
int obdIIPowerOn = -1;
int GpsPowerOn = -1;
int accelerometerPowerOn = -1;
bool IsETracker = false;
bool GpsETracker = false;
bool BluetoothETracker = false;
bool obdIIETracker = false;
bool accelerometerETracker = false;

//Lists

String ipBroker = "rsttpl.ddns.net"; //broker ip address
List<String> deviceIDList = [];
List<String> topicList = [];
List<String> MarkersOnMap = [];
Map<dynamic, dynamic> lastKnownLocation = {};

Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
String google_api_key = "AIzaSyDA60M1bFZGiO_tFqTfiQUbrvCIyZ5u3NI";

//Styles:

final ButtonStyle yellowButtonStyle =
    ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A3A3A));

const TextStyle blackTextStyleForYellowButton =
    TextStyle(color: Color(0xffffffff));
const TextStyle whiteTextStyle =
TextStyle(color: Color(0xffffffff));

const TextStyle whiteHintTextStyle15px =
TextStyle(fontSize: 15.0, color: Color(0xffffffff));