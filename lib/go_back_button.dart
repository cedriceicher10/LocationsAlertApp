import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'formatted_text.dart';
import 'styles.dart';

class GoBackButton {
  // Package back: -1 = none, 0 = true, 1 = false
  Widget back(String text, double buttonWidth, double buttonHeight,
      BuildContext context, Color color,
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
            backgroundColor: color,
            fixedSize: Size(buttonWidth / 2, buttonHeight / 2)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
          Expanded(
              child: SizedBox(
            width: 1,
          )),
          buttonText(text)
        ]));
  }

  Widget buttonText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: Colors.white,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }
}
