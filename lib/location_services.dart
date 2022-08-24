import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

Location location = Location();

class LocationServices {
  double userLat = 0;
  double userLon = 0;
  double alertLat = 0;
  double alertLon = 0;
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

  Future<bool> reverseGeolocateCheck(String locationQuery) async {
    // Attempt to reverse geocode to get lat/lon
    List<geocoding.Location> latLonFromQuery;
    try {
      latLonFromQuery = await geocoding.locationFromAddress(locationQuery);
    } catch (exception) {
      print('REVERSE GEOLOCATE EXCEPTION: ' + exception.toString());
      return false;
    }
    alertLat = latLonFromQuery[0].latitude;
    alertLon = latLonFromQuery[0].longitude;
    return true;
  }
}
