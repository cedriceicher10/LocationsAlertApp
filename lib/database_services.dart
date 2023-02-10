import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locationalertsapp/start_screen.dart';
import 'package:locationalertsapp/exception_services.dart';
import 'package:flutter/material.dart';

final COLLECTION_REMINDERS = 'reminders';
final COLLECTION_USERS = 'users';
final ALERT_LIMIT = 150;

class userInfo {
  Timestamp firstLogin;
  Timestamp lastLogin;
  int numAppOpens;
  int remindersCompleted;
  int remindersCreated;
  int remindersUpdated;
  int remindersDeleted;
  String userId;
  int userNo;
  userInfo(
      this.firstLogin,
      this.lastLogin,
      this.numAppOpens,
      this.remindersCompleted,
      this.remindersCreated,
      this.remindersUpdated,
      this.remindersDeleted,
      this.userId,
      this.userNo);
  userInfo.init()
      : this.firstLogin = Timestamp.now(),
        this.lastLogin = Timestamp.now(),
        this.numAppOpens = 0,
        this.remindersCompleted = 0,
        this.remindersCreated = 0,
        this.remindersDeleted = 0,
        this.remindersUpdated = 0,
        this.userId = '',
        this.userNo = -1;
}

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
    // Collect latest (highest) userNo to assign new userNo
    var query =
        await FirebaseFirestore.instance.collection(COLLECTION_USERS).get();
    int highestUserNo = -1;
    for (int index = 0; index < query.docs.length; index++) {
      if (query.docs[index]['userNo'] > highestUserNo) {
        highestUserNo = query.docs[index]['userNo'];
      }
    }

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
      'userNo': highestUserNo + 1,
      'adsServed': 0,
    }).catchError((error) {
      _exception.popUp(context,
          'Add to users database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  Future<userInfo> getUsersSnapshot(BuildContext context) async {
    // Retrieve alert
    var query = await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .where("userId", isEqualTo: UUID_GLOBAL)
        .get();
    return userInfo(
        query.docs[0]['firstLogin'],
        query.docs[0]['lastLogin'],
        query.docs[0]['numAppOpens'],
        query.docs[0]['remindersCompleted'],
        query.docs[0]['remindersCreated'],
        query.docs[0]['remindersUpdated'],
        query.docs[0]['remindersDeleted'],
        query.docs[0]['userId'],
        query.docs[0][
            'userNo']); // Figured I wouldn't add adsServed here since it won't even be used
  }

  Future<bool> isUuidTaken(BuildContext context, String uuid) async {
    // Ensure that uuid isn't already taken
    var snapshot = await FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .where('userId', isEqualTo: uuid)
        .get()
        .catchError((error) {
      _exception.popUp(context,
          'Get from users database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
    if (snapshot.docs.length > 0) {
      return true;
    }
    return false;
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

  void updateUsersAdsServed(BuildContext context) async {
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
      'adsServed': query.docs[0]['adsServed'] + 1,
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
      double longitude,
      double triggerDistance,
      String triggerUnits) async {
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
      'triggerDistance': triggerDistance,
      'triggerUnits': triggerUnits
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

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getRemindersCompleteAlertsSnapshotCall() {
    return FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .where('userId', isEqualTo: UUID_GLOBAL)
        .where('isCompleted', isEqualTo: true)
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

  void updateRemindersSpecificAlertRestore(
      BuildContext context, String id) async {
    // Delete alert
    await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .doc(id)
        .update({
      'isCompleted': false,
    }).catchError((error) {
      _exception.popUp(context,
          'Update in reminders database to restore reminder: Action failed\n error string: ${error.toString()}\nerror raw: $error');
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
      bool isSpecific,
      double triggerDistance,
      String triggerUnits) async {
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
      'triggerDistance': triggerDistance,
      'triggerUnits': triggerUnits
    }).catchError((error) {
      _exception.popUp(context,
          'Update in reminders database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void updateRemindersGenericAlert(BuildContext context, String id,
      String reminderBody, String location, bool isSpecific) async {
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

  void completeRemindersAlertWithContext(
      BuildContext context, String id) async {
    // Mark alert complete
    await FirebaseFirestore.instance
        .collection(COLLECTION_REMINDERS)
        .doc(id)
        .update({
      'dateTimeCompleted': Timestamp.now(),
      'isCompleted': true,
    }).catchError((error) {
      _exception.popUp(context,
          'Mark complete in reminders database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
      throw ('Error: $error');
    });
  }

  void completeRemindersAlert(String id) async {
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
