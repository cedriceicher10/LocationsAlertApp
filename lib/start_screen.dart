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

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

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
        // Generate (hidden) unique user id for the user to be used to identify their reminders in the db
        generateUniqueUserId();
        return Scaffold(
          appBar: AppBar(
            title: startScreenTitle('Location Alerts'),
            backgroundColor: const Color(s_blackBlue),
            centerTitle: true,
          ),
          body: startScreenBody(context),
        );
      }),
    );
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
            .get();
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
          explainerTitle('Phone alerts based on your current location!'),
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
          myAlertsButton(context, 'View my Alerts (0)'),
          SizedBox(height: buttonSpacing),
          signatureText(),
          SizedBox(height: buttonSpacing),
          locationDisclosureButton(context)
        ]));
  }

  Widget explainerTitle(String text) {
    return FormattedText(
        text: text,
        size: s_fontSizeMedium,
        color: const Color(s_darkSalmon),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GenericScreen()),
            );
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SpecificScreen()),
            );
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
        child: buttonText(text),
        style: ElevatedButton.styleFrom(
            primary: const Color(s_darkSalmon),
            fixedSize: Size(buttonWidth, buttonHeight)));
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
        color: const Color(s_aquariumLighter),
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold);
  }
}
