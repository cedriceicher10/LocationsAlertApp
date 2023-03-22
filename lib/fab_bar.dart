import 'package:flutter/material.dart';
import 'package:locationalertsapp/map_screen.dart';
import 'package:locationalertsapp/my_alerts_screen.dart';
import 'language_services.dart';
import 'formatted_text.dart';
import 'styles.dart';

enum FAB { LIST, MAP }

final LanguageServices _languageServices = LanguageServices();

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
  String fabToggleText = _languageServices.myAlertsMapView;
  if (fabSelection == FAB.LIST) {
    iconSelection = Icons.list;
    fabToggleText = _languageServices.myAlertsListView;
  }
  return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        osmDisclosure(fabSelection),
        SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                backgroundColor: myAlertsBackButton,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(cornerRadius))),
                label:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    color: myAlertsBackIcon,
                    size: buttonIconWidth,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  buttonText(buttonFontSize)
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
                              MyAlertsScreen(
                            alertList: AlertList.NOT_COMPLETED,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }
                  },
                  backgroundColor: myAlertsMapViewButton,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(cornerRadius))),
                  label: Column(children: [
                    Text(
                      fabToggleText,
                      style: TextStyle(color: myAlertsMapViewText),
                    ),
                    Icon(
                      iconSelection,
                      color: myAlertsMapViewIcon,
                      size: iconSize,
                    )
                  ])))
        ])
      ]);
}

Widget osmDisclosure(FAB fabSelection) {
  if (fabSelection == FAB.LIST) {
    return Text(_languageServices.mapViewOSM);
  }
  return Container();
}

Widget buttonText(double fontSize) {
  return FormattedText(
    text: _languageServices.myAlertsBackButton,
    size: fontSize,
    color: myAlertsBackText,
    font: font_bigButtonText,
    weight: FontWeight.bold,
  );
}
