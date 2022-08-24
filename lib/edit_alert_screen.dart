import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'start_screen.dart';
import 'my_alerts_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'database_services.dart';
import 'location_services.dart';

class EditAlertScreen extends StatefulWidget {
  final ReminderTile reminderTile;
  const EditAlertScreen({required this.reminderTile, Key? key})
      : super(key: key);

  @override
  State<EditAlertScreen> createState() => _EditAlertScreenState();
}

class _EditAlertScreenState extends State<EditAlertScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final LocationServices _locationServices = LocationServices();
  final DatabaseServices _dbServices = DatabaseServices();
  String _reminderBody = '';
  String _location = '';
  bool _reverseGeolocateSuccess = false;
  final double topPadding = 80;
  final double textWidth = 325;
  final double buttonWidth = 260;
  final double buttonHeight = 60;
  final double buttonSpacing = 10;
  final double switchButtonHeight = 20;
  final double switchButtonWidth = 200;

  String atLocationText = '';
  String atLocationTextOpposite = '';
  bool _isGeneric = true;

  @override
  void initState() {
    if (widget.reminderTile.isSpecific) {
      _isGeneric = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isGeneric) {
      atLocationText = 'generic';
      atLocationTextOpposite = 'specific';
    } else {
      atLocationText = 'specific';
      atLocationTextOpposite = 'generic';
    }
    // Wrapping the MaterialApp allows the user to tap anywhere on the screen
    // to remove the keyboard focus
    // See: https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          title: 'Edit Alert Screen',
          home: Scaffold(
            appBar: AppBar(
              title: editAlertTitle('Edit Alert'),
              backgroundColor: const Color(s_aquariumLighter),
              centerTitle: true,
            ),
            resizeToAvoidBottomInset: false,
            body: editAlertScreenBody(),
          ),
        ));
  }

  Widget editAlertScreenBody() {
    return SizedBox(
        height: 500,
        width: 400,
        child: Form(
            key: formKey,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  SizedBox(height: topPadding),
                  titleText('Remind me to...'),
                  SizedBox(width: textWidth, child: reminderEntry()),
                  SizedBox(height: buttonSpacing),
                  titleText('At the $atLocationText location...'),
                  SizedBox(width: textWidth, child: locationEntry()),
                  switchReminderTypeButton(
                      switchButtonWidth, switchButtonHeight),
                  deleteButton(switchButtonWidth, switchButtonHeight),
                  SizedBox(height: buttonSpacing / 2),
                  updateButton(buttonWidth, buttonHeight),
                  SizedBox(height: buttonSpacing / 2),
                  cancelButton(buttonWidth, buttonHeight)
                ]))));
  }

  Widget reminderEntry() {
    TextEditingController controller = TextEditingController();
    controller.text = widget.reminderTile.reminder;
    controller.selection = TextSelection.fromPosition(TextPosition(
        offset: controller.text.length)); // Puts cursor at end of field
    return TextFormField(
        autofocus: true,
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
            labelStyle: const TextStyle(
                color: Color(s_aquariumLighter), fontWeight: FontWeight.bold),
            hintText: widget.reminderTile.reminder,
            hintStyle: const TextStyle(color: Colors.black),
            errorStyle: const TextStyle(
                color: Color(s_declineRed), fontWeight: FontWeight.bold),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color(s_aquariumLighter), width: 2.0))),
        onSaved: (value) {
          _reminderBody = value!;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a reminder';
          } else {
            return null;
          }
        });
  }

  Widget locationEntry() {
    if (_isGeneric) {
      if (widget.reminderTile.isSpecific) {
        _location = 'Grocery Store';
      } else {
        _location = widget.reminderTile.location;
      }
      return Center(
          child: DropdownButton<String>(
              icon: const Icon(Icons.add_location_alt_outlined),
              iconEnabledColor: const Color(s_aquarium),
              items: generalLocations(),
              value: _location,
              onChanged: (value) {
                setState(() {
                  _location = value!;
                });
              }));
    } else {
      String hintTextForGeneric = '';
      TextStyle hintColor = const TextStyle(color: Colors.black);
      TextEditingController controller = TextEditingController();
      controller.selection = TextSelection.fromPosition(TextPosition(
          offset: controller.text.length)); // Puts cursor at end of field
      if (widget.reminderTile.isSpecific) {
        controller.text = widget.reminderTile.location;
        hintTextForGeneric = widget.reminderTile.location;
      } else {
        controller.text = '';
        hintTextForGeneric = '42 Wallaby Way, Sydney, NSW';
        hintColor = const TextStyle(color: Color(s_disabledGray));
      }
      return TextFormField(
          autofocus: true,
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
              labelStyle: const TextStyle(
                  color: Color(s_aquariumLighter), fontWeight: FontWeight.bold),
              hintText: hintTextForGeneric,
              hintStyle: hintColor,
              errorStyle: const TextStyle(
                  color: Color(s_declineRed), fontWeight: FontWeight.bold),
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color(s_aquariumLighter), width: 2.0))),
          onSaved: (value) async {
            _location = value!;
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a location';
            } else if (!_reverseGeolocateSuccess) {
              return 'Could not locate the location you entered. \nPlease be more specific.';
            } else {
              return null;
            }
          });
    }
  }

  Widget switchReminderTypeButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          setState(() {
            if (_isGeneric) {
              _isGeneric = false;
            } else {
              _isGeneric = true;
            }
          });
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_blackBlue),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.switch_access_shortcut,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(
            width: 4,
          ),
          FormattedText(
            text: 'Switch to $atLocationTextOpposite location',
            size: s_fontSizeExtraSmall,
            color: Colors.white,
            font: s_font_IBMPlexSans,
          )
        ]));
  }

  Widget deleteButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          _dbServices.deleteAlert(widget.reminderTile.id);
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_declineRed),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(
            Icons.delete_forever,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(
            width: 4,
          ),
          FormattedText(
            text: 'Delete Alert',
            size: s_fontSizeExtraSmall,
            color: Colors.white,
            weight: FontWeight.bold,
            font: s_font_IBMPlexSans,
          )
        ]));
  }

  Widget updateButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          formKey.currentState?.save();
          _reverseGeolocateSuccess =
              await _locationServices.reverseGeolocateCheck(_location);
          if (formKey.currentState!.validate()) {
            formKey.currentState?.save();
            _dbServices.updateAlert(
                widget.reminderTile.id, _reminderBody, _location);
            // Remove keyboard
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_aquarium),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(
            Icons.update,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(
            width: 4,
          ),
          FormattedText(
            text: 'Update Alert',
            size: s_fontSizeMedium,
            color: Colors.white,
            font: s_font_BonaNova,
            weight: FontWeight.bold,
          )
        ]));
  }

  Widget cancelButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_darkSalmon),
            fixedSize: Size(buttonWidth / 2, buttonHeight / 2)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(
            width: buttonWidth / 12,
          ),
          cancelText('Cancel')
        ]));
  }

  Widget cancelText(String text) {
    return FormattedText(
      text: text,
      size: s_fontSizeSmall,
      color: Colors.white,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget editAlertTitle(String title) {
    return FormattedText(
      text: title,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }

  Widget titleText(String title) {
    return FormattedText(
        text: title,
        size: s_fontSizeMedLarge,
        color: const Color(s_blackBlue),
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }
}
