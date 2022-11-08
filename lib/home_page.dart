import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_mqtt/data_provider.dart';
import 'package:phone_mqtt/provider_ui.dart';
import 'mqtt_connect.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

final Completer<GoogleMapController> _controller = Completer();
String google_api_key = "AIzaSyDA60M1bFZGiO_tFqTfiQUbrvCIyZ5u3NI";
bool provider = false;

class _HomePageState extends State<HomePage> {
  MqttConnect mqttConnect = MqttConnect();
  DataProvider dataProvider = DataProvider();

  final String pubTopic = "test";
  String _getMessange = '';
  ProviderUI providerUI = ProviderUI();
  double latitude = 0.0;
  double longitude = 0.0;
  int currentPageIndex = 0;

  @override
  void initState() {

    setupMqttClient();
    setupUpdatesListener();
    _getNewMessange();
    super.initState();
  }

  void _sendMessage() => setState(() {

    mqttConnect.publishMessage(pubTopic, '$latitude,$longitude');
  });



  void _subscribeMessange() => setState(() {
        mqttConnect.subscribe(pubTopic);
      });






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Udostępnianie lokalizacji'),
      ),
      body: Column(
        children: <Widget>[


        ],
      ),
    );
  }

  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
    mqttConnect.subscribe(pubTopic);
  }

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

  void setupUpdatesListener() {
    mqttConnect
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
    });
  }

@override
void dispose() {
  mqttConnect.disconnect();
  super.dispose();
}
}
