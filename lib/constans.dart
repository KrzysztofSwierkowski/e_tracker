
import 'package:firebase_auth/firebase_auth.dart';

String topic = FirebaseAuth.instance.currentUser!.uid;
String ipBroker = "178.43.231.218"; //broker ip address
List<String> deviceIDList = [];
