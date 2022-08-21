import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'notification_services.dart';

class AlertServices {
  final TRIGGER_DISTANCE = 1.0; //mi

  bool checkAlertDistance(
      double userLat, double userLon, double alertLat, double alertLon) {
    // All angles MUST BE IN RADIANS

    // References:
    //   https://www.movable-type.co.uk/scripts/latlong.html
    //   https://en.wikipedia.org/wiki/Haversine_formula

    const EARTH_RADIUS = 6371e3; // m

    double phi1 = userLat * pi / 180;
    double phi2 = alertLat * pi / 180;
    double deltaPhi = (alertLat - userLat) * pi / 180;
    double deltaLambda = (alertLon - userLon) * pi / 180;

    double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double greatCircleDistanceMeters = EARTH_RADIUS * c; // m
    double greatCircleDistanceMiles = greatCircleDistanceMeters / 1609; // mi
    //double greatCircleDistanceYards = greatCircleDistanceMiles * 1760; // yd

    if (greatCircleDistanceMiles <= TRIGGER_DISTANCE) {
      return true;
    }
    return false;
  }

  Future<void> showAlertNotification(String reminder, String location) async {
    NotificationServices().showNotification(reminder, location);
  }
}
