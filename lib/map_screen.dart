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

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final DatabaseServices _dbServices = DatabaseServices();
  final BackgroundTheme _background = BackgroundTheme(Screen.MY_ALERTS_SCREEN);
  final LocationServices _locationServices = LocationServices();
  List<AlertObject> _alertObjs = [];
  List<LatLng> _alertLatLngList = [];
  MapController _mapController = MapController();
  PopupController _popupLayerController = PopupController();

  double _startLat = 0;
  double _startLon = 0;
  bool _userPin = false;
  bool _alreadyUpdated = false;

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

  // ****** From pick_on_map_screen.dart > location_picker.dart
  /// Create a animation controller, add a listener to the controller, and
  /// then forward the controller with the new location
  ///
  /// Args:
  ///   destLocation (LatLng): The LatLng of the destination location.
  ///   destZoom (double): The zoom level you want to animate to.
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: _mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Future<bool> fetchStartingLatLon() async {
    if (!_alreadyUpdated) {
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
    }
    _alreadyUpdated = true;
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
    for (int index = 0; index < _alertLatLngList.length; ++index) {
      Marker marker = Marker(
          point: _alertLatLngList[index],
          width: 50,
          height: 50,
          builder: (context) => Icon(
                Icons.location_on_sharp,
                size: (index == 0 && (_userPin)) ? 50 : 60,
                color: (index == 0 && (_userPin))
                    ? Color(s_declineRed)
                    : Color(s_aquariumLighter),
              ));
      _alertMarkers.add(marker);
    }
    // Build the map
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: LatLng(_startLat, _startLon),
        zoom: 16,
        //onTap: (_, __) => _popupLayerController.hideAllPopups(),
      ),
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
        // PopupMarkerLayerOptions(
        //   markers: _alertMarkers,
        //   popupController: _popupLayerController,
        //   popupBuilder: (_, Marker marker) {
        //     return Card(child: Text('Hello There'));
        //   },
        // ),
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
                        _animatedMapMove(
                            LatLng(_alertLatLngList[0].latitude,
                                _alertLatLngList[0].longitude),
                            16);
                        //_mapController.move(_alertLatLngList[0], 16);
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
