
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phone_mqtt/constans.dart' as Constans;

class GpsDeviceController {
  static const String gpsIdDevicesKey = "gpsIdDevices";

  void saveDeviceIDList() async {
   // 1
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // 2
  prefs.setStringList(gpsIdDevicesKey, Constans.deviceIDList);
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
  }

}