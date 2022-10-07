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
  final double topPadding = 80;
  final double buttonWidth = 260;
  final double buttonHeight = 60;
  final double buttonSpacing = 10;

  final DatabaseServices _dbServices = DatabaseServices();
  final AlertServices _alertServices = AlertServices();
  final LocationServices _locationServices = LocationServices();
  bool _masterLocationToggle = false;
  Color masterLocationColor = Colors.grey;
  double userBgLat = 0;
  double userBgLon = 0;

  @override
  Widget build(BuildContext context) {
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
    // Check for location services and kickoff background location tracking
    await locationToggleCheck();
    // Set up shared prefs for recently chosen locations
    await sharedPrefsSetup();
    return true;
  }

  Future<void> locationToggleCheck() async {
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
        userBgLat = bgLocationData.latitude!;
        userBgLon = bgLocationData.longitude!;
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
                  userBgLat, userBgLon, alerts.docs[index]);
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
        masterLocationColor = Colors.grey;
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
    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          SizedBox(height: topPadding),
          Center(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: explainerTitle(
                      'Phone alerts based on your current location!'))),
          SizedBox(height: buttonSpacing),
          const Icon(
            Icons.add_location_alt_outlined,
            color: Color(s_blackBlue),
            size: 150,
          ),
          locationToggle(),
          // Turning off generic alerts for first prod version
          // genericLocationButton(context, 'Generic'),
          // genericHelpText(),
          SizedBox(height: buttonSpacing),
          specificLocationButton(context, 'Specific'),
          specificHelpText(),
          SizedBox(height: buttonSpacing),
          myAlertsButton(context, 'View my Alerts ($ALERTS_NUM_GLOBAL)'),
          SizedBox(height: buttonSpacing),
          signatureText(),
          SizedBox(height: buttonSpacing),
          locationDisclosureButton(context)
        ]));
  }

  Widget explainerTitle(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeMedLarge,
        color: Colors.black,
        font: s_font_BonaNova,
        weight: FontWeight.bold,
        align: TextAlign.center);
  }

  Widget locationToggle() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      FormattedText(
          text: 'Allow My Location: ',
          size: s_fontSizeExtraSmall + 2,
          color: masterLocationColor,
          font: s_font_IBMPlexSans,
          weight: FontWeight.bold,
          align: TextAlign.center),
      Switch(
        inactiveThumbColor: Colors.grey,
        activeTrackColor: Colors.lightGreenAccent,
        activeColor: Colors.green,
        value: _masterLocationToggle,
        onChanged: (value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool? showLocationDisclosure =
              prefs.getBool('showLocationDisclosure');
          if ((showLocationDisclosure == false) &&
              (showLocationDisclosure != null)) {
            setState(() {
              _masterLocationToggle = value;
              prefs.setBool('masterLocationToggle', value);
              if (_masterLocationToggle == false) {
                masterLocationColor = Colors.grey;
              } else {
                masterLocationColor = Colors.green;
              }
              print('LOCATION TOGGLE: $_masterLocationToggle');
            });
          } else {
            showLocationDisclosureAlert(context, prefs);
          }
        },
      ),
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
            // Old way: From the bottom
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const GenericScreen()),
            // );
            // New way: From a direction
            Navigator.of(context)
                .push(createRoute(const GenericScreen(), 'from_right'))
                .then((value) => setState(
                    () {})); // This allows for page rebuilding upon pop
          }
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          buttonText(text),
          SizedBox(
            width: buttonWidth / 3,
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 24,
          )
        ]),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_aquarium),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget genericHelpText() {
    return const FormattedText(
        text: 'Such as: At any grocery store',
        size: s_fontSizeSmall,
        color: Color(s_blackBlue),
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget specificLocationButton(BuildContext context, String text) {
    return ElevatedButton(
        onPressed: () async {
          // SharedPreferences prefs = await SharedPreferences.getInstance();
          // bool? showLocationDisclosure =
          //     prefs.getBool('showLocationDisclosure');
          // if ((showLocationDisclosure == null) ||
          //     (showLocationDisclosure == true)) {
          //   showLocationDisclosureAlert(context, prefs);
          // } else {
          // Old way: From the bottom
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const SpecificScreen()),
          // );
          // New way: From a direction
          Navigator.of(context)
              .push(createRoute(const SpecificScreen(), 'from_right'))
              .then((value) => setState(() {}));
          // }
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          buttonText(text),
          SizedBox(
            width: buttonWidth / 3,
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 24,
          )
        ]),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_aquariumLighter),
            fixedSize: Size(buttonWidth, buttonHeight)));
  }

  Widget specificHelpText() {
    return const FormattedText(
        text: 'Such as: At a specific address',
        size: s_fontSizeSmall,
        color: Color(s_blackBlue),
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget myAlertsButton(BuildContext context, String text) {
    return ElevatedButton(
        onPressed: () {
          // Old way: From the bottom
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const MyAlertsScreen()),
          // );
          // New way: From a direction
          Navigator.of(context)
              .push(createRoute(const MyAlertsScreen(), 'from_right'))
              .then((value) => setState(() {}));
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_darkSalmon),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.doorbell,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(
              width: 4,
            ),
            buttonText(text)
          ],
        ));
  }

  Widget startScreenTitle(String title) {
    return FormattedText(
      text: title,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }

  Widget buttonText(String title) {
    return FormattedText(
        text: title,
        size: s_fontSizeMedium,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget signatureText() {
    return RichText(
      text: TextSpan(
          style: const TextStyle(
              color: Colors.black,
              fontFamily: s_font_IBMPlexSans,
              fontSize: s_fontSizeExtraSmall,
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
        height: 30,
        width: 125,
        child: DecoratedBox(
            decoration: const BoxDecoration(
                color: Color(s_blackBlue),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on,
                      size: 12, color: Color(s_darkSalmon)),
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
        size: 12 * 0.8,
        color: Colors.white,
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold);
  }
}
