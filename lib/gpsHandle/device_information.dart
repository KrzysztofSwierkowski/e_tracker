import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phone_mqtt/client_ui.dart';
import 'package:phone_mqtt/constans.dart' as constans;
import 'package:phone_mqtt/mqtt_connect.dart';

class DeviceInformation extends StatefulWidget {
  DeviceInformation({Key? key, required this.deviceId}) : super(key: key);
  String deviceId;

  @override
  _DeviceInformationState createState() => _DeviceInformationState();
}

class _DeviceInformationState extends State<DeviceInformation> {
  MqttConnect mqttConnect = MqttConnect();

  int BluetoothPowerOn = -1;
  int obdIIPowerOn = -1;
  int GpsPowerOn = -1;
  int accelerometerPowerOn = -1;
  bool IsETracker = false;
  bool GpsETracker = false;
  bool BluetoothETracker = false;
  bool obdIIETracker = false;
  bool accelerometerETracker = false;

  @override
  void initState() {
    setupMqttClient();
    super.initState();
  }

  void subscribeDeviceSetupTopics() {
    mqttConnect.subscribe("gpsDevice/${widget.deviceId}/BluetoothPowerOn");
    mqttConnect.subscribe("gpsDevice/${widget.deviceId}/obdIIPowerOn");
    mqttConnect.subscribe("gpsDevice/${widget.deviceId}/GpsPowerOn");
    mqttConnect.subscribe("gpsDevice/${widget.deviceId}/accelerometerPowerOn");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1F22),
        ),
        child: SafeArea(
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Text("Urządzenie ${widget.deviceId} model \"E-Tracker\"   ",
                  textAlign: TextAlign.left,
                  style:
                      const TextStyle(color: Color(0xffffffff), fontSize: 15)),
              Switch(
                // This bool value toggles the switch.
                value: IsETracker,
                activeColor: Colors.greenAccent,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    IsETracker = value;
                    if (!IsETracker) {
                      GpsETracker = value;
                      BluetoothETracker = value;
                      accelerometerETracker = value;
                      obdIIETracker = value;
                    }
                    print(IsETracker);
                  });
                },
              ),
            ]),
            const Divider(
              color: Color(0xffFFF800),
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Text("GPS",
                  textAlign: TextAlign.left,
                  style:
                      const TextStyle(color: Color(0xffffffff), fontSize: 15)),
              Switch(
                // This bool value toggles the switch.
                value: GpsETracker,
                activeColor: Colors.greenAccent,

                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    GpsETracker = value;
                    if (IsETracker & GpsETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/GpsPowerOn", "1");
                      GpsETracker = value;
                      print(GpsETracker);
                    } else if (!GpsETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/GpsPowerOn", "-1");
                      GpsETracker = value;
                    } else if (!IsETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/GpsPowerOn", "-1");
                      GpsETracker = !value;
                    }
                  });
                },
              ),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              const Text("Wykrycie ruchu/kolizji",
                  textAlign: TextAlign.left,
                  style:
                      TextStyle(color: Color(0xffffffff), fontSize: 15)),
              Switch(
                // This bool value toggles the switch.
                value: accelerometerETracker,
                activeColor: Colors.greenAccent,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    accelerometerETracker = value;
                    if (IsETracker & accelerometerETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/accelerometerPowerOn",
                          "1");
                      accelerometerETracker = value;
                      print(accelerometerETracker);
                    } else if (!accelerometerETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/accelerometerPowerOn",
                          "-1");
                      accelerometerETracker = value;
                    } else if (!IsETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/accelerometerPowerOn",
                          "-1");
                      accelerometerETracker = !value;
                    }
                  });
                },
              ),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              const Text("ELM327 OBDII",
                  textAlign: TextAlign.left,
                  style:
                      TextStyle(color: Color(0xffffffff), fontSize: 15)),
              Switch(
                // This bool value toggles the switch.
                value: obdIIETracker,
                activeColor: Colors.greenAccent,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    obdIIETracker = value;
                    if (IsETracker & obdIIETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/obdIIPowerOn", "1");
                      obdIIETracker = value;
                      print(obdIIETracker);
                    } else if (!obdIIETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/obdIIPowerOn", "-1");
                      obdIIETracker = value;
                    } else if (!IsETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/obdIIPowerOn", "-1");
                      obdIIETracker = !value;
                    }
                  });
                },
              ),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              const Text("Bluetooth",
                  textAlign: TextAlign.left,
                  style:
                      TextStyle(color: Color(0xffffffff), fontSize: 15)),
              Switch(
                // This bool value toggles the switch.
                value: BluetoothETracker,
                activeColor: Colors.greenAccent,
                onChanged: (bool value) {
                  // This is called when the user toggles the switch.
                  setState(() {
                    BluetoothETracker = value;
                    if (IsETracker & BluetoothETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/BluetoothPowerOn", "1");
                      BluetoothETracker = value;
                      if (kDebugMode) {
                        print(BluetoothETracker);
                      }
                    } else if (!BluetoothETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/BluetoothPowerOn",
                          "-1");
                      BluetoothETracker = value;
                    } else if (!IsETracker) {
                      sendValueoOfPowerState(
                          "gpsDevice/${widget.deviceId}/BluetoothPowerOn",
                          "-1");
                      BluetoothETracker = !value;
                    }
                  });
                },
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void sendValueoOfPowerState(topic, messange) {
    mqttConnect.publishMessage(topic, "$messange");
  }

  Future<void> setupMqttClient() async {
    await mqttConnect.connect();
    subscribeDeviceSetupTopics();
  }
}
