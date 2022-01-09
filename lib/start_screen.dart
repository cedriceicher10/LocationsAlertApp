import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'specific_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

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
      home: Builder(
          builder: (context) => Scaffold(
                appBar: AppBar(
                  title: startScreenTitle('Location Alerts'),
                  backgroundColor: const Color(s_blackBlue),
                  centerTitle: true,
                ),
                body: startScreenBody(context),
              )),
    );
  }

  Widget startScreenBody(BuildContext context) {
    return Column(children: [
      Center(
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
            genericLocationButton('Generic'),
            genericHelpText(),
            SizedBox(height: buttonSpacing),
            specificLocationButton(context, 'Specific'),
            specificHelpText(),
            SizedBox(height: buttonSpacing),
            viewMyAlertsButton('View my Alerts (0)'),
            SizedBox(height: buttonSpacing),
          ])),
      Expanded(
        child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: signatureText('An App by Cedric Eicher'),
        ),
      )
    ]);
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

  Widget genericLocationButton(String text) {
    return ElevatedButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => LoginScreen()),
          // );
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
        style: FontStyle.italic,
        weight: FontWeight.bold);
  }

  Widget specificLocationButton(BuildContext context, String text) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SpecificScreen()),
          );
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
        style: FontStyle.italic,
        weight: FontWeight.bold);
  }

  Widget viewMyAlertsButton(String text) {
    return ElevatedButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => LoginScreen()),
          // );
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

  Widget signatureText(String title) {
    return RichText(
      text: TextSpan(
          style: const TextStyle(
              color: Colors.black,
              fontFamily: s_font_BonaNova,
              fontSize: s_fontSizeExtraSmall,
              fontWeight: FontWeight.bold),
          text: title,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              var url = "https://www.linkedin.com/in/cedriceicher/";
              if (!await launch(url)) throw 'Could not launch $url';
            }),
    );
  }
}
