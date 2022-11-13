// import 'package:flutter/cupertino.dart';
// import 'package:phone_mqtt/data_provider.dart';
// import 'package:phone_mqtt/user_location.dart';
// import 'dart:developer' as developer;
//
// enum LocationProviderStatus {
//   Initial,
//   Loading,
//   Success,
//   Error,
// }
//
// class LocationProvider with ChangeNotifier {
//   late UserLocation _userLocation;
//   final DataProvider _locationServices = DataProvider();
//
//   LocationProviderStatus _status = LocationProviderStatus.Initial;
//
//   UserLocation get userLocation => _userLocation;
//
//   LocationProviderStatus get status => _status;
//
//   Future<void> getLocation() async {
//     try {
//       _updateStatus(LocationProviderStatus.Loading);
//
//       _userLocation = await _locationServices.currentLoc();
//
//       _updateStatus(LocationProviderStatus.Success);
//     } catch (e) {
//       _updateStatus(LocationProviderStatus.Error);
//     }
//   }
//
//   void _updateStatus(LocationProviderStatus status) {
//     if (_status != status) {
//       developer.log('LocationProvider: Status updated from: $_status to: $status');
//       _status = status;
//       notifyListeners();
//     }
//   }
// }