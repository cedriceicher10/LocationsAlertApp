import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:locationalertsapp/styles.dart';
import 'database_services.dart';

class NotificationServices {
  String _docId = '';
  static final NotificationServices _notificationService =
      NotificationServices._internal();

  factory NotificationServices() {
    return _notificationService;
  }

  NotificationServices._internal();

  final DatabaseServices _dbServices = DatabaseServices();

  Future<void> initNotifications() async {
    AwesomeNotifications().initialize('resource://drawable/app_icon', [
      NotificationChannel(
          channelGroupKey: 'basic_tests',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Color(s_aquariumLighter),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          enableVibration: true)
    ]);
    AwesomeNotifications().actionStream.listen((action) {
      if (action.buttonKeyPressed == 'Completed') {
        // Mark alert complete
        _dbServices.completeAlert(_docId);
      } else if (action.buttonKeyPressed == 'Dismissed') {
        // Alert is dismissed, remains active and notification dissappears
      }
    });
  }

  Future<void> showNotification(String docId, String title, String body) async {
    // Save the docId in case this is marked complete
    _docId = docId;
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 0, channelKey: 'basic_channel', title: title, body: body),
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
