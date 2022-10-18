import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'start_screen.dart';
import 'my_alerts_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'database_services.dart';
import 'location_services.dart';
import 'pick_on_map_screen.dart';
import 'recent_locations.dart';
import 'go_back_button.dart';
import 'background_theme.dart';

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
  RecentLocations _rl = RecentLocations();
  final TextEditingController _controllerRecentLocations =
      TextEditingController();
  final BackgroundTheme _background =
      BackgroundTheme(Screen.EDIT_ALERTS_SCREEN);
  var _recentLocations = ['Make a few reminders to see their locations here!'];
  Map _recentLocationsMap = new Map();
  String _reminderBody = '';
  String _location = '';
  bool _reverseGeolocateSuccess = false;
  bool _isStart = true;
  bool _locationTextMapPick = false;
  bool _locationTextUserEntered = false;

  double _topPadding = 0;
  double _deleteButtonTopPadding = 0;
  double _buttonHeight = 0;
  double _buttonSpacing = 0;
  double _locationButtonHeight = 0;
  double _locationButtonWidth = 0;
  double _textWidth = 0;
  double _iconGapWidth = 0;
  double _titleTextFontSize = 0;
  double _formFontSize = 0;
  double _locationButtonTextFontSize = 0;
  double _updateButtonFontSize = 0;
  double _atMyLocationIconSize = 0;
  double _pickOnMapIconSize = 0;
  double _dropDownIconSize = 0;
  double _updateButtonIconSize = 0;
  double _cancelIconSize = 0;
  double _smallButtonCornerRadius = 0;
  double _largeButtonCornerRadius = 0;
  double _dropDownFontScale = 0;
  double _switchReminderTypeIconSize = 0;
  double _switchReminderFontsize = 0;
  double _guideTextFontSize = 0;
  double _deleteAlertIconSize = 0;
  double _bottomPadding = 0;
  double _formErrorFontSize = 0;

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
    _location = widget.reminderTile.location;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    generateLayout();
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
              backgroundColor: const Color(s_aquarium),
              centerTitle: true,
            ),
            resizeToAvoidBottomInset: false,
            body: editAlertScreenBody(),
          ),
        ));
  }

  void loadRecentLocations() {
    _rl.retrieveRecentLocations();
    _recentLocations = _rl.recentLocations;
    _recentLocationsMap = _rl.recentLocationsMap;
  }

  Widget editAlertScreenBody() {
    return SafeArea(
        child: Container(
            decoration: _background.getBackground(),
            child: Form(
                key: formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: _topPadding),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleText('Remind me to...'),
                          SizedBox(width: _textWidth, child: reminderEntry()),
                        ],
                      ),
                      SizedBox(height: _buttonSpacing),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleText('At the location...'),
                            SizedBox(width: _textWidth, child: locationEntry()),
                          ]),
                      SizedBox(height: _buttonSpacing),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            atMyLocationButton(
                                _locationButtonWidth, _locationButtonHeight),
                            SizedBox(width: _buttonSpacing),
                            pickOnMapButton(
                                _locationButtonWidth, _locationButtonHeight),
                          ]),
                      deleteButton(_locationButtonWidth, _locationButtonHeight),
                      // switchReminderTypeButton(_locationButtonWidth, _locationButtonHeight),
                      SizedBox(height: _deleteButtonTopPadding),
                      cancelButton(_textWidth, _buttonHeight),
                      SizedBox(height: _buttonSpacing),
                      updateButton(_textWidth, _buttonHeight),
                      SizedBox(height: _bottomPadding),
                    ]))));
  }

  Widget reminderEntry() {
    return TextFormField(
        autofocus: true,
        initialValue: widget.reminderTile.reminder,
        style: TextStyle(color: Colors.white, fontSize: _formFontSize),
        decoration: InputDecoration(
            labelStyle: TextStyle(
                color: Color(s_aquarium), fontWeight: FontWeight.bold),
            hintText: widget.reminderTile.reminder,
            hintStyle: TextStyle(color: Colors.grey, fontSize: _formFontSize),
            errorStyle: TextStyle(
                color: Color(s_declineRed),
                fontWeight: FontWeight.bold,
                fontSize: _formErrorFontSize),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color(s_darkSalmon), width: 2.0))),
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
      if (_isStart) {
        _controllerRecentLocations.selection = TextSelection.fromPosition(
            TextPosition(
                offset: _controllerRecentLocations
                    .text.length)); // Puts cursor at end of field
      }
      String hintTextForGeneric = '';
      TextStyle hintColor =
          TextStyle(color: Color(s_disabledGray), fontSize: _formFontSize);
      if (!_isGeneric) {
        if (_locationTextUserEntered) {
          // User entered text
        } else if (_locationTextMapPick) {
          _controllerRecentLocations.text = __pickOnMapLocation.location;
          _locationTextMapPick = false;
        } else {
          if (_isStart) {
            _controllerRecentLocations.text = widget.reminderTile.location;
            _isStart = false;
          }
        }
        hintTextForGeneric = widget.reminderTile.location;
      } else {
        _controllerRecentLocations.text = '';
        hintTextForGeneric = '42 Wallaby Way, Sydney, NSW';
        hintColor = const TextStyle(color: Colors.grey);
      }
      return Row(children: <Widget>[
        Flexible(
            child: TextFormField(
                autofocus: true,
                controller: _controllerRecentLocations,
                style: TextStyle(color: Colors.white, fontSize: _formFontSize),
                decoration: InputDecoration(
                    labelStyle: const TextStyle(
                        color: Color(s_aquarium), fontWeight: FontWeight.bold),
                    hintText: hintTextForGeneric,
                    hintStyle: hintColor,
                    errorStyle: TextStyle(
                        color: Color(s_declineRed),
                        fontWeight: FontWeight.bold,
                        fontSize: _formErrorFontSize),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(s_darkSalmon), width: 2.0))),
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
          icon: Icon(Icons.arrow_drop_down,
              size: _dropDownIconSize, color: Color(s_darkSalmon)),
          onSelected: (String value) {
            _controllerRecentLocations.text = value;
            _locationTextUserEntered = true;
            _locationTextMapPick = false;
          },
          itemBuilder: (BuildContext context) {
            return _recentLocations.map<PopupMenuItem<String>>((String value) {
              return PopupMenuItem(
                  child: Text(value, textScaleFactor: _dropDownFontScale),
                  value: value,
                  padding: EdgeInsets.all(5));
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
          Icon(
            Icons.switch_access_shortcut,
            color: Colors.white,
            size: _switchReminderTypeIconSize,
          ),
          SizedBox(
            width: _iconGapWidth,
          ),
          FormattedText(
            text: 'Switch to $atLocationTextOpposite location',
            size: _switchReminderFontsize,
            color: Colors.white,
            font: s_font_IBMPlexSans,
          )
        ]));
  }

  void populateLocationFromPickOnMap(PickOnMapLocation pickOnMapLocation) {
    __pickOnMapLocation.location = pickOnMapLocation.location;
    __pickOnMapLocation.lat = pickOnMapLocation.lat;
    __pickOnMapLocation.lon = pickOnMapLocation.lon;
    _locationTextMapPick = true;
    _locationTextUserEntered = false;
  }

  Widget atMyLocationButton(double buttonWidth, double buttonHeight) {
    return Visibility(
        visible: !_isGeneric,
        child: ElevatedButton(
            onPressed: () async {
              // Remove keyboard
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              // Location look up
              SharedPreferences prefs = await SharedPreferences.getInstance();
              bool? showLocationDisclosure =
                  prefs.getBool('showLocationDisclosure');
              bool? masterLocationToggle =
                  prefs.getBool('masterLocationToggle');
              // Show location disclosure on the start screen
              if ((showLocationDisclosure != null) &&
                  (showLocationDisclosure)) {
                Navigator.pop(context, true);
              } else {
                if ((masterLocationToggle != null) &&
                    (masterLocationToggle == false)) {
                  await _locationServices.getLocation();
                  if (_locationServices.permitted) {
                    prefs.setBool('masterLocationToggle', true);
                    var placemarks = await placemarkFromCoordinates(
                        _locationServices.userLat, _locationServices.userLon);
                    _location = placemarks[0].street! +
                        ', ' +
                        placemarks[0].locality! +
                        ', ' +
                        placemarks[0].administrativeArea! +
                        ', ' +
                        placemarks[0].postalCode!;
                    _controllerRecentLocations.text = _location;
                    _locationTextUserEntered = true;
                    _locationTextMapPick = false;
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 4, 123, 221),
                fixedSize: Size(buttonWidth, buttonHeight),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(_smallButtonCornerRadius))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.my_location_sharp,
                color: Colors.white,
                size: _atMyLocationIconSize,
              ),
              SizedBox(
                width: _iconGapWidth,
              ),
              cancelText('My Location')
            ])));
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
                  .push(createRoute(
                      PickOnMapScreen(
                          startLatitude: widget.reminderTile.latitude,
                          startLongitude: widget.reminderTile.longitude),
                      'from_right'))
                  .then((value) => setState(() {
                        populateLocationFromPickOnMap(value);
                      }));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 1, 117, 16),
                fixedSize: Size(buttonWidth, buttonHeight),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(_smallButtonCornerRadius))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.add_location_alt_outlined,
                color: Colors.white,
                size: _pickOnMapIconSize,
              ),
              SizedBox(
                width: _iconGapWidth,
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
          Navigator.pop(context, false);
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_declineRed),
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.delete_forever,
            color: Colors.white,
            size: _deleteAlertIconSize,
          ),
          SizedBox(
            width: _iconGapWidth,
          ),
          cancelText('Delete Alert')
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
              // Update in db
              _dbServices.updateAlert(context, widget.reminderTile.id,
                  _reminderBody, locationToUse, !_isGeneric);
              // Save for previously chosen locations
              _rl.add(locationToUse);
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
          Navigator.pop(context, false);
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_aquarium),
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_largeButtonCornerRadius))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.update,
            color: Colors.white,
            size: _updateButtonIconSize,
          ),
          SizedBox(
            width: _iconGapWidth,
          ),
          FormattedText(
            text: 'Update Alert',
            size: _updateButtonFontSize,
            color: Colors.white,
            font: s_font_BonaNova,
            weight: FontWeight.bold,
          )
        ]));
  }

  Widget cancelButton(double buttonWidth, double buttonHeight) {
    return GoBackButton().back(
        'Cancel',
        buttonWidth,
        buttonHeight,
        _updateButtonFontSize,
        _cancelIconSize,
        _largeButtonCornerRadius,
        context,
        Color(s_darkSalmon),
        1); // return false
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
      size: _locationButtonTextFontSize,
      color: Colors.white,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget editAlertTitle(String title) {
    return FormattedText(
      text: title,
      size: _titleTextFontSize,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }

  Widget titleText(String title) {
    return FormattedText(
        text: title,
        size: _guideTextFontSize,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  void generateLayout() {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

    // Original ratios based on a Google Pixel 5 (392 x 781) screen
    // and a 56 height appBar

    // Height
    _topPadding = (80 / 781) * _screenHeight;
    _buttonHeight = (60 / 781) * _screenHeight;
    _deleteButtonTopPadding = (125 / 781) * _screenHeight;
    _locationButtonHeight = (30 / 781) * _screenHeight;
    _bottomPadding = (20 / 781) * _screenHeight;

    // Width
    _textWidth = (325 / 392) * _screenWidth;
    _buttonSpacing = (10 / 392) * _screenWidth;
    _locationButtonWidth = ((_textWidth - _buttonSpacing) / 2);
    _iconGapWidth = 8;

    // Font
    _titleTextFontSize = (32 / 56) * AppBar().preferredSize.height;
    _guideTextFontSize = (26 / 781) * _screenHeight;
    _formFontSize = (16 / 60) * _buttonHeight;
    _locationButtonTextFontSize = (16 / 30) * _locationButtonHeight;
    _updateButtonFontSize = (20 / 60) * _buttonHeight;
    _switchReminderFontsize = (12 / 30) * _locationButtonHeight;
    _formErrorFontSize = (12 / 60) * _buttonHeight;

    // Icons
    _atMyLocationIconSize = (16 / 30) * _locationButtonHeight;
    _pickOnMapIconSize = (16 / 30) * _locationButtonHeight;
    _dropDownIconSize = 40;
    _updateButtonIconSize = (32 / 60) * _buttonHeight;
    _deleteAlertIconSize = (20 / 60) * _buttonHeight;
    _cancelIconSize = (24 / 60) * _buttonHeight;
    _switchReminderTypeIconSize = (16 / _locationButtonHeight) * _screenHeight;

    // Styling
    _smallButtonCornerRadius = (20 / 30) * _locationButtonHeight;
    _largeButtonCornerRadius = (10 / 60) * _buttonHeight;
    _dropDownFontScale = (_screenHeight / 781) * 1.0;
  }
}
