// import 'dart:async';
// import 'package:geolocator/geolocator.dart';
// import 'package:phone_mqtt/user_location.dart';
//
// class DataProvider {
//   late UserLocation userLocation;
//   //MqttConnect mqttConnect = MqttConnect();
//   //JsonToLocationConverter jsonToLocationConverter = JsonToLocationConverter();
//
//   String _getMessange = '';
//   final String pubTopic = "test";
//
//
//
//   final StreamController<UserLocation> _locationController =
//       StreamController<UserLocation>();
//
//   Stream<UserLocation> get locationStream => _locationController.stream;
//
//   late UserLocation _currentLocation;
//
//   Future<UserLocation> currentLoc() async {
//   try {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     _currentLocation = UserLocation(
//         position.latitude,position.longitude);
//   } on Exception catch (e) {
//     print("Error");
//   }
//
//   userLocation = UserLocation(_currentLocation.latitude,_currentLocation.longitude);
//   _locationController.add(UserLocation(userLocation.latitude,userLocation.longitude));
// return userLocation;
//
//   }
//
//
//
//   void getLocation() async {
//     //setupMqttClient();
//     const LocationSettings locationSettings = LocationSettings(
//       accuracy: LocationAccuracy.high,
//       distanceFilter: 20,
//     );
//     StreamSubscription<Position> positionStream =
//         Geolocator.getPositionStream(locationSettings: locationSettings)
//             .listen((Position position) {
//       _locationController.sink.add(UserLocation(
//         position.latitude,
//         position.longitude,
//       ));
//       print(position == null
//           ? 'Unknown'
//           : '${position.latitude}, ${position.longitude}');
//     });
//   }
//
// // void locationupdates() {
// //   const LocationSettings locationSettings = LocationSettings(
// //     accuracy: LocationAccuracy.high,
// //     distanceFilter: 10,
// //   );
// //   StreamSubscription<Position> positionStream =
// //       Geolocator.getPositionStream(locationSettings: locationSettings)
// //           .listen((Position? position) {
// //     print(position == null
// //         ? 'Unknown'
// //         : '${position.latitude.toString()}, ${position.longitude.toString()}');
// //   });
// // }
//
// //   void getLocationJson() async {
// //     const LocationSettings locationSettings = LocationSettings(
// //       accuracy: LocationAccuracy.high,
// //       distanceFilter: 5,
// //     );
// //     StreamSubscription<Position> positionStream =
// //         Geolocator.getPositionStream(locationSettings: locationSettings)
// //             .listen((Position? position) {
// //       if (mqttConnect.client.connectionStatus!.state ==
// //           MqttConnectionState.connected) {
// //         mqttConnect.publishMessage(
// //             pubTopic,
// //             position == null
// //                 ? '0,0'
// //                 : '{\"latitude\":${position.latitude.toString()},\"longitude\":${position.longitude.toString()}}');
// //       } else {
// //         setupMqttClient();
// //       }
// //     });
// //   }
// //
// //   getNewMessange() {
// //     mqttConnect
// //         .getMessagesStream()!
// //         .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
// //       final recMess = c![0].payload as MqttPublishMessage;
// //       late final newLocationJson =
// //           MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
// //       print(
// //           'MQTTClient::Message received on topic: <${c[0].topic}> is $newLocationJson\n');
// //       Position? newLocationData = _convertJsonToLocation(newLocationJson);
// //       _getMessange =
// //           MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
// //       print(_getMessange);
// //     });
// //     return null;
// //   }
// //
// //   Position? _convertJsonToLocation(String newLocationJson) {
// //     try {
// //       return jsonToLocationConverter.convert(newLocationJson);
// //     } catch (exception) {
// //       print("Json can't be formatted ${exception.toString()}");
// //     }
// //     return null;
// //   }
// //
// //   Future<void> setupMqttClient() async {
// //     await mqttConnect.connect();
// //     mqttConnect.subscribe(pubTopic);
// //   }
// // }
// //
// // class JsonToLocationConverter {
// //   Position convert(String input) {
// //     Map<String, dynamic> jsonInput = jsonDecode(input);
// //     return Position.fromMap({
// //       'latitude': jsonInput['latitude'],
// //       'longitude': jsonInput['longitude'],
// //     });
// //   }
// }
