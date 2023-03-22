import 'package:flutter/material.dart';
import 'package:locationalertsapp/specific_screen.dart';
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
import 'start_screen.dart';
import 'language_services.dart';
import 'edit_alert_screen.dart';
import 'my_alerts_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final DatabaseServices _dbServices = DatabaseServices();
  final BackgroundTheme _background = BackgroundTheme(Screen.MY_ALERTS_SCREEN);
  final LocationServices _locationServices = LocationServices();
  final LanguageServices _languageServices = LanguageServices();
  List<AlertObject> _alertObjs = [];
  MapController _mapController = MapController();
  PopupController _popupController = PopupController();

  double _locationOnZoom = 14;
  double _locationOffZoom = 7;
  double _zoomCirclesCutOff = 10;
  double _zoomClusteringCutOff = 10;

  double _startLat = 0;
  double _startLon = 0;
  bool _userPin = false;
  bool _alreadyUpdated = false;
  bool _circlesOff = false;

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
  double _popupWidth = 0;
  double _popupErrorFontSize = 0;
  double _popupBorderRadius = 0;
  double _popupTextPadding = 0;
  double _popupTitleFontSize = 0;
  double _popupLocationFontSize = 0;
  double _popupDateFontSize = 0;
  double _editIconSize = 0;
  double _popupUserLocationWidth = 0;
  double _clusterAlertNumFontSize = 0;

  @override
  Widget build(BuildContext context) {
    generateLayout();
    return MaterialApp(
      title: 'Map Screen',
      home: Scaffold(
        appBar: AppBar(
          title: myAlertsScreenTitle(),
          backgroundColor: mapViewAppBar,
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
            future: fetchStartingLatLon(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return buildMap();
              } else {
                return Center(
                    child: CircularProgressIndicator(
                  color: mapViewCircularProgressIndicator,
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
        _alertObjs.add(AlertObject(
            id: 'USER_LOCATION',
            dateTimeCreated: '',
            dateTimeCompleted: '',
            isCompleted: false,
            isSpecific: true,
            location: '',
            latitude: _startLat,
            longitude: _startLon,
            reminder: '',
            userId: '',
            triggerDistance: 0,
            triggerUnits: ''));
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
              return Container(
                  decoration: _background.getBackground(),
                  child: Center(
                      child:
                          noAlertsYetText(_languageServices.mapViewNoneYet)));
            }
          } else {
            return Center(
                child: CircularProgressIndicator(
              color: mapViewCircularProgressIndicator,
            ));
          }
        });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> retrieveReminders() {
    return _dbServices.getRemindersIncompleteAlertsSnapshotCall();
  }

  void convertAlertsToMarkers(AsyncSnapshot<QuerySnapshot> snapshotReminders) {
    List<String> snapshotIds = [];
    for (int index = 0; index < snapshotReminders.data!.docs.length; ++index) {
      // Convert to lightweight alert objects
      AlertObject alertObj = AlertObject(
        id: snapshotReminders.data!.docs[index].id,
        dateTimeCompleted: DateFormat.yMMMMd('en_US').add_jm().format(
            snapshotReminders.data!.docs[index]['dateTimeCompleted'].toDate()),
        dateTimeCreated: DateFormat.yMMMMd('en_US').add_jm().format(
            snapshotReminders.data!.docs[index]['dateTimeCreated'].toDate()),
        isCompleted: snapshotReminders.data!.docs[index]['isCompleted'],
        isSpecific: snapshotReminders.data!.docs[index]['isSpecific'],
        location: snapshotReminders.data!.docs[index]['location'],
        latitude: snapshotReminders.data!.docs[index]['latitude'],
        longitude: snapshotReminders.data!.docs[index]['longitude'],
        reminder: snapshotReminders.data!.docs[index]['reminderBody'],
        userId: snapshotReminders.data!.docs[index]['userId'],
        triggerDistance: snapshotReminders.data!.docs[index]['triggerDistance'],
        triggerUnits: snapshotReminders.data!.docs[index]['triggerUnits'],
      );
      // Add to the master list; we check if we need to update or newly add
      addOrUpdateAlertObjs(alertObj);
      // Keep track of alert ids to check if they're no longer active
      snapshotIds.add(snapshotReminders.data!.docs[index].id);
    }
    // Remove those that may have been completed (and are no longer in the db response)
    for (int index = 0; index < _alertObjs.length; ++index) {
      if ((!(snapshotIds.contains(_alertObjs[index].id))) &&
          (_alertObjs[index].latitude != _startLat) &&
          (_alertObjs[index].longitude != _startLon)) {
        _alertObjs.removeAt(index);
      }
    }
  }

  void addOrUpdateAlertObjs(AlertObject alertObj) {
    // Check if already present in the list and update it
    for (int index = 0; index < _alertObjs.length; ++index) {
      if (alertObj.id == _alertObjs[index].id) {
        _alertObjs[index] = alertObj;
        return;
      }
    }
    // Add if truly new
    _alertObjs.add(alertObj);
  }

  Widget buildMapWithMarkers() {
    // Create markers
    List<Marker> _alertMarkers = [];
    for (int index = 0; index < _alertObjs.length; ++index) {
      Marker marker = Marker(
          point:
              LatLng(_alertObjs[index].latitude, _alertObjs[index].longitude),
          width: 50,
          height: 50,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          builder: (context) => Icon(
                Icons.location_on_sharp,
                size: (index == 0 && (_userPin)) ? 50 : 60,
                color: (index == 0 && (_userPin))
                    ? mapViewUserLocation
                    : mapViewAlertMarker,
              ));
      _alertMarkers.add(marker);
    }
    // Create marker circles
    List<CircleMarker> _alertCircles = [];
    for (int index = 0; index < _alertObjs.length; ++index) {
      CircleMarker circle;
      if ((index == 0) && (_userPin)) {
        // The user location doesn't need a circle
        circle = CircleMarker(
            point:
                LatLng(_alertObjs[index].latitude, _alertObjs[index].longitude),
            useRadiusInMeter: true,
            radius: 0);
      } else {
        circle = CircleMarker(
            point:
                LatLng(_alertObjs[index].latitude, _alertObjs[index].longitude),
            color: (mapViewTriggerRadius).withOpacity(0.15),
            borderStrokeWidth: 3.0,
            borderColor: mapViewTriggerRadius,
            useRadiusInMeter: true,
            radius: determineRadiusInMeters(index));
      }
      _alertCircles.add(circle);
    }
    // Button placements
    double rotateResetButtonBottomDistance = 115 + 65 + 65;
    double zoomInButtonBottomDistance = 115 + 65;
    double zoomOutButtonBottomDistance = 115;
    if (_userPin) {
      zoomOutButtonBottomDistance = 180;
      zoomInButtonBottomDistance = zoomOutButtonBottomDistance + 65;
      rotateResetButtonBottomDistance = zoomInButtonBottomDistance + 65;
    }
    // Build the map
    _mapController.mapEventStream.listen((event) {
      // This reloads the map for the circles to show up if zoomed in enough
      if (((_mapController.zoom >= _zoomCirclesCutOff) && (_circlesOff)) ||
          ((_mapController.zoom < _zoomCirclesCutOff) && !(_circlesOff))) {
        setState(() {});
      }
    });
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: determineMapStartLocation(),
        zoom: (_userPin) ? _locationOnZoom : _locationOffZoom,
        plugins: [MarkerClusterPlugin()],
        onTap: (_, __) => _popupController.hideAllPopups(),
      ),
      layers: [
        TileLayerOptions(
          minZoom: 1,
          maxZoom: 20,
          backgroundColor: mapViewTilesUnloaded,
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        // DEBUG: Static for testing purposes
        // MarkerLayerOptions(
        //   markers: _alertMarkers,
        // ),
        generateMarkerCircles(_alertCircles),
        MarkerClusterLayerOptions(
          maxClusterRadius: 190,
          disableClusteringAtZoom: _zoomClusteringCutOff.toInt(),
          size: Size(90, 90),
          fitBoundsOptions: FitBoundsOptions(
            padding: EdgeInsets.all(50),
          ),
          markers: _alertMarkers,
          polygonOptions: PolygonOptions(
              borderColor: Colors.blueAccent,
              color: Colors.black12,
              borderStrokeWidth: 3),
          builder: (context, markers) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: mapViewAlertMarker, shape: BoxShape.circle),
              child: clusteringText(markers),
            );
          },
          popupOptions: PopupOptions(
              popupSnap: PopupSnap.markerTop,
              popupController: _popupController,
              popupBuilder: (_, marker) => GestureDetector(
                  onTap: () {
                    _popupController.hideAllPopups();
                    Navigator.of(context)
                        .push(createRoute(
                            //EditAlertScreen(alert: findMarkerAlertObj(marker)),
                            SpecificScreen(
                                screen: ScreenType.EDIT,
                                alert: findMarkerAlertObj(marker)),
                            'from_right'))
                        .then((value) => setState(() {
                              checkIfInstaPop(value);
                            }));
                  },
                  child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Container(
                        alignment: Alignment.center,
                        width: (useSmallPopupMarker(marker))
                            ? _popupUserLocationWidth
                            : _popupWidth,
                        decoration: BoxDecoration(
                            color: mapViewCardBackground,
                            shape: BoxShape.rectangle,
                            border:
                                Border.all(color: mapViewCardBorder, width: 3),
                            borderRadius: BorderRadius.all(
                                Radius.circular(_popupBorderRadius))),
                        child: Padding(
                            padding: EdgeInsets.all(_popupTextPadding),
                            child: popupText(marker)),
                      )))),
        ),
      ],
      nonRotatedChildren: [
        (_userPin)
            ? Positioned(
                right: 5,
                bottom: 115,
                child: FloatingActionButton(
                  heroTag: 'user_location',
                  backgroundColor: mapViewMyLocationButton,
                  onPressed: () {
                    // Go to the user's location
                    setState(() {
                      if (_userPin) {
                        _mapController.rotate(0);
                        _animatedMapMove(
                            LatLng(_startLat, _startLon), _locationOnZoom);
                      }
                    });
                  },
                  child: Icon(
                    Icons.my_location,
                    color: mapViewMyLocationIcon,
                  ),
                ),
              )
            : Container(),
        Positioned(
          right: 5,
          bottom: rotateResetButtonBottomDistance,
          child: FloatingActionButton(
            heroTag: 'rotation_reset',
            backgroundColor: mapViewResetNorthButton,
            onPressed: () {
              // Go to the user's location
              setState(() {
                _mapController.rotate(0);
              });
            },
            child: Icon(
              Icons.arrow_upward_sharp,
              color: mapViewResetNorthIcon,
            ),
          ),
        ),
        Positioned(
          right: 5,
          bottom: zoomInButtonBottomDistance,
          child: FloatingActionButton(
            heroTag: 'zoom_in',
            backgroundColor: mapViewZoomInButton,
            onPressed: () {
              // Zoom in
              setState(() {
                _animatedMapMove(
                    _mapController.center, _mapController.zoom + 1);
              });
            },
            child: Icon(
              Icons.zoom_in,
              color: mapViewZoomInIcon,
            ),
          ),
        ),
        Positioned(
          right: 5,
          bottom: zoomOutButtonBottomDistance,
          child: FloatingActionButton(
            heroTag: 'zoom_out',
            backgroundColor: mapViewZoomOutButton,
            onPressed: () {
              // Zoom in
              setState(() {
                _animatedMapMove(
                    _mapController.center, _mapController.zoom - 1);
              });
            },
            child: Icon(
              Icons.zoom_out,
              color: mapViewZoomOutIcon,
            ),
          ),
        )
      ],
    );
  }

  CircleLayerOptions generateMarkerCircles(List<CircleMarker> alertCircles) {
    try {
      if (_mapController.zoom >= _zoomCirclesCutOff) {
        return CircleLayerOptions(
          circles: alertCircles,
        );
      } else {
        return CircleLayerOptions(
            circles: [CircleMarker(point: LatLng(0, 0), radius: 0.0)]);
      }
    } catch (e) {
      if (_userPin) {
        return CircleLayerOptions(
          circles: alertCircles,
        );
      } else {
        return CircleLayerOptions(
            circles: [CircleMarker(point: LatLng(0, 0), radius: 0.0)]);
      }
    }
  }

  Text clusteringText(List<Marker> markers) {
    int userPinOffset = 0;
    for (int index = 0; index < markers.length; ++index) {
      if ((markers[index].point.latitude == _startLat) &&
          (markers[index].point.longitude == _startLon)) {
        userPinOffset = 1;
      }
    }
    return Text('${markers.length - userPinOffset}',
        style: TextStyle(
            color: mapViewClusterText, fontSize: _clusterAlertNumFontSize));
  }

  double determineRadiusInMeters(int index) {
    if (_alertObjs[index].triggerUnits == TriggerUnits.km) {
      return _alertObjs[index].triggerDistance * 1000; // km to m
    } else {
      return _alertObjs[index].triggerDistance * 1609.34; // mi to m
    }
  }

  LatLng determineMapStartLocation() {
    if ((!_userPin) && (_alertObjs.length > 0)) {
      double latTotal = 0;
      double lonTotal = 0;
      for (int index = 0; index < _alertObjs.length; ++index) {
        latTotal += _alertObjs[index].latitude;
        lonTotal += _alertObjs[index].longitude;
      }
      return LatLng(latTotal / _alertObjs.length, lonTotal / _alertObjs.length);
    } else {
      return LatLng(_startLat, _startLon);
    }
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

  void checkIfInstaPop(bool value) {
    if (value) {
      Navigator.pop(context);
    }
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

  Widget popupText(Marker marker) {
    AlertObject alertObj = findMarkerAlertObj(marker);
    if (alertObj.id == 'USER_LOCATION') {
      return FormattedText(
        text: _languageServices.mapViewYourLocation,
        size: _popupErrorFontSize,
        color: mapViewCardUserLocationText,
        font: font_plainText,
        weight: FontWeight.bold,
        align: TextAlign.center,
      );
    } else if (alertObj.id == 'NOT_FOUND') {
      return FormattedText(
          text: _languageServices.mapViewNoAlertInformation,
          size: _popupErrorFontSize,
          color: mapViewCardNotFoundText,
          font: font_plainText,
          weight: FontWeight.bold,
          align: TextAlign.center);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      reminderCardTitleText(alertObj.reminder),
      reminderCardLocationText(
          '${_languageServices.mapViewTileLocation}: ${alertObj.location}'),
      reminderCardDateText(
          '${_languageServices.mapViewTileDate}: ${alertObj.dateTimeCreated}'),
      Center(
          child: Icon(
        Icons.edit,
        color: mapViewCardIcon,
        size: _editIconSize,
      ))
    ]);
  }

  Widget reminderCardTitleText(String text) {
    return FormattedText(
      text: text,
      size: _popupTitleFontSize,
      color: mapViewCardLineOne,
      font: font_plainText,
      weight: FontWeight.bold,
    );
  }

  Widget reminderCardLocationText(String text) {
    return FormattedText(
      text: text,
      size: _popupLocationFontSize,
      color: mapViewCardLineTwo,
      font: font_plainText,
      decoration: TextDecoration.underline,
      weight: FontWeight.bold,
    );
  }

  Widget reminderCardDateText(String text) {
    return FormattedText(
      text: text,
      size: _popupDateFontSize,
      color: mapViewCardLineThree,
      font: font_plainText,
      style: FontStyle.italic,
      weight: FontWeight.bold,
    );
  }

  bool useSmallPopupMarker(Marker marker) {
    if ((_userPin) &&
        ((marker.point.latitude == _startLat) &&
            (marker.point.longitude == _startLon))) {
      return true;
    }
    return false;
  }

  AlertObject findMarkerAlertObj(Marker marker) {
    for (int index = 0; index < _alertObjs.length; ++index) {
      // User's location marker
      if ((marker.point.latitude == _startLat) &&
          (marker.point.longitude == _startLon)) {
        return AlertObject(
            id: 'USER_LOCATION',
            dateTimeCreated: '',
            dateTimeCompleted: '',
            isCompleted: false,
            isSpecific: true,
            location: '',
            latitude: 0,
            longitude: 0,
            reminder: '',
            userId: '',
            triggerDistance: 0,
            triggerUnits: '');
      }
      // Alert marker
      if ((_alertObjs[index].latitude == marker.point.latitude) &&
          (_alertObjs[index].longitude == marker.point.longitude)) {
        return _alertObjs[index];
      }
    }
    // Nothing found
    return AlertObject(
        id: 'NOT_FOUND',
        dateTimeCreated: '',
        dateTimeCompleted: '',
        isCompleted: false,
        isSpecific: true,
        location: '',
        latitude: 0,
        longitude: 0,
        reminder: '',
        userId: '',
        triggerDistance: 0,
        triggerUnits: '');
  }

  Widget myAlertsScreenTitle() {
    return FormattedText(
      text: _languageServices.mapViewTitle,
      size: _titleTextFontSize,
      color: mapViewTitleText,
      font: font_appBarText,
    );
  }

  Widget noAlertsYetText(String text) {
    return FormattedText(
      text: text,
      align: TextAlign.center,
      size: _noAlertsYetText,
      color: mapViewNoAlertsText,
      font: font_nakedText,
      weight: FontWeight.bold,
    );
  }

  void generateLayout() {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    double langScale = _languageServices.getLanguageScale();

    // Original ratios based on a Google Pixel 5 (392 x 781) screen
    // and a 56 height appBar

    // Height
    _buttonHeight = (60 / 781) * _screenHeight;

    // Width
    _buttonWidthMaster = (325 / 392) * _screenWidth;
    _fabSpacing = (5 / 392) * _screenWidth;
    _buttonWidth = (_buttonWidthMaster - _fabSpacing) * 0.70;
    _fabMapWidth = (_buttonWidthMaster - _fabSpacing) * 0.30;
    _popupWidth = (250 / 392) * _screenWidth;
    _popupUserLocationWidth = (150 / 392) * _screenWidth;

    // Font
    _titleTextFontSize = (32 / 56) * AppBar().preferredSize.height * langScale;
    _backButtonFontSize = (20 / 60) * _buttonHeight * langScale;
    _noAlertsYetText = (26 / 781) * _screenHeight * langScale;
    _popupTitleFontSize = (20 / 781) * _screenHeight * langScale;
    _popupLocationFontSize = (14 / 781) * _screenHeight * langScale;
    _popupDateFontSize = (12 / 781) * _screenHeight * langScale;
    _popupErrorFontSize = (16 / 781) * _screenHeight * langScale;
    _clusterAlertNumFontSize = (20 / 781) * _screenHeight * langScale;

    // Icons
    _backButtonIconSize = (24 / 60) * _buttonHeight;
    _mapButtonIconSize = (30 / 60) * _buttonHeight;
    _editIconSize = (20 / 60) * _buttonHeight;

    // Styling
    _backButtonCornerRadius = (10 / 60) * _buttonHeight;
    _popupBorderRadius = (25 / _popupWidth) * 250;
    _popupTextPadding = (15 / _popupWidth) * 250;
  }
}
