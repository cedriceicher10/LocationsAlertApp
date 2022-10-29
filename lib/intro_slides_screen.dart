import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:locationalertsapp/start_screen.dart';
import 'styles.dart';

class IntroSlidesScreen extends StatefulWidget {
  double screenWidth;
  double screenHeight;
  IntroSlidesScreen({
    Key? key,
    this.screenWidth = 0,
    this.screenHeight = 0,
  }) : super(key: key);

  @override
  State<IntroSlidesScreen> createState() => _IntroSlidesScreenState();
}

class _IntroSlidesScreenState extends State<IntroSlidesScreen> {
  List<ContentConfig> listContentConfig = [];

  double _titleFontSize = 0;
  double _textFontSize = 0;
  double _imageWidth = 0;
  double _imageHeight = 0;

  @override
  void initState() {
    generateLayout();
    listContentConfig.add(
      ContentConfig(
        title: "Getting Started",
        styleTitle: titleTextStyleDark(),
        description: "Start by tapping Create Alert",
        styleDescription: textStyleDark(),
        pathImage: "assets/images/IntroSlide_CreateAlert.png",
        widthImage: _imageWidth,
        heightImage: _imageHeight,
        foregroundImageFit: BoxFit.fitWidth,
        backgroundColor: Color(s_beauBlue),
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: "Creating an Alert",
        styleTitle: titleTextStyleLight(),
        description:
            "\nEnter what you want to be reminded about and where. Such as:\n\nGrab more sugar next time I'm at my grocery store.",
        styleDescription: textStyleLight(),
        pathImage: "assets/images/IntroSlide_WriteAlert.png",
        widthImage: _imageWidth,
        heightImage: _imageHeight,
        backgroundColor: Color(s_darkSalmon),
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: "Alert Triggers",
        styleTitle: titleTextStyleDark(),
        description:
            "After your alert is created, make sure the location toggle is ON and your location service is ACTIVE.\n\nLeave the app open in the background and just wait until you arrive at one of your specified locations for an alert to trigger!",
        styleDescription: textStyleDark(),
        pathImage: "assets/images/IntroSlide_LocationOn.png",
        widthImage: _imageWidth,
        heightImage: _imageHeight,
        backgroundColor: Color(s_beauBlue),
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: "Your Alerts",
        styleTitle: titleTextStyleLight(),
        description:
            "You can set multiple alerts for multiple locations! Tap View my Alerts at any time to look at your current alerts, edit them, or delete them.\n\nLet's get started!",
        styleDescription: textStyleLight(),
        pathImage: "assets/images/IntroSlide_ManyAlerts.png",
        widthImage: _imageWidth,
        heightImage: _imageHeight,
        backgroundColor: Color(s_darkSalmon),
      ),
    );
    super.initState();
  }

  void onDonePress() {
    Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new StartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      key: UniqueKey(),
      listContentConfig: listContentConfig,
      onDonePress: onDonePress,
      isShowSkipBtn: false,
      isShowPrevBtn: true,
    );
  }

  TextStyle titleTextStyleDark() {
    return TextStyle(
        color: Color(s_darkSalmon),
        fontSize: _titleFontSize,
        fontFamily: s_font_BonaNova,
        fontWeight: FontWeight.bold);
  }

  TextStyle titleTextStyleLight() {
    return TextStyle(
        color: Color(s_lavenderWeb),
        fontSize: _titleFontSize,
        fontFamily: s_font_BonaNova,
        fontWeight: FontWeight.bold);
  }

  TextStyle textStyleDark() {
    return TextStyle(
        color: Color(s_darkSalmon),
        fontSize: _textFontSize,
        fontFamily: s_font_IBMPlexSans,
        fontWeight: FontWeight.bold);
  }

  TextStyle textStyleLight() {
    return TextStyle(
        color: Color(s_lavenderWeb),
        fontSize: _textFontSize,
        fontFamily: s_font_IBMPlexSans,
        fontWeight: FontWeight.bold);
  }

  void generateLayout() {
    _titleFontSize = (32 / 781) * this.widget.screenHeight;
    _textFontSize = (15 / 781) * this.widget.screenHeight;
    _imageWidth = (300 / 392) * this.widget.screenWidth;
    _imageHeight = (300 / 392) * this.widget.screenWidth;
  }
}
