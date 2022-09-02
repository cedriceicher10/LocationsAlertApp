import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notification_services.dart';

class AlertServices {
  final TRIGGER_DISTANCE = 0.5; // mi
  final NEW_ALERT_TIME = 2; // min

  // docId, latitude, longitude
  List alertList = [
    ['', 0.0, 0.0]
  ];

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

  Future<void> showAlertNotification(String docId, double latitude,
      double longitude, String reminder, String location) async {
    //print('PURGE ALERT LIST: $docId');
    if (!checkForActiveAlert(docId)) {
      NotificationServices().showNotification(docId, reminder, location);
      addToActive(docId, latitude, longitude);
    }
  }

  bool checkForActiveAlert(String docId) {
    for (int index = 1; index < alertList.length; ++index) {
      if (alertList[index][0] == docId) {
        //print('CHECK ALERT LIST: Already found! Not showing alert.');
        return true;
      }
    }
    //print('CHECK ALERT LIST: Not found! Showing alert.');
    return false;
  }

  void addToActive(String docId, double latitude, double longitude) {
    alertList.add([docId, latitude, longitude]);
    //print('ADD ALERT LIST: $alertList');
  }

  void purgeActive(double userBgLat, double userBgLon) {
    for (int index = 1; index < alertList.length; ++index) {
      if (!checkAlertDistance(
          userBgLat, userBgLon, alertList[index][1], alertList[index][2])) {
        //print('PURGE ALERT LIST: Removing docid ${alertList[index][0]}');
        alertList.removeAt(index);
      }
    }
    //print('PURGE ALERT LIST: $alertList');
  }

  bool checkNewAlert(Timestamp dateTimeCreated) {
    if ((Timestamp.now().seconds - dateTimeCreated.seconds) <
        (NEW_ALERT_TIME * 60)) {
      return true;
    }
    return false;
  }
}
