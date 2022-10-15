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

class SpecificScreen extends StatefulWidget {
  const SpecificScreen({Key? key}) : super(key: key);

  @override
  State<SpecificScreen> createState() => _SpecificScreenState();
}

class _SpecificScreenState extends State<SpecificScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final LocationServices _locationServices = LocationServices();
  final DatabaseServices _dbServices = DatabaseServices();
  RecentLocations _rl = RecentLocations();
  String _reminderBody = '';
  String _specificLocation = '';
  bool _reverseGeolocateSuccess = false;
  bool _usingRecentLocation = false;

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
          ),
        ));
  }

  void loadRecentLocations() {
    _rl.retrieveRecentLocations();
    _recentLocations = _rl.recentLocations;
    _recentLocationsMap = _rl.recentLocationsMap;
  }

  Widget specificScreenBody() {
    return SafeArea(
        child: SizedBox(
            child: Form(
                key: formKey,
                child: SingleChildScrollView(
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
                      SizedBox(height: _submitButtonTopPadding),
                      cancelButton(_textWidth, _buttonHeight),
                      SizedBox(height: _buttonSpacing),
                      submitButton(_textWidth, _buttonHeight),
                      SizedBox(height: _bottomPadding),
                    ])))));
  }

  Widget reminderEntry() {
    return TextFormField(
        autofocus: true,
        style: TextStyle(color: Colors.black, fontSize: _formFontSize),
        decoration: InputDecoration(
            labelStyle: TextStyle(
                color: Color(s_aquarium), fontWeight: FontWeight.bold),
            hintText: 'Pick up some limes',
            hintStyle: TextStyle(
                color: Color(s_disabledGray), fontSize: _formFontSize),
            errorStyle: TextStyle(
                color: Color(s_declineRed),
                fontWeight: FontWeight.bold,
                fontSize: _formErrorFontSize),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(s_aquarium), width: 2.0))),
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
    if (__pickOnMapLocation.location != '') {
      _controllerRecentLocations.text = __pickOnMapLocation.location;
      _controllerRecentLocations.selection = TextSelection.fromPosition(
          TextPosition(offset: _controllerRecentLocations.text.length));
    } // Puts cursor at end of field
    return Row(children: <Widget>[
      Flexible(
        child: TextFormField(
            controller: _controllerRecentLocations,
            autofocus: true,
            style: TextStyle(color: Colors.black, fontSize: _formFontSize),
            decoration: InputDecoration(
                labelStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                hintText: 'Sprouts, Redlands, CA',
                hintStyle: TextStyle(
                    color: Color(s_disabledGray), fontSize: _formFontSize),
                errorStyle: TextStyle(
                    color: Color(s_declineRed),
                    fontWeight: FontWeight.bold,
                    fontSize: _formErrorFontSize),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(s_aquarium), width: 2.0))),
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
            size: _dropDownIconSize, color: Color(s_raisinBlack)),
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

  Widget submitButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
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
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_aquarium),
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_largeButtonCornerRadius))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
        ]));
  }

  void populateLocationFromPickOnMap(PickOnMapLocation pickOnMapLocation) {
    __pickOnMapLocation.location = pickOnMapLocation.location;
    __pickOnMapLocation.lat = pickOnMapLocation.lat;
    __pickOnMapLocation.lon = pickOnMapLocation.lon;
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
            backgroundColor: Color.fromARGB(255, 4, 123, 221),
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
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
              .push(createRoute(const PickOnMapScreen(), 'from_right'))
              .then((value) => setState(() {
                    populateLocationFromPickOnMap(value);
                  }));
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 1, 117, 16),
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
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
        ]));
  }

  Widget cancelButton(double buttonWidth, double buttonHeight) {
    return GoBackButton().back(
        'Cancel',
        buttonWidth,
        buttonHeight,
        _submitButtonFontSize,
        _cancelIconSize,
        _largeButtonCornerRadius,
        context,
        Color(s_declineRed));
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
        color: const Color(s_blackBlue),
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
