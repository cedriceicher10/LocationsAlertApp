import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:locationalertsapp/language_services.dart';
import 'package:locationalertsapp/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'database_services.dart';
import 'dart:math';

class NotificationServices {
  LanguageServices _languageServices = LanguageServices();
  int _notificationId = 0;
  Map _activeNotificationsMap = new Map();
  static final NotificationServices _notificationService =
      NotificationServices._internal();

  factory NotificationServices() {
    return _notificationService;
  }

  NotificationServices._internal();

  final DatabaseServices _dbServices = DatabaseServices();

  Future<void> initNotifications() async {
    // Setup notification tracking so as to complete those that are marked done
    var rng = Random();
    // Choose a sufficiently large number in case the user doesn't clear
    // notficiations and closes the app (hence the _notificationId starting
    // value is reset)
    _notificationId = rng.nextInt(100000);
    // Setup notifications
    AwesomeNotifications().initialize('resource://drawable/app_icon', [
      NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Color(s_aquariumLighter),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          enableVibration: true)
    ]);
    // Future notifications
    AwesomeNotifications().actionStream.listen((action) async {
      String docId = _activeNotificationsMap[action.id];
      if (action.buttonKeyPressed == 'Completed') {
        // Mark alert complete
        _dbServices.completeRemindersAlert(docId);
        _dbServices.updateUsersReminderComplete();
      } else if (action.buttonKeyPressed == 'Dismissed') {
        // Alert is dismissed, remains active and notification dissappears
      } else if (action.buttonKeyPressed == 'DissmissedScheduled') {
        // Scheduled notification
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('scheduledNotificationOn', false);
      }
    });
  }

  Future<void> showNotification(String docId, String title, String body) async {
    // Having a unique id number allows for multiple notifications at the same place
    _notificationId++;
    // Save the docId in case this is marked complete
    _activeNotificationsMap[_notificationId] = docId;
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: _notificationId,
          channelKey: 'basic_channel',
          title: title,
          body: body),
      actionButtons: <NotificationActionButton>[
        NotificationActionButton(
            key: 'Completed',
            label: _languageServices.notificationsMarkComplete,
            color: Color(s_aquarium)),
        NotificationActionButton(
            key: 'Dismissed',
            label: _languageServices.notificationsDismiss,
            color: Color(s_disabledGray),
            buttonType: ActionButtonType.DisabledAction),
      ],
    );
  }

  Future<void> scheduleNewNotification() async {
    // // This is
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool scheduledNotificationOn = false;
    // if (prefs.getBool('scheduledNotificationOn') == null) {
    //   prefs.setBool('scheduledNotificationOn', true);
    // } else {
    //   scheduledNotificationOn = prefs.getBool('scheduledNotificationOn')!;
    // }

    // if (!scheduledNotificationOn) {
    //   bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    //   if (isAllowed) {
    //     // Set notification for 1 hr away
    //     int timeDelay = 60;
    //     // Prep notification
    //     AwesomeNotifications().createNotification(
    //         content: NotificationContent(
    //           id: -1, // -1 is replaced by a random number
    //           channelKey: 'basic_channel',
    //           title: "Location Alerts",
    //           body: "Fancy creating a location alert?",
    //         ),
    //         actionButtons: [
    //           NotificationActionButton(
    //               key: 'DissmissedScheduled',
    //               label: 'Dismiss',
    //               buttonType: ActionButtonType.DisabledAction)
    //         ],
    //         schedule: NotificationCalendar.fromDate(
    //             date: DateTime.now().add(Duration(seconds: timeDelay))));
    //   }
    // }
  }
}
