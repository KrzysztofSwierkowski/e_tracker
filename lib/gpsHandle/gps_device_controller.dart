
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phone_mqtt/constans.dart' as Constans;

class GpsDeviceController {
  static const String gpsIdDevicesKey = "gpsIdDevices";
  static const String gpsTopicsKey = "gpsTopics";
  static const String topicCurrentDeviceNameKey = "topicCurrentDeviceName";

  void saveDeviceIDList() async {
   // 1
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // 2
  prefs.setStringList(gpsIdDevicesKey, Constans.deviceIDList);
  prefs.setStringList(gpsTopicsKey, Constans.topicList);
  prefs.setString(topicCurrentDeviceNameKey, Constans.topicCurrentDeviceName);

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
    if (prefs.containsKey(topicCurrentDeviceNameKey)) {
      // 3
      Constans.topicCurrentDeviceName = prefs.getString(topicCurrentDeviceNameKey)!;
      // 4

    }
  }

  void saveCurrentDeviceNameKey() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(topicCurrentDeviceNameKey, Constans.topicCurrentDeviceName);

  }

  void getCurrentDeviceNameKey() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();


    if (prefs.containsKey(topicCurrentDeviceNameKey)) {

      Constans.topicCurrentDeviceName = prefs.getString(topicCurrentDeviceNameKey)!;


    }
  }

}