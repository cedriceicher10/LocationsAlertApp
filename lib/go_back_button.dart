import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'formatted_text.dart';
import 'styles.dart';

class GoBackButton {
  // Package back: -1 = none, 0 = true, 1 = false
  Widget back(
      String text,
      double buttonWidth,
      double buttonHeight,
      double fontSize,
      double iconSize,
      double cornerRadius,
      BuildContext context,
      Color color,
      [int package = -1]) {
    return ElevatedButton(
        onPressed: () {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          if (package == 0) {
            Navigator.pop(context, true);
          } else if (package == 1) {
            Navigator.pop(context, false);
          } else {
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
            primary: color,
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cornerRadius))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: iconSize,
          ),
          // Expanded(
          //     child: SizedBox(
          //   width: 1,
          // )),
          SizedBox(
            width: 8,
          ),
          buttonText(text, fontSize)
        ]));
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
}
