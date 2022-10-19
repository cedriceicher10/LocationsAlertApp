import 'package:flutter/material.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_services.dart';

// General knowledge
// For the Specific Screen
//   if (masterLocationToggle == true)  -> user's location
//   if (masterLocationToggle == false) -> DEFAULT_LOCATION
//
// For the Edit Alert Screen
//   if (masterLocationToggle == true)  -> previous alert location
//   if (masterLocationToggle == false) -> previous alert location

class PickOnMapLocation {
  String location;
  double lat;
  double lon;
  PickOnMapLocation(this.location, this.lat, this.lon);
}

class PickOnMapScreen extends StatefulWidget {
  double startLatitude;
  double startLongitude;
  PickOnMapScreen({
    Key? key,
    this.startLatitude = 0,
    this.startLongitude = 0,
  }) : super(key: key);

  @override
  State<PickOnMapScreen> createState() => _PickOnMapScreenState();
}

class _PickOnMapScreenState extends State<PickOnMapScreen> {
  final LocationServices _locationServices = LocationServices();
  bool _initUserLocation = false;

  double _titleTextFontSize = 0;
  double _initMapZoom = 0;

  // False Idol
  double DEFAULT_LOCATION_LAT = 32.72078130242355;
  double DEFAULT_LOCATION_LON = -117.16897626202451;

  @override
  Widget build(BuildContext context) {
    generateLayout();
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          title: 'Pick on Map',
          home: Scaffold(
            appBar: AppBar(
              title: pickOnMapTitle('Pick on Map'),
              backgroundColor: const Color(s_aquariumLighter),
              centerTitle: true,
            ),
            resizeToAvoidBottomInset: false,
            body: FutureBuilder(
                future: locationOnCheck(),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) {
                    return pickOnMapBody();
                  } else {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Color(s_darkSalmon),
                    ));
                  }
                }),
          ),
        ));
  }

  void generateLayout() {
    double _screenHeight = MediaQuery.of(context).size.height;

    // Original ratios based on a Google Pixel 5 (392 x 781) screen
    // and a 56 height appBar

    // Height

    // Width

    // Font
    _titleTextFontSize = (32 / 56) * AppBar().preferredSize.height;

    // Styling
    _initMapZoom = (15 / _screenHeight) * _screenHeight;
  }

  Future<bool> locationOnCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? showLocationDisclosure = prefs.getBool('showLocationDisclosure');
    bool? masterLocationToggle = prefs.getBool('masterLocationToggle');
    if (((showLocationDisclosure == false) &&
            (showLocationDisclosure != null)) &&
        ((masterLocationToggle == true) && (masterLocationToggle != null))) {
      await _locationServices.getLocation();
      if (_locationServices.permitted) {
        _initUserLocation = true;
      } else {
        _initUserLocation = false;
      }
    }
    // This is here to satisfy the FutureBuilder
    return true;
  }

  Widget pickOnMapBody() {
    // For the Edit Alert screen, show the previously chosen location (or if none, False Idol)
    double initLat = 0;
    double initLon = 0;
    if ((this.widget.startLatitude != 0) && (this.widget.startLongitude != 0)) {
      initLat = this.widget.startLatitude;
      initLon = this.widget.startLongitude;
      _initUserLocation = false;
    } else {
      // False Idol
      initLat = DEFAULT_LOCATION_LAT;
      initLon = DEFAULT_LOCATION_LON;
    }

    // Pick on the map
    return FlutterLocationPicker(
        initPosition: LatLong(initLat, initLon),
        locationButtonsBackgroundColor: Color(s_darkSalmon),
        selectLocationButtonColor: Color(s_aquariumLighter),
        zoomButtonsBackgroundColor: Color(s_aquariumLighter),
        markerIconColor: Color(s_declineRed),
        markerIcon: Icons.location_on_sharp,
        selectLocationButtonText: 'Set Alert Location',
        initZoom: _initMapZoom,
        trackMyPosition: _initUserLocation,
        onPicked: (pickedData) {
          // Debug
          // print(pickedData.latLong.latitude);
          // print(pickedData.latLong.longitude);
          // print(pickedData.address);
          PickOnMapLocation pickOnMapLocation = PickOnMapLocation(
              pickedData.address,
              pickedData.latLong.latitude,
              pickedData.latLong.longitude);
          Navigator.pop(context, pickOnMapLocation);
        });
  }

  Widget pickOnMapTitle(String title) {
    return FormattedText(
      text: title,
      size: _titleTextFontSize,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }
}
