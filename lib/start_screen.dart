import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:background_location/background_location.dart';
import 'package:locationalertsapp/exception_services.dart';
import 'dart:math';
import 'location_services.dart';
import 'my_alerts_screen.dart';
import 'generic_screen.dart';
import 'specific_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'database_services.dart';
import 'alerts_services.dart';
import 'background_theme.dart';
import 'logging_services.dart';

String UUID_GLOBAL = '';
int ALERTS_NUM_GLOBAL = 0;
List<String> GENERAL_LOCATIONS_GLOBAL = [
  'Grocery Store',
  'Drug Store',
  'Hardware Store',
  'Convenience Store',
  'Restaurant'
];

List<DropdownMenuItem<String>> generalLocations() {
  List<DropdownMenuItem<String>> listGenericLocations = [];
  for (int index = 0; index < GENERAL_LOCATIONS_GLOBAL.length; ++index) {
    DropdownMenuItem<String> item = DropdownMenuItem(
      child: Text(GENERAL_LOCATIONS_GLOBAL[index]),
      value: GENERAL_LOCATIONS_GLOBAL[index],
      alignment: Alignment.center,
    );
    listGenericLocations.add(item);
  }
  return listGenericLocations;
}

// Firebase cloud firestore
CollectionReference reminders =
    FirebaseFirestore.instance.collection('reminders');

// Exceptions
ExceptionServices _exception = ExceptionServices();

// Enables screen transition to the right (instead of default bottom)
Route createRoute(Widget page, String direction) {
  Offset begin = Offset.zero;
  Offset end = Offset.zero;
  if (direction == 'from_left') {
    begin = const Offset(-1.0, 0.0);
  } else if (direction == 'from_right') {
    begin = const Offset(1.0, 0.0);
  }
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      begin;
      end;
      const curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final DatabaseServices _dbServices = DatabaseServices();
  final AlertServices _alertServices = AlertServices();
  final LocationServices _locationServices = LocationServices();
  final BackgroundTheme _background = BackgroundTheme(Screen.START_SCREEN);
  final LoggingServices _logger = LoggingServices();
  bool _masterLocationToggle = false;
  bool _toggleJustDone = false;
  bool _toggleBack = false;
  Color _masterLocationColorOn = Color.fromARGB(255, 105, 235, 66);
  Color _masterLocationColorOff = Colors.white;
  Color _masterLocationColor = Colors.white;
  double _userBgLat = 0;
  double _userBgLon = 0;

  double _topPadding = 0;
  double _buttonWidth = 0;
  double _buttonHeight = 0;
  double _buttonSpacing = 0;
  double _iconGap = 0;
  double _titleIconSize = 0;
  double _explainerTextPadding = 0;
  double _specificLocationIconSize = 0;
  double _locationDisclosureButtonHeight = 0;
  double _locationDisclosureButtonWidth = 0;
  double _locationDisclosureFontSize = 0;
  double _titleTextFontSize = 0;
  double _locationDisclosureIconSize = 0;
  double _explainerFontSize = 0;
  double _submitButtonFontSize = 0;
  double _helpFontSize = 0;
  double _signatureFontSize = 0;
  double _locationToggleFontSize = 0;
  double _locationDisclosureButtonCornerRadius = 0;
  double _submitButtonCornerRadius = 0;
  double _gapBeforeTitleIcon = 0;
  double _gapAfterTitleIcon = 0;
  double _gapBeforeButtons = 0;
  double _gapAfterButtons = 0;
  double _locationToggleScale = 0;
  double _locationToggleGapWidth = 0;
  double _bottomPadding = 0;

  @override
  Widget build(BuildContext context) {
    generateLayout();
    return MaterialApp(
      title: 'Start Screen',
      // This Builder is here so that routes needing a up-the-tree context can
      // find it. See: https://stackoverflow.com/questions/44004451/navigator-operation-requested-with-a-context-that-does-not-include-a-navigator
      home: Builder(builder: (context) {
        // Prominent disclosure on location usage
        Future.delayed(Duration.zero, () {
          return showLocationDisclosureDetermination(context);
        });
        return Scaffold(
          appBar: AppBar(
            title: startScreenTitle('Location Alerts'),
            backgroundColor: const Color(s_blackBlue),
            centerTitle: true,
          ),
          body: FutureBuilder(
              future: initFunctions(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData) {
                  return startScreenBody(context);
                } else {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Color(s_darkSalmon),
                  ));
                }
              }),
        );
      }),
    );
  }

  Future<bool> initFunctions() async {
    // Generate (hidden) unique user id for the user to be used to identify their reminders in the db
    await generateUniqueUserId();
    // Tally the number of uncompleted alerts for the My Alerts button
    await setAlertCount();

    await oldWay();
    // Check status of location services and toggle
    //await locationToggleCheck();
    // Kickoff background location tracking
    //await kickoffBackgroundLocation();
    // Set up shared prefs for recently chosen locations
    await sharedPrefsSetup();
    return true;
  }

  // Future<void> locationToggleCheck() async {
  //   // Check if the location services changed outside the toggle (turned off/on while closed, on another screen, etc)
  //   // Update masterLocationToggle (screen var _masterLocationToggle, shared prefs var masterLocationToggle, and toggle appearance)
  //   if (!_toggleJustDone) {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     bool? showLocationDisclosure = prefs.getBool('showLocationDisclosure');
  //     if ((showLocationDisclosure != null) &&
  //         (showLocationDisclosure == false)) {
  //       await _locationServices.getLocation();
  //       if (_locationServices.permitted) {
  //         _masterLocationToggle = true;
  //         prefs.setBool('masterLocationToggle', true);
  //         _masterLocationColor = _masterLocationColorOn;
  //       } else {
  //         _masterLocationToggle = false;
  //         prefs.setBool('masterLocationToggle', false);
  //         _masterLocationColor = _masterLocationColorOff;
  //       }
  //     }
  //   } else {
  //     _toggleJustDone = false;
  //   }
  //   // Situation where user toggles on, then denies the location permissions
  //   if (_toggleBack) {
  //     _masterLocationToggle = false;
  //     _toggleBack = false;
  //   }
  // }

  // Future<void> kickoffBackgroundLocation() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool? masterLocationToggle = prefs.getBool('masterLocationToggle');
  //   // Only have masterLocationToggle determine if the location tracking is on
  //   if ((masterLocationToggle == true) && (masterLocationToggle != null)) {
  //     // Background location service
  //     await BackgroundLocation.setAndroidNotification(
  //       title: 'Location Alerts',
  //       message: 'Background services currently in progress',
  //       icon: '@mipmap/ic_launcher',
  //     );
  //     await BackgroundLocation.setAndroidConfiguration(1000);
  //     await BackgroundLocation.startLocationService(distanceFilter: 0);
  //     BackgroundLocation.getLocationUpdates((bgLocationData) {
  //       _userBgLat = bgLocationData.latitude!;
  //       _userBgLon = bgLocationData.longitude!;
  //       setState(() async {
  //         print('BACKGROUND LOCATION TRIGGERED ==============');
  //         print('Latitude : ${bgLocationData.latitude}');
  //         print('Longitude: ${bgLocationData.longitude}');
  //         print('Accuracy : ${bgLocationData.accuracy}');
  //         print('Altitude : ${bgLocationData.altitude}');
  //         print('Bearing  : ${bgLocationData.bearing}');
  //         print('Speed    : ${bgLocationData.speed}');
  //         print(
  //             'Time     : ${DateTime.fromMillisecondsSinceEpoch(bgLocationData.time!.toInt())}');

  //         // NOTIFICATION KICKOFF LOGIC
  //         // Retrieve alerts
  //         QuerySnapshot<Map<String, dynamic>> alerts =
  //             await _dbServices.getIsCompleteAlertsGetCall(context);

  //         // Alert trigger
  //         for (var index = 0; index < alerts.docs.length; ++index) {
  //           // For now only specific alerts
  //           if (alerts.docs[index]['isSpecific']) {
  //             _alertServices.alertDeterminationLogic(
  //                 _userBgLat, _userBgLon, alerts.docs[index]);
  //           }
  //         }
  //       });
  //     });
  //   } else {
  //     BackgroundLocation.stopLocationService();
  //     print('BACKGROUND LOCATION SERVICES OFF');
  //   }
  // }

  // // OLD WAY: Part of overhaul to try to fix location/location toggle issues
  Future<void> oldWay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? showLocationDisclosure = prefs.getBool('showLocationDisclosure');
    bool? masterLocationToggle = prefs.getBool('masterLocationToggle');
    if (masterLocationToggle == null) {
      _masterLocationToggle = false;
      prefs.setBool('masterLocationToggle', false);
    } else {
      _masterLocationToggle = masterLocationToggle;
    }
    if ((_masterLocationToggle) &&
        ((showLocationDisclosure == false) &&
            (showLocationDisclosure != null))) {
      _masterLocationColor = Color.fromARGB(255, 105, 235, 66);
      await _locationServices.getLocation();

      // Background location service
      await BackgroundLocation.setAndroidNotification(
        title: 'Location Alerts',
        message: 'Background services currently in progress',
        icon: '@mipmap/ic_launcher',
      );
      await BackgroundLocation.setAndroidConfiguration(1000);
      await BackgroundLocation.startLocationService(distanceFilter: 0);
      BackgroundLocation.getLocationUpdates((bgLocationData) {
        _userBgLat = bgLocationData.latitude!;
        _userBgLon = bgLocationData.longitude!;
        setState(() async {
          print('BACKGROUND LOCATION TRIGGERED ==============');
          print('Latitude : ${bgLocationData.latitude}');
          print('Longitude: ${bgLocationData.longitude}');
          print('Accuracy : ${bgLocationData.accuracy}');
          print('Altitude : ${bgLocationData.altitude}');
          print('Bearing  : ${bgLocationData.bearing}');
          print('Speed    : ${bgLocationData.speed}');
          print(
              'Time     : ${DateTime.fromMillisecondsSinceEpoch(bgLocationData.time!.toInt())}');

          // NOTIFICATION KICKOFF LOGIC
          // Retrieve alerts
          QuerySnapshot<Map<String, dynamic>> alerts =
              await _dbServices.getIsCompleteAlertsGetCall(context);

          // Alert trigger
          for (var index = 0; index < alerts.docs.length; ++index) {
            // For now only specific alerts
            if (alerts.docs[index]['isSpecific']) {
              _alertServices.alertDeterminationLogic(
                  _userBgLat, _userBgLon, alerts.docs[index]);
            }
          }
        });
      });
      if (_locationServices.permitted) {
        // Location is turned on
        print('LOCATION SERVICES: $_masterLocationToggle');
      } else {
        _masterLocationToggle = false;
        prefs.setBool('masterLocationToggle', false);
        _masterLocationColor = Colors.white;
        BackgroundLocation.stopLocationService();
      }
    } else {
      BackgroundLocation.stopLocationService();
      // Location toggle is turned off
      print('LOCATION SERVICES: $_masterLocationToggle');
    }
  }

  Future<void> setAlertCount() async {
    ALERTS_NUM_GLOBAL = await _dbServices.getAlertCount(context);
  }

  Future<void> generateUniqueUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uuidSP = prefs.getString('uuid');
    if (uuidSP == null) {
      // The unique user id (uuid) is 10 sequential numerals (0-9)
      // Ex: 0613108162
      String uuid = '';
      var rng = Random();
      bool isNotUnique = true;
      while (isNotUnique) {
        for (var i = 0; i < 10; i++) {
          uuid += rng.nextInt(9).toString();
        }
        // Ensure that uuid isn't already taken
        var snapshot = await FirebaseFirestore.instance
            .collection('reminders')
            .where('userId', isEqualTo: uuid)
            .get()
            .catchError((error) {
          _exception.popUp(context,
              'Get from database: Action failed\n error string: ${error.toString()}\nerror raw: $error');
          throw ('Error: $error');
        });
        bool alreadyTaken = false;
        snapshot.docs.forEach((result) {
          alreadyTaken = true;
        });
        if (alreadyTaken == false) {
          isNotUnique = false;
        }
      }
      // Assign to prefs so can be accessed in the app
      prefs.setString('uuid', uuid);
      UUID_GLOBAL = uuid;
    } else {
      UUID_GLOBAL = uuidSP;
    }
  }

  Future<void> sharedPrefsSetup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recentLocationsList =
        prefs.getStringList('recentLocationsList');
    if (recentLocationsList == null) {
      List<String> emptyList = [];
      prefs.setStringList('recentLocationsList', emptyList);
    }
  }

  showLocationDisclosureDetermination(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? showLocationDisclosure = prefs.getBool('showLocationDisclosure');
    // Show the disclosure if it's the first time or user has previously dismissed location services
    if ((showLocationDisclosure == null) || (showLocationDisclosure == true)) {
      showLocationDisclosureAlert(context, prefs);
    }
  }

  dynamic showLocationDisclosureAlert(
      BuildContext context, SharedPreferences prefs) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return locationDisclosureAlert(context, prefs);
      },
    );
  }

  AlertDialog locationDisclosureAlert(
      BuildContext context, SharedPreferences prefs) {
    return AlertDialog(
      title: const Text(
        "Location Disclosure",
        style: TextStyle(
            color: Colors.transparent,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(offset: Offset(0, -3), color: Colors.black)],
            decoration: TextDecoration.underline,
            decorationColor: Colors.black,
            decorationThickness: 1),
      ),
      content: const Text(
          "Location Alerts collects background location data to deliver reminder alerts based on your location. This feature may be in use when the app is in the background or closed. \n\nLocation Alerts will ALWAYS ask your permission before turning on your location services."),
      actions: <Widget>[
        TextButton(
            child: const Text("Decline (No location services)"),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              prefs.setBool('showLocationDisclosure', true);
              // Notice that app will not deliver alerts based on location
              Future.delayed(Duration.zero, () {
                return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return locationOffNoticeAlert(context, prefs);
                    });
              });
            }),
        TextButton(
          child: const Text("Acknowledge",
              style: TextStyle(fontWeight: FontWeight.bold)),
          style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 18, 148, 23)),
          onPressed: () async {
            Navigator.of(context).pop();
            prefs.setBool('showLocationDisclosure', false);
          },
        )
      ],
    );
  }

  AlertDialog locationOffNoticeAlert(
      BuildContext context, SharedPreferences prefs) {
    return AlertDialog(
        title: const Text(
          "Notice of Location Dismissal",
          style: TextStyle(
              color: Colors.transparent,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(offset: Offset(0, -3), color: Colors.black)],
              decoration: TextDecoration.underline,
              decorationColor: Colors.black,
              decorationThickness: 1),
        ),
        content: const Text(
            "To receive alerts based on your current location, tap on the Location Disclosure button at the bottom of the screen and Acknowledge."),
        actions: <Widget>[
          TextButton(
              child: const Text("Close"),
              style:
                  TextButton.styleFrom(foregroundColor: Color(s_disabledGray)),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ]);
  }

  Widget startScreenBody(BuildContext context) {
    return SafeArea(
        child: Container(
            decoration: _background.getBackground(),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: _topPadding),
                  Center(
                      child: Container(
                          padding: EdgeInsets.fromLTRB(_explainerTextPadding, 0,
                              _explainerTextPadding, 0),
                          child: explainerTitle(
                              'Phone alerts based on your current location!'))),
                  SizedBox(height: _gapBeforeTitleIcon),
                  Icon(
                    Icons.add_location_alt_outlined,
                    color: Color(s_blackBlue),
                    size: _titleIconSize,
                  ),
                  SizedBox(height: _gapAfterTitleIcon),
                  locationToggle(),
                  // Turning off generic alerts for first prod version
                  // genericLocationButton(context, 'Generic'),
                  // genericHelpText(),
                  SizedBox(height: _gapBeforeButtons),
                  specificLocationButton(context, 'Create Alert'),
                  //specificHelpText(),
                  SizedBox(height: _buttonSpacing),
                  myAlertsButton(
                      context, 'View my Alerts ($ALERTS_NUM_GLOBAL)'),
                  SizedBox(height: _gapAfterButtons),
                  locationDisclosureButton(context),
                  SizedBox(height: _buttonSpacing),
                  signatureText(),
                  SizedBox(height: _bottomPadding),
                ])));
  }

  Widget explainerTitle(String text) {
    return FormattedText(
        text: text,
        size: _explainerFontSize,
        color: Colors.black,
        font: s_font_BonaNova,
        weight: FontWeight.bold,
        align: TextAlign.center);
  }

  Widget locationToggle() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      FormattedText(
          text: 'Allow My Location: ',
          size: _locationToggleFontSize,
          color: _masterLocationColor,
          font: s_font_IBMPlexSans,
          weight: FontWeight.bold,
          align: TextAlign.center),
      SizedBox(width: _locationToggleGapWidth),
      Transform.scale(
          scale: _locationToggleScale,
          child: Switch(
            inactiveThumbColor: Colors.white,
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
            value: _masterLocationToggle,
            onChanged: (value) async {
              // SharedPreferences prefs = await SharedPreferences.getInstance();
              // _masterLocationToggle = value;
              // if (_masterLocationToggle) {
              //   bool? showLocationDisclosure =
              //       prefs.getBool('showLocationDisclosure');
              //   if ((showLocationDisclosure == false) &&
              //       (showLocationDisclosure != null)) {
              //     await _locationServices.getLocation();
              //     setState(() {
              //       if (_locationServices.permitted) {
              //         _masterLocationColor = Color.fromARGB(255, 105, 235, 66);
              //         prefs.setBool(
              //             'masterLocationToggle', _masterLocationToggle);
              //       } else {
              //         _toggleBack = true;
              //         prefs.setBool('masterLocationToggle',
              //             false); // User backed out of location permissions
              //       }
              //     });
              //   } else {
              //     showLocationDisclosureAlert(context, prefs);
              //   }
              // } else {
              //   setState(() {
              //     _masterLocationColor = Colors.white;
              //     prefs.setBool('masterLocationToggle', _masterLocationToggle);
              //   });
              // }
              // _toggleJustDone = true;

              // OLD WAY: Part of overhaul to try to fix location/location toggle issues
              SharedPreferences prefs = await SharedPreferences.getInstance();
              bool? showLocationDisclosure =
                  prefs.getBool('showLocationDisclosure');
              if ((showLocationDisclosure == false) &&
                  (showLocationDisclosure != null)) {
                setState(() {
                  _masterLocationToggle = value;
                  prefs.setBool('masterLocationToggle', value);
                  if (_masterLocationToggle == false) {
                    _masterLocationColor = Colors.white;
                  } else {
                    _masterLocationColor = Color.fromARGB(255, 105, 235, 66);
                  }
                  _toggleJustDone = true;
                  print('LOCATION TOGGLE: $_masterLocationToggle');
                });
              } else {
                showLocationDisclosureAlert(context, prefs);
              }
            },
          )),
    ]);
  }

  Widget genericLocationButton(BuildContext context, String text) {
    return ElevatedButton(
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool? showLocationDisclosure =
              prefs.getBool('showLocationDisclosure');
          if ((showLocationDisclosure == null) ||
              (showLocationDisclosure == true)) {
            showLocationDisclosureAlert(context, prefs);
          } else {
            Navigator.of(context)
                .push(createRoute(const GenericScreen(), 'from_right'))
                .then((value) => setState(
                    () {})); // This allows for page rebuilding upon pop
          }
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          buttonText(text),
          SizedBox(
            width: _iconGap,
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: _specificLocationIconSize,
          )
        ]),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_aquarium),
            fixedSize: Size(_buttonWidth, _buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(_submitButtonCornerRadius))));
  }

  Widget genericHelpText() {
    return FormattedText(
        text: 'Such as: At any grocery store',
        size: _helpFontSize,
        color: Color(s_blackBlue),
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget specificLocationButton(BuildContext context, String text) {
    return ElevatedButton(
        onPressed: () async {
          // // LOG TEST
          // _logger.log(logType.INFO, 'start_screen', 637,
          //     'Going to Specific Creat Alert');
          Navigator.of(context)
              .push(createRoute(const SpecificScreen(), 'from_right'))
              .then((value) => setState(() {}));
          // }
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.add_alert,
            color: Colors.white,
            size: _specificLocationIconSize,
          ),
          SizedBox(width: _iconGap),
          buttonText(text),
          Expanded(
              child: SizedBox(
            width: 1,
          )),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: _specificLocationIconSize,
          )
        ]),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_aquarium),
            fixedSize: Size(_buttonWidth, _buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(_submitButtonCornerRadius))));
  }

  Widget specificHelpText() {
    return FormattedText(
        text: 'Such as: At a specific address',
        size: _helpFontSize,
        color: Color(s_blackBlue),
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget myAlertsButton(BuildContext context, String text) {
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context)
              .push(createRoute(const MyAlertsScreen(), 'from_right'))
              .then((value) => setState(() {}));
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_darkSalmon),
            fixedSize: Size(_buttonWidth, _buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(_submitButtonCornerRadius))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.doorbell,
              color: Colors.white,
              size: _specificLocationIconSize,
            ),
            SizedBox(
              width: _iconGap,
            ),
            buttonText(text),
            Expanded(
                child: SizedBox(
              width: 1,
            )),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: _specificLocationIconSize,
            )
          ],
        ));
  }

  Widget startScreenTitle(String title) {
    return FormattedText(
      text: title,
      size: _titleTextFontSize,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }

  Widget buttonText(String title) {
    return FormattedText(
        text: title,
        size: _submitButtonFontSize,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget signatureText() {
    return RichText(
      text: TextSpan(
          style: TextStyle(
              color: Colors.black,
              fontFamily: s_font_IBMPlexSans,
              fontSize: _signatureFontSize,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
          text: 'An App by Cedric Eicher',
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              var url = "https://www.linkedin.com/in/cedriceicher/";
              if (!await launch(url)) {
                _exception.popUp(context, 'Launch URL: Could not launch $url');
                throw 'Could not launch $url';
              }
            }),
    );
  }

  Widget locationDisclosureButton(BuildContext context) {
    return SizedBox(
        height: _locationDisclosureButtonHeight,
        width: _locationDisclosureButtonWidth,
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: Color(s_blackBlue),
                borderRadius: BorderRadius.all(
                    Radius.circular(_locationDisclosureButtonCornerRadius))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.location_on,
                      size: _locationDisclosureIconSize,
                      color: Color(s_darkSalmon)),
                  TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: locationDisclosureText('Location Disclosure'),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        showLocationDisclosureAlert(context, prefs);
                      })
                ])));
  }

  Widget locationDisclosureText(String text) {
    return FormattedText(
        text: text,
        size: _locationDisclosureFontSize,
        color: Colors.white,
        font: s_font_IBMPlexSans,
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
    _locationDisclosureButtonHeight = (30 / 781) * _screenHeight;
    _gapBeforeTitleIcon = (50 / 781) * _screenHeight;
    _gapAfterTitleIcon = (45 / 781) * _screenHeight;
    _gapBeforeButtons = (5 / 781) * _screenHeight;
    _gapAfterButtons = (20 / 781) * _screenHeight;
    _bottomPadding = (20 / 781) * _screenHeight;

    // Width
    _buttonWidth = (325 / 392) * _screenWidth;
    _buttonSpacing = (10 / 392) * _screenWidth;
    _iconGap = 8;
    _explainerTextPadding = (20 / 392) * _screenWidth;
    _locationDisclosureButtonWidth = (125 / 392) * _screenWidth;
    _locationToggleGapWidth = (10 / 392) * _screenWidth;

    // Font
    _submitButtonFontSize = (20 / 60) * _buttonHeight;
    _locationDisclosureFontSize = (9.6 / 30) * _locationDisclosureButtonHeight;
    _titleTextFontSize = (32 / 56) * AppBar().preferredSize.height;
    _explainerFontSize = (26 / 781) * _screenHeight;
    _helpFontSize = (16 / 781) * _screenHeight;
    _signatureFontSize = (12 / 781) * _screenHeight;
    _locationToggleFontSize = (14 / 781) * _screenHeight;

    // Icons
    _titleIconSize = (175 / 781) * _screenHeight;
    _specificLocationIconSize = (24 / 60) * _buttonHeight;
    _locationDisclosureIconSize = (12 / 30) * _locationDisclosureButtonHeight;

    // Styling
    _locationDisclosureButtonCornerRadius =
        (50 / 30) * _locationDisclosureButtonHeight;
    _submitButtonCornerRadius = (10 / 60) * _buttonHeight;
    _locationToggleScale = (_screenHeight / 781) * 1.15;
  }
}
