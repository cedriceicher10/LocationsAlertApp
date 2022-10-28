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
  Color topColor = Color(s_darkSalmon);
  Color bottomColor = Color(s_aquarium);

  BackgroundTheme(Screen screen) {
    switch (screen) {
      case Screen.START_SCREEN:
        {
          topColor = Color(s_aquarium);
          bottomColor = Color(s_lavenderWeb);
        }
        break;
      case Screen.SPECIFIC_ALERT_SCREEN:
        {
          topColor = Color(s_aquarium);
          bottomColor = Color(s_lavenderWeb);
        }
        break;
      case Screen.GENERIC_ALERT_SCREEN:
        {
          topColor = Color(s_aquarium);
          bottomColor = Color(s_lavenderWeb);
        }
        break;
      case Screen.MY_ALERTS_SCREEN:
        {
          topColor = Color(s_aquarium);
          bottomColor = Color(s_lavenderWeb);
        }
        break;
      case Screen.EDIT_ALERTS_SCREEN:
        {
          topColor = Color(s_aquarium);
          bottomColor = Color(s_lavenderWeb);
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
