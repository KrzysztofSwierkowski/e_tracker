import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:location/location.dart';
import 'package:phone_mqtt/constans.dart' as Constans;

class TestDB {

  DatabaseReference ref = FirebaseDatabase.instance.ref(Constans.topic);


  Future<void> saveData(double latitude,double longitude,String id) async {
    await ref.child(id).set({"latitude" : latitude,
      "longitude" : longitude});

  }

 void getLastKnownLocalization(String id) async {
    Map<String, dynamic> lastKnownLocalization;
    var data = "";
    final snapshot = await ref.child(id).get();
    if (snapshot.exists) {
      print(snapshot.value);
      var data = jsonEncode(snapshot.value);
      lastKnownLocalization = jsonDecode(data);

      Map<dynamic, dynamic> values = lastKnownLocalization;

      LocationData newLocation = LocationData.fromMap({
        'latitude': values['latitude'],
        'longitude': values['longitude'],
      });

      Constans.lastKnownLocation = values;


      //return data;
    } else {
      print('No data available.');
      data = "";
    }


    // await ref.child(id).onValue.listen((DatabaseEvent event) {
    //   final data = event.snapshot.value;
    //   print(data);
    // });
    //return data;
  }

}