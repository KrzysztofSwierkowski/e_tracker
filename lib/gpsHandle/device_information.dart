import 'package:flutter/material.dart';
import 'package:phone_mqtt/constans.dart' as constans;

class DeviceInformation extends StatefulWidget {
  const DeviceInformation({super.key});



  @override
  _DeviceInformationState createState() => _DeviceInformationState();
}

class _DeviceInformationState extends State<DeviceInformation> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("${constans.deviceIDList}")
      
      
      ]);
  }
}
