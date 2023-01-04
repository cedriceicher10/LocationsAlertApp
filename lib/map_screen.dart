import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/spline.dart';
import 'package:intl/intl.dart';
import 'formatted_text.dart';
import 'location_services.dart';
import 'database_services.dart';
import 'background_theme.dart';
import 'styles.dart';
import 'fab_bar.dart';

class AlertObject {
  String id;
  String dateTimeCreated;
  String dateTimeCompleted;
  bool isCompleted;
  bool isSpecific;
  String location;
  double latitude;
  double longitude;
  String reminder;
  String userId;
  AlertObject(
      {required this.id,
      required this.dateTimeCreated,
      required this.dateTimeCompleted,
      required this.isCompleted,
      required this.isSpecific,
      required this.location,
      required this.latitude,
      required this.longitude,
      required this.reminder,
      required this.userId});
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DatabaseServices _dbServices = DatabaseServices();
  final BackgroundTheme _background = BackgroundTheme(Screen.MY_ALERTS_SCREEN);
  final LocationServices _locationServices = LocationServices();
  List<AlertObject> _alertObjs = [];
  List<LatLng> _alertLatLngList = [];
  MapController _mapController = MapController();

  double _startLat = 0;
  double _startLon = 0;
  bool _userPin = false;

  // False Idol
  double DEFAULT_LOCATION_LAT = 32.72078130242355;
  double DEFAULT_LOCATION_LON = -117.16897626202451;

  double _screenHeight = 0;
  double _screenWidth = 0;
  double _buttonWidth = 0;
  double _buttonHeight = 0;
  double _titleTextFontSize = 0;
  double _backButtonFontSize = 0;
  double _backButtonIconSize = 0;
  double _backButtonCornerRadius = 0;
  double _fabSpacing = 0;
  double _fabMapWidth = 0;
  double _buttonWidthMaster = 0;
  double _mapButtonIconSize = 0;
  double _noAlertsYetText = 0;

  @override
  Widget build(BuildContext context) {
    generateLayout();
    return MaterialApp(
      title: 'Map Screen',
      home: Scaffold(
        appBar: AppBar(
          title: myAlertsScreenTitle('My Alerts'),
          backgroundColor: Color(s_darkSalmon),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
            future: fetchStartingLatLon(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return buildMap();
              } else {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Color(s_darkSalmon),
                ));
              }
            }),
        floatingActionButton: fab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Future<bool> fetchStartingLatLon() async {
    // Determine if location is on, to center on user
    bool initUserLocation = await locationOnCheck();
    if (initUserLocation) {
      _startLat = _locationServices.userLat;
      _startLon = _locationServices.userLon;
      _alertLatLngList.add(LatLng(_startLat, _startLon));
      _userPin = true;
    } else {
      _startLat = DEFAULT_LOCATION_LAT;
      _startLon = DEFAULT_LOCATION_LON;
      _userPin = false;
    }
    return true;
  }

  Widget buildMap() {
    return StreamBuilder(
        stream: retrieveReminders(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshotReminders) {
          if (snapshotReminders.hasData) {
            if (snapshotReminders.data!.size > 0) {
              // Extract the lat lon values
              convertAlertsToMarkers(snapshotReminders);
              // Fetch the map
              return buildMapWithMarkers();
            } else {
              return Center(child: noAlertsYetText('No alerts created yet!'));
            }
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(s_blackBlue),
            ));
          }
        });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> retrieveReminders() {
    return _dbServices.getRemindersIncompleteAlertsSnapshotCall();
  }

  void convertAlertsToMarkers(AsyncSnapshot<QuerySnapshot> snapshotReminders) {
    for (var index = 0; index < snapshotReminders.data!.docs.length; ++index) {
      // Convert to lightweight alert objects
      AlertObject alertObj = AlertObject(
          id: snapshotReminders.data!.docs[index].id,
          dateTimeCompleted: DateFormat.yMMMMd('en_US').add_jm().format(
              snapshotReminders.data!.docs[index]['dateTimeCompleted']
                  .toDate()),
          dateTimeCreated: DateFormat.yMMMMd('en_US').add_jm().format(
              snapshotReminders.data!.docs[index]['dateTimeCreated'].toDate()),
          isCompleted: snapshotReminders.data!.docs[index]['isCompleted'],
          isSpecific: snapshotReminders.data!.docs[index]['isSpecific'],
          location: snapshotReminders.data!.docs[index]['location'],
          latitude: snapshotReminders.data!.docs[index]['latitude'],
          longitude: snapshotReminders.data!.docs[index]['longitude'],
          reminder: snapshotReminders.data!.docs[index]['reminderBody'],
          userId: snapshotReminders.data!.docs[index]['userId']);
      _alertObjs.add(alertObj);
      // Extract the lat lon values for markers
      _alertLatLngList.add(LatLng(alertObj.latitude, alertObj.longitude));
    }
  }

  Widget buildMapWithMarkers() {
    // Turn the latlon pairs into map markers
    List<Marker> _alertMarkers = [];
    for (int i = 0; i < _alertLatLngList.length; ++i) {
      // Color pinColor = Color(s_aquariumLighter);
      // IconData icon = Icons.location_on_sharp;
      // if (i == 0) {
      //   if (_userPin) {
      //     pinColor = Color(s_declineRed);
      //   }
      // }
      Marker marker = Marker(
          point: _alertLatLngList[i],
          width: 50,
          height: 50,
          builder: (context) => Icon(
                Icons.location_on_sharp,
                size: (i == 0) ? 50 : 60,
                color:
                    (i == 0) ? Color(s_declineRed) : Color(s_aquariumLighter),
              ));
      _alertMarkers.add(marker);
    }
    // Build the map
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(center: LatLng(_startLat, _startLon), zoom: 16),
      layers: [
        TileLayerOptions(
          minZoom: 1,
          maxZoom: 18,
          backgroundColor: Colors.white,
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(
          markers: _alertMarkers,
        ),
      ],
      nonRotatedChildren: [
        (_userPin)
            ? Positioned(
                right: 5,
                bottom: 115,
                child: FloatingActionButton(
                  backgroundColor: Color(s_declineRed),
                  onPressed: () {
                    // Go to the user's location
                    setState(() {
                      if (_userPin) {
                        _mapController.move(_alertLatLngList[0], 16);
                      }
                    });
                  },
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                ),
              )
            : Container(),
      ],
    );
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
        return true;
      }
    }
    return false;
  }

  Widget fab() {
    return fabBar(
        context,
        FAB.LIST,
        _buttonHeight,
        _buttonWidth,
        _backButtonFontSize,
        _backButtonIconSize,
        _backButtonCornerRadius,
        _fabSpacing,
        _fabMapWidth,
        _mapButtonIconSize);
  }

  Widget myAlertsScreenTitle(String title) {
    return FormattedText(
      text: title,
      size: _titleTextFontSize,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }

  Widget buttonText(String text, double fontSize) {
    return FormattedText(
      text: text,
      size: fontSize,
      color: Colors.white,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget noAlertsYetText(String text) {
    return FormattedText(
      text: text,
      size: _noAlertsYetText,
      color: Color(s_darkSalmon),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  void generateLayout() {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    // Original ratios based on a Google Pixel 5 (392 x 781) screen
    // and a 56 height appBar

    // Height
    _buttonHeight = (60 / 781) * _screenHeight;

    // Width
    _buttonWidthMaster = (325 / 392) * _screenWidth;
    _fabSpacing = (5 / 392) * _screenWidth;
    _buttonWidth = (_buttonWidthMaster - _fabSpacing) * 0.80;
    _fabMapWidth = (_buttonWidthMaster - _fabSpacing) * 0.20;

    // Font
    _titleTextFontSize = (32 / 56) * AppBar().preferredSize.height;
    _backButtonFontSize = (20 / 60) * _buttonHeight;
    _noAlertsYetText = (26 / 781) * _screenHeight;

    // Icons
    _backButtonIconSize = (24 / 60) * _buttonHeight;
    _mapButtonIconSize = (30 / 60) * _buttonHeight;

    // Styling
    _backButtonCornerRadius = (10 / 60) * _buttonHeight;
  }
}
