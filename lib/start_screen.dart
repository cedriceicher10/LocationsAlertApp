import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'my_alerts_screen.dart';
import 'generic_screen.dart';
import 'specific_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

String UUID_GLOBAL = '';
int ALERTS_NUM_GLOBAL = 0;
List<String> GENERAL_LOCATIONS_GLOBAL = [
  'Grocery Store',
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
    return true;
  }

  Future<void> setAlertCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('uuid');
    var snapshot = await FirebaseFirestore.instance
        .collection('reminders')
        .where('userId', isEqualTo: uuid)
        .where('isCompleted', isEqualTo: false)
        .get()
        .catchError((error) => throw ('Error: $error'));
    int alertCount = 0;
    snapshot.docs.forEach((result) {
      alertCount++;
    });
    ALERTS_NUM_GLOBAL = alertCount;
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
            .catchError((error) => throw ('Error: $error'));
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

  showLocationDisclosureDetermination(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? showLocationDisclosure = prefs.getBool('showLocationDisclosure');
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
          style: TextButton.styleFrom(primary: Colors.red),
          onPressed: () {
            Navigator.of(context).pop();
            prefs.setBool('showLocationDisclosure', true);
          },
        ),
        TextButton(
          child: const Text("Acknowledge",
              style: TextStyle(fontWeight: FontWeight.bold)),
          style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: const Color.fromARGB(255, 18, 148, 23)),
          onPressed: () {
            Navigator.of(context).pop();
            prefs.setBool('showLocationDisclosure', false);
          },
        )
      ],
    );
  }

  Widget startScreenBody(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          SizedBox(height: topPadding),
          Center(
              child: explainerTitle(
                  'Phone alerts based on your current location!')),
          SizedBox(height: buttonSpacing),
          const Icon(
            Icons.add_location_alt_outlined,
            color: Color(s_blackBlue),
            size: 150,
          ),
          SizedBox(height: buttonSpacing * 2),
          genericLocationButton(context, 'Generic'),
          genericHelpText(),
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
                .push(createRoute(const GenericScreen(), 'from_right'));
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
            primary: const Color(s_aquarium),
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
            //   MaterialPageRoute(builder: (context) => const SpecificScreen()),
            // );
            // New way: From a direction
            Navigator.of(context)
                .push(createRoute(const SpecificScreen(), 'from_right'));
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
            primary: const Color(s_aquariumLighter),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyAlertsScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
            primary: const Color(s_darkSalmon),
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
              if (!await launch(url)) throw 'Could not launch $url';
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
