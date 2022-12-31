import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/spline.dart';
import 'formatted_text.dart';
import 'database_services.dart';
import 'background_theme.dart';
import 'styles.dart';
import 'fab_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DatabaseServices _dbServices = DatabaseServices();
  final BackgroundTheme _background = BackgroundTheme(Screen.MY_ALERTS_SCREEN);

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

  late FlutterMap map;

  @override
  Widget build(BuildContext context) {
    generateLayout();
    return MaterialApp(
      title: 'My Alerts Screen',
      home: Scaffold(
        appBar: AppBar(
          title: myAlertsScreenTitle('My Alerts'),
          backgroundColor: Color(s_darkSalmon),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
            future: fetchMaps(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return mapBody();
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

  Future<bool> fetchMaps() async {
    map = await FlutterMap(
        //mapController: ...,
        options: MapOptions(
            center: LatLng(DEFAULT_LOCATION_LAT, DEFAULT_LOCATION_LON),
            zoom: 13),
        layers: [
          TileLayerOptions(
            minZoom: 1,
            maxZoom: 18,
            backgroundColor: Colors.white,
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
        ]);
    return true;
  }

  Widget mapBody() {
    return map;
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

    // Icons
    _backButtonIconSize = (24 / 60) * _buttonHeight;
    _mapButtonIconSize = (30 / 60) * _buttonHeight;

    // Styling
    _backButtonCornerRadius = (10 / 60) * _buttonHeight;
  }
}
