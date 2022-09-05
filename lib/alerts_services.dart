import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notification_services.dart';

class AlertServices {
  final TRIGGER_DISTANCE = 0.5; // mi
  final NEW_ALERT_TIME = 1; // min

  // doNotAlertList [docId, lat, lon]
  //  - If alert is already active
  //  - If alert is new
  //  - If alert is new && within distance
  List doNotAlertList = [
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

    print(
        'ALERT DET: ${greatCircleDistanceMiles.toStringAsFixed(2)} vs ${TRIGGER_DISTANCE} mi');

    if (greatCircleDistanceMiles <= TRIGGER_DISTANCE) {
      return true;
    }
    return false;
  }

  //**
  // Trigger Alert Logic Tree
  // Trigger if: 1) Alert is not new, 2) Alert is not active, 3) Alert is within distance
  // Purge doNotAlertList if: Everytime
  //
  // Note: If a new alert is made and the user is within distance, it will NOT
  //       trigger until the user is out of distance and then back within.
  //
  // */
  void alertDeterminationLogic(double userBgLat, double userBgLon, var alert) {
    if (checkNewAlert(alert['dateTimeCreated'])) {
      print('ALERT DET: NEW - ${alert['reminderBody']}');
      addToDoNotAlertList(alert.id, alert['latitude'], alert['longitude']);
    } else {
      if (!checkDoNotAlertList(alert.id)) {
        print('ALERT DET: NOT IN DoNotAlert - ${alert['reminderBody']}');
        if (checkAlertDistance(
            userBgLat, userBgLon, alert['latitude'], alert['longitude'])) {
          print('ALERT DET: WITHIN DISTANCE - ${alert['reminderBody']}');
          NotificationServices().showNotification(
              alert.id, alert['reminderBody'], alert['location']);
          addToDoNotAlertList(alert.id, alert['latitude'], alert['longitude']);
        } else {
          print('ALERT DET: NOT WITHIN DISTANCE - ${alert['reminderBody']}');
        }
      } else {
        print('ALERT DET: IN DoNotAlert - ${alert['reminderBody']}');
      }
    }
    print('=======================================================');
    purgeDoNotAlertList(userBgLat, userBgLon);
  }

  void showAlertNotification(String docId, String reminder, String location) {
    NotificationServices().showNotification(docId, reminder, location);
  }

  bool checkDoNotAlertList(String docId) {
    for (int index = 1; index < doNotAlertList.length; ++index) {
      if (doNotAlertList[index][0] == docId) {
        return true;
      }
    }
    return false;
  }

  void addToDoNotAlertList(String docId, double latitude, double longitude) {
    doNotAlertList.add([docId, latitude, longitude]);
  }

  // Purging removes all alerts that are
  // 1. No longer within distance
  // 2. No longer new (&& no longer within distance)
  void purgeDoNotAlertList(double userBgLat, double userBgLon) {
    for (int index = 1; index < doNotAlertList.length; ++index) {
      if (!checkAlertDistance(userBgLat, userBgLon, doNotAlertList[index][1],
          doNotAlertList[index][2])) {
        doNotAlertList.removeAt(index);
      }
    }
  }

  bool checkNewAlert(Timestamp dateTimeCreated) {
    int timeDiff = (Timestamp.now().seconds - dateTimeCreated.seconds);
    if (timeDiff < (NEW_ALERT_TIME * 60)) {
      return true;
    }
    return false;
  }
}
