import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'exception_services.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

Location _location = Location();
ExceptionServices _exception = ExceptionServices();

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
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        Icons.assignment_return;
        return;
      }
    }
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.granted) {
      permitted = true;
    } else {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        permitted = true;
      }
    }
    if (permitted) {
      _locationData = await _location.getLocation();
      userLat = _locationData.latitude!;
      userLon = _locationData.longitude!;
    }
    return;
  }

  Future<bool> reverseGeolocateCheck(
      BuildContext context, String locationQuery) async {
    // Attempt to reverse geocode to get lat/lon
    List<geocoding.Location> latLonFromQuery;
    try {
      latLonFromQuery = await geocoding.locationFromAddress(locationQuery);
    } catch (exception) {
      _exception.popUp(context, 'Location finding: ' + exception.toString());
      print('REVERSE GEOLOCATE EXCEPTION: ' + exception.toString());
      return false;
    }
    alertLat = latLonFromQuery[0].latitude;
    alertLon = latLonFromQuery[0].longitude;
    return true;
  }
}
