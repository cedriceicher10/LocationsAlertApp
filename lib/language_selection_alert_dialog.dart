import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<String> languageList = [];
  String dropDownValue = '';

  Color _buttonColor = Color(s_darkSalmon);
  bool _firstTimePressed = false;
  bool _showRestartWarning = false;

  double _languageDropDownRowWidth = 0;
  double _languageDropDownRowHeight = 0;
  double _spacer = 0;

  @override
  void initState() {
    languageList = _languageServices.getLanguageList();
    dropDownValue = languageList[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    generateLayout();
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
      content: Container(
          width: _languageDropDownRowWidth,
          height: _languageDropDownRowHeight,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              Text('Language:'),
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
                items:
                    languageList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ]),
            (_firstTimePressed) ? SizedBox(height: _spacer) : Container(),
            (_firstTimePressed)
                ? Text(
                    'Please RESTART the app for the language change to take effect.',
                    style: TextStyle(
                        color: Color(s_declineRed),
                        fontWeight: FontWeight.bold),
                  )
                : Container(),
          ])),
      actions: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, this.widget.padding, 0),
            child: TextButton(
              child: const Text("Change Language",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                  backgroundColor: _buttonColor, foregroundColor: Colors.white),
              onPressed: () async {
                // First time pressed, inform user that a restart is necessary
                if (!_firstTimePressed) {
                  setState(() {
                    _buttonColor = Color(s_declineRed);
                    _showRestartWarning = true;
                    _firstTimePressed = true;
                  });
                } else {
                  // Second time pressed, close and restart
                  changeLanguage(dropDownValue);
                  Navigator.of(context).pop();
                }
              },
            )),
        Padding(
            padding: EdgeInsets.fromLTRB(0, 0, this.widget.padding, 0),
            child: TextButton(
              child: const Text('Close',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                  backgroundColor: Color(s_aquarium),
                  foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ))
      ],
    );
  }

  void changeLanguage(String chosenLanguage) async {
    // Get new language code
    String newLanguageCode = _languageServices.getLanguageCode(chosenLanguage);
    // Change language in shared prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('currentLanguage', newLanguageCode);
    // Load new translations
    _languageServices.newLanguage(newLanguageCode);
  }

  void generateLayout() {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

    // Height
    if (!_firstTimePressed) {
      _languageDropDownRowHeight = (50 / _screenHeight) * _screenHeight;
    } else {
      _languageDropDownRowHeight = (105 / _screenHeight) * _screenHeight;
    }
    _spacer = (10 / _screenHeight) * _screenHeight;

    // Width
    _languageDropDownRowWidth = (100 / _screenWidth) * _screenWidth;
  }
}
