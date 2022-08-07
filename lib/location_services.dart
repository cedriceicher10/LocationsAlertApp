import 'package:flutter/material.dart';
import 'package:location/location.dart';

Location location = Location();

class LocationServices {
  double userLat = 0;
  double userLon = 0;
  bool permitted =
      false; // Used for lookups to stop infinite "ask for location" loop

  Future<void> getLocation() async {
    permitted = false;
    // Adapted from: https://pub.dev/packages/location
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        Icons.assignment_return;
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.granted) {
      permitted = true;
    } else {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        permitted = true;
      }
    }
    if (permitted) {
      _locationData = await location.getLocation();
      userLat = _locationData.latitude!;
      userLon = _locationData.longitude!;
    }
    return;
  }
}
