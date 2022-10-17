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
          topColor = Color(s_darkSalmon);
          bottomColor = Color(s_aquarium);
        }
        break;
      case Screen.SPECIFIC_ALERT_SCREEN:
        {
          topColor = Color(s_aquarium);
          bottomColor = Color(s_darkSalmon);
        }
        break;
      case Screen.GENERIC_ALERT_SCREEN:
        {
          topColor = Color(s_aquarium);
          bottomColor = Color(s_darkSalmon);
        }
        break;
      case Screen.MY_ALERTS_SCREEN:
        {
          topColor = Color(s_darkSalmon);
          bottomColor = Color(s_aquarium);
        }
        break;
      case Screen.EDIT_ALERTS_SCREEN:
        {
          topColor = Color(s_aquarium);
          bottomColor = Color(s_darkSalmon);
        }
        break;
    }
  }

  BoxDecoration getBackground() {
    return BoxDecoration(
        gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        topColor,
        bottomColor,
      ],
    ));
  }
}
