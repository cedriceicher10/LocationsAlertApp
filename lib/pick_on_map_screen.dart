import 'package:flutter/material.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_services.dart';

class PickOnMapLocation {
  String location;
  double lat;
  double lon;
  PickOnMapLocation(this.location, this.lat, this.lon);
}

class PickOnMapScreen extends StatefulWidget {
  const PickOnMapScreen({Key? key}) : super(key: key);

  @override
  State<PickOnMapScreen> createState() => _PickOnMapScreenState();
}

class _PickOnMapScreenState extends State<PickOnMapScreen> {
  final LocationServices _locationServices = LocationServices();
  bool _initUserLocation = false;

  @override
  Widget build(BuildContext context) {
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
    // Pick on the map
    return FlutterLocationPicker(
        initPosition: LatLong(32.72078130242355, -117.16897626202451),
        locationButtonsBackgroundColor: Color(s_darkSalmon),
        selectLocationButtonColor: Color(s_aquariumLighter),
        zoomButtonsBackgroundColor: Color(s_aquariumLighter),
        markerIconColor: Color(s_declineRed),
        markerIcon: Icons.location_on_sharp,
        selectLocationButtonText: 'Set Alert Location',
        initZoom: 15,
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
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }
}
