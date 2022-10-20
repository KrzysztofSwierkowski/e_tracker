import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'MqttConnect.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MqttConnect mqttConnect = MqttConnect();
  final String pubTopic = "test/counter";

  void initState() {
    setupMqttClient();
    setupUpdatesListener();
    super.initState();
  }

  void _sendMessage() => setState(() {
    mqttConnect.publishMessage(
        pubTopic, "Welcome, that's a test message!");
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mqtt Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'TXT: Home',
            ),
            Text(
              'Liczba',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            ElevatedButton(
              onPressed: () {_sendMessage();},
              child: const Text('Send topic'),
            ),
          ],
        ),
      ),
    ); // przyjemniejsze.
  }

  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
    mqttConnect.subscribe(pubTopic);
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
