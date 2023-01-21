import 'package:flutter/material.dart';
import 'language_services.dart';
import 'styles.dart';

class LanguageSelectionAlertDialogue extends StatefulWidget {
  final double padding;
  LanguageSelectionAlertDialogue({required this.padding, super.key});

  @override
  State<LanguageSelectionAlertDialogue> createState() =>
      _LanguageSelectionAlertDialogueState();
}

class _LanguageSelectionAlertDialogueState
    extends State<LanguageSelectionAlertDialogue> {
  final LanguageServices _languageServices = LanguageServices();

  double _languageDropDownRowWidth = 0;

  @override
  Widget build(BuildContext context) {
    generateLayout();
    List<String> languageList = _languageServices.getLanguageList();
    String dropDownValue = languageList[0];

    return AlertDialog(
      title: const Text(
        "Select Language",
        style: TextStyle(
            color: Colors.transparent,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(offset: Offset(0, -3), color: Colors.black)],
            decoration: TextDecoration.underline,
            decorationColor: Colors.black,
            decorationThickness: 1),
      ),
      actions: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, this.widget.padding, 0),
            child: TextButton(
              child: const Text("Close",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                  backgroundColor: Color(s_aquarium),
                  foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ))
      ],
      content: Container(
          width: _languageDropDownRowWidth,
          child: Row(children: [
            Text("Language:"),
            Expanded(child: SizedBox()),
            DropdownButton<String>(
              value: dropDownValue,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 16,
              style: TextStyle(color: Color(s_darkSalmon)),
              underline: Container(
                height: 2,
                color: Color(s_darkSalmon),
              ),
              onChanged: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  dropDownValue = value!;
                });
              },
              items: languageList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ])),
    );
  }

  void generateLayout() {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

    // Width
    _languageDropDownRowWidth = (100 / _screenWidth) * _screenWidth;
  }
}
