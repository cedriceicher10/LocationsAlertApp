import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:locationalertsapp/start_screen.dart';
import 'language_services.dart';
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
  LanguageServices _languageServices = LanguageServices();

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
        title: _languageServices.introSlidesGettingStartedTitle,
        styleTitle: titleTextStyleDark(),
        description: _languageServices.introSlidesGettingStartedDesc,
        styleDescription: textStyleDark(),
        pathImage: "assets/images/IntroSlide_CreateAlert.png",
        widthImage: _imageWidth,
        heightImage: _imageHeight,
        foregroundImageFit: BoxFit.fitWidth,
        backgroundColor: introSlidesBackgroundSlide1,
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: _languageServices.introSlidesCreatingAlertTitle,
        styleTitle: titleTextStyleLight(),
        description: _languageServices.introSlidesCreatingAlertDesc,
        styleDescription: textStyleLight(),
        pathImage: "assets/images/IntroSlide_WriteAlert.png",
        widthImage: _imageWidth,
        heightImage: _imageHeight,
        backgroundColor: introSlidesBackgroundSlide2,
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: _languageServices.introSlidesAlertTriggersTitle,
        styleTitle: titleTextStyleDark(),
        description: _languageServices.introSlidesAlertTriggersDesc,
        styleDescription: textStyleDark(),
        pathImage: "assets/images/IntroSlide_LocationOn.png",
        widthImage: _imageWidth,
        heightImage: _imageHeight,
        backgroundColor: introSlidesBackgroundSlide3,
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: _languageServices.introSlidesYourAlertsTitle,
        styleTitle: titleTextStyleLight(),
        description: _languageServices.introSlidesYourAlertsDesc,
        styleDescription: textStyleLight(),
        pathImage: "assets/images/IntroSlide_ManyAlerts.png",
        widthImage: _imageWidth,
        heightImage: _imageHeight,
        backgroundColor: introSlidesBackgroundSlide4,
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
        color: introSlidesTitleTextSlide1,
        fontSize: _titleFontSize,
        fontFamily: font_bigButtonText,
        fontWeight: FontWeight.bold);
  }

  TextStyle titleTextStyleLight() {
    return TextStyle(
        color: introSlidesTitleTextSlide2,
        fontSize: _titleFontSize,
        fontFamily: font_bigButtonText,
        fontWeight: FontWeight.bold);
  }

  TextStyle textStyleDark() {
    return TextStyle(
        color: introSlidesTextSlide1,
        fontSize: _textFontSize,
        fontFamily: font_plainText,
        fontWeight: FontWeight.bold);
  }

  TextStyle textStyleLight() {
    return TextStyle(
        color: introSlidesTextSlide2,
        fontSize: _textFontSize,
        fontFamily: font_plainText,
        fontWeight: FontWeight.bold);
  }

  void generateLayout() {
    double langScale = _languageServices.getLanguageScale();

    _titleFontSize = (32 / 781) * this.widget.screenHeight * langScale;
    _textFontSize = (15 / 781) * this.widget.screenHeight * langScale;
    _imageWidth = (300 / 392) * this.widget.screenWidth;
    _imageHeight = (300 / 392) * this.widget.screenWidth;
  }
}
