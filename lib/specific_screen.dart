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
import 'recent_locations.dart';

class SpecificScreen extends StatefulWidget {
  const SpecificScreen({Key? key}) : super(key: key);

  @override
  State<SpecificScreen> createState() => _SpecificScreenState();
}

class _SpecificScreenState extends State<SpecificScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final LocationServices _locationServices = LocationServices();
  final DatabaseServices _dbServices = DatabaseServices();
  String _reminderBody = '';
  String _specificLocation = '';
  bool _reverseGeolocateSuccess = false;
  bool _usingRecentLocation = false;
  final double topPadding = 80;
  final double textWidth = 325;
  final double buttonWidth = 260;
  final double buttonHeight = 60;
  final double buttonSpacing = 10;

  PickOnMapLocation __pickOnMapLocation = PickOnMapLocation('', 0.0, 0.0);

  final TextEditingController _controllerRecentLocations =
      TextEditingController();
  var _recentLocations = ['Make a few reminders to see their locations here!'];
  Map _recentLocationsMap = new Map();

  @override
  Widget build(BuildContext context) {
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
              title: specificScreenTitle('Specific Alert'),
              backgroundColor: const Color(s_aquariumLighter),
              centerTitle: true,
            ),
            resizeToAvoidBottomInset: false,
            body: specificScreenBody(),
          ),
        ));
  }

  void loadRecentLocations() {
    RecentLocations rl = RecentLocations();
    rl.retrieveRecentLocations();
    _recentLocations = rl.recentLocations;
    _recentLocationsMap = rl.recentLocationsMap;
  }

  Widget specificScreenBody() {
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
                  titleText('At the specific location...'),
                  SizedBox(width: textWidth, child: locationEntry()),
                  SizedBox(height: buttonSpacing),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    atMyLocationButton(buttonWidth / 1.7, buttonHeight / 2),
                    SizedBox(width: buttonSpacing),
                    pickOnMapButton(buttonWidth / 1.7, buttonHeight / 2),
                  ]),
                  SizedBox(height: buttonSpacing),
                  submitButton(buttonWidth, buttonHeight),
                  SizedBox(height: buttonSpacing / 2),
                  cancelButton(buttonWidth, buttonHeight)
                ]))));
  }

  Widget reminderEntry() {
    return TextFormField(
        autofocus: true,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
            labelStyle: TextStyle(
                color: Color(s_aquariumLighter), fontWeight: FontWeight.bold),
            hintText: 'Pickup some more olive oil',
            hintStyle: TextStyle(color: Color(s_disabledGray)),
            errorStyle: TextStyle(
                color: Color(s_declineRed), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
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
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
                labelStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                hintText: 'Sprouts, Redlands, CA',
                hintStyle: TextStyle(color: Color(s_disabledGray)),
                errorStyle: TextStyle(
                    color: Color(s_declineRed), fontWeight: FontWeight.bold),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(s_aquariumLighter), width: 2.0))),
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
            backgroundColor: const Color(s_aquariumLighter),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(
            width: 4,
          ),
          FormattedText(
            text: 'Create Alert',
            size: s_fontSizeMedium,
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
            fixedSize: Size(buttonWidth, buttonHeight)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.my_location_sharp,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(
            width: buttonWidth / 20,
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
            backgroundColor: Color.fromARGB(255, 4, 123, 221),
            fixedSize: Size(buttonWidth, buttonHeight)),
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
            backgroundColor: const Color(s_declineRed),
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

  Widget specificScreenTitle(String title) {
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
