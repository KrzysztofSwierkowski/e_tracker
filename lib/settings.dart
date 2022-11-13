// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:phone_mqtt/data_provider.dart';
// import 'package:phone_mqtt/user_location.dart';
// import 'package:provider/provider.dart';
//
// import 'mqtt_connect.dart';
//
// class Settings extends StatefulWidget {
//   const Settings({super.key});
//
//   @override
//   _SettingsState createState() => _SettingsState();
// }
//
//
//
// class _SettingsState extends State<Settings> {
//
//
//
//
//
//   DataProvider dataProvider = DataProvider();
//   MqttConnect mqttConnect = MqttConnect();
//   UserLocation _userLocation = UserLocation(0,0);
//   final String pubTopic = "test";
//   String _getMessange = '';
//
//   initState() {
//     setupMqttClient();
//     setupUpdatesListener();
//     _getNewMessange();
//     dataProvider.currentLoc();
//     dataProvider.getLocation();
// //  dataProvider.getNewMessange();
//     //dataProvider.getLocationJson();
//    dataProvider.currentLoc();
//
//    super.initState();
//   }
//
//   pos()async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     UserLocation _currentLocation = UserLocation(
//         position.latitude, position.longitude);
//
//
//   }
//
//   UserLocation get userLocation => _userLocation;
//
//   @override
//   Widget build(BuildContext context) {
//     var userLocation = Provider.of<UserLocation>(context);
//     return Scaffold(
//       appBar: AppBar(),
//       body: Column(children: [
//         Container(
//           child: Text('Wiadomość: $_getMessange,${_userLocation.longitude}'),
//         ),
//
//         Container(
//           child: ElevatedButton(onPressed: _sendMessage, child: Text('Wiadomość')),
//
//         ),
//         Container(child: Text('Location: Lat${userLocation.latitude}, Long: ${userLocation.longitude}'),)
//       ]),
//     );
//   }
//
//   void _sendMessage() => setState(() {
//
//     mqttConnect.publishMessage(pubTopic, 'Messange from MQTT');
//   });
//
//   Future<void> setupMqttClient() async {
//     await mqttConnect.connect();
//     mqttConnect.subscribe(pubTopic);
//   }
//
//   void _getNewMessange() {
//     mqttConnect
//         .getMessagesStream()!
//         .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//       final recMess = c![0].payload as MqttPublishMessage;
//       late final pt =
//           MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
//       print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
//       setState(() {
//         _getMessange =
//             MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
//       });
//     });
//   }
//
//   void setupUpdatesListener() {
//     mqttConnect
//         .getMessagesStream()!
//         .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//       final recMess = c![0].payload as MqttPublishMessage;
//       final pt =
//           MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
//       print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
//     });
//   }
//
//   @override
//   void dispose() {
//     mqttConnect.disconnect();
//     super.dispose();
//   }
// }
