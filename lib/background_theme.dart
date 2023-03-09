import 'package:flutter/material.dart';
import 'styles.dart';

enum Screen {
  START_SCREEN,
  SPECIFIC_ALERT_SCREEN,
  GENERIC_ALERT_SCREEN,
  MY_ALERTS_SCREEN,
  EDIT_ALERTS_SCREEN
}

class BackgroundTheme {
  Color topColor = gunmetal;
  Color bottomColor = teal;

  BackgroundTheme(Screen screen) {
    switch (screen) {
      case Screen.START_SCREEN:
        {
          topColor = startScreenBackgroundTop;
          bottomColor = startScreenBackgroundBottom;
        }
        break;
      case Screen.SPECIFIC_ALERT_SCREEN:
        {
          topColor = createAlertBackgroundTop;
          bottomColor = createAlertBackgroundBottom;
        }
        break;
      case Screen.GENERIC_ALERT_SCREEN:
        {
          topColor = createAlertBackgroundTop;
          bottomColor = createAlertBackgroundBottom;
        }
        break;
      case Screen.MY_ALERTS_SCREEN:
        {
          topColor = myAlertsBackgroundTop;
          bottomColor = myAlertsBackgroundBottom;
        }
        break;
      case Screen.EDIT_ALERTS_SCREEN:
        {
          topColor = teal;
          bottomColor = lavenderWeb;
        }
        break;
    }
  }

  BoxDecoration getBackground() {
    return BoxDecoration(
        gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        topColor,
        bottomColor,
      ],
    ));
  }
}
