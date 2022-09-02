import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:locationalertsapp/styles.dart';
import 'database_services.dart';
import 'dart:math';

class NotificationServices {
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
    AwesomeNotifications().actionStream.listen((action) {
      String docId = _activeNotificationsMap[action.id];
      if (action.buttonKeyPressed == 'Completed') {
        // Mark alert complete
        _dbServices.completeAlert(docId);
      } else if (action.buttonKeyPressed == 'Dismissed') {
        // Alert is dismissed, remains active and notification dissappears
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
            key: 'Completed', label: 'Mark Complete', color: Color(s_aquarium)),
        NotificationActionButton(
            key: 'Dismissed',
            label: 'Dismiss (next time)',
            color: Color(s_disabledGray),
            buttonType: ActionButtonType.DisabledAction),
      ],
    );
  }
}
