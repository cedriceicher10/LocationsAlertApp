import 'package:flutter/material.dart';
import 'package:locationalertsapp/map_screen.dart';
import 'package:locationalertsapp/my_alerts_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

enum FAB { LIST, MAP }

Widget fabBar(
    BuildContext context,
    FAB fabSelection,
    double buttonHeight,
    double buttonWidth,
    double buttonFontSize,
    double buttonIconWidth,
    double cornerRadius,
    double iconSpacing,
    double iconWidth,
    double iconSize) {
  IconData iconSelection = Icons.map;
  if (fabSelection == FAB.LIST) {
    iconSelection = Icons.list;
  }
  return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(
      height: buttonHeight,
      width: buttonWidth,
      child: FloatingActionButton.extended(
          heroTag: 'FAB_back',
          onPressed: () {
            // Remove keyboard
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            Navigator.pop(context);
          },
          backgroundColor: Color(s_darkSalmon),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(cornerRadius))),
          label: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: buttonIconWidth,
            ),
            SizedBox(
              width: 8,
            ),
            buttonText('Back', buttonFontSize)
          ])),
    ),
    SizedBox(width: iconSpacing),
    Container(
        height: buttonHeight,
        width: iconWidth,
        child: FloatingActionButton.extended(
            heroTag: 'FAB_switch',
            onPressed: () {
              if (fabSelection == FAB.MAP) {
                // Navigate to my other screen
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        MapScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        MyAlertsScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }
            },
            backgroundColor: Color.fromARGB(255, 252, 241, 144),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(cornerRadius))),
            label: Icon(
              iconSelection,
              color: Color(s_darkSalmon),
              size: iconSize,
            )))
  ]);
}

Widget buttonText(String text, double fontSize) {
  return FormattedText(
    text: text,
    size: fontSize,
    color: Colors.white,
    font: s_font_BonaNova,
    weight: FontWeight.bold,
  );
}
