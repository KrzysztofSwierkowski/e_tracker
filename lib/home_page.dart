import 'package:flutter/material.dart';

import 'gpsHandle/gps_device_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GpsDeviceController gpsDeviceController = GpsDeviceController();

  @override
  void initState() {
    gpsDeviceController.getDeviceIDList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/HomeBackground.png"), fit: BoxFit.cover),

      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 25, 0, 250),
                child: Center(
                  child: Text(
                    "LOKALIZACJA URZĄDZENIA",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      shadows: <Shadow>[
                        Shadow(
                          //offset: Offset(3.0, 10.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        Shadow(
                          // offset: Offset(3.0, 10.0),
                          blurRadius: 8.0,
                          color: Color.fromARGB(125, 0, 0, 255),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45.0),
                  child: const Image(
                    image: AssetImage('assets/icon.png'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//todo create userfriendly UI
