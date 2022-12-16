
import 'package:firebase_auth/firebase_auth.dart';

String idGPS = "";
String topic = FirebaseAuth.instance.currentUser!.uid;
String topicSpeed = "gpsDevice/GPS001/speed";
String topicAltitude = "gpsDevice/GPS001/altitude";
String topicLongLat = "gpsDevice/GPS001/longLat";
String topicInit = "gpsDevice/GPS001/state";
String topicIP = "gpsDevice/GPS001/ip";

String ipBroker = "178.43.129.129"; //broker ip address
List<String> deviceIDList = [];
