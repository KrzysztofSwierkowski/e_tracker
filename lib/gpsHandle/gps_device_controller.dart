
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phone_mqtt/constans.dart' as Constans;

class GpsDeviceController {
  static const String gpsIdDevicesKey = "gpsIdDevices";
  static const String gpsTopicsKey = "gpsTopics";


  void saveDeviceIDList() async {
   // 1
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // 2
  prefs.setStringList(gpsIdDevicesKey, Constans.deviceIDList);
  prefs.setStringList(gpsTopicsKey, Constans.topicList);

}


  void getDeviceIDList() async {
    // 1
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 2
    if (prefs.containsKey(gpsIdDevicesKey)) {
      // 3
      Constans.deviceIDList = prefs.getStringList(gpsIdDevicesKey)!;
      // 4

    }
    if (prefs.containsKey(gpsTopicsKey)) {
      // 3
      Constans.topicList = prefs.getStringList(gpsTopicsKey)!;
      // 4

    }
  }

}