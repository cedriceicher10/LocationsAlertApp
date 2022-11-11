import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locationalertsapp/recent_locations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'database_services.dart';
import 'location_services.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'start_screen.dart';
import 'pick_on_map_screen.dart';
import 'go_back_button.dart';
import 'background_theme.dart';

class SpecificScreen extends StatefulWidget {
  const SpecificScreen({Key? key}) : super(key: key);

  @override
  State<SpecificScreen> createState() => _SpecificScreenState();
}

class _SpecificScreenState extends State<SpecificScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final LocationServices _locationServices = LocationServices();
  final DatabaseServices _dbServices = DatabaseServices();
  final BackgroundTheme _background =
      BackgroundTheme(Screen.SPECIFIC_ALERT_SCREEN);
  RecentLocations _rl = RecentLocations();
  String _reminderBody = '';
  String _specificLocation = '';
  bool _reverseGeolocateSuccess = false;
  bool _usingRecentLocation = false;
  bool _locationTextMapPick = false;

  double _topPadding = 0;
  double _submitButtonTopPadding = 0;
  double _buttonHeight = 0;
  double _buttonSpacing = 0;
  double _locationButtonHeight = 0;
  double _locationButtonWidth = 0;
  double _textWidth = 0;
  double _iconGapWidth = 0;
  double _titleTextFontSize = 0;
  double _guideTextFontSize = 0;
  double _formFontSize = 0;
  double _locationButtonTextFontSize = 0;
  double _submitButtonFontSize = 0;
  double _atMyLocationIconSize = 0;
  double _pickOnMapIconSize = 0;
  double _dropDownIconSize = 0;
  double _submitButtonIconSize = 0;
  double _cancelIconSize = 0;
  double _smallButtonCornerRadius = 0;
  double _largeButtonCornerRadius = 0;
  double _dropDownFontScale = 0;
  double _fabPadding = 0;
  double _bottomPadding = 0;
  double _formErrorFontSize = 0;

  PickOnMapLocation __pickOnMapLocation = PickOnMapLocation('', 0.0, 0.0);

  final TextEditingController _controllerRecentLocations =
      TextEditingController();
  var _recentLocations = ['Make a few reminders to see their locations here!'];
  Map _recentLocationsMap = new Map();

  @override
  Widget build(BuildContext context) {
    generateLayout();
    loadRecentLocations();
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
          title: 'Specific Screen',
          home: Scaffold(
            appBar: AppBar(
              title: specificScreenTitle('Create Alert'),
              backgroundColor: const Color(s_aquarium),
              centerTitle: true,
            ),
            resizeToAvoidBottomInset: false,
            body: specificScreenBody(),
            floatingActionButton: buttonsFAB(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        ));
  }

  void loadRecentLocations() {
    _rl.retrieveRecentLocations();
    _recentLocations = _rl.recentLocations;
    _recentLocationsMap = _rl.recentLocationsMap;
  }

  Widget buttonsFAB() {
    return Container(
        height: _fabPadding,
        width: _textWidth,
        child: Column(children: [
          cancelButtonFAB(_textWidth, _buttonHeight),
          SizedBox(height: _buttonSpacing),
          submitButtonFAB(_textWidth, _buttonHeight),
        ]));
  }

  Widget specificScreenBody() {
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
                      // SizedBox(height: _submitButtonTopPadding),
                      // cancelButton(_textWidth, _buttonHeight),
                      // SizedBox(height: _buttonSpacing),
                      // submitButton(_textWidth, _buttonHeight),
                      // SizedBox(height: _bottomPadding),
                    ]))));
  }

  Widget reminderEntry() {
    return TextFormField(
        autofocus: true,
        style: TextStyle(color: Colors.black, fontSize: _formFontSize),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelStyle: TextStyle(
                color: Color(s_aquarium), fontWeight: FontWeight.bold),
            hintText: 'E.g. Pick up some limes',
            hintStyle: TextStyle(
                color: Color(s_disabledGray), fontSize: _formFontSize),
            errorStyle: TextStyle(
                color: Color(s_declineRed),
                fontWeight: FontWeight.bold,
                fontSize: _formErrorFontSize),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color(s_raisinBlack), width: 2.0)),
            focusedBorder: OutlineInputBorder(
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
    if (_locationTextMapPick) {
      _controllerRecentLocations.text = __pickOnMapLocation.location;
      _controllerRecentLocations.selection = TextSelection.fromPosition(
          TextPosition(offset: _controllerRecentLocations.text.length));
      _locationTextMapPick = false;
    } // Puts cursor at end of field
    return Row(children: <Widget>[
      Flexible(
        child: TextFormField(
            controller: _controllerRecentLocations,
            autofocus: true,
            style: TextStyle(color: Colors.black, fontSize: _formFontSize),
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                hintText: 'E.g. Sprouts, Redlands, CA',
                hintStyle: TextStyle(
                    color: Color(s_disabledGray), fontSize: _formFontSize),
                errorStyle: TextStyle(
                    color: Color(s_declineRed),
                    fontWeight: FontWeight.bold,
                    fontSize: _formErrorFontSize),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(s_raisinBlack), width: 2.0)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(s_darkSalmon), width: 2.0))),
            onSaved: (value) async {
              _specificLocation = value!;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a location';
              } else if (!_reverseGeolocateSuccess) {
                return 'Could not locate the location you entered. \nPlease be more specific.';
              } else {
                return null;
              }
            }),
      ),
      PopupMenuButton<String>(
        icon: Icon(Icons.arrow_drop_down,
            size: _dropDownIconSize, color: Color(s_darkSalmon)),
        onSelected: (String value) {
          _controllerRecentLocations.text = value;
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

  Widget submitButtonFAB(double buttonWidth, double buttonHeight) {
    return Container(
        width: buttonWidth,
        height: buttonHeight,
        child: FloatingActionButton.extended(
            heroTag: "submit",
            onPressed: () async {
              formKey.currentState?.save();
              _usingRecentLocation = checkRecentLocationMap(_specificLocation);
              String locationToUse;
              if (_usingRecentLocation) {
                locationToUse = _recentLocationsMap[_specificLocation];
              } else {
                locationToUse = _specificLocation;
              }
              _reverseGeolocateSuccess = await _locationServices
                  .reverseGeolocateCheck(context, locationToUse);
              if (formKey.currentState!.validate()) {
                formKey.currentState?.save();
                // Save for previously chosen locations
                _rl.add(locationToUse);
                // Put in Firestore cloud database
                _dbServices.addToDatabase(
                    context,
                    _reminderBody,
                    true,
                    false,
                    locationToUse,
                    _locationServices.alertLat,
                    _locationServices.alertLon);
                // Remove keyboard
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                Navigator.pop(context);
              }
            },
            backgroundColor: Color(s_aquarium),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(_largeButtonCornerRadius))),
            label: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.add,
                color: Colors.white,
                size: _submitButtonIconSize,
              ),
              SizedBox(
                width: _iconGapWidth,
              ),
              FormattedText(
                text: 'Create Alert',
                size: _submitButtonFontSize,
                color: Colors.white,
                font: s_font_BonaNova,
                weight: FontWeight.bold,
              )
            ])));
  }

  // Widget submitButton(double buttonWidth, double buttonHeight) {
  //   return ElevatedButton(
  //       onPressed: () async {
  //         formKey.currentState?.save();
  //         _usingRecentLocation = checkRecentLocationMap(_specificLocation);
  //         String locationToUse;
  //         if (_usingRecentLocation) {
  //           locationToUse = _recentLocationsMap[_specificLocation];
  //         } else {
  //           locationToUse = _specificLocation;
  //         }
  //         _reverseGeolocateSuccess = await _locationServices
  //             .reverseGeolocateCheck(context, locationToUse);
  //         if (formKey.currentState!.validate()) {
  //           formKey.currentState?.save();
  //           // Save for previously chosen locations
  //           _rl.add(locationToUse);
  //           // Put in Firestore cloud database
  //           _dbServices.addToDatabase(
  //               context,
  //               _reminderBody,
  //               true,
  //               false,
  //               locationToUse,
  //               _locationServices.alertLat,
  //               _locationServices.alertLon);
  //           // Remove keyboard
  //           FocusScopeNode currentFocus = FocusScope.of(context);
  //           if (!currentFocus.hasPrimaryFocus) {
  //             currentFocus.unfocus();
  //           }
  //           Navigator.pop(context);
  //         }
  //       },
  //       style: ElevatedButton.styleFrom(
  //           backgroundColor: const Color(s_aquarium),
  //           fixedSize: Size(buttonWidth, buttonHeight),
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(_largeButtonCornerRadius))),
  //       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //         Icon(
  //           Icons.add,
  //           color: Colors.white,
  //           size: _submitButtonIconSize,
  //         ),
  //         SizedBox(
  //           width: _iconGapWidth,
  //         ),
  //         FormattedText(
  //           text: 'Create Alert',
  //           size: _submitButtonFontSize,
  //           color: Colors.white,
  //           font: s_font_BonaNova,
  //           weight: FontWeight.bold,
  //         )
  //       ]));
  // }

  void populateLocationFromPickOnMap(PickOnMapLocation pickOnMapLocation) {
    __pickOnMapLocation.location = pickOnMapLocation.location;
    __pickOnMapLocation.lat = pickOnMapLocation.lat;
    __pickOnMapLocation.lon = pickOnMapLocation.lon;
    _locationTextMapPick = true;
  }

  bool checkRecentLocationMap(String location) {
    if (_recentLocationsMap[location] == null) {
      return false;
    }
    return true;
  }

  Widget atMyLocationButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
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
          bool? masterLocationToggle = prefs.getBool('masterLocationToggle');
          // Show location disclosure on the start screen
          if ((showLocationDisclosure != null) && (showLocationDisclosure)) {
            Navigator.pop(context);
          } else {
            // Set master location toggle if not set yet
            if (masterLocationToggle == null) {
              prefs.setBool('masterLocationToggle', false);
            } else {
              await _locationServices.getLocation();
            }
            if (_locationServices.permitted) {
              prefs.setBool('masterLocationToggle', true);
              var placemarks = await placemarkFromCoordinates(
                  _locationServices.userLat, _locationServices.userLon);
              _specificLocation = placemarks[0].street! +
                  ', ' +
                  placemarks[0].locality! +
                  ', ' +
                  placemarks[0].administrativeArea! +
                  ', ' +
                  placemarks[0].postalCode!;
              _controllerRecentLocations.text = _specificLocation;
            }
          }
        },
        style: ElevatedButton.styleFrom(
            primary: s_myLocationColor,
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.my_location_sharp,
            color: Color(s_darkSalmon),
            size: _atMyLocationIconSize,
          ),
          SizedBox(
            width: _iconGapWidth,
          ),
          smallButtonText('My Location')
        ]));
  }

  Widget pickOnMapButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          // Pick on map screen
          Navigator.of(context)
              .push(createRoute(PickOnMapScreen(), 'from_right'))
              .then((value) => setState(() {
                    populateLocationFromPickOnMap(value);
                  }));
        },
        style: ElevatedButton.styleFrom(
            primary: s_pickOnMapColor,
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.add_location_alt_outlined,
            color: Color(s_darkSalmon),
            size: _pickOnMapIconSize,
          ),
          SizedBox(
            width: _iconGapWidth,
          ),
          smallButtonText('Pick on Map')
        ]));
  }

  Widget cancelButtonFAB(double buttonWidth, double buttonHeight) {
    return Container(
        width: buttonWidth,
        height: buttonHeight,
        child: FloatingActionButton.extended(
            heroTag: "cancel",
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
                borderRadius: BorderRadius.all(
                    Radius.circular(_largeButtonCornerRadius))),
            label: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: _cancelIconSize,
              ),
              // Expanded(
              //     child: SizedBox(
              //   width: 1,
              // )),
              SizedBox(
                width: 8,
              ),
              cancelButtonText('Cancel', _submitButtonFontSize)
            ])));
  }

  Widget cancelButtonText(String text, double fontSize) {
    return FormattedText(
      text: text,
      size: fontSize,
      color: Colors.white,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  // Widget cancelButton(double buttonWidth, double buttonHeight) {
  //   return GoBackButton().back(
  //       'Cancel',
  //       buttonWidth,
  //       buttonHeight,
  //       _submitButtonFontSize,
  //       _cancelIconSize,
  //       _largeButtonCornerRadius,
  //       context,
  //       Color(s_darkSalmon));
  // }

  Widget smallButtonText(String text) {
    return FormattedText(
      text: text,
      size: _locationButtonTextFontSize,
      color: Color(s_darkSalmon),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget specificScreenTitle(String title) {
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
    _submitButtonTopPadding = (175 / 781) * _screenHeight;
    _locationButtonHeight = (30 / 781) * _screenHeight;
    _bottomPadding = (20 / 781) * _screenHeight;
    _fabPadding = (_buttonHeight * 2.75) + _buttonSpacing;

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
    _submitButtonFontSize = (20 / 60) * _buttonHeight;
    _formErrorFontSize = (12 / 60) * _buttonHeight;

    // Icons
    _atMyLocationIconSize = (16 / 30) * _locationButtonHeight;
    _pickOnMapIconSize = (16 / 30) * _locationButtonHeight;
    _dropDownIconSize = 40;
    _submitButtonIconSize = (32 / 60) * _buttonHeight;
    _cancelIconSize = (24 / 60) * _buttonHeight;

    // Styling
    _smallButtonCornerRadius = (20 / 30) * _locationButtonHeight;
    _largeButtonCornerRadius = (10 / 60) * _buttonHeight;
    _dropDownFontScale = (_screenHeight / 781) * 1.0;
  }
}
