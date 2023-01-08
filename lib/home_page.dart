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
    gpsDeviceController.getCurrentDeviceNameKey();
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
                padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
                child: Container(
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
                      "LOKALIZACJA URZĄDZENIA",
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
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black26,
                    width: 5.0,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  color: const Color(0xFF3A3A3A),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
                  child: Text(
                      "Aplikacja przy pomocy której można lokalizować urządzenia GPS przy pomocy map google.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xffffffff),
                      )),
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
