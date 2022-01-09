import 'package:flutter/material.dart';
import 'start_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

class SpecificScreen extends StatefulWidget {
  const SpecificScreen({Key? key}) : super(key: key);

  @override
  State<SpecificScreen> createState() => _SpecificScreenState();
}

class _SpecificScreenState extends State<SpecificScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String reminder = '';
  String location = '';
  final double topPadding = 80;
  final double textWidth = 325;
  final double buttonWidth = 260;
  final double buttonHeight = 60;
  final double buttonSpacing = 10;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Specific Screen',
      home: Scaffold(
        appBar: AppBar(
          title: specificScreenTitle('Specific Alert'),
          backgroundColor: const Color(s_aquariumLighter),
          centerTitle: true,
        ),
        body: specificScreenBody(),
      ),
    );
  }

  Widget specificScreenBody() {
    return Center(
        child: Form(
            key: formKey,
            child: Column(children: [
              SizedBox(height: topPadding),
              titleText('Remind me to...'),
              SizedBox(width: textWidth, child: reminderEntry()),
              SizedBox(height: buttonSpacing),
              titleText('At the location...'),
              SizedBox(width: textWidth, child: locationEntry()),
              SizedBox(height: buttonSpacing),
              submitButton(buttonWidth, buttonHeight),
            ])));
  }

  Widget reminderEntry() {
    return TextFormField(
        autofocus: true,
        style: const TextStyle(color: Color(s_aquariumLighter)),
        decoration: const InputDecoration(
            labelStyle: TextStyle(
                color: Color(s_aquariumLighter), fontWeight: FontWeight.bold),
            hintText: 'Check the pantry for extra paper towels',
            hintStyle: TextStyle(color: Color(s_disabledGray)),
            errorStyle: TextStyle(
                color: Color(s_declineRed), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color(s_aquariumLighter), width: 2.0))),
        onSaved: (value) {
          reminder = value!;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a reminder';
          } else {
            return null;
          }
        });
  }

  Widget locationEntry() {
    return TextFormField(
        autofocus: true,
        style: const TextStyle(color: Color(s_aquariumLighter)),
        decoration: const InputDecoration(
            labelStyle: TextStyle(
                color: Color(s_aquariumLighter), fontWeight: FontWeight.bold),
            hintText: '675 W Beech St, San Diego, CA 92101',
            hintStyle: TextStyle(color: Color(s_disabledGray)),
            errorStyle: TextStyle(
                color: Color(s_declineRed), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color(s_aquariumLighter), width: 2.0))),
        onSaved: (value) {
          reminder = value!;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a location';
          } else {
            return null;
          }
        });
  }

  Widget submitButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            formKey.currentState?.save();

            // Put in database as a current reminder

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const StartScreen()),
                (Route<dynamic> route) => false);
          }
        },
        style: ElevatedButton.styleFrom(
            primary: const Color(s_aquariumLighter),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child: const FormattedText(
          text: 'Create Reminder',
          size: s_fontSizeSmall,
          color: Colors.white,
          font: s_font_BonaNova,
          weight: FontWeight.bold,
        ));
  }

  Widget specificScreenTitle(String title) {
    return FormattedText(
      text: title,
      size: s_fontSizeLarge,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }

  Widget titleText(String title) {
    return FormattedText(
        text: title,
        size: s_fontSizeLarge,
        color: const Color(s_blackBlue),
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }
}
