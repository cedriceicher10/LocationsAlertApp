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

  double _titleFontSizeSlide1 = 0;
  double _titleFontSizeSlide2 = 0;
  double _titleFontSizeSlide3 = 0;
  double _titleFontSizeSlide4 = 0;
  double _textFontSizeSlide1 = 0;
  double _textFontSizeSlide2 = 0;
  double _textFontSizeSlide3 = 0;
  double _textFontSizeSlide4 = 0;
  double _imageWidthSlide1 = 0;
  double _imageHeightSlide1 = 0;
  double _imageWidthSlide2 = 0;
  double _imageHeightSlide2 = 0;
  double _imageWidthSlide3 = 0;
  double _imageHeightSlide3 = 0;
  double _imageWidthSlide4 = 0;
  double _imageHeightSlide4 = 0;

  @override
  void initState() {
    generateLayout();
    listContentConfig.add(
      ContentConfig(
        title: _languageServices.introSlidesGettingStartedTitle,
        styleTitle: titleTextStyleSlide1(),
        description: _languageServices.introSlidesGettingStartedDesc,
        styleDescription: textStyleSlide1(),
        pathImage: "assets/images/IntroSlide_CreateAlert.png",
        widthImage: _imageWidthSlide1,
        heightImage: _imageHeightSlide1,
        foregroundImageFit: BoxFit.fitWidth,
        backgroundColor: introSlidesBackgroundSlide1,
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: _languageServices.introSlidesCreatingAlertTitle,
        styleTitle: titleTextStyleSlide2(),
        description: _languageServices.introSlidesCreatingAlertDesc,
        styleDescription: textStyleSlide2(),
        pathImage: "assets/images/IntroSlide_WriteAlert.png",
        widthImage: _imageWidthSlide2,
        heightImage: _imageHeightSlide2,
        foregroundImageFit: BoxFit.fitHeight,
        backgroundColor: introSlidesBackgroundSlide2,
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: _languageServices.introSlidesAlertTriggersTitle,
        styleTitle: titleTextStyleSlide3(),
        description: _languageServices.introSlidesAlertTriggersDesc,
        styleDescription: textStyleSlide3(),
        pathImage: "assets/images/IntroSlide_LocationOn.png",
        widthImage: _imageWidthSlide3,
        heightImage: _imageHeightSlide3,
        foregroundImageFit: BoxFit.fitWidth,
        backgroundColor: introSlidesBackgroundSlide3,
      ),
    );
    listContentConfig.add(
      ContentConfig(
        title: _languageServices.introSlidesYourAlertsTitle,
        styleTitle: titleTextStyleSlide4(),
        description: _languageServices.introSlidesYourAlertsDesc,
        styleDescription: textStyleSlide4(),
        pathImage: "assets/images/IntroSlide_ManyAlerts.png",
        widthImage: _imageWidthSlide4,
        heightImage: _imageHeightSlide4,
        foregroundImageFit: BoxFit.fitWidth,
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

  TextStyle titleTextStyleSlide1() {
    return TextStyle(
        color: introSlidesTitleTextSlide1,
        fontSize: _titleFontSizeSlide1,
        fontFamily: font_bigButtonText,
        fontWeight: FontWeight.bold);
  }

  TextStyle titleTextStyleSlide2() {
    return TextStyle(
        color: introSlidesTitleTextSlide2,
        fontSize: _titleFontSizeSlide2,
        fontFamily: font_bigButtonText,
        fontWeight: FontWeight.bold);
  }

  TextStyle titleTextStyleSlide3() {
    return TextStyle(
        color: introSlidesTitleTextSlide3,
        fontSize: _titleFontSizeSlide3,
        fontFamily: font_bigButtonText,
        fontWeight: FontWeight.bold);
  }

  TextStyle titleTextStyleSlide4() {
    return TextStyle(
        color: introSlidesTitleTextSlide4,
        fontSize: _titleFontSizeSlide4,
        fontFamily: font_bigButtonText,
        fontWeight: FontWeight.bold);
  }

  TextStyle textStyleSlide1() {
    return TextStyle(
        color: introSlidesTextSlide1,
        fontSize: _textFontSizeSlide1,
        fontFamily: font_plainText,
        fontWeight: FontWeight.bold);
  }

  TextStyle textStyleSlide2() {
    return TextStyle(
        color: introSlidesTextSlide2,
        fontSize: _textFontSizeSlide2,
        fontFamily: font_plainText,
        fontWeight: FontWeight.bold);
  }

  TextStyle textStyleSlide3() {
    return TextStyle(
        color: introSlidesTextSlide3,
        fontSize: _textFontSizeSlide3,
        fontFamily: font_plainText,
        fontWeight: FontWeight.bold);
  }

  TextStyle textStyleSlide4() {
    return TextStyle(
        color: introSlidesTextSlide4,
        fontSize: _textFontSizeSlide4,
        fontFamily: font_plainText,
        fontWeight: FontWeight.bold);
  }

  void generateLayout() {
    double langScale = _languageServices.getLanguageScale();

    _titleFontSizeSlide1 = (34 / 781) * this.widget.screenHeight * langScale;
    _titleFontSizeSlide2 = (34 / 781) * this.widget.screenHeight * langScale;
    _titleFontSizeSlide3 = (34 / 781) * this.widget.screenHeight * langScale;
    _titleFontSizeSlide4 = (34 / 781) * this.widget.screenHeight * langScale;

    _textFontSizeSlide1 = (20 / 781) * this.widget.screenHeight * langScale;
    _textFontSizeSlide2 = (20 / 781) * this.widget.screenHeight * langScale;
    _textFontSizeSlide3 = (20 / 781) * this.widget.screenHeight * langScale;
    _textFontSizeSlide4 = (20 / 781) * this.widget.screenHeight * langScale;

    _imageWidthSlide1 = (300 / 392) * this.widget.screenWidth;
    _imageHeightSlide1 = (300 / 392) * this.widget.screenWidth;
    _imageWidthSlide2 = (300 / 392) * this.widget.screenWidth;
    _imageHeightSlide2 = (300 / 392) * this.widget.screenWidth;
    _imageWidthSlide3 = (300 / 392) * this.widget.screenWidth;
    _imageHeightSlide3 = (300 / 392) * this.widget.screenWidth;
    _imageWidthSlide4 = (300 / 392) * this.widget.screenWidth;
    _imageHeightSlide4 = (400 / 392) * this.widget.screenWidth;
  }
}
