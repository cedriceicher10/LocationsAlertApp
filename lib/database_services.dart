import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locationalertsapp/start_screen.dart';
import 'package:locationalertsapp/exception_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

final COLLECTION_REMINDERS = 'reminders';
final COLLECTION_USERS = 'users';

final ALERT_LIMIT = 150;

class DatabaseServices {
  CollectionReference reminders =
      FirebaseFirestore.instance.collection(COLLECTION_REMINDERS);
  CollectionReference users =
      FirebaseFirestore.instance.collection(COLLECTION_USERS);
  ExceptionServices _exception = ExceptionServices();

  // This one accepts the uuid because occasionally the _uuid above is still
  // "" by the time it gets here
  Future<int> getAlertCount(BuildContext context) async {
    var snapshot = await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .where('userId', isEqualTo: UUID_GLOBAL)
        .where('isCompleted', isEqualTo: false)
        .get()
        .catchError((error) {
      _exception.popUp(context,
          'Get from database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
    int alertCount = 0;
    snapshot.docs.forEach((result) {
      alertCount++;
    });
    return alertCount;
  }

  Future<bool> checkRemindersNum(BuildContext context) async {
    int numAlerts = await getAlertCount(context);
    if (numAlerts < ALERT_LIMIT) {
      return true;
    }
    return false;
  }

  void addToUsersDatabase(BuildContext context) async {
    // Put in Firestore cloud database
    users.add({
      'firstLogin': Timestamp.now(),
      'lastLogin': Timestamp.now(),
      'numAppOpens': 0,
      'remindersCompleted': 0,
      'remindersCreated': 0,
      'remindersUpdated': 0,
      'remindersDeleted': 0,
      'userId': UUID_GLOBAL,
    }).catchError((error) {
      _exception.popUp(context,
          'Add to users database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void updateUsersAppOpens(BuildContext context) async {
    // Retrieve alert
    var query = await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .where("userId", isEqualTo: UUID_GLOBAL)
        .get();
    // Update alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .doc(query.docs[0].id)
        .update({
      'numAppOpens': query.docs[0]['numAppOpens'] + 1,
    }).catchError((error) {
      _exception.popUp(context,
          'Update in users database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void updateUsersLastLogin(BuildContext context) async {
    // Retrieve alert
    var query = await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .where("userId", isEqualTo: UUID_GLOBAL)
        .get();
    // Update alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .doc(query.docs[0].id)
        .update({
      'lastLogin': Timestamp.now(),
    }).catchError((error) {
      _exception.popUp(context,
          'Update in users database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void updateUsersReminderComplete() async {
    // Retrieve alert
    var query = await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .where("userId", isEqualTo: UUID_GLOBAL)
        .get();
    // Update alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .doc(query.docs[0].id)
        .update({
      'remindersCompleted': query.docs[0]['remindersCompleted'] + 1,
    });
  }

  void updateUsersReminderCreated(BuildContext context) async {
    // Retrieve alert
    var query = await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .where("userId", isEqualTo: UUID_GLOBAL)
        .get();
    // Update alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .doc(query.docs[0].id)
        .update({
      'remindersCreated': query.docs[0]['remindersCreated'] + 1,
    }).catchError((error) {
      _exception.popUp(context,
          'Update in users database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void updateUsersReminderUpdated(BuildContext context) async {
    // Retrieve alert
    var query = await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .where("userId", isEqualTo: UUID_GLOBAL)
        .get();
    // Update alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .doc(query.docs[0].id)
        .update({
      'remindersUpdated': query.docs[0]['remindersUpdated'] + 1,
    }).catchError((error) {
      _exception.popUp(context,
          'Update in users database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void updateUsersReminderDeleted(BuildContext context) async {
    // Retrieve alert
    var query = await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .where("userId", isEqualTo: UUID_GLOBAL)
        .get();
    // Update alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .doc(query.docs[0].id)
        .update({
      'remindersDeleted': query.docs[0]['remindersDeleted'] + 1,
    }).catchError((error) {
      _exception.popUp(context,
          'Update in users database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void addToRemindersDatabase(
      BuildContext context,
      String reminderBody,
      bool isSpecific,
      bool isCompleted,
      String location,
      double latitude,
      double longitude) async {
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
    }).catchError((error) {
      _exception.popUp(context,
          'Add to reminders database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getRemindersIncompleteAlertsSnapshotCall() {
    return FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .where('userId', isEqualTo: UUID_GLOBAL)
        .where('isCompleted', isEqualTo: false)
        .orderBy('dateTimeCreated', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>>
      getRemindersIsCompleteAlertsGetCall(BuildContext context) async {
    return await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .where('userId', isEqualTo: UUID_GLOBAL)
        .where('isCompleted', isEqualTo: false)
        .orderBy('dateTimeCreated', descending: true)
        .get()
        .catchError((error) {
      _exception.popUp(context,
          'Get from reminders database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void deleteRemindersAlert(BuildContext context, String id) async {
    // Retrieve alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .doc(id)
        .get()
        .catchError((error) {
      _exception.popUp(context,
          'Get from reminders database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
    // Delete alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .doc(id)
        .delete()
        .catchError((error) {
      _exception.popUp(context,
          'Delete in reminders database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void updateRemindersSpecificAlert(
      BuildContext context,
      String id,
      String reminderBody,
      String location,
      double latitude,
      double longitude,
      bool isSpecific) async {
    // Retrieve alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .doc(id)
        .get()
        .catchError((error) {
      _exception.popUp(context,
          'Get from reminders database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
    // Update alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .doc(id)
        .update({
      'reminderBody': reminderBody,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'isSpecific': isSpecific,
    }).catchError((error) {
      _exception.popUp(context,
          'Update in reminders database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void updateRemindersGenericAlert(BuildContext context, String id,
      String reminderBody, String location, bool isSpecific) async {
    // Retrieve alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .doc(id)
        .get()
        .catchError((error) {
      _exception.popUp(context,
          'Get from reminders database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
    // Update alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .doc(id)
        .update({
      'reminderBody': reminderBody,
      'location': location,
      'isSpecific': isSpecific,
    }).catchError((error) {
      _exception.popUp(context,
          'Update in reminders database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void completeRemindersAlert(String id) async {
    // Retrieve alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .doc(id)
        .get()
        .catchError((error) => throw ('Error: $error'));
    // Complete alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .doc(id)
        .update({
      'dateTimeCompleted': Timestamp.now(),
      'isCompleted': true,
    }).catchError((error) => throw ('Error: $error'));
  }
}
