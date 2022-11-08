import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';



const double cameraZoom = 15;
const double cameraTilt = 50;
const double cameraBearing = 30;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});



  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  late Position position;
  late GoogleMapController mapControler;
  Completer<GoogleMapController> _controller = Completer();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Container());
  }

  @override
  void dispose() {
    super.dispose();
  }

}
