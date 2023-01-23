import 'package:flutter/material.dart';
import 'mqtt_connect.dart';
import 'gpsHandle/gps_device_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  GpsDeviceController gpsDeviceController = GpsDeviceController();
  MqttConnect mqttConnect = MqttConnect();



  @override
  void initState() {
    gpsDeviceController.getDeviceIDList();
    gpsDeviceController.getCurrentDeviceNameKey();
    setupMqttClient();
    mqttConnect.client.connectionStatus!.state.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1F22),
        //image: DecorationImage(
        //  image: AssetImage("assets/HomeBackground.png"), fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black26,
                      width: 5.0,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    color: const Color(0xFF3A3A3A),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(10, 25, 10, 25),
                    child: Text(
                      "E-Tracker",
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
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black26,
                    width: 5.0,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  color: const Color(0xFF3A3A3A),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                    Text("Połączenie z serwerem MQTT",
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Color(0xffffffff),
                          fontSize: 20
                        )),

                      Container(
                        child: mqttConnect.client.connectionStatus!.state.name ==
                                "connected"
                            ? //check if loading is true or false
                            const Icon(
                                Icons.sensors_outlined,
                                color: Colors.green,
                                size: 30.0,
                                semanticLabel: 'Połączono z MQTT',
                              )
                            : //show progress on loading = true
                            const Icon(
                                Icons.sensors_off_outlined,
                                color: Colors.red,
                                size: 30.0,
                                semanticLabel: 'Brak połączenia z MQTT',
                              ), //show this text on loading = false
                      ),

                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(45.0),
                    child: const Image(
                      image: AssetImage('assets/icon.png'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
    setState(() {

    });
  }

  @override
  void dispose() {
    mqttConnect.disconnect();
    super.dispose();
  }

}
//todo create userfriendly UI
