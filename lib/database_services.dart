import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locationalertsapp/start_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

final COLLECTION = 'reminders';

class DatabaseServices {
  CollectionReference reminders =
      FirebaseFirestore.instance.collection(COLLECTION);

  // This one accepts the uuid because occasionally the _uuid above is still
  // "" by the time it gets here
  Future<int> getAlertCount() async {
    var snapshot = await FirebaseFirestore.instance
        .collection(COLLECTION)
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
        .collection(COLLECTION)
        .where('userId', isEqualTo: UUID_GLOBAL)
        .where('isCompleted', isEqualTo: false)
        .orderBy('dateTimeCreated', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>>
      getIsCompleteAlertsGetCall() async {
    return await FirebaseFirestore.instance
        .collection(COLLECTION)
        .where('userId', isEqualTo: UUID_GLOBAL)
        .where('isCompleted', isEqualTo: false)
        .orderBy('dateTimeCreated', descending: true)
        .get();
  }

  void deleteAlert(String id) async {
    // Retrieve alert
    await FirebaseFirestore.instance
        .collection(COLLECTION)
        .doc(id)
        .get()
        .catchError((error) => throw ('Error: $error'));
    // Delete alert
    await FirebaseFirestore.instance
        .collection(COLLECTION)
        .doc(id)
        .delete()
        .catchError((error) => throw ('Error: $error'));
  }

  void updateAlert(String id, String reminderBody, String location) async {
    // Retrieve alert
    await FirebaseFirestore.instance
        .collection(COLLECTION)
        .doc(id)
        .get()
        .catchError((error) => throw ('Error: $error'));
    // Update alert
    await FirebaseFirestore.instance.collection(COLLECTION).doc(id).update({
      'reminderBody': reminderBody,
      'location': location,
    }).catchError((error) => throw ('Error: $error'));
  }

  void completeAlert(String id) async {
    // Retrieve alert
    await FirebaseFirestore.instance
        .collection(COLLECTION)
        .doc(id)
        .get()
        .catchError((error) => throw ('Error: $error'));
    // Complete alert
    await FirebaseFirestore.instance.collection(COLLECTION).doc(id).update({
      'dateTimeCompleted': Timestamp.now(),
      'isCompleted': true,
    }).catchError((error) => throw ('Error: $error'));
  }
}
