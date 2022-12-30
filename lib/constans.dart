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

//Lists

String ipBroker = "178.43.120.9"; //broker ip address
List<String> deviceIDList = [];
List<String> topicList = [];
Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
String google_api_key = "AIzaSyDA60M1bFZGiO_tFqTfiQUbrvCIyZ5u3NI";

//Styles:

final ButtonStyle yellowButtonStyle =
    ElevatedButton.styleFrom(backgroundColor: const Color(0xffFFF800));

const TextStyle blackTextStyleForYellowButton =
    TextStyle(color: Color(0xff000000));
const TextStyle whiteTextStyle =
TextStyle(color: Color(0xffFFFFFF));

const TextStyle whiteHintTextStyle15px =
TextStyle(fontSize: 15.0, color: Color(0xffFFFFFF));