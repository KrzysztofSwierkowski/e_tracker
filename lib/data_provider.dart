import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_mqtt/user_location.dart';

import 'mqtt_connect.dart';

class DataProvider {
  late UserLocation userLocation;
  MqttConnect mqttConnect = MqttConnect();
  String pubTopic = 'test';

  void locationupdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude
          .toString()}');
    });
  }

  void getLocation() async {
    setupMqttClient();
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
    );
    StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
if (mqttConnect.client.connectionStatus!.state == MqttConnectionState.connected) {
  mqttConnect.publishMessage(
      pubTopic,
      position == null
          ? '0,0'
          : '${position.latitude.toString()},${position.longitude
          .toString()}');
} else {
  setupMqttClient();
}
    });

  }

  void getLocationJson() async {
    setupMqttClient();
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
    );
    StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (mqttConnect.client.connectionStatus!.state == MqttConnectionState.connected) {
        mqttConnect.publishMessage(
            pubTopic,
            position == null
                ? '0,0'
                : '{\"latitude\":${position.latitude.toString()},\"longitude\":${position.longitude
                .toString()}}');
      } else {
        setupMqttClient();
      }
    });

  }

  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
    mqttConnect.subscribe(pubTopic);
  }
}
