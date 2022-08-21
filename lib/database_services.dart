import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locationalertsapp/start_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class DatabaseServices {
  CollectionReference reminders =
      FirebaseFirestore.instance.collection('reminders');

  // This one accepts the uuid because occasionally the _uuid above is still
  // "" by the time it gets here
  Future<int> getAlertCount() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: UUID_GLOBAL)
        .where('isCompleted', isEqualTo: false)
        .get()
        .catchError((error) => throw ('Error: $error'));
    int alertCount = 0;
    snapshot.docs.forEach((result) {
      alertCount++;
    });
    return alertCount;
  }

  void addToDatabase(String reminderBody, bool isSpecific, bool isCompleted,
      String location, double latitude, double longitude) async {
    // Put in Firestore cloud database
    reminders.add({
      'userId': UUID_GLOBAL,
      'reminderBody': reminderBody,
      'isSpecific': isSpecific,
      'isCompleted': isCompleted,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'dateTimeCreated': Timestamp.now(),
      'dateTimeCompleted': Timestamp.now(),
    }).catchError((error) => throw ('Error: $error'));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getIncompleteAlertsSnapshotCall() {
    return FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: UUID_GLOBAL)
        .where('isCompleted', isEqualTo: false)
        .orderBy('dateTimeCreated', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>>
      getIncompleteAlertsGetCall() async {
    dynamic variable = await FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: UUID_GLOBAL)
        .where('isCompleted', isEqualTo: false)
        .orderBy('dateTimeCreated', descending: true)
        .get();
    print('hi');
    return variable;
  }

  void deleteAlert(String id) async {
    // Retrieve alert
    await FirebaseFirestore.instance
        .collection('reminders')
        .doc(id)
        .get()
        .catchError((error) => throw ('Error: $error'));
    // Delete alert (set isCompleted == true)
    await FirebaseFirestore.instance.collection('reminders').doc(id).update({
      'isCompleted': true,
    }).catchError((error) => throw ('Error: $error'));
  }

  void updateAlert(String id, String reminderBody, String location) async {
    // Retrieve alert
    await FirebaseFirestore.instance
        .collection('reminders')
        .doc(id)
        .get()
        .catchError((error) => throw ('Error: $error'));
    // Update alert
    await FirebaseFirestore.instance.collection('reminders').doc(id).update({
      'reminderBody': reminderBody,
      'location': location,
    }).catchError((error) => throw ('Error: $error'));
  }
}
