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
import 'pick_on_map_screen.dart';
import 'recent_locations.dart';

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
  final TextEditingController _controllerRecentLocations =
      TextEditingController();
  var _recentLocations = ['Make a few reminders to see their locations here!'];
  Map _recentLocationsMap = new Map();
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

  PickOnMapLocation __pickOnMapLocation = PickOnMapLocation('', 0.0, 0.0);
  bool _usingRecentLocation = false;

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
    loadRecentLocations();
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

  void loadRecentLocations() {
    RecentLocations rl = RecentLocations();
    rl.retrieveRecentLocations();
    _recentLocations = rl.recentLocations;
    _recentLocationsMap = rl.recentLocationsMap;
  }

  Widget editAlertScreenBody() {
    return SizedBox(
        //height: 500,
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
                  SizedBox(height: buttonSpacing / 2),
                  pickOnMapButton(buttonWidth, buttonHeight),
                  SizedBox(height: buttonSpacing / 2),
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
      _controllerRecentLocations.selection = TextSelection.fromPosition(
          TextPosition(
              offset: _controllerRecentLocations
                  .text.length)); // Puts cursor at end of field
      String hintTextForGeneric = '';
      TextStyle hintColor = const TextStyle(color: Colors.black);
      if (widget.reminderTile.isSpecific) {
        _controllerRecentLocations.text = widget.reminderTile.location;
        hintTextForGeneric = widget.reminderTile.location;
        if (__pickOnMapLocation.location != '') {
          _controllerRecentLocations.text = __pickOnMapLocation.location;
        }
      } else {
        _controllerRecentLocations.text = '';
        hintTextForGeneric = '42 Wallaby Way, Sydney, NSW';
        hintColor = const TextStyle(color: Color(s_disabledGray));
      }
      return Row(children: <Widget>[
        Flexible(
            child: TextFormField(
                autofocus: true,
                controller: _controllerRecentLocations,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    labelStyle: const TextStyle(
                        color: Color(s_aquariumLighter),
                        fontWeight: FontWeight.bold),
                    hintText: hintTextForGeneric,
                    hintStyle: hintColor,
                    errorStyle: const TextStyle(
                        color: Color(s_declineRed),
                        fontWeight: FontWeight.bold),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(s_aquariumLighter), width: 2.0))),
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
                })),
        PopupMenuButton<String>(
          icon: const Icon(Icons.arrow_drop_down,
              size: 40, color: Color(s_aquariumLighter)),
          onSelected: (String value) {
            _controllerRecentLocations.text = value;
          },
          itemBuilder: (BuildContext context) {
            return _recentLocations.map<PopupMenuItem<String>>((String value) {
              return PopupMenuItem(
                  child: Text(value), value: value, padding: EdgeInsets.all(5));
            }).toList();
          },
        )
      ]);
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

  void populateLocationFromPickOnMap(PickOnMapLocation pickOnMapLocation) {
    __pickOnMapLocation.location = pickOnMapLocation.location;
    __pickOnMapLocation.lat = pickOnMapLocation.lat;
    __pickOnMapLocation.lon = pickOnMapLocation.lon;
  }

  Widget pickOnMapButton(double buttonWidth, double buttonHeight) {
    return Visibility(
        visible: !_isGeneric,
        child: ElevatedButton(
            onPressed: () {
              // Remove keyboard
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              // Pick on map screen
              Navigator.of(context)
                  .push(createRoute(const PickOnMapScreen(), 'from_right'))
                  .then((value) => setState(() {
                        populateLocationFromPickOnMap(value);
                      }));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 4, 123, 221),
                fixedSize: Size(buttonWidth / 1.5, buttonHeight / 2)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(
                Icons.add_location_alt_outlined,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(
                width: buttonWidth / 20,
              ),
              cancelText('Pick on Map')
            ])));
  }

  Widget deleteButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          _dbServices.deleteAlert(context, widget.reminderTile.id);
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
          if (!_isGeneric) {
            _usingRecentLocation = checkRecentLocationMap(_location);
            String locationToUse;
            if (_usingRecentLocation) {
              locationToUse = _recentLocationsMap[_location];
            } else {
              locationToUse = _location;
            }
            _reverseGeolocateSuccess = await _locationServices
                .reverseGeolocateCheck(context, locationToUse);
            if (formKey.currentState!.validate()) {
              formKey.currentState?.save();
              _dbServices.updateAlert(context, widget.reminderTile.id,
                  _reminderBody, locationToUse, !_isGeneric);
              // Save for previously chosen locations
              SharedPreferences prefs = await SharedPreferences.getInstance();
              List<String>? recentLocationsList =
                  prefs.getStringList('recentLocationsList');
              if ((recentLocationsList == null) ||
                  (recentLocationsList.length < 5)) {
                recentLocationsList!.insert(0, locationToUse);
                prefs.setStringList('recentLocationsList', recentLocationsList);
              } else {
                recentLocationsList.removeLast();
                recentLocationsList.insert(0, locationToUse);
                // Remove duplicates
                recentLocationsList = recentLocationsList.toSet().toList();
                prefs.setStringList('recentLocationsList', recentLocationsList);
              }
            }
          } else {
            if (formKey.currentState!.validate()) {
              formKey.currentState?.save();
              _dbServices.updateAlert(context, widget.reminderTile.id,
                  _reminderBody, _location, !_isGeneric);
            }
          }
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          Navigator.pop(context);
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

  bool checkRecentLocationMap(String location) {
    if (_recentLocationsMap[location] == null) {
      return false;
    }
    return true;
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
