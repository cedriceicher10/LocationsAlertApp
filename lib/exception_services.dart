import 'package:flutter/material.dart';
import 'package:locationalertsapp/styles.dart';

class ExceptionServices {
  void popUp(BuildContext context, String popUpText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Unexpected Error:",
            style: TextStyle(
                color: Colors.transparent,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(offset: Offset(0, -3), color: Colors.black)],
                decoration: TextDecoration.underline,
                decorationColor: Colors.black,
                decorationThickness: 1),
          ),
          content: Text(popUpText),
          actions: <Widget>[
            TextButton(
                child: const Text("Close"),
                style: TextButton.styleFrom(primary: Color(s_disabledGray)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }
}
